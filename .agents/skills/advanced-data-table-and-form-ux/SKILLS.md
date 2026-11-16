# Skill: Advanced Data Table and Form UX

## Purpose
Design and implement reliable, efficient data tables, search/filter experiences, and business forms for management applications.

## Activation
Use for CRUD screens, ticket/customer lists, search, filtering, sorting, pagination, bulk actions, create/edit forms, and detail panels.

## Data table principles
- Make column selection reflect real user tasks.
- Prioritize key identifying information and current status.
- Use consistent alignment: text left, numeric values consistently aligned.
- Keep row height and density readable.
- Use clear headers and meaningful sort indicators.
- Keep search and filters close to the results they control.
- Show active filters and provide an easy way to clear them.
- Preserve filter and sort state when navigating back where appropriate.
- Use pagination or lazy loading for large datasets.
- Provide a useful empty state and a distinct no-results state.
- Provide loading feedback that does not cause unnecessary layout shifts.
- Make row actions discoverable; avoid too many always-visible icons.
- Confirm bulk and destructive actions, and show how many records are affected.

For responsive layouts, choose deliberately between horizontal scrolling, hiding lower-priority columns, or transforming rows into cards. Do not simply compress every column.

## Form principles
- Group related fields and use clear section headings only when helpful.
- Use labels that remain visible; do not rely only on placeholder text.
- Mark required fields clearly and explain validation expectations.
- Validate near the field and provide actionable error messages.
- Preserve entered data when safe after validation or network errors.
- Distinguish client-side validation from server-side errors.
- Disable submit only when the reason is clear; show progress during submission.
- Prevent accidental duplicate submissions.
- Use confirmation for consequential actions, not routine saves.
- Set sensible defaults only when they are safe and understandable.

## Search and filtering
- Debounce remote search when appropriate.
- Make clear whether search applies to the current page or all records.
- Support combining filters only when the backend supports the semantics.
- Reflect applied filters in the UI.
- Do not imply that a filter is active when it is not.
- Provide clear no-result guidance.

## Ticket-specific considerations
Where supported by requirements, present ticket subject, customer, status, priority, category, and updated time in a scannable manner. Make status and priority labels understandable in text, not color alone. Avoid inventing ticket fields or workflow states.

## Flutter implementation guidance
- Use project-standard table/list components.
- Keep presentation widgets separate from BLoC/Cubit logic.
- Use immutable state and stable keys.
- Keep sorting/filtering state explicit.
- Use lazy list construction for large result sets.
- Keep form validation and submission feedback consistent.
- Ensure focus moves sensibly after validation failures.

## Quality checklist
- [ ] Search, filters, sorting, and pagination behave as labelled.
- [ ] Active filters are visible and removable.
- [ ] Empty and no-results states differ.
- [ ] Table remains usable at narrow widths.
- [ ] Form labels and validation are clear.
- [ ] Submission progress and errors are communicated.
- [ ] Destructive and bulk actions are safe.
