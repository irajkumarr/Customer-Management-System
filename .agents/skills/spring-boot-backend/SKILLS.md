# Skill: Spring Boot Backend Engineering

## Purpose and project context
Implement the backend for the Customer Management System (AI Helpdesk) described in the project plan.

**Fixed project decisions**
- Spring Boot 4, Java 17, Spring MVC, Spring Data JPA, Spring Security.
- PostgreSQL with the `pgvector` extension.
- Session-based authentication for one Admin account. Use Spring Security's `JSESSIONID`; do not introduce JWT.
- Mailgun Inbound Routes/Webhooks receive customer emails; Mailgun Messages API sends replies.
- Google Gemini through Spring AI handles chat and embeddings.
- REST endpoints are consumed by a Flutter Web dashboard.
- Ticket categories: `BILLING`, `TECHNICAL`, `ACCOUNT`, `GENERAL`, `UNKNOWN`.
- Ticket statuses: `NEW`, `AI_PROCESSING`, `AI_REPLIED`, `ESCALATED_TO_HUMAN`, `IN_PROGRESS`, `RESOLVED`, `CLOSED`.

Do not silently change these decisions. If a requirement conflicts with the existing repository or a technical limitation, explain the conflict and propose the smallest safe change before implementing it.

## 1. Mandatory workflow
1. Inspect the repository, build files, package structure, existing entities, migrations, configuration, and tests before editing.
2. Identify the current implementation phase and the exact requested scope.
3. Reuse existing conventions and dependencies. Do not recreate existing classes or add duplicate abstractions.
4. Present a short implementation plan for multi-file or architectural work.
5. Implement only the requested phase/scope. Do not jump ahead into unrelated phases.
6. Run relevant formatting, compilation, and tests. Report commands and actual results.
7. Review the diff for secrets, accidental deletions, unrelated refactors, and incomplete TODOs.

Never claim a build or test passed unless you actually ran it and observed success. If a command cannot run, state why.

## 2. Architecture and package boundaries
Use a feature-oriented, layered structure. Adapt names to the existing repository rather than forcing a large migration.

Suggested structure:
```text
com.example.helpdesk/
  common/
    config/
    exception/
    response/
  auth/
    controller/
    dto/
    service/
  admin/
    entity/
    repository/
  customer/
    entity/
    repository/
    service/
  ticket/
    controller/
    dto/
    entity/
    enums/
    repository/
    service/
  message/
    entity/
    repository/
    service/
  webhook/
    controller/
    dto/
    security/
    service/
  ai/
    config/
    dto/
    service/
  knowledge/
    entity/
    repository/
    service/
  email/
    service/
    dto/
```

Rules:
- Controllers handle HTTP mapping, validation, and response codes; keep business logic in services.
- Services coordinate use cases and transactions.
- Repositories perform persistence queries only.
- DTOs are API contracts. Do not expose JPA entities directly from controllers.
- Keep mapping logic explicit or use an existing mapper already present in the project.
- Avoid generic `BaseService`, `BaseController`, and premature abstractions.
- Use constructor injection; do not use field injection.
- Keep classes focused and avoid circular dependencies.

## 3. Database and persistence
- Use migrations (Flyway or the migration tool already selected by the repository) as the source of truth for schema changes. Do not rely on Hibernate `ddl-auto=update` in production.
- Use `@Enumerated(EnumType.STRING)` for status, category, sender type, and other enums.
- Add database constraints and indexes for actual query patterns:
  - unique customer email;
  - unique admin username;
  - ticket foreign key to customer;
  - message foreign key to ticket;
  - indexes for ticket status, category, `updated_at`, customer ID, and message ticket/timestamp where useful.
- Use `Instant` or a consistent UTC time representation for persisted timestamps.
- Define relationship fetch behavior deliberately. Prefer lazy associations and explicit queries/entity graphs for required data.
- Avoid serializing bidirectional JPA relationships.
- Use optimistic locking (`@Version`) where concurrent ticket updates could overwrite one another.
- Ensure `knowledge_vectors.embedding` uses the PostgreSQL `vector` type. Dimension must match the configured embedding model.
- Enable the pgvector extension through a migration.
- Store only necessary email content and metadata. Do not log full customer email bodies, credentials, or sensitive attachment contents.

## 4. Ticket lifecycle and business invariants
Treat ticket transitions as business rules, not arbitrary status updates.

Expected flow:
- New inbound email creates a `NEW` ticket, or appends a message to an existing thread.
- Before AI work begins, transition to `AI_PROCESSING`.
- A safe automated response transitions to `AI_REPLIED`.
- An uncertain, unsafe, unsupported, or failed AI result transitions to `ESCALATED_TO_HUMAN`.
- An Admin taking ownership transitions to `IN_PROGRESS`.
- Admin may transition a ticket to `RESOLVED`, then `CLOSED`, according to the product rules.

Requirements:
- Centralize transition validation in a ticket domain/service method.
- Reject invalid transitions with a clear domain exception and appropriate HTTP response.
- A customer reply to an `AI_REPLIED` ticket must reopen/escalate it to `ESCALATED_TO_HUMAN`; do not send another unattended answer without re-evaluation.
- Never let AI mark a ticket `RESOLVED` or `CLOSED`.
- Record human actions and AI actions as messages/events with sender type and timestamps.
- Ensure status/category updates and message persistence are transactionally consistent.
- Avoid holding a database transaction open while waiting for Gemini or Mailgun network calls.

## 5. Mailgun Inbound Webhook / Route
The endpoint receives `multipart/form-data` or `application/x-www-form-urlencoded`.

