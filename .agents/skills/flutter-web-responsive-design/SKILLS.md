# Skill: Flutter Web Responsive Design

## Purpose
Implement responsive, accessible, production-quality Flutter Web layouts for desktop-first business applications.

## Activation
Use for any Flutter Web page, application shell, responsive layout, breakpoint behavior, or browser-specific UI issue.

## Inspect before changing
- Current Flutter version and dependencies.
- Existing responsive utilities and breakpoints.
- Routing and shell layout.
- Current theme and shared widgets.
- Target viewport requirements and any browser-specific constraints.

## Responsive strategy
Use constraints and available width rather than device labels alone. Define and document project breakpoints; do not scatter unrelated breakpoint numbers through widgets. Example starting points (adjust to the project):
- Compact: below 600 logical pixels
- Medium: 600–1023 logical pixels
- Expanded: 1024 logical pixels and above

Use `LayoutBuilder`, `MediaQuery`, and existing project utilities appropriately. Avoid building separate duplicated screens when a shared responsive composition is possible.

## Layout behavior
- Expanded desktop: persistent sidebar, clear content max-width, appropriate multi-column layouts.
- Medium tablet: collapsible navigation, reduced secondary content, flexible columns.
- Compact mobile: compact navigation, single-column flow, touch-friendly controls.
- Use `Expanded`, `Flexible`, `Wrap`, constraints, and scroll views intentionally.
- Avoid fixed widths/heights for content that can grow.
- Prevent horizontal overflow; allow intentional horizontal scrolling only for content that genuinely requires it, such as wide data tables.
- Ensure dialogs and forms fit short viewports and remain scrollable.

## Web interaction and accessibility
- Support mouse, keyboard, and touch.
- Provide hover and focus feedback without making hover the only way to discover actions.
- Ensure logical tab order and visible focus indicators.
- Use tooltips for icon-only controls.
- Make clickable areas clear and sufficiently large.
- Avoid hover-only menus on touch devices.
- Handle browser resizing without layout breakage.

## Performance
- Avoid rebuilding large subtrees unnecessarily.
- Use lazy builders for long lists.
- Paginate or virtualize large datasets where appropriate.
- Avoid expensive effects and unnecessary animations.
- Keep images and assets appropriately sized.

## Verification
Test at representative widths, including:
- 375 px compact
- 768 px medium
- 1024 px expanded boundary
- 1440 px wide desktop

Also test:
- Long page titles
- Long customer names and email addresses
- Empty and very large datasets
- Open dialogs at short viewport heights
- Browser zoom and text scaling where feasible

## Quality checklist
- [ ] No overflow or clipped controls at supported widths.
- [ ] Navigation adapts intentionally.
- [ ] Tables remain usable on compact layouts.
- [ ] Forms and dialogs remain accessible.
- [ ] Keyboard, mouse, and touch interactions work.
- [ ] Text remains readable and does not become excessively small.
