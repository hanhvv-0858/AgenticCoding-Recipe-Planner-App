<!--
  Sync Impact Report
  ==================
  Version change: N/A → 1.0.0 (initial adoption)
  Modified principles: N/A (initial)
  Added sections:
    - Core Principles (5 principles)
    - Technology & Platform Constraints
    - Development Workflow
    - Governance
  Removed sections: N/A
  Templates requiring updates:
    - .specify/templates/plan-template.md ✅ compatible (no changes needed)
    - .specify/templates/spec-template.md ✅ compatible (no changes needed)
    - .specify/templates/tasks-template.md ✅ compatible (no changes needed)
  Follow-up TODOs: None
-->

# Recipe Planner App Constitution

## Core Principles

### I. Cross-Platform First

- The application MUST target both iOS and Android from a single
  shared codebase using a cross-platform framework (e.g., Flutter
  or React Native).
- Platform-specific code MUST be isolated behind clear abstraction
  boundaries (e.g., plugins, platform channels) and MUST NOT leak
  into shared business logic.
- Every feature MUST be validated on both iOS and Android before
  it is considered complete.
- UI components MUST respect each platform's design conventions
  (Material Design on Android, Human Interface Guidelines on iOS)
  while maintaining a consistent brand identity.

**Rationale**: A single codebase reduces duplication, accelerates
delivery, and ensures feature parity across platforms.

### II. Offline-Capable (NON-NEGOTIABLE)

- All core features — recipe browsing, meal plan viewing, and
  grocery list management — MUST function without an active
  network connection.
- Local data MUST be persisted using an embedded database (e.g.,
  SQLite, Hive, or Realm) so that users never lose access to
  their saved content.
- When connectivity is restored, the app MUST synchronize local
  changes with the remote backend using a conflict-resolution
  strategy (last-write-wins or merge, documented per entity).
- Network failures MUST be handled gracefully with clear user
  feedback; the app MUST NOT crash or show empty states due to
  connectivity issues.

**Rationale**: Users plan meals and shop in locations with
unreliable connectivity (kitchens, grocery stores). Offline
support is a core value proposition, not an enhancement.

### III. Test-First

- TDD cycle MUST be followed: write failing tests → implement →
  refactor.
- Unit tests MUST cover all business logic (recipe parsing, meal
  plan generation, grocery list aggregation).
- Widget/UI tests MUST cover critical user flows (add recipe,
  create meal plan, manage grocery list).
- Integration tests MUST verify data persistence round-trips and
  sync behavior.
- Minimum code coverage target: 80% for business logic modules.

**Rationale**: A meal-planning app handles user-created data that
is difficult to recover. Rigorous testing prevents data loss and
regression in core workflows.

### IV. User Data Integrity

- Recipe data, meal plans, and grocery lists MUST never be silently
  lost or corrupted.
- All destructive operations (delete recipe, clear meal plan) MUST
  require explicit user confirmation.
- The app MUST implement local backup/export capability so users
  can recover their data independently.
- Database migrations MUST be backward-compatible; schema changes
  MUST NOT destroy existing user data.
- Every data-mutating operation MUST be logged for debugging and
  audit purposes.

**Rationale**: Users invest significant effort curating recipes
and planning meals. Data loss erodes trust irreversibly.

### V. Simplicity & Performance

- Start with the simplest implementation that satisfies
  requirements. Apply YAGNI — do not build features speculatively.
- App startup MUST complete within 2 seconds on mid-range devices.
- List scrolling (recipes, meal plans, grocery items) MUST
  maintain 60 fps with no visible jank.
- Image loading MUST use lazy loading with placeholder thumbnails;
  full-resolution images MUST be cached locally.
- Dependencies MUST be justified. Each third-party package MUST
  solve a concrete problem that would take >1 day to implement
  in-house.
- Complexity (extra layers, abstractions, patterns) MUST be
  justified with a documented reason before introduction.

**Rationale**: Mobile users expect instant responsiveness. A lean
codebase is easier to maintain, debug, and onboard new
contributors to.

## Technology & Platform Constraints

- **Target Platforms**: iOS 15+ and Android 8.0+ (API level 26+).
- **Framework**: Cross-platform framework (Flutter recommended;
  React Native acceptable with documented justification).
- **Language**: Dart (Flutter) or TypeScript (React Native) for
  shared code; Swift/Kotlin for platform-specific modules only
  when required.
- **Local Storage**: Embedded database for structured data (SQLite,
  Hive, or Realm). File system for cached images.
- **Backend (if applicable)**: RESTful API or GraphQL. Backend
  technology is unconstrained but MUST provide OpenAPI/GraphQL
  schema documentation.
- **Authentication**: OAuth 2.0 / OpenID Connect for user accounts.
  The app MUST support a guest/offline-only mode without requiring
  sign-in for core features.
- **Image Handling**: Recipes MUST support photo attachments.
  Images MUST be compressed client-side before upload (max 1 MB).
- **Accessibility**: WCAG 2.1 AA compliance. All interactive
  elements MUST have accessible labels. Dynamic text sizing MUST
  be supported.
- **Internationalization**: Architecture MUST support localization
  from day one (externalized strings, RTL-ready layouts), even if
  only one locale is shipped initially.

## Development Workflow

- **Branching**: Trunk-based development with short-lived feature
  branches. Branch naming: `<issue-number>-<short-description>`.
- **Code Review**: Every pull request MUST be reviewed by at least
  one other contributor before merge.
- **CI Pipeline**: On every PR the CI MUST run linting, formatting
  checks, unit tests, widget tests, and static analysis. Builds
  for both iOS and Android MUST succeed.
- **Quality Gates**: PRs MUST NOT be merged if any of the
  following fail: tests, lint, formatting, or static analysis.
- **Release Process**: Semantic versioning (MAJOR.MINOR.PATCH).
  Release candidates MUST pass a manual smoke test on both
  physical iOS and Android devices before production release.
- **Documentation**: Public APIs, data models, and architectural
  decisions MUST be documented. ADRs (Architecture Decision
  Records) SHOULD be used for significant technical choices.

## Governance

- This constitution is the highest-authority document for the
  Recipe Planner App project. It supersedes all other process
  documents, style guides, and ad-hoc practices.
- All pull requests and code reviews MUST verify compliance with
  the principles defined above.
- Amendments to this constitution require:
  1. A written proposal describing the change and its rationale.
  2. Review and approval by at least one project maintainer.
  3. A migration plan if the change affects existing code or
     workflows.
  4. An updated version number following semantic versioning
     (MAJOR for principle removal/redefinition, MINOR for new
     principles/sections, PATCH for wording/clarification).
- A compliance review SHOULD be conducted at the start of each
  major feature cycle to ensure ongoing adherence.
- For day-to-day development guidance beyond this constitution,
  refer to the project README and docs/ directory.

**Version**: 1.0.0 | **Ratified**: 2026-02-26 | **Last Amended**: 2026-02-26
