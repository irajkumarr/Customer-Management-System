# Skill: Enterprise Dashboard Design

## Purpose
Design coherent, information-dense enterprise SaaS interfaces for admin tools, customer management systems, helpdesks, and operational dashboards.

## Activation
Use for application shells, dashboard overview pages, sidebars, top bars, ticket queues, customer lists, analytics pages, and detail workspaces.

## Design principles
- Optimize for frequent, repeated work rather than marketing-style presentation.
- Prioritize scanability, predictable navigation, and low interaction cost.
- Use a stable application shell with clear active navigation.
- Keep page titles, context, filters, actions, and content in a consistent hierarchy.
- Use density intentionally: compact enough for work, spacious enough to scan.
- Avoid excessive cards, decorative gradients, oversized headings, and unnecessary whitespace.
- Maintain a consistent layout across related modules.

## Application shell
Consider:
- Persistent sidebar on wide desktop layouts.
- Collapsible or compact navigation when space is limited.
- Top bar for global search, contextual actions, notifications, and account controls only when required.
- Clear page title and optional breadcrumb/context.
- Main content area with predictable horizontal alignment and max-width rules.
- Responsive navigation transformation for tablet and mobile rather than simple scaling.

## Dashboard overview
Use summary metrics only when they help users make decisions. Each metric should have:
- Clear label
- Meaningful value
- Relevant time range or scope
- Comparison or trend only when accurate and useful
- Accessible text equivalent; never rely only on color or chart shape

Avoid meaningless KPI cards, fake trends, decorative charts, and redundant data visualizations.

## Helpdesk / customer management patterns
For ticket queues, consider:
- Search and filter controls near the list they affect.
- Clear status, priority, category, assignee, and updated-time presentation.
- Saved views only if supported by product requirements.
- Row selection and bulk actions with clear selection feedback.
- A detail workspace that preserves list context where appropriate.
- Conversation chronology with clear sender identity and timestamps.
- Internal notes visually distinct from customer-visible replies.
- AI-generated suggestions clearly identified and distinguishable from sent messages.
- Escalation and automation states explained in plain language.
- Confirmation for destructive or customer-impacting actions.

Do not assume features such as teams, multiple agents, SLA timers, or role permissions unless the product specification confirms them.

## Responsive behavior
- Desktop: use available width for navigation, list/detail layouts, and operational context.
- Tablet: reduce secondary columns and allow navigation to collapse.
- Mobile: prioritize the main task; convert dense tables into readable cards or structured detail views where necessary.
- Never solve overflow by shrinking text to unreadable sizes.

## Quality checklist
- [ ] Navigation labels are clear and active location is obvious.
- [ ] Page title and key actions are easy to locate.
- [ ] Data density is balanced with readability.
- [ ] Filters and search are visibly associated with their results.
- [ ] Status and priority are understandable without color alone.
- [ ] Long content and narrow screens are handled intentionally.
- [ ] Repeated pages follow the same shell and spacing rules.
