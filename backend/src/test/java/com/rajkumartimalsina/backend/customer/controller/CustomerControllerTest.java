package com.rajkumartimalsina.backend.customer.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.rajkumartimalsina.backend.admin.service.AdminDetailsService;
import com.rajkumartimalsina.backend.common.config.CorsConfig;
import com.rajkumartimalsina.backend.common.config.SecurityConfig;
import com.rajkumartimalsina.backend.customer.dto.CustomerCreateRequest;
import com.rajkumartimalsina.backend.customer.dto.CustomerResponse;
import com.rajkumartimalsina.backend.customer.dto.CustomerUpdateRequest;
import com.rajkumartimalsina.backend.customer.service.CustomerService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(CustomerController.class)
@Import({SecurityConfig.class, CorsConfig.class})
class CustomerControllerTest {

    @Autowired
    private MockMvc mockMvc;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @MockitoBean
    private CustomerService customerService;

    @MockitoBean
    private AdminDetailsService adminDetailsService;

    @Test
    void getCustomers_WithoutAuth_Returns401() throws Exception {
        mockMvc.perform(get("/api/customers"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false));
    }

    @Test
    void getCustomers_WithAuth_Returns200() throws Exception {
        UUID id = UUID.randomUUID();
        CustomerResponse customer = new CustomerResponse(id, "test@example.com", "Test User", Instant.now(), Instant.now());
        when(customerService.getAllCustomers(any(), any())).thenReturn(new PageImpl<>(List.of(customer), PageRequest.of(0, 20), 1));

        mockMvc.perform(get("/api/customers").with(user("admin").roles("ADMIN")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.content[0].email").value("test@example.com"));
    }

    @Test
    void getCustomerById_Returns200() throws Exception {
        UUID id = UUID.randomUUID();
        CustomerResponse customer = new CustomerResponse(id, "test@example.com", "Test User", Instant.now(), Instant.now());
        when(customerService.getCustomerById(id)).thenReturn(customer);

        mockMvc.perform(get("/api/customers/" + id).with(user("admin").roles("ADMIN")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.id").value(id.toString()))
                .andExpect(jsonPath("$.data.name").value("Test User"));
    }

    @Test
    void createCustomer_Valid_Returns201() throws Exception {
        UUID id = UUID.randomUUID();
        CustomerCreateRequest request = new CustomerCreateRequest("new@example.com", "New User");
        CustomerResponse response = new CustomerResponse(id, "new@example.com", "New User", Instant.now(), Instant.now());

        when(customerService.createCustomer(any())).thenReturn(response);

        mockMvc.perform(post("/api/customers")
                        .with(user("admin").roles("ADMIN"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.email").value("new@example.com"));
    }

    @Test
    void createCustomer_InvalidEmail_Returns400() throws Exception {
        CustomerCreateRequest request = new CustomerCreateRequest("not-an-email", "Invalid");

        mockMvc.perform(post("/api/customers")
                        .with(user("admin").roles("ADMIN"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false));
    }

    @Test
    void updateCustomer_Returns200() throws Exception {
        UUID id = UUID.randomUUID();
        CustomerUpdateRequest request = new CustomerUpdateRequest("Updated Name");
        CustomerResponse response = new CustomerResponse(id, "test@example.com", "Updated Name", Instant.now(), Instant.now());

        when(customerService.updateCustomer(eq(id), any())).thenReturn(response);

        mockMvc.perform(put("/api/customers/" + id)
                        .with(user("admin").roles("ADMIN"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.name").value("Updated Name"));
    }
}
