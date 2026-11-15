# Customer Management System (AI Helpdesk) - Project Plan

## 1. Project Overview
A responsive Customer Management System where customer emails are ingested via Mailgun webhooks, processed by Google Gemini AI using a Retrieval-Augmented Generation (RAG) pipeline against a local knowledge base, and either auto-replied to or escalated to a human agent. The AI also automatically categorizes the ticket. The frontend is a responsive Flutter Web dashboard restricted to a **single Admin login**, managed via simple session-based authentication and manual refreshes.

## 2. Technology Stack

### Backend
*   **Framework:** Spring Boot 4 (Java 17)
*   **Security:** Spring Security (Session-based authentication for the single Admin)
*   **Database:** PostgreSQL with `pgvector` extension (Relational data + Vector embeddings)
*   **AI Provider:** Google Gemini via `spring-ai-starter-model-google-genai`
*   **Email Provider:** Mailgun (Inbound Routes / Webhooks + Outbound API)

### Frontend (Flutter Web/Responsive)
*   **State Management:** `flutter_bloc` (BLoC / Cubit)
*   **Data Models:** `freezed` (Immutable models, JSON serialization)
*   **Networking:** `dio` (HTTP client)
*   **Cookie Management:** `cookie_jar` & `dio_cookie_manager` (To handle the session cookie automatically)
*   **Routing:** `go_router` (with AuthGuard for protected routes)
*   **UI/UX:** Material 3, `responsive_builder`, `flutter_markdown`

---

## 3. Architecture & Data Flow

1.  **Ingestion:** Customer emails `support@domain.com`. Mailgun intercepts and POSTs payload to Spring Boot.
2.  **Processing:** Spring Boot verifies Mailgun webhook signature, parses email, and creates/updates a `Ticket`.
3.  **AI RAG & Categorization Pipeline:** 
    *   Spring Boot embeds the customer's query using Gemini.
    *   Queries `pgvector` for relevant chunks from `knowledge_base.md`.
    *   Sends context + query to Gemini, forcing **Structured JSON Output** (Reply + Escalation Flag + Category).
4.  **Routing & Categorization:** 
    *   AI assigns a `category` (e.g., BILLING, TECHNICAL, ACCOUNT).
    *   If AI is confident (`requires_human: false`): Status -> `AI_REPLIED`. Sends email reply.
    *   If AI is unsure (`requires_human: true`): Status -> `ESCALATED_TO_HUMAN`. Sends polite holding email.
5.  **Admin Access:** The single Admin logs in via the Flutter Web app. Spring Security creates a secure session cookie (`JSESSIONID`).
6.  **Frontend Sync:** Admin views the dashboard. Dio automatically attaches the session cookie to all requests. Admin manually refreshes the page/pulls-to-refresh to see new updates (No WebSockets/Polling).

---

## 4. Database Schema (PostgreSQL + pgvector)

*   **`admins`**: `id`, `username` (unique), `password_hash`, `role` (ADMIN) *(Note: You will only ever have 1 row here)*
*   **`customers`**: `id`, `email` (unique), `name`, `created_at`
*   **`tickets`**: `id`, `customer_id`, `subject`, `status` (Enum), `category` (Enum), `created_at`, `updated_at`
*   **`messages`**: `id`, `ticket_id`, `sender_type` (customer/ai/admin), `body`, `is_ai_generated`, `created_at`
*   **`knowledge_vectors`** (pgvector): `id`, `content` (text), `embedding` (vector), `metadata` (jsonb)

**Ticket Status Enum:**
`NEW` -> `AI_PROCESSING` -> `AI_REPLIED` OR `ESCALATED_TO_HUMAN` -> `IN_PROGRESS` -> `RESOLVED` -> `CLOSED`

**Ticket Category Enum:**
`BILLING`, `TECHNICAL`, `ACCOUNT`, `GENERAL`, `UNKNOWN`

---

## 5. Implementation Phases

### Phase 1: Project Setup & Database
*   Initialize Spring Boot 4 project (Java 17). Add dependencies: `Spring Web`, `Spring Data JPA`, `PostgreSQL Driver`, `spring-ai-starter-model-google-genai`, `Spring Security`.
*   Initialize Flutter project. Add dependencies: `flutter_bloc`, `bloc`, `freezed`, `json_annotation`, `dio`, `cookie_jar`, `dio_cookie_manager`, `go_router`, `flutter_markdown`, `responsive_builder`.
*   Setup PostgreSQL and enable `pgvector`.
*   Create JPA Entities in Spring Boot, including the simple `Admin` entity and `TicketCategory` enum.
*   Create Freezed models in Flutter (`Ticket`, `Message`, `Customer`).

