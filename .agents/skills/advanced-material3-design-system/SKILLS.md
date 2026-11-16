# Skill: Advanced Material 3 Design System

## Purpose
Create and maintain a reusable, consistent Material 3 design system for Flutter applications.

## Activation
Use when establishing or changing themes, tokens, typography, colors, component styles, or shared UI primitives.

## First inspect
1. Read the current theme and component structure.
2. Identify existing tokens and reusable widgets.
3. Check whether light and dark themes already exist.
4. Preserve established project conventions and avoid parallel theme systems.

## Design system requirements
Define semantic tokens rather than scattering raw values:
- Color roles: primary, on-primary, primary-container, secondary, tertiary, surface, surface-container levels, outline, error, and corresponding on-colors.
- Typography roles: display, headline, title, body, and label styles.
- Spacing scale: use a documented, consistent scale (for example 4, 8, 12, 16, 24, 32).
- Shape scale: small, medium, large, and extra-large with consistent use.
- Elevation and borders: subtle, purposeful, and consistent.
- Motion: restrained transitions with reduced-motion considerations.

Use Flutter `ThemeData`, `ColorScheme`, `TextTheme`, `ThemeExtension` where appropriate, and component themes. Prefer semantic theme references over hardcoded colors and dimensions.

## Component standards
Create reusable components only when they represent a repeated pattern or meaningful abstraction. Consider shared styles for:
- Buttons and icon buttons
- Text fields and form fields
- Cards and panels
- Dialogs and bottom sheets
- Menus and tooltips
- Chips and status indicators
- Tabs and navigation
- Data table controls
- Empty, loading, and error presentations

Components must expose appropriate configuration without becoming overly generic. Avoid giant widgets with many unrelated boolean flags.

## Visual rules
- Use hierarchy, alignment, contrast, and spacing before adding decoration.
- Use shadows sparingly; prefer surface and border hierarchy where appropriate.
- Use consistent corner radii.
- Ensure text and interactive controls meet accessible contrast and target-size expectations.
- Do not use color as the only status signal.
- Support light and dark modes only when required by the product, but design tokens so both can be supported cleanly.

## Implementation rules
- Do not introduce a second design system or duplicate tokens.
- Do not replace existing styling wholesale without inspecting current usage.
- Keep design tokens separate from feature-specific business logic.
- Use `const` where appropriate.
- Document non-obvious design decisions.
- Verify theme changes across representative screens, not just one widget.

## Quality checklist
- [ ] Components use semantic theme tokens.
- [ ] Typography hierarchy is consistent.
- [ ] Spacing and shape scales are documented.
- [ ] Interactive states are defined: hover, focus, pressed, disabled, loading.
- [ ] Light/dark behavior is coherent if both are supported.
- [ ] Contrast and target sizes are usable.
- [ ] No unnecessary duplicate components or magic values.
