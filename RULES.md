# Project: AI Customer Management System

## Core Architecture Constraints

- **No WebSockets, No SSE, No Polling.** The frontend relies strictly on manual refresh (Pull-to-Refresh / Refresh Button) via standard REST APIs.
- **Single Admin User.** Do NOT implement JWT or complex OAuth. Use standard Spring Security Session-based authentication (`JSESSIONID`) with a single hardcoded or DB-stored admin row.
- **Email Provider:** Mailgun ONLY. Use Mailgun Routes / Webhooks for inbound ingestion and Mailgun Messages REST API for outbound emails.

## Tech Stack Enforcement

- **Backend:** Java 17, Spring Boot 4, Spring Data JPA, PostgreSQL with `pgvector`.
- **AI:** `spring-ai-starter-model-google-genai` (Google Gemini).
- **Frontend:** Flutter Web, `flutter_bloc` (BLoC pattern), `freezed` (models), `dio` (networking), `go_router` (routing).

## Code Generation Rules

- Always use Java Records for backend DTOs.
- Always use Freezed for Flutter models. Remind me to run `build_runner` if Freezed files are modified.
- Keep backend controllers thin; push all business logic to `@Service` classes.
