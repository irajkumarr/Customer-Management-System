package com.rajkumartimalsina.backend.health;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.rajkumartimalsina.backend.common.response.ApiResponse;

@RestController
@RequestMapping("/ping")
public class HealthController {

    @GetMapping
    public ResponseEntity<ApiResponse<String>> ping() {
        return ResponseEntity.ok(ApiResponse.success("pong"));
    }
}
