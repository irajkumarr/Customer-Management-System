package com.rajkumartimalsina.backend.webhook.security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Instant;
import java.util.HexFormat;

@Component
@Slf4j
public class MailgunSignatureVerifier {

    private static final String HMAC_SHA256_ALGORITHM = "HmacSHA256";
    private static final long REPLAY_TOLERANCE_SECONDS = 900; // 15 minutes

    @Value("${app.mailgun.webhook-signing-key:}")
    private String signingKey;

    public boolean isVerificationEnabled() {
        return signingKey != null && !signingKey.trim().isBlank();
    }

    public boolean verify(String timestamp, String token, String signature) {
        if (!isVerificationEnabled()) {
            log.debug("Mailgun webhook signature verification is disabled (no signing key configured).");
            return true;
        }

        if (timestamp == null || timestamp.isBlank() ||
                token == null || token.isBlank() ||
                signature == null || signature.isBlank()) {
            log.warn("Missing required Mailgun signature parameters: timestamp, token, or signature.");
            return false;
        }

        // Replay attack prevention: check timestamp freshness
        try {
            long epochSeconds = Long.parseLong(timestamp.trim());
            long currentSeconds = Instant.now().getEpochSecond();
            if (Math.abs(currentSeconds - epochSeconds) > REPLAY_TOLERANCE_SECONDS) {
                log.warn("Mailgun webhook timestamp rejected due to replay tolerance window. Timestamp={}, current={}",
                        epochSeconds, currentSeconds);
                return false;
            }
        } catch (NumberFormatException e) {
            log.warn("Invalid Mailgun timestamp format: '{}'", timestamp);
            return false;
        }

        try {
            Mac hmacSha256 = Mac.getInstance(HMAC_SHA256_ALGORITHM);
            SecretKeySpec secretKeySpec = new SecretKeySpec(signingKey.trim().getBytes(StandardCharsets.UTF_8), HMAC_SHA256_ALGORITHM);
            hmacSha256.init(secretKeySpec);

            String payloadToSign = timestamp.trim() + token.trim();
            byte[] hmacBytes = hmacSha256.doFinal(payloadToSign.getBytes(StandardCharsets.UTF_8));
            String calculatedHex = HexFormat.of().formatHex(hmacBytes);

            boolean isValid = MessageDigest.isEqual(
                    calculatedHex.toLowerCase().getBytes(StandardCharsets.UTF_8),
                    signature.trim().toLowerCase().getBytes(StandardCharsets.UTF_8)
            );

            if (!isValid) {
                log.warn("Mailgun webhook signature verification failed.");
            }
            return isValid;
        } catch (Exception e) {
            log.error("Error during Mailgun signature verification: {}", e.getMessage());
            return false;
        }
    }
}
