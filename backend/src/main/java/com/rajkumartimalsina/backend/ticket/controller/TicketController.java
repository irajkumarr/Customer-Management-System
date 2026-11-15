package com.rajkumartimalsina.backend.ticket.controller;

import com.rajkumartimalsina.backend.common.response.ApiResponse;
import com.rajkumartimalsina.backend.message.dto.MessageCreateRequest;
import com.rajkumartimalsina.backend.message.dto.MessageResponse;
import com.rajkumartimalsina.backend.ticket.dto.*;
import com.rajkumartimalsina.backend.ticket.enums.TicketCategory;
import com.rajkumartimalsina.backend.ticket.enums.TicketStatus;
import com.rajkumartimalsina.backend.ticket.service.TicketService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/tickets")
@RequiredArgsConstructor
public class TicketController {

    private final TicketService ticketService;

    @GetMapping
    public ResponseEntity<ApiResponse<Page<TicketResponse>>> getTickets(
            @RequestParam(required = false) TicketStatus status,
            @RequestParam(required = false) TicketCategory category,
            @RequestParam(required = false) UUID customerId,
            @RequestParam(required = false) String search,
            @PageableDefault(size = 20, sort = "updatedAt", direction = Sort.Direction.DESC) Pageable pageable
    ) {
        Page<TicketResponse> tickets = ticketService.getTickets(status, category, customerId, search, pageable);
        return ResponseEntity.ok(ApiResponse.success(tickets));
    }

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<TicketStatsResponse>> getStats() {
        TicketStatsResponse stats = ticketService.getTicketStats();
        return ResponseEntity.ok(ApiResponse.success(stats));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<TicketDetailResponse>> getTicketById(@PathVariable UUID id) {
        TicketDetailResponse ticket = ticketService.getTicketById(id);
        return ResponseEntity.ok(ApiResponse.success(ticket));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<TicketResponse>> createTicket(
            @Valid @RequestBody TicketCreateRequest request
    ) {
        TicketResponse created = ticketService.createTicket(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Ticket created successfully", created));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<ApiResponse<TicketResponse>> updateStatus(
            @PathVariable UUID id,
            @Valid @RequestBody TicketStatusUpdateRequest request
    ) {
        TicketResponse updated = ticketService.updateStatus(id, request.status());
        return ResponseEntity.ok(ApiResponse.success("Ticket status updated successfully", updated));
    }

    @PatchMapping("/{id}/category")
    public ResponseEntity<ApiResponse<TicketResponse>> updateCategory(
            @PathVariable UUID id,
            @Valid @RequestBody TicketCategoryUpdateRequest request
    ) {
        TicketResponse updated = ticketService.updateCategory(id, request.category());
        return ResponseEntity.ok(ApiResponse.success("Ticket category updated successfully", updated));
    }

    @GetMapping("/{id}/messages")
    public ResponseEntity<ApiResponse<List<MessageResponse>>> getTicketMessages(@PathVariable UUID id) {
        List<MessageResponse> messages = ticketService.getTicketMessages(id);
        return ResponseEntity.ok(ApiResponse.success(messages));
    }

    @PostMapping("/{id}/messages")
    public ResponseEntity<ApiResponse<MessageResponse>> sendAdminReply(
            @PathVariable UUID id,
            @Valid @RequestBody MessageCreateRequest request
    ) {
        MessageResponse reply = ticketService.sendAdminReply(id, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Admin reply sent and emailed to customer", reply));
    }
}
