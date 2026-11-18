package com.rajkumartimalsina.backend.email.service;

import com.rajkumartimalsina.backend.email.dto.EmailSendRequest;
import com.rajkumartimalsina.backend.email.dto.EmailSendResult;
import lombok.extern.slf4j.Slf4j;
import org.commonmark.node.Node;
import org.commonmark.parser.Parser;
import org.commonmark.renderer.html.HtmlRenderer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClient;

import java.net.http.HttpClient;
import java.time.Duration;
import java.util.UUID;

@Service
@Slf4j
public class MailgunEmailService implements EmailService {

    private final Parser markdownParser = Parser.builder().build();
    private final HtmlRenderer htmlRenderer = HtmlRenderer.builder().build();
    private final RestClient restClient;

    @Value("${app.mailgun.api-key:key-dummy}")
    private String apiKey;

    @Value("${app.mailgun.domain:sandbox.mailgun.org}")
    private String domain;

    @Value("${app.mailgun.base-url:https://api.mailgun.net}")
    private String baseUrl;

    @Value("${app.mailgun.from-email:support@sandbox.mailgun.org}")
    private String fromEmail;

    public MailgunEmailService() {
        HttpClient httpClient = HttpClient.newBuilder()
                .version(HttpClient.Version.HTTP_1_1)
                .connectTimeout(Duration.ofSeconds(15))
                .followRedirects(HttpClient.Redirect.NORMAL)
                .build();
        JdkClientHttpRequestFactory requestFactory = new JdkClientHttpRequestFactory(httpClient);
        requestFactory.setReadTimeout(Duration.ofSeconds(30));

        this.restClient = RestClient.builder()
                .requestFactory(requestFactory)
                .build();
    }

    @Override
    public EmailSendResult sendEmail(EmailSendRequest request) {
        String generatedMessageId = "<" + UUID.randomUUID() + "@" + domain + ">";

        // If API key is dummy or not set, log and simulate success for local dev
        if (apiKey == null || apiKey.isBlank() || apiKey.startsWith("key-dummy")
                || apiKey.contains("your_mailgun_api_key")) {
            log.info("[DEV MODE] Mailgun API key not configured. Simulated sending email to '{}', Subject: '{}'",
                    request.to(), request.subject());
            return new EmailSendResult(true, 200, generatedMessageId, null);
        }

        String plainText = request.markdownBody();
        String htmlBody = renderMarkdownToHtml(request.markdownBody());

        MultiValueMap<String, String> formData = new LinkedMultiValueMap<>();
        formData.add("from", fromEmail);
        formData.add("to", request.to());
        formData.add("subject", request.subject());
        formData.add("text", plainText != null ? plainText : "");
        formData.add("html", htmlBody);

        // Threading headers
        formData.add("h:Message-Id", generatedMessageId);

        if (request.inReplyTo() != null && !request.inReplyTo().isBlank()) {
            String inReplyTo = request.inReplyTo().startsWith("<") ? request.inReplyTo()
                    : "<" + request.inReplyTo() + ">";
            formData.add("h:In-Reply-To", inReplyTo);
        }

        if (request.references() != null && !request.references().isEmpty()) {
            StringBuilder refsBuilder = new StringBuilder();
            for (String ref : request.references()) {
                String formattedRef = ref.startsWith("<") ? ref : "<" + ref + ">";
                refsBuilder.append(formattedRef).append(" ");
            }
            formData.add("h:References", refsBuilder.toString().trim());
        }

        String endpointUri = baseUrl.replaceAll("/+$", "") + "/v3/" + domain.trim() + "/messages";
        int maxAttempts = 3;
        Exception lastException = null;

        for (int attempt = 1; attempt <= maxAttempts; attempt++) {
            try {
                var response = restClient.post()
                        .uri(endpointUri)
                        .headers(headers -> headers.setBasicAuth("api", apiKey.trim()))
                        .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                        .body(formData)
                        .retrieve()
                        .onStatus(HttpStatusCode::isError, (req, resp) -> {
                            String errorBody = new String(resp.getBody().readAllBytes());
                            log.warn("Mailgun API returned error status {}: {}", resp.getStatusCode(), errorBody);
                        })
                        .toBodilessEntity();

                int statusCode = response.getStatusCode().value();
                if (response.getStatusCode().is2xxSuccessful()) {
                    log.info("Mailgun email successfully sent to '{}' with status {} and Message-ID '{}'{}",
                            request.to(), statusCode, generatedMessageId,
                            attempt > 1 ? " (attempt " + attempt + ")" : "");
                    return new EmailSendResult(true, statusCode, generatedMessageId, null);
                } else {
                    return new EmailSendResult(false, statusCode, generatedMessageId,
                            "Failed with status: " + statusCode);
                }
            } catch (Exception e) {
                lastException = e;
                log.warn("Attempt {}/{} failed sending email via Mailgun to '{}': {}",
                        attempt, maxAttempts, request.to(), e.getMessage());
                if (attempt < maxAttempts) {
                    try {
                        Thread.sleep(1500L * attempt);
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        break;
                    }
                }
            }
        }

        String errorMsg = lastException != null ? lastException.getMessage() : "Unknown delivery error";
        log.error("All {} attempts to send email via Mailgun to '{}' failed: {}", maxAttempts, request.to(), errorMsg);
        return new EmailSendResult(false, 500, generatedMessageId, errorMsg);
    }

    private String renderMarkdownToHtml(String markdown) {
        if (markdown == null || markdown.isBlank()) {
            return "<p></p>";
        }
        Node document = markdownParser.parse(markdown);
        return htmlRenderer.render(document);
    }
}
