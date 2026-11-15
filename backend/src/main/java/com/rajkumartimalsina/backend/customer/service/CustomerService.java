package com.rajkumartimalsina.backend.customer.service;

import com.rajkumartimalsina.backend.common.exception.InvalidOperationException;
import com.rajkumartimalsina.backend.common.exception.ResourceNotFoundException;
import com.rajkumartimalsina.backend.customer.dto.CustomerCreateRequest;
import com.rajkumartimalsina.backend.customer.dto.CustomerResponse;
import com.rajkumartimalsina.backend.customer.dto.CustomerUpdateRequest;
import com.rajkumartimalsina.backend.customer.entity.CustomerEntity;
import com.rajkumartimalsina.backend.customer.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class CustomerService {

    private final CustomerRepository customerRepository;

    @Transactional(readOnly = true)
    public Page<CustomerResponse> getAllCustomers(String search, Pageable pageable) {
        if (search != null && !search.isBlank()) {
            String trimmed = search.trim();
            return customerRepository
                    .findByNameContainingIgnoreCaseOrEmailContainingIgnoreCase(trimmed, trimmed, pageable)
                    .map(CustomerResponse::fromEntity);
        }
        return customerRepository.findAll(pageable).map(CustomerResponse::fromEntity);
    }

    @Transactional(readOnly = true)
    public CustomerResponse getCustomerById(UUID id) {
        CustomerEntity customer = customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found with id: " + id));
        return CustomerResponse.fromEntity(customer);
    }

    @Transactional(readOnly = true)
    public CustomerResponse getCustomerByEmail(String email) {
        CustomerEntity customer = customerRepository.findByEmailIgnoreCase(email.trim())
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found with email: " + email));
        return CustomerResponse.fromEntity(customer);
    }

    @Transactional
    public CustomerResponse createCustomer(CustomerCreateRequest request) {
        String normalizedEmail = request.email().trim().toLowerCase();
        if (customerRepository.existsByEmailIgnoreCase(normalizedEmail)) {
            throw new InvalidOperationException("Customer with email '" + normalizedEmail + "' already exists");
        }

        String name = request.name() != null ? request.name().trim() : null;
        CustomerEntity customer = CustomerEntity.builder()
                .email(normalizedEmail)
                .name(name)
                .build();

        CustomerEntity saved = customerRepository.save(customer);
        log.info("Created new customer with id '{}' and email '{}'", saved.getId(), saved.getEmail());
        return CustomerResponse.fromEntity(saved);
    }

    @Transactional
    public CustomerResponse updateCustomer(UUID id, CustomerUpdateRequest request) {
        CustomerEntity customer = customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found with id: " + id));

        if (request.name() != null) {
            customer.setName(request.name().trim());
        }

        CustomerEntity updated = customerRepository.save(customer);
        log.info("Updated customer id '{}'", updated.getId());
        return CustomerResponse.fromEntity(updated);
    }

    @Transactional
    public CustomerEntity findOrCreateCustomer(String email, String name) {
        String normalizedEmail = email.trim().toLowerCase();
        String trimmedName = name != null ? name.trim() : null;

        return customerRepository.findByEmailIgnoreCase(normalizedEmail)
                .map(existing -> {
                    if ((existing.getName() == null || existing.getName().isBlank()) && trimmedName != null) {
                        existing.setName(trimmedName);
                        return customerRepository.save(existing);
                    }
                    return existing;
                })
                .orElseGet(() -> {
                    CustomerEntity newCustomer = CustomerEntity.builder()
                            .email(normalizedEmail)
                            .name(trimmedName)
                            .build();
                    CustomerEntity saved = customerRepository.save(newCustomer);
                    log.info("Registered new customer during thread/ticket lookup: {}", normalizedEmail);
                    return saved;
                });
    }
}