- Map and validate the documented fields, including `from`, `sender`, `recipient`, `subject`, `body-plain`, `stripped-text`, `body-html`, `message-headers`, and `Message-Id`.
- Prefer text content for AI input; sanitize/strip HTML before using it as fallback. Preserve the original message body for the message record according to retention requirements.
- Parse headers using a proper email/header parser where possible. Header names are case-insensitive and may be folded or formatted as JSON arrays.
- Parse `Message-ID`, `In-Reply-To`, and `References`. Normalize message IDs consistently (including angle brackets and whitespace) before lookup.
- Match a reply to an existing ticket using `In-Reply-To` first and `References` as a fallback. Store inbound message IDs with a uniqueness constraint to prevent duplicate ingestion.
- If no matching thread exists, create a new ticket.
- Treat missing or malformed fields as validation failures; do not create corrupt records.
- Enforce request size and attachment limits. Do not trust file names or MIME types supplied by the sender.
- Return a successful webhook response only after the inbound event is durably accepted. For long-running AI processing, persist the message and enqueue/dispatch processing after commit.

### Webhook authentication — important
- Configure and enable **Webhook signing key verification** in Mailgun.
- For signature verification, compute HMAC-SHA256 over `timestamp + token` using Mailgun's HTTP webhook signing key (or API key) and verify against the provided `signature`.
- Keep the verification signing key outside source control and support key rotation.
- Reject invalid/missing signatures when signature verification is configured.
- Do not rely on IP allowlisting alone.
- Add replay protection using the signed timestamp with a reasonable clock-skew window (e.g. 15 minutes) and idempotency.

## 6. Email sending and threading
- Use a dedicated email service; do not send email directly from controllers.
- Configure Mailgun API credentials through environment variables or secret management.
- Set sender identity and reply-to behavior explicitly.
- Persist the outbound message and provider response metadata needed for diagnostics.
- Include stable `Message-ID`, `In-Reply-To`, and `References` headers when supported so customer replies can be associated with the same ticket.
- Make outbound sending idempotent where practical. Avoid duplicate replies after retries.
- Convert Gemini Markdown to safe HTML with a maintained Markdown renderer and sanitize generated HTML before sending. Provide a plain-text alternative.
- Never send internal escalation notes, retrieved private context, stack traces, or system prompts to customers.
- Handle provider timeouts and failures without losing the ticket/message. Record a retryable failure state or queue item.

## 7. Spring Security: single Admin session
- Permit only the intended login endpoint and secured webhook endpoint(s); secure all other `/api/**` routes.
- Keep webhook authentication independent from Admin session authentication.
- Use Spring Security's session management and `JSESSIONID`; do not add JWT filters, token providers, or bearer-token authentication.
- Store the Admin password as a strong adaptive hash (e.g. BCrypt/Argon2 through Spring Security); never store plaintext.
- Provision the single Admin through a controlled seed/configuration process. Do not expose public Admin registration.
- Implement logout by invalidating the server-side session and clearing the session cookie.
- Return consistent `401` for unauthenticated requests and `403` for authenticated but unauthorized requests.
- Configure CSRF deliberately. Do not globally disable it just to make Flutter requests work. Document how login, logout, and state-changing API requests obtain/send the CSRF token.
- Configure CORS with the exact allowed Flutter Web origin(s), `allowCredentials(true)`, explicit methods/headers, and no wildcard origin when credentials are enabled.
- Use secure cookie settings in production: `HttpOnly`, `Secure`, and an appropriate `SameSite` policy. Cross-site deployments may require `SameSite=None; Secure`; verify browser third-party-cookie restrictions and prefer same-site deployment/reverse proxy where possible.
- Never log session IDs, cookies, passwords, API keys, or CSRF tokens.

## 8. REST API conventions
- Use `/api/...` consistently and version only if the project requires it.
- Validate request DTOs with Jakarta Bean Validation (`@Valid`, `@NotBlank`, size constraints, etc.).
- Return appropriate status codes: `200`, `201`, `204`, `400`, `401`, `403`, `404`, `409`, and `5xx` as appropriate.
- Use a consistent error response shape with a safe message, machine-readable code, timestamp, and field validation details when relevant.
- Add pagination and sorting to ticket-list endpoints; use bounded page sizes.
- Use explicit filters for status/category and validate enum values.
- Avoid N+1 queries; fetch list/detail views with deliberate projections/entity graphs.
- Do not return stack traces or internal exception messages to the client.

## 9. Configuration and secrets
- Use typed configuration (`@ConfigurationProperties`) for related settings.
- Keep secrets out of Git, logs, tests, and generated documentation.
- Provide `.env.example` or documented placeholder environment variables, never real values.
- Separate local, test, and production configuration.
- Fail fast on missing required production secrets.
- Do not hardcode model IDs, origins, webhook URLs, or credentials in business logic.

## 10. Testing requirements
Add tests appropriate to the change:
- Unit tests for ticket transitions, email threading, message parsing, and AI response validation.
- Repository/integration tests for uniqueness, relationships, pgvector schema, and queries.
- MockMvc/security tests for login, session persistence, authorization, CSRF, CORS, and logout.
- Webhook tests for multipart parsing, signature success/failure, malformed requests, replay/idempotency, duplicate delivery, and attachment limits.
- AI tests using a mocked model; do not call paid/live Gemini in ordinary unit tests.
- Email tests using a mocked Mailgun client or mock server.
- Test failure paths and retries, not only happy paths.

## 11. Definition of done
A backend change is complete only when:
- It follows the existing package and layering conventions.
- Validation, authorization, error handling, and transaction boundaries are correct.
- No secrets or sensitive payloads are logged.
- Relevant tests pass, or unrun tests are explicitly reported.
- API contract changes are reflected in DTOs and documented for Flutter.
- No unrelated files or project phases were changed.
