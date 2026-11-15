# Skill: Flutter Web, BLoC, and Networking

## Purpose and project context
Build the responsive Flutter Web dashboard for the Customer Management System (AI Helpdesk).

Fixed stack:
- Flutter Web, Dart, `flutter_bloc`/Cubit, `equatable` where appropriate.
- Freezed + `json_serializable` for immutable API models.
- Dio for HTTP, GoRouter for navigation.
- Material 3, responsive desktop/tablet/mobile layouts.
- Single Admin session authenticated by Spring Security `JSESSIONID`.
- Dashboard uses manual refresh; do not add polling, timers, or WebSockets.

## 1. Mandatory workflow
1. Inspect the current Flutter version, `pubspec.yaml`, folder structure, routes, theme, API contracts, and existing state management.
2. Reuse existing architecture and dependencies. Do not replace BLoC with another state manager.
3. Confirm backend endpoint paths, request/response JSON, status codes, and cookie/CSRF behavior before implementing API calls.
4. Propose a concise plan for multi-file changes.
5. Implement the requested feature only.
6. Run `dart format`, `flutter analyze`, and relevant tests. Report actual results.
7. Do not modify generated files manually.

## 2. Clean Architecture is mandatory
Use feature-first Clean Architecture. Each feature owns its presentation, domain, and data layers. Adapt names to the existing repository, but preserve the dependency direction and layer responsibilities. Do not restructure the whole app without a request.

```text
lib/
  app/
    app.dart
    router/
    di/                       # composition root / dependency registration
    theme/
  core/
    config/
    errors/                   # shared failures and app-level exceptions
    network/                  # Dio client and transport configuration
    responsive/
    widgets/                  # genuinely shared UI components
  features/
    auth/
      data/
        datasources/
        models/
        repositories/
      domain/
        entities/
        repositories/          # abstract contracts
        usecases/
      presentation/
        bloc/                  # BLoC/Cubit, events, states
        pages/
        widgets/
    tickets/
      data/
        datasources/
        models/
        repositories/
      domain/
        entities/
        repositories/
        usecases/
      presentation/
        bloc/
        pages/
        widgets/
    ticket_detail/             # same layer structure when kept separate
    dashboard/                 # presentation composition where appropriate
```

### Layer responsibilities and dependency rules
- **Presentation:** pages, widgets, BLoC/Cubit, events, and states. It may depend on domain abstractions/use cases, but not on Dio, API models, or concrete data-source implementations.
- **Domain:** pure Dart entities, value objects where useful, repository contracts, use cases, and business rules. It must not import Flutter, BLoC, Dio, Freezed JSON models, or other data/presentation implementation details.
- **Data:** API/local data sources, DTO/API models, serialization, repository implementations, and mapping between external models and domain entities. It implements domain repository contracts.
- **Core:** only cross-feature infrastructure and genuinely shared primitives. Do not turn `core` into a dumping ground for feature-specific code.
- Dependencies point inward: `presentation -> domain` and `data -> domain`. Domain depends on neither outer layer. The app composition root wires concrete data implementations to domain contracts and injects use cases into presentation.
- BLoCs/Cubits call use cases, not Dio or data sources. Widgets call neither repositories nor use cases directly; they interact through BLoC/Cubit.
- Data sources must not be called directly from presentation.
- Keep API response models separate from domain entities. Map at the data/repository boundary; do not leak transport-specific JSON shapes into business logic.
- Define repository interfaces in `domain/repositories/`; implement them in `data/repositories/`.
- Use one use case per meaningful application action/business operation (for example, `GetTickets`, `RefreshTickets`, `LoginAdmin`, `TakeOverTicket`). Do not create trivial wrapper classes for every getter or line of code.
- Keep each BLoC/Cubit focused on a feature or cohesive workflow.
- Repositories translate transport/parsing errors into typed domain failures or app-level exceptions; raw Dio exceptions must not cross into presentation/domain.
- Avoid giant `utils.dart`, global mutable state, service-locator access from widgets/BLoCs, and over-generalized base classes.

### Architecture acceptance checks
Before considering a feature complete, verify that domain code can be unit-tested without Flutter or network dependencies; presentation depends on abstractions; data implements domain contracts; mappings are explicit; and dependencies are wired at the app boundary. If a proposed change breaks these rules, explain why before proceeding.

## 3. BLoC and state rules
- Keep events, states, and BLoC in separate files when the feature is substantial; small Cubits may use a clear, compact structure.
- Use immutable states. Freezed is preferred for complex state unions; Equatable is acceptable where the current codebase uses it.
- Do not redundantly combine Equatable and Freezed for the same generated state model.
- Use descriptive event/state names consistently. Prefer action-oriented event names (`TicketsFetched`, `TicketStatusChanged`) or the repository's established convention; do not mix naming styles within a feature.
- Keep event handlers short and delegate work to use cases/repositories.
- Handle loading, success, empty, and failure states explicitly.
- Preserve current filter/search state during manual refresh unless product behavior says otherwise.
- Prevent stale concurrent requests from overwriting newer filter results. Use request sequencing/cancellation where needed.
- Use `BlocListener` for one-off side effects (navigation, snackbars); use `BlocBuilder`/`BlocSelector` for rendering.
- Do not dispatch events from `build()` methods.
- Close manually owned controllers/subscriptions; prefer `BlocProvider` ownership rules.

Ticket-list behavior:
- Fetch initial tickets.
- Filter by status and category.
- Refresh explicitly through a repository fetch.
- Support pagination if the backend returns paged results.
- Show a clear empty state when filters produce no results.
- A refresh must not create a timer or background polling loop.

