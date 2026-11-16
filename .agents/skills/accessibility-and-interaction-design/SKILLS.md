# Skill: Accessibility and Interaction Design

## Purpose
Ensure interfaces are understandable and operable for users with different abilities and input methods.

## Activation
Use for new UI components, forms, navigation, dialogs, interactive controls, status indicators, and final UX reviews.

## Core requirements
- Never communicate meaning through color alone; combine color with text, icon, or shape.
- Maintain sufficient text and non-text contrast.
- Provide visible keyboard focus.
- Ensure all interactive elements can be reached and operated with a keyboard where applicable.
- Use semantic labels and tooltips for icon-only actions.
- Maintain logical reading and focus order.
- Provide accessible names for controls and meaningful semantics for custom widgets.
- Respect text scaling; avoid fixed-height text containers that clip content.
- Avoid flashing, excessive motion, and motion that cannot be reduced where relevant.
- Use clear, plain-language labels and error messages.
- Do not rely on hover as the only way to reveal important actions.

## Interaction states
For interactive components, define:
- Default
- Hover (where pointer input applies)
- Focus
- Pressed
- Selected
- Disabled
- Loading
- Error or invalid
- Success where relevant

States should be visually distinguishable and consistent across the application.

## Forms and dialogs
- Associate labels and error messages with their fields.
- Make validation errors specific and actionable.
- Do not move focus unexpectedly.
- For dialogs, provide a clear title, purpose, actions, and predictable dismissal behavior.
- Ensure keyboard focus is managed appropriately when dialogs open and close.
- Do not use a destructive action as the visually dominant default without a clear reason.

## Flutter guidance
Use Flutter semantics where needed, meaningful widget labels, focus management, keyboard shortcuts only when useful, and theme-level focus styling. Verify with Flutter accessibility guideline checks where available and manually test keyboard navigation.

## Quality checklist
- [ ] Keyboard navigation is logical.
- [ ] Focus is visible.
- [ ] Icon-only controls have accessible labels.
- [ ] Status is not communicated by color alone.
- [ ] Text scaling does not clip content.
- [ ] Contrast is sufficient.
- [ ] Errors are associated with relevant controls.
- [ ] Touch targets are practical.
