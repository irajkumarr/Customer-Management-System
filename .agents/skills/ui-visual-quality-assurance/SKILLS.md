# Skill: UI Visual Quality Assurance

## Purpose
Review the actual rendered application and systematically improve visual quality, usability, and responsive behavior without unnecessary redesign.

## Activation
Use after implementing a screen, when a screenshot is supplied, during visual regression review, or before considering a UI feature complete.

## Required approach
1. Inspect the implemented screen and relevant design-system rules.
2. Obtain or use screenshots from the running application when available. Do not claim to have visually inspected a screen if no screenshot or rendering is available.
3. Compare the result against the UX specification and established design system.
4. Identify issues with evidence: location, visible symptom, and likely cause.
5. Rank issues by severity:
   - Critical: blocks task completion, inaccessible, or broken layout.
   - High: major hierarchy, navigation, readability, or responsive problem.
   - Medium: inconsistent spacing, alignment, or interaction feedback.
   - Low: minor polish that does not materially affect usability.
6. Propose the smallest set of changes that resolves the issues.
7. Implement fixes without changing unrelated features.
8. Re-check the affected screen and nearby states at relevant viewport sizes.

## Review dimensions
- Layout and alignment
- Visual hierarchy
- Typography and readability
- Spacing consistency
- Color and contrast
- Component consistency
- Navigation clarity
- Interaction feedback
- Data density and scanability
- Responsive behavior
- Accessibility
- Loading, empty, error, and success states

## Screenshot critique format
For each issue provide:
- Severity
- Exact location
- What is wrong
- Why it matters
- Recommended fix

Then provide:
- What is already working and should be preserved
- Prioritized fix plan
- Verification steps

## Guardrails
- Do not redesign a screen merely to make it look different.
- Do not invent screenshot details.
- Do not claim pixel-perfect comparison without a reference image and matching viewport.
- Do not add decorative elements to hide structural problems.
- Do not change product behavior while performing a visual-only refinement unless explicitly required.
- Prefer consistent design tokens over one-off values.

## Definition of done
A screen is not complete merely because it compiles. It must satisfy its UX requirements, render correctly at supported sizes, provide clear interaction feedback, and follow the project's design system.