Ticket-detail behavior:
- Fetch a ticket and its chronological message thread.
- Support taking over an escalated ticket, changing permitted status, resolving, and closing according to backend rules.
- Disable or show progress for actions while requests are pending.
- Refresh detail after successful mutations or update local state from the authoritative response.

## 4. Dio networking and session authentication
### Flutter Web
- The browser owns HttpOnly cookies. Flutter Web cannot read an HttpOnly `JSESSIONID`, and the app must not try to inspect it to determine authentication.
- Configure Dio's browser adapter to send credentials for cross-origin requests (`BrowserHttpClientAdapter(withCredentials: true)`) when frontend and backend have different origins.
- Backend CORS must return the exact allowed origin and `Access-Control-Allow-Credentials: true`; wildcard origins are invalid for credentialed requests.
- Do not rely on `CookieJar`/`CookieManager` as the mechanism for browser-managed HttpOnly cookies.
- Same-origin deployment or a reverse proxy is preferred when practical. Cross-site cookie policies and browser third-party-cookie restrictions can affect deployments.
- Keep CSRF behavior aligned with the backend. If Spring Security requires a CSRF token, implement the documented token bootstrap/read/send flow; do not disable CSRF just to make requests succeed.

### Native platforms, if ever added
- A `CookieJar`/`CookieManager` can be used for native Dio clients where the platform adapter allows application-managed cookie persistence.
- Keep platform-specific cookie configuration isolated; do not force native cookie logic into the web client.

### General Dio rules
- Configure base URL, connect/receive/send timeouts, JSON headers, and a consistent response strategy in one place.
- Add an interceptor for safe logging in development only. Redact passwords, cookies, session IDs, CSRF tokens, and customer message bodies.
- Convert Dio exceptions into typed app failures in the data layer.
- Handle `401` by clearing in-memory auth state and redirecting to login through a centralized navigation/auth mechanism. Avoid navigation directly from low-level interceptors if it creates dependency cycles.
- Handle `403` separately from `401`.
- Do not automatically retry non-idempotent mutations unless an idempotency strategy exists.
- Avoid logging full request/response payloads in production.

## 5. Authentication and routing
- Routes: `/login`, `/tickets`, `/tickets/:id` (and any existing agreed routes).
- Keep login public and ticket routes protected.
- Since HttpOnly cookies cannot be inspected by Dart, use a backend session-check endpoint (e.g. `/api/auth/me`) to establish authenticated state on app startup and after refresh.
- Do not use `CookieJar.isEmpty` as a web auth guard.
- Use GoRouter redirect based on the app's auth state; avoid redirect loops while auth status is `unknown/loading`.
- After login, call the session-check endpoint or trust a successful login response according to the backend contract.
- Logout must call the backend logout endpoint, then clear local auth state and navigate to login.
- Handle expired sessions consistently.
- Never store the Admin password or session cookie in local storage, shared preferences, or browser-accessible state.

## 6. Freezed models and API mapping
- Keep API models immutable and separate from UI state where that improves clarity.
- Include `fromJson`/`toJson` only when required by the API direction.
- Use explicit JSON key mappings when backend uses snake_case.
- Parse timestamps safely and consistently as UTC/ISO-8601.
- Model nullable fields intentionally; do not force unwrap optional API values.
- Handle unknown enum values defensively (e.g. `UNKNOWN`) so a new backend enum does not crash the app.
- Never edit generated `.freezed.dart` or `.g.dart` files manually.

After creating or changing a Freezed/JSON-serializable model, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## 7. UI states and responsive behavior
- Use Material 3 `ColorScheme` and `TextTheme` from the app theme.
- Use a consistent spacing scale and radius system defined in theme/constants.
- Use breakpoints from a central responsive utility; do not scatter magic width values.
- Desktop: sidebar + ticket list + ticket detail when sufficient width is available.
- Mobile: drawer/navigation + ticket list; open detail as a separate route/page.
- Tablet: adapt panels based on available width rather than assuming desktop.
- Use `LayoutBuilder`/MediaQuery appropriately; avoid device-type assumptions.
- Use `ListView.builder`/`ListView.separated` for long lists.
- Provide loading, empty, error-with-retry, and disabled-action states.
- Ensure keyboard navigation, focus visibility, semantic labels, and adequate contrast.
- Avoid excessive animation, nested scrolling, oversized cards, and unnecessary rebuilds.
- Extract widgets when a build method becomes difficult to understand; 80 lines is a warning threshold, not a mechanical rule.

## 8. Ticket UI rules
- Display status and category distinctly; do not rely on color alone.
- Use consistent status/category labels and icons.
- Sort message threads chronologically and distinguish customer, AI, and Admin messages.
- Render AI Markdown safely and handle malformed Markdown gracefully.
- Make escalation reason visible to the Admin, but never expose internal-only content to customer-facing views.
- Confirm destructive or irreversible actions where appropriate.
- Show success/failure feedback for Admin actions.
- Keep selected ticket/filter state predictable across refresh and navigation.

## 9. Testing and definition of done
- Unit-test repositories with mocked Dio responses and error cases.
- BLoC tests for loading/success/empty/error/filter/refresh/action transitions.
- Widget tests for responsive layout, empty/error states, and key interactions.
- Test auth guard behavior for unknown, authenticated, unauthenticated, expired, and forbidden states.
- Test cookie credentials configuration in web integration/manual verification; Dart unit tests alone cannot prove browser cookie policy works.
- Run:
```bash
dart format .
flutter analyze
flutter test
```
- Report any tests not run and why. Do not claim browser session behavior is verified without a browser-level test.
