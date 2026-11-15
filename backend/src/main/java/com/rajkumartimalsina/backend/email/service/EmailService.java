package com.rajkumartimalsina.backend.email.service;

import com.rajkumartimalsina.backend.email.dto.EmailSendRequest;
import com.rajkumartimalsina.backend.email.dto.EmailSendResult;

public interface EmailService {
    EmailSendResult sendEmail(EmailSendRequest request);
}
