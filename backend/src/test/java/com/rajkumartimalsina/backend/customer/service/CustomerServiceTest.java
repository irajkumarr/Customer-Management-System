package com.rajkumartimalsina.backend.customer.service;

import com.rajkumartimalsina.backend.common.exception.InvalidOperationException;
import com.rajkumartimalsina.backend.common.exception.ResourceNotFoundException;
import com.rajkumartimalsina.backend.customer.dto.CustomerCreateRequest;
import com.rajkumartimalsina.backend.customer.dto.CustomerResponse;
import com.rajkumartimalsina.backend.customer.dto.CustomerUpdateRequest;
import com.rajkumartimalsina.backend.customer.entity.CustomerEntity;
import com.rajkumartimalsina.backend.customer.repository.CustomerRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CustomerServiceTest {

    @Mock
    private CustomerRepository customerRepository;

    private CustomerService customerService;

    @BeforeEach
    void setUp() {
        customerService = new CustomerService(customerRepository);
    }

    @Test
    void getAllCustomers_WithoutSearch_ReturnsAllPaged() {
        UUID id = UUID.randomUUID();
        CustomerEntity customer = CustomerEntity.builder()
                .id(id)
                .email("alice@example.com")
                .name("Alice")
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        Pageable pageable = PageRequest.of(0, 10);
        when(customerRepository.findAll(pageable)).thenReturn(new PageImpl<>(List.of(customer)));

        Page<CustomerResponse> result = customerService.getAllCustomers(null, pageable);

        assertEquals(1, result.getTotalElements());
        assertEquals("alice@example.com", result.getContent().get(0).email());
        verify(customerRepository, times(1)).findAll(pageable);
        verify(customerRepository, never()).findByNameContainingIgnoreCaseOrEmailContainingIgnoreCase(any(), any(), any());
    }

    @Test
    void getAllCustomers_WithSearch_ReturnsMatchingPaged() {
        UUID id = UUID.randomUUID();
        CustomerEntity customer = CustomerEntity.builder()
                .id(id)
                .email("bob@example.com")
                .name("Bob")
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        Pageable pageable = PageRequest.of(0, 10);
        when(customerRepository.findByNameContainingIgnoreCaseOrEmailContainingIgnoreCase(eq("bob"), eq("bob"), eq(pageable)))
                .thenReturn(new PageImpl<>(List.of(customer)));

        Page<CustomerResponse> result = customerService.getAllCustomers("bob", pageable);

        assertEquals(1, result.getTotalElements());
        assertEquals("bob@example.com", result.getContent().get(0).email());
        verify(customerRepository, times(1))
                .findByNameContainingIgnoreCaseOrEmailContainingIgnoreCase(eq("bob"), eq("bob"), eq(pageable));
    }

    @Test
    void getCustomerById_WhenFound_ReturnsResponse() {
        UUID id = UUID.randomUUID();
        CustomerEntity customer = CustomerEntity.builder()
                .id(id)
                .email("carol@example.com")
                .name("Carol")
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        when(customerRepository.findById(id)).thenReturn(Optional.of(customer));

        CustomerResponse response = customerService.getCustomerById(id);

        assertNotNull(response);
        assertEquals(id, response.id());
        assertEquals("carol@example.com", response.email());
    }

    @Test
    void getCustomerById_WhenNotFound_ThrowsException() {
        UUID id = UUID.randomUUID();
        when(customerRepository.findById(id)).thenReturn(Optional.empty());

        assertThrows(ResourceNotFoundException.class, () -> customerService.getCustomerById(id));
    }

    @Test
    void createCustomer_WhenEmailIsNew_CreatesCustomer() {
        CustomerCreateRequest request = new CustomerCreateRequest("dave@example.com", "Dave");
        when(customerRepository.existsByEmailIgnoreCase("dave@example.com")).thenReturn(false);

        UUID id = UUID.randomUUID();
        CustomerEntity saved = CustomerEntity.builder()
                .id(id)
                .email("dave@example.com")
                .name("Dave")
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        when(customerRepository.save(any(CustomerEntity.class))).thenReturn(saved);

        CustomerResponse response = customerService.createCustomer(request);

        assertNotNull(response);
        assertEquals(id, response.id());
        assertEquals("dave@example.com", response.email());
        assertEquals("Dave", response.name());
    }

    @Test
    void createCustomer_WhenEmailExists_ThrowsInvalidOperationException() {
        CustomerCreateRequest request = new CustomerCreateRequest("existing@example.com", "Existing");
        when(customerRepository.existsByEmailIgnoreCase("existing@example.com")).thenReturn(true);

        assertThrows(InvalidOperationException.class, () -> customerService.createCustomer(request));
        verify(customerRepository, never()).save(any());
    }

    @Test
    void updateCustomer_WhenFound_UpdatesName() {
        UUID id = UUID.randomUUID();
        CustomerEntity customer = CustomerEntity.builder()
                .id(id)
                .email("user@example.com")
                .name("Old Name")
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        when(customerRepository.findById(id)).thenReturn(Optional.of(customer));
        when(customerRepository.save(any(CustomerEntity.class))).thenAnswer(invocation -> invocation.getArgument(0));

        CustomerUpdateRequest request = new CustomerUpdateRequest("New Name");
        CustomerResponse response = customerService.updateCustomer(id, request);

        assertEquals("New Name", response.name());
        assertEquals("New Name", customer.getName());
    }

    @Test
    void findOrCreateCustomer_WhenExists_ReturnsExisting() {
        CustomerEntity existing = CustomerEntity.builder()
                .id(UUID.randomUUID())
                .email("known@example.com")
                .name("Known User")
                .build();

        when(customerRepository.findByEmailIgnoreCase("known@example.com")).thenReturn(Optional.of(existing));

        CustomerEntity result = customerService.findOrCreateCustomer("known@example.com", "Another Name");

        assertEquals(existing.getId(), result.getId());
        verify(customerRepository, never()).save(any());
    }

    @Test
    void findOrCreateCustomer_WhenNew_CreatesAndReturns() {
        when(customerRepository.findByEmailIgnoreCase("newuser@example.com")).thenReturn(Optional.empty());

        UUID id = UUID.randomUUID();
        CustomerEntity created = CustomerEntity.builder()
                .id(id)
                .email("newuser@example.com")
                .name("New User")
                .build();

        when(customerRepository.save(any(CustomerEntity.class))).thenReturn(created);

        CustomerEntity result = customerService.findOrCreateCustomer("newuser@example.com", "New User");

        assertNotNull(result);
        assertEquals(id, result.getId());
        assertEquals("newuser@example.com", result.getEmail());
    }
}
