# Skill: UI/UX Design and Material 3 for the Helpdesk Dashboard

## Purpose and product context
Design a professional, responsive Admin dashboard for the Customer Management System (AI Helpdesk). The primary user is a support Admin who triages tickets, reads customer conversations, reviews AI suggestions/escalations, and updates ticket status.

Design for clarity, speed, trust, and accessibility. This is an operational dashboard, not a marketing site.

## 1. Mandatory design workflow
1. Inspect existing screens, theme, components, routes, and responsive behavior before redesigning.
2. Identify the screen's primary task and information hierarchy.
3. Reuse established design tokens and components.
4. State the intended layout for desktop, tablet, and mobile before major UI changes.
5. Implement with Material 3 and real application data/state.
6. Verify loading, empty, error, long-content, and narrow-screen states.
7. Do not invent data, actions, or backend capabilities to make a mockup look complete.

## 2. Visual direction
- Clean, calm, professional SaaS support dashboard.
- Prioritize readable typography, whitespace, alignment, and clear hierarchy.
- Use Material 3 `ColorScheme` and `TextTheme`; avoid scattered hardcoded colors.
- Use a consistent 8-point spacing scale (8, 16, 24, 32, 40, 48) with smaller values only where necessary for dense controls.
- Define consistent shape/radius tokens (for example 8, 12, 16) centrally.
- Use elevation sparingly; rely on surface tones, borders, and spacing to group content.
- Keep status and category color semantics consistent across list, detail, filters, and badges.
- Avoid gradients, excessive shadows, glassmorphism, unnecessary animation, and decorative illustrations in operational views.

## 3. Information architecture
### Main dashboard
Prioritize:
1. Page title and key actions (refresh, logout/profile).
2. Useful ticket summary counts only if supported by API data.
3. Search and filters (status/category).
4. Ticket list with customer, subject, latest activity, status, and category.
5. Selected ticket detail/conversation when desktop width permits.

Do not crowd the screen with every possible metric. Summary cards must not push the ticket workflow below the fold.

### Ticket list
- Make subject and customer identity easy to scan.
- Show status and category as separate labels.
- Display a useful timestamp (e.g. latest activity) in a consistent format.
- Make selected/hover/focus states clear.
- Support long subjects and customer names without layout overflow.
- Provide empty states that explain whether there are no tickets or no filter matches.

### Ticket detail
- Show subject, customer details available from the API, current status/category, and permitted actions.
- Render the conversation in chronological order.
- Visually distinguish customer, AI, and Admin messages.
- Clearly mark AI-generated messages.
- Show escalation reason and relevant internal context only in the Admin interface.
- Keep the composer/actions clear if Admin replies are part of the implemented backend scope.
- Confirm destructive or irreversible actions.

## 4. Responsive behavior
Use available width, not device labels alone.

- **Desktop (approximately 1200px and above):** sidebar + ticket list + ticket detail where all panes remain usable.
- **Tablet (approximately 900–1199px):** compact/collapsible navigation and a two-pane or single-pane layout based on available width.
- **Mobile (below approximately 900px):** drawer/navigation and ticket list; navigate to ticket detail as a separate route.
- Keep breakpoints centralized and adjustable.
- Prevent horizontal overflow, clipped dialogs, tiny tap targets, and fixed-width panels that cannot shrink.
- Test long email addresses, long subjects, large message bodies, and empty/loading states at each breakpoint.

## 5. Interaction and feedback
- Provide clear hover, focus, pressed, selected, disabled, loading, and error states.
- Manual refresh must be visible and discoverable (AppBar refresh and pull-to-refresh where the platform interaction is appropriate).
- Do not add auto-refresh, polling, timers, or WebSockets.
- Disable duplicate submissions while an action is in progress.
- Give immediate feedback after successful/failed Admin actions.
- Use confirmation for consequential status changes where appropriate.
- Keep filters visible and make active filters easy to clear.
- Preserve sensible selection/filter state when refreshing.
- Avoid interactions that depend only on hover; mobile users must have equivalent access.

## 6. Material 3 implementation
- Define app-wide theme in a central theme file.
- Use `Theme.of(context).colorScheme` and `Theme.of(context).textTheme`.
- Use Material 3 components (`NavigationRail`, `NavigationDrawer`, `NavigationBar`, `Card`, `Chip`, `Badge`, `Dialog`, etc.) where they fit the interaction.
- Customize component themes centrally rather than styling every instance independently.
- Use `ColorScheme` semantic roles for success/warning/error/info states where the project defines them.
- Maintain sufficient contrast in light and dark themes if both are supported.
- Do not use deprecated Material APIs when a current equivalent exists.

## 7. Accessibility and content design
- Maintain readable contrast and text sizes.
- Provide semantics/tooltips for icon-only buttons.
- Ensure keyboard navigation and visible focus indicators.
- Do not rely on color alone for status/category.
- Use concise, action-oriented labels.
- Use consistent date/time formatting and relative-time labels where useful.
- Avoid unexplained abbreviations.
- Ensure dialogs and drawers have sensible focus behavior.
- Support text scaling without clipping.

## 8. UI state coverage
Every data-driven screen must define:
- Initial/loading state.
- Loaded state.
- Empty state.
- Error state with retry where retry is meaningful.
- Disabled/in-progress action state.
- Long-content and overflow behavior.

Never display raw exception text or stack traces. Never show fake tickets or placeholder metrics in production UI.

## 9. Definition of done
- The primary Admin workflow is immediately understandable.
- Desktop, tablet, and mobile layouts are usable.
- Material 3 tokens are used consistently.
- Ticket status and category remain distinguishable without color alone.
- Loading, empty, error, and long-content states are implemented.
- Keyboard and semantic accessibility have been considered.
- No unsupported feature or fake data has been added.
- Relevant widget tests and `flutter analyze` have been run and reported.
