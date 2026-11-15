package com.rajkumartimalsina.backend.message.repository;

import com.rajkumartimalsina.backend.message.entity.MessageEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface MessageRepository extends JpaRepository<MessageEntity, UUID> {

    List<MessageEntity> findByTicketIdOrderByCreatedAtAsc(UUID ticketId);

    Optional<MessageEntity> findByInboundMessageId(String inboundMessageId);
}
