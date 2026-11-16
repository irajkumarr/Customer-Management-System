# Skill: Product UX Design

## Purpose
Translate product requirements into clear, efficient, accessible user experiences before implementation. Use for new features, major workflow changes, navigation decisions, and UX reviews.

## Activation
Activate when a task changes what a user needs to accomplish, introduces a workflow, adds a screen, changes navigation, or creates confusing interactions.

## Operating principles
- Start with user goals and business outcomes, not visual styling.
- Prefer the simplest workflow that fully supports the task.
- Make the primary action and current system state obvious.
- Preserve established product conventions unless there is a clear usability reason to change them.
- Do not invent product requirements, permissions, or data.
- Distinguish confirmed requirements from assumptions and ask only when an unresolved decision blocks progress.

## Workflow
1. Inspect the existing feature, routes, screens, state, and relevant project documentation.
2. Identify the user, their goal, entry point, expected outcome, and likely failure cases.
3. Map the happy path and meaningful alternate paths.
4. Define information architecture and the content hierarchy.
5. Specify actions, feedback, validation, confirmations, and navigation outcomes.
6. Define states: initial, loading, populated, empty, filtered-empty, error, success, disabled, and permission-denied where relevant.
7. Consider keyboard use, screen-reader semantics, focus order, and responsive behavior.
8. Present a concise UX specification before substantial implementation.
9. After implementation, evaluate the real flow against the specification.

## UX specification template
For each feature, document:
- User goal
- Entry point
- Main workflow
- Primary and secondary actions
- Required information
- Validation and constraints
- Loading / empty / error / success states
- Navigation and back behavior
- Accessibility considerations
- Responsive considerations
- Open assumptions

## Quality checklist
- [ ] A first-time user can understand the purpose of the screen.
- [ ] The primary action is visually and semantically clear.
- [ ] The workflow avoids unnecessary steps and repeated data entry.
- [ ] Destructive or irreversible actions are clearly explained and confirmed.
- [ ] Feedback appears after user actions.
- [ ] Empty, loading, error, and success states are designed.
- [ ] Forms preserve user input when safe to do so.
- [ ] Keyboard and focus behavior are considered.
- [ ] The UX works at supported viewport sizes.

## Avoid
- Designing screens before understanding the workflow.
- Adding charts, cards, animations, or controls without a user need.
- Hiding important actions in obscure menus.
- Using color alone to communicate status.
- Treating a visually attractive screen as proof of good UX.
