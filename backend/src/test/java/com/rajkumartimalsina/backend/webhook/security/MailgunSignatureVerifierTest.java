package com.rajkumartimalsina.backend.webhook.security;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.HexFormat;

import static org.assertj.core.api.Assertions.assertThat;

class MailgunSignatureVerifierTest {

    private MailgunSignatureVerifier verifier;
    private final String testSigningKey = "test-signing-key-12345";

    @BeforeEach
    void setUp() {
        verifier = new MailgunSignatureVerifier();
        ReflectionTestUtils.setField(verifier, "signingKey", testSigningKey);
    }

    private String computeHmacHex(String key, String data) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
        return HexFormat.of().formatHex(mac.doFinal(data.getBytes(StandardCharsets.UTF_8)));
    }

    @Test
    @DisplayName("Should verify valid HMAC-SHA256 signature when timestamp is current")
    void shouldVerifyValidSignature() throws Exception {
        String timestamp = String.valueOf(Instant.now().getEpochSecond());
        String token = "random-token-xyz-123";
        String signature = computeHmacHex(testSigningKey, timestamp + token);

        boolean result = verifier.verify(timestamp, token, signature);

        assertThat(result).isTrue();
    }

    @Test
    @DisplayName("Should reject invalid signature")
    void shouldRejectInvalidSignature() {
        String timestamp = String.valueOf(Instant.now().getEpochSecond());
        String token = "random-token-xyz-123";
        String invalidSignature = "deadbeef00000000000000000000000000000000000000000000000000000000";

        boolean result = verifier.verify(timestamp, token, invalidSignature);

        assertThat(result).isFalse();
    }

    @Test
    @DisplayName("Should reject expired timestamp beyond replay window")
    void shouldRejectExpiredTimestamp() throws Exception {
        long oldSeconds = Instant.now().getEpochSecond() - 1200; // 20 minutes ago
        String timestamp = String.valueOf(oldSeconds);
        String token = "random-token-xyz-123";
        String signature = computeHmacHex(testSigningKey, timestamp + token);

        boolean result = verifier.verify(timestamp, token, signature);

        assertThat(result).isFalse();
    }

    @Test
    @DisplayName("Should return true when verification is disabled (empty signing key)")
    void shouldAllowWhenVerificationDisabled() {
        ReflectionTestUtils.setField(verifier, "signingKey", "");

        boolean result = verifier.verify("12345", "token", "signature");

        assertThat(result).isTrue();
        assertThat(verifier.isVerificationEnabled()).isFalse();
    }

    @Test
    @DisplayName("Should reject when parameters are null or blank")
    void shouldRejectWhenParametersAreBlank() {
        assertThat(verifier.verify(null, "token", "sig")).isFalse();
        assertThat(verifier.verify("123", "", "sig")).isFalse();
        assertThat(verifier.verify("123", "token", null)).isFalse();
    }
}