### Phase 2: Admin Session Authentication (Spring Security)
*   Configure Spring Security to secure all `/api/**` endpoints except `/api/auth/login` and `/api/webhooks/**`.
*   Implement a simple `/api/auth/login` endpoint that validates the single Admin's credentials and returns `200 OK` (Spring Security automatically handles creating the `JSESSIONID` cookie).
*   Configure Spring Security CORS to allow credentials (cookies) from your Flutter Web domain.
*   In Flutter, initialize a `CookieJar` and attach it to `Dio` using `CookieManager`. This ensures the session cookie is automatically saved and sent with every subsequent API request.
*   Setup `go_router` `redirect` logic: If the `CookieJar` is empty (no session), redirect to `/login`.

### Phase 3: Mailgun Ingestion & Webhooks
*   Configure Mailgun Routes. Point MX records and set webhook forward URL to `/api/webhooks/mailgun`.
*   Build Spring Boot `@RestController` to accept `multipart/form-data` and `application/x-www-form-urlencoded`.
*   Implement Mailgun Webhook Signature Verification using HMAC-SHA256 (Security).
*   Implement Email Threading: Parse `In-Reply-To` and `References` headers to append messages to existing tickets.

### Phase 4: Gemini AI, RAG & Categorization
*   Write a startup script to read `knowledge_base.md`, chunk it, embed via Gemini, and store in `pgvector`.
*   Build the RAG Service using `spring-ai-starter-model-google-genai`.
*   Implement **Gemini Structured Output**: Force the LLM to return JSON:
    ```json
    {
      "reply_text": "string",
      "requires_human": boolean,
      "escalation_reason": "string",
      "category": "BILLING" 
    }
    ```
*   Update `TicketService` to read the JSON, update the `TicketStatus` and `TicketCategory`, and use the Mailgun API to send the outbound email.

### Phase 5: Flutter Networking & State Management
*   **Networking & Data Mapping:** Configure the HTTP client to automatically manage session cookies for authentication. Map JSON API responses to immutable data models for type-safe handling across the app.
*   **Authentication State Features:** Implement state handling for the login flow, including processing credentials, tracking active session status, and handling secure logout/session clearing.
*   **Ticket List State Features:** Implement state handling for the main dashboard, including fetching ticket collections, filtering by status, filtering by AI category, and handling manual data refreshes.
*   **Ticket Detail State Features:** Implement state handling for individual ticket views, including fetching full message threads and processing human agent actions (e.g., taking over an escalated ticket, updating status, resolving).

### Phase 6: Flutter Responsive UI & Manual Refresh
*   **Routing:** Setup `go_router` with `/login` (public) and `/tickets`, `/tickets/:id` (protected).
*   **Responsive Layout:** 
    *   Desktop (>900px): Sidebar | Ticket List | Ticket Detail.
    *   Mobile (<900px): Drawer | Ticket List (pushes to Detail).
*   **UI Components:**
    *   Login Screen: Simple form for the Admin credentials.
    *   Ticket List: Color-coded status chips AND category badges.
    *   Ticket Detail: Chronological message thread. Render AI messages using `flutter_markdown`.
*   **Manual Refresh UX:**
    *   Wrap lists in `RefreshIndicator` (Pull-to-refresh).
    *   Add `IconButton(Icons.refresh)` in the AppBar.
    *   Both actions trigger a manual data fetch via the state management layer.

### Phase 7: Edge Cases & Deployment
*   **Edge Case - Angry Customer:** If a customer replies to an `AI_REPLIED` ticket, webhook logic automatically bumps status to `ESCALATED_TO_HUMAN`.
*   **Edge Case - Markdown Emails:** Convert Gemini's Markdown output to HTML before sending via Mailgun.
*   **Deployment:**
    *   Backend: Dockerize Spring Boot 4 (Java 17). Deploy to Render/Railway/AWS. Ensure DB has `pgvector`.
    *   Frontend: `flutter build web --release`. Deploy to Firebase Hosting/Vercel. Configure server to rewrite all 404s to `index.html` for `go_router` support.

---

## 6. Key "Gotchas" & Best Practices

1.  **Session Cookies & CORS:** Because Flutter Web runs in the browser, if your frontend (e.g., Vercel) and backend (e.g., Render) are on different domains, you **must** configure Spring Security CORS to `allowCredentials(true)` and specify the exact frontend origin. Otherwise, the browser will block the session cookie.
2.  **Dio Cookie Management:** Unlike a standard browser, `Dio` does not save cookies automatically. You *must* use the `cookie_jar` and `dio_cookie_manager` packages, otherwise, the Admin will log in successfully but get `401 Unauthorized` on the very next API call.
3.  **Spring AI Google GenAI Starter:** Ensure your `application.properties` correctly sets `spring.ai.google.genai.api-key` and the specific chat/embedding model names (e.g., `gemini-1.5-pro`).
4.  **Mailgun Webhook Security:** Mailgun signs webhooks using HMAC-SHA256 on the `timestamp + token` concatenation with your Mailgun Webhook Signing Key. Verify this signature to prevent unauthorized calls.
5.  **Freezed Boilerplate:** Every time you change a Freezed model in Flutter, run `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate files.