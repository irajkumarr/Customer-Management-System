package com.rajkumartimalsina.backend.webhook.security;

import com.sendgrid.helpers.eventwebhook.EventWebhook;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.security.interfaces.ECPublicKey;

@Component
@Slf4j
public class SendGridSignatureVerifier {

    private final EventWebhook eventWebhook = new EventWebhook();

    @Value("${app.sendgrid.webhook.public-key:}")
    private String webhookPublicKey;

    public boolean isVerificationEnabled() {
        return webhookPublicKey != null && !webhookPublicKey.trim().isBlank();
    }

    public boolean verify(byte[] payload, String signature, String timestamp) {
        if (!isVerificationEnabled()) {
            log.debug("SendGrid webhook signature verification is disabled (no public key configured).");
            return true;
        }

        if (signature == null || signature.isBlank() || timestamp == null || timestamp.isBlank()) {
            log.warn("Missing SendGrid signature or timestamp headers.");
            return false;
        }

        try {
            ECPublicKey ecPublicKey = eventWebhook.ConvertPublicKeyToECDSA(webhookPublicKey.trim());
            boolean isValid = eventWebhook.VerifySignature(ecPublicKey, payload, signature, timestamp);
            if (!isValid) {
                log.warn("SendGrid webhook signature verification failed.");
            }
            return isValid;
        } catch (Exception e) {
            log.error("Error during SendGrid webhook signature verification: {}", e.getMessage());
            return false;
        }
    }
}
