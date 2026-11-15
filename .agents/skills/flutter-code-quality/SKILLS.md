# Skill: Flutter Code Quality and Architecture Standards

## Purpose
Apply consistent, maintainable engineering practices across the Customer Management System Flutter Web codebase. These rules complement the feature-specific Flutter BLoC skill; they do not override the project plan or existing repository conventions.

## 1. Inspect before changing
- Read the relevant files and neighboring features before editing.
- Follow existing naming, dependency injection, routing, theme, and error-handling conventions.
- Make the smallest coherent change that solves the requested problem.
- Do not rename, move, or reformat unrelated files.
- Do not add a dependency for functionality already provided by the SDK or an installed package.

## 2. Naming and formatting
- Files and folders: `snake_case`.
- Classes, enums, typedefs: `PascalCase`.
- Variables, methods, parameters: `lowerCamelCase`.
- Constants: follow the repository convention; prefer `lowerCamelCase` for Dart constants unless an established project-wide convention says otherwise.
- Private members start with `_`.
- Use trailing commas for readable multiline Dart formatting.
- Run `dart format` rather than manually approximating formatter output.
- Import order: Dart SDK, Flutter SDK, third-party packages, then project-relative imports. Keep ordering consistent with `dart format`/lint tooling and existing conventions.

## 3. Widget design
- Prefer `const` constructors and `const` child widgets when values are compile-time constants.
- Prefer `StatelessWidget`; use `StatefulWidget` only for local ephemeral UI state.
- Keep business logic and network access out of widgets.
- Extract a widget when it has a clear responsibility, is reused, or makes its parent difficult to read.
- Do not split every three lines into a separate widget; avoid excessive fragmentation.
- Avoid declaring complex closures, data transformations, or business rules inside `build()`.
- Never trigger network requests or dispatch BLoC events directly from `build()`.
- Use stable keys for reorderable/stateful list items when identity matters.
- Use `ListView.builder` or `ListView.separated` for large/unknown-length lists.

## 4. State and immutability
- Keep feature state immutable.
- Use BLoC/Cubit for shared or asynchronous feature state; use local widget state for small transient interactions.
- Do not mutate lists/maps held by state. Create new immutable values.
- Keep derived UI values derived rather than storing duplicate state.
- Avoid global mutable singletons.
- Use `BlocSelector`/`buildWhen` only when they improve measured or obvious rebuild behavior; do not optimize blindly.

## 5. Clean Architecture and error handling
Clean Architecture is required for feature development. Use the following dependency flow:

```text
Presentation (Pages / Widgets / BLoC-Cubit)
                 |
                 v
Domain (Use cases / Entities / Repository contracts)
                 ^
                 | implements
Data (Repository implementations / Models / Data sources)
```

- Domain is pure Dart and framework-independent. It must not import Flutter, BLoC, Dio, JSON serialization, or data-layer classes.
- Put entities, repository interfaces, and meaningful use cases in each feature's `domain/` directory.
- Put DTO/API models, data sources, model-to-entity mapping, and repository implementations in `data/`.
- Put BLoCs/Cubits, states, events, pages, and widgets in `presentation/`. BLoCs/Cubits depend on domain use cases/contracts, never on Dio or concrete data sources.
- Widgets communicate through BLoC/Cubit and must not call repositories, use cases, data sources, or Dio directly.
- Repository interfaces belong to the domain layer; their implementations belong to the data layer.
- Wire implementations and dependencies in the app composition root/DI setup. Do not resolve dependencies from a global service locator inside widgets or business logic.
- Keep API models separate from domain entities when their responsibilities or shapes differ. Convert external data into domain entities at the data boundary.
- Add use cases for meaningful business actions and orchestration. Avoid pointless one-line wrappers that add no policy, validation, or abstraction value.
- Shared `core/` code must be truly cross-feature; feature-specific rules remain inside that feature.
- UI -> BLoC/Cubit -> use case -> domain repository contract; data repository implementation -> data source.
- Widgets display user-friendly failures; they do not interpret raw Dio exceptions.
- Data repositories translate transport/parsing failures into typed domain/app failures.
- Preserve useful diagnostic causes internally without exposing stack traces or server internals to users.
- Do not swallow exceptions silently.
- Use `BlocListener` for navigation, dialogs, and snackbars; builders should remain declarative.
- Every async operation must have explicit loading/success/failure behavior.
- Empty data is not automatically an error.

## 6. Async safety and lifecycle
- Avoid updating state after a Cubit/Bloc/controller has been closed.
- Cancel or ignore stale requests where a newer query/filter supersedes an older one.
- Dispose `TextEditingController`, `ScrollController`, `FocusNode`, and animation controllers.
- Do not create timers, streams, or subscriptions in `build()`.
- Do not introduce polling for this project; dashboard synchronization is manual refresh.
- Use debouncing only for search inputs that actually trigger remote requests.

## 7. UI and accessibility
- Use theme tokens instead of hardcoded colors, typography, spacing, and radii.
- Do not use color as the only indicator of ticket status/category.
- Provide tooltips or semantic labels for icon-only actions.
- Ensure focus states and keyboard operation for interactive controls.
- Support text scaling and avoid fixed heights that clip content.
- Use responsive constraints rather than hardcoded device assumptions.
- Handle loading, empty, error, and success states consistently.
- Avoid decorative animations that make a business dashboard slower or harder to use.

## 8. Performance
- Use lazy lists for long collections.
- Avoid expensive computation in `build()`.
- Cache only when there is a clear invalidation strategy.
- Use image caching only for actual network-image use cases.
- Avoid unnecessary `shrinkWrap: true` and nested scrollables.
- Do not introduce pagination or caching abstractions unless data size or product requirements justify them.
- Profile before applying complex performance optimizations.

## 9. Generated code and dependencies
- Never manually edit generated files (`*.g.dart`, `*.freezed.dart`).
- After changing Freezed/JSON models, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```
- Add dependencies only when needed; check compatibility with the project's Flutter/Dart SDK.
- Update lockfiles intentionally and explain significant dependency changes.
- Do not run broad dependency upgrades as part of an unrelated feature.

## 10. Code review checklist
Before finishing, check:
- Does the feature follow Clean Architecture and inward dependency direction?
- Is domain pure Dart and independent of Flutter/network/serialization frameworks?
- Are repository contracts in domain and implementations/data sources in data?
- Do BLoCs depend on use cases rather than Dio or concrete data sources?
- Are API models mapped to domain entities at the data boundary?
- Is each class responsible for one clear concern?
- Are names and types descriptive?
- Are nullable values handled safely?
- Are errors converted and displayed appropriately?
- Are async operations and controllers lifecycle-safe?
- Are widgets responsive and accessible?
- Are generated files generated rather than hand-edited?
- Did the change introduce duplicated logic, dead code, debug prints, secrets, or unrelated formatting?
- Did `dart format`, `flutter analyze`, and relevant tests run successfully?

Report commands and results honestly.
