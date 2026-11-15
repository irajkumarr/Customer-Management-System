package com.rajkumartimalsina.backend;

import com.rajkumartimalsina.backend.admin.entity.AdminEntity;
import com.rajkumartimalsina.backend.admin.enums.AdminRole;
import com.rajkumartimalsina.backend.admin.repository.AdminRepository;
import com.rajkumartimalsina.backend.customer.entity.CustomerEntity;
import com.rajkumartimalsina.backend.customer.repository.CustomerRepository;
import com.rajkumartimalsina.backend.message.entity.MessageEntity;
import com.rajkumartimalsina.backend.message.enums.MessageSenderType;
import com.rajkumartimalsina.backend.message.repository.MessageRepository;
import com.rajkumartimalsina.backend.ticket.entity.TicketEntity;
import com.rajkumartimalsina.backend.ticket.enums.TicketCategory;
import com.rajkumartimalsina.backend.ticket.enums.TicketStatus;
import com.rajkumartimalsina.backend.ticket.repository.TicketRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@DataJpaTest
class EntityPersistenceTest {

    @Autowired
    private AdminRepository adminRepository;

    @Autowired
    private CustomerRepository customerRepository;

    @Autowired
    private TicketRepository ticketRepository;

    @Autowired
    private MessageRepository messageRepository;

    @Test
    void testAdminPersistence() {
        AdminEntity admin = AdminEntity.builder()
                .username("testadmin")
                .passwordHash("hashedpw")
                .role(AdminRole.ADMIN)
                .build();

        AdminEntity saved = adminRepository.save(admin);
        assertNotNull(saved.getId());
        assertNotNull(saved.getCreatedAt());

        Optional<AdminEntity> found = adminRepository.findByUsername("testadmin");
        assertTrue(found.isPresent());
        assertEquals(AdminRole.ADMIN, found.get().getRole());
    }

    @Test
    void testCustomerTicketAndMessageCascade() {
        CustomerEntity customer = CustomerEntity.builder()
                .email("user@example.com")
                .name("John Doe")
                .build();

        CustomerEntity savedCustomer = customerRepository.save(customer);
        assertNotNull(savedCustomer.getId());

        TicketEntity ticket = TicketEntity.builder()
                .customer(savedCustomer)
                .subject("Billing Inquiry")
                .status(TicketStatus.NEW)
                .category(TicketCategory.BILLING)
                .build();

        MessageEntity message1 = MessageEntity.builder()
                .senderType(MessageSenderType.CUSTOMER)
                .body("Hello, I need help with my invoice.")
                .isAiGenerated(false)
                .inboundMessageId("<msg1@example.com>")
                .build();

        ticket.addMessage(message1);
        TicketEntity savedTicket = ticketRepository.save(ticket);
        assertNotNull(savedTicket.getId());
        assertNotNull(savedTicket.getVersion());
        assertEquals(1, savedTicket.getMessages().size());

        List<MessageEntity> messages = messageRepository.findByTicketIdOrderByCreatedAtAsc(savedTicket.getId());
        assertEquals(1, messages.size());
        assertEquals(MessageSenderType.CUSTOMER, messages.get(0).getSenderType());
        assertEquals("<msg1@example.com>", messages.get(0).getInboundMessageId());
    }
}
