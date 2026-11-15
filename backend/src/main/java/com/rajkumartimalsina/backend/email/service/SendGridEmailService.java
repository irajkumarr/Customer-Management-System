package com.rajkumartimalsina.backend.email.service;

import com.rajkumartimalsina.backend.email.dto.EmailSendRequest;
import com.rajkumartimalsina.backend.email.dto.EmailSendResult;
import com.sendgrid.Method;
import com.sendgrid.Request;
import com.sendgrid.Response;
import com.sendgrid.SendGrid;
import com.sendgrid.helpers.mail.Mail;
import com.sendgrid.helpers.mail.objects.Content;
import com.sendgrid.helpers.mail.objects.Email;
import lombok.extern.slf4j.Slf4j;
import org.commonmark.node.Node;
import org.commonmark.parser.Parser;
import org.commonmark.renderer.html.HtmlRenderer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.UUID;

@Service
@Slf4j
public class SendGridEmailService implements EmailService {

    private final Parser markdownParser = Parser.builder().build();
    private final HtmlRenderer htmlRenderer = HtmlRenderer.builder().build();

    @Value("${app.sendgrid.api-key:SG.dummy}")
    private String apiKey;

    @Value("${app.sendgrid.from-email:support@example.com}")
    private String fromEmail;

    @Override
    public EmailSendResult sendEmail(EmailSendRequest request) {
        String generatedMessageId = "<" + UUID.randomUUID() + "@" + extractDomain(fromEmail) + ">";

        // If API key is dummy or not set, log and simulate success for local dev
        if (apiKey == null || apiKey.isBlank() || apiKey.startsWith("SG.dummy") || apiKey.contains("your_sendgrid_api_key")) {
            log.info("[DEV MODE] SendGrid API key not configured. Simulated sending email to '{}', Subject: '{}'",
                    request.to(), request.subject());
            return new EmailSendResult(true, 202, generatedMessageId, null);
        }

        Email from = new Email(fromEmail);
        Email to = new Email(request.to());
        String subject = request.subject();

        String plainText = request.markdownBody();
        String htmlBody = renderMarkdownToHtml(request.markdownBody());

        Content textContent = new Content("text/plain", plainText);
        Mail mail = new Mail(from, subject, to, textContent);
        mail.addContent(new Content("text/html", htmlBody));

        // Threading headers
        mail.addHeader("Message-ID", generatedMessageId);
        if (request.inReplyTo() != null && !request.inReplyTo().isBlank()) {
            String inReplyTo = request.inReplyTo().startsWith("<") ? request.inReplyTo() : "<" + request.inReplyTo() + ">";
            mail.addHeader("In-Reply-To", inReplyTo);
        }
        if (request.references() != null && !request.references().isEmpty()) {
            StringBuilder refsBuilder = new StringBuilder();
            for (String ref : request.references()) {
                String formattedRef = ref.startsWith("<") ? ref : "<" + ref + ">";
                refsBuilder.append(formattedRef).append(" ");
            }
            mail.addHeader("References", refsBuilder.toString().trim());
        }

        SendGrid sendGrid = new SendGrid(apiKey);
        Request sgRequest = new Request();

        try {
            sgRequest.setMethod(Method.POST);
            sgRequest.setEndpoint("mail/send");
            sgRequest.setBody(mail.build());

            Response response = sendGrid.api(sgRequest);
            int statusCode = response.getStatusCode();

            if (statusCode >= 200 && statusCode < 300) {
                log.info("SendGrid email successfully sent to '{}' with status {} and Message-ID '{}'",
                        request.to(), statusCode, generatedMessageId);
                return new EmailSendResult(true, statusCode, generatedMessageId, null);
            } else {
                log.warn("SendGrid returned non-2xx status: {} - {}", statusCode, response.getBody());
                return new EmailSendResult(false, statusCode, generatedMessageId, response.getBody());
            }
        } catch (IOException e) {
            log.error("Failed to send email via SendGrid to '{}': {}", request.to(), e.getMessage());
            return new EmailSendResult(false, 500, generatedMessageId, e.getMessage());
        }
    }

    private String renderMarkdownToHtml(String markdown) {
        if (markdown == null || markdown.isBlank()) {
            return "<p></p>";
        }
        Node document = markdownParser.parse(markdown);
        return htmlRenderer.render(document);
    }

    private String extractDomain(String email) {
        if (email != null && email.contains("@")) {
            return email.substring(email.indexOf("@") + 1);
        }
        return "example.com";
    }
}
