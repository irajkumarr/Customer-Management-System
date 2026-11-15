package com.rajkumartimalsina.backend.webhook.service;

import com.rajkumartimalsina.backend.webhook.dto.ParsedEmailHeaders;
import com.rajkumartimalsina.backend.webhook.dto.ParsedEmailSender;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.StringReader;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
public class EmailHeaderParser {

    private static final Pattern SENDER_PATTERN = Pattern.compile("^(?:[\"']?([^\"'<]*)[\"']?\\s*)?<?([^\\s<>]+@[^\\s<>]+)>?$");
    private static final Pattern MESSAGE_ID_PATTERN = Pattern.compile("<([^>]+)>");

    public Map<String, String> parseRawHeaders(String rawHeaders) {
        Map<String, String> headerMap = new LinkedHashMap<>();
        if (rawHeaders == null || rawHeaders.isBlank()) {
            return headerMap;
        }

        try (BufferedReader reader = new BufferedReader(new StringReader(rawHeaders))) {
            String line;
            String currentHeaderName = null;
            StringBuilder currentValue = new StringBuilder();

            while ((line = reader.readLine()) != null) {
                // Header unfolding: line starts with space or tab
                if (line.startsWith(" ") || line.startsWith("\t")) {
                    if (currentHeaderName != null) {
                        currentValue.append(" ").append(line.trim());
                    }
                } else {
                    if (currentHeaderName != null) {
                        headerMap.put(currentHeaderName.toLowerCase(Locale.ROOT), currentValue.toString().trim());
                    }
                    int colonIdx = line.indexOf(':');
                    if (colonIdx > 0) {
                        currentHeaderName = line.substring(0, colonIdx).trim();
                        currentValue = new StringBuilder(line.substring(colonIdx + 1).trim());
                    } else {
                        currentHeaderName = null;
                        currentValue = new StringBuilder();
                    }
                }
            }

            if (currentHeaderName != null) {
                headerMap.put(currentHeaderName.toLowerCase(Locale.ROOT), currentValue.toString().trim());
            }
        } catch (Exception ignored) {
        }

        return headerMap;
    }

    public ParsedEmailHeaders extractHeaders(String rawHeaders) {
        Map<String, String> headers = parseRawHeaders(rawHeaders);

        String messageId = normalizeMessageId(headers.get("message-id"));
        String inReplyTo = normalizeMessageId(headers.get("in-reply-to"));
        List<String> references = parseReferences(headers.get("references"));
        String subject = headers.get("subject");
        String from = headers.get("from");

        return new ParsedEmailHeaders(messageId, inReplyTo, references, subject, from);
    }

    public ParsedEmailSender parseSender(String fromHeader) {
        if (fromHeader == null || fromHeader.isBlank()) {
            return new ParsedEmailSender("unknown@example.com", "Unknown Sender");
        }

        String cleaned = fromHeader.trim();
        Matcher matcher = SENDER_PATTERN.matcher(cleaned);
        if (matcher.find()) {
            String name = matcher.group(1);
            String email = matcher.group(2);

            if (name != null) {
                name = name.trim();
                if (name.isEmpty()) {
                    name = null;
                }
            }
            if (email != null) {
                email = email.trim().toLowerCase(Locale.ROOT);
                return new ParsedEmailSender(email, name != null ? name : email);
            }
        }

        // Fallback simple search
        int angleOpen = cleaned.indexOf('<');
        int angleClose = cleaned.indexOf('>');
        if (angleOpen >= 0 && angleClose > angleOpen) {
            String email = cleaned.substring(angleOpen + 1, angleClose).trim().toLowerCase(Locale.ROOT);
            String name = cleaned.substring(0, angleOpen).replace("\"", "").trim();
            return new ParsedEmailSender(email, name.isEmpty() ? email : name);
        }

        return new ParsedEmailSender(cleaned.toLowerCase(Locale.ROOT), cleaned);
    }

    public String normalizeMessageId(String rawMessageId) {
        if (rawMessageId == null || rawMessageId.isBlank()) {
            return null;
        }

        String trimmed = rawMessageId.trim();
        Matcher matcher = MESSAGE_ID_PATTERN.matcher(trimmed);
        if (matcher.find()) {
            return matcher.group(1).trim();
        }
        return trimmed.replace("<", "").replace(">", "").trim();
    }

    public List<String> parseReferences(String referencesHeader) {
        if (referencesHeader == null || referencesHeader.isBlank()) {
            return Collections.emptyList();
        }

        List<String> result = new ArrayList<>();
        Matcher matcher = MESSAGE_ID_PATTERN.matcher(referencesHeader);
        while (matcher.find()) {
            String id = matcher.group(1).trim();
            if (!id.isEmpty()) {
                result.add(id);
            }
        }

        if (result.isEmpty()) {
            for (String part : referencesHeader.split("\\s+")) {
                String norm = normalizeMessageId(part);
                if (norm != null && !norm.isEmpty()) {
                    result.add(norm);
                }
            }
        }

        return result;
    }
}
