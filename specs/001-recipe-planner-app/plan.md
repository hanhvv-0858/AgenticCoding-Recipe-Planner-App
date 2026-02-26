# Implementation Plan: Recipe Planner App – Meal Plan & Grocery List

**Branch**: `001-recipe-planner-app` | **Date**: 2026-02-26 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-recipe-planner-app/spec.md`

## Summary

A cross-platform mobile app (iOS & Android) for recipe discovery, weekly meal planning, and automated grocery list generation. Built with **Flutter** (Clean Architecture + BLoC) as the mobile client, **Next.js** (App Router) as the backend API, and **Supabase** (PostgreSQL + Auth + Storage) as the database and authentication layer. The app supports full offline functionality with local SQLite (drift) and syncs to Supabase when connectivity is restored.

## Technical Context

**Language/Version**: Dart 3.x (Flutter 3.24+), TypeScript 5.x (Next.js 14+)
**Primary Dependencies**:
- *Flutter*: flutter_bloc, go_router, drift (SQLite), supabase_flutter, get_it, dartz, cached_network_image, equatable, json_annotation
- *Next.js*: @supabase/supabase-js, zod, next-auth (optional, Supabase Auth primary)
**Storage**: Supabase (PostgreSQL) for cloud persistence; drift (SQLite) for local offline cache on Flutter
**Testing**: flutter_test + bloc_test + integration_test (Flutter); jest + supertest (Next.js)
**Target Platform**: iOS 15+, Android 8.0+ (API 26+); Next.js deployed on Vercel/Node.js server
**Project Type**: Mobile app (Flutter) + Backend API (Next.js)
**Performance Goals**: 60 fps list scrolling, <2s app startup, <200ms API p95 response time
**Constraints**: Offline-capable (NON-NEGOTIABLE per constitution), <100MB app bundle, cross-platform parity
**Scale/Scope**: ~25 screens, 9 key entities, 35 functional requirements, initial target user base

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| # | Principle | Status | Notes |
|---|-----------|--------|-------|
| I | Cross-Platform First | ✅ PASS | Flutter provides single Dart codebase for iOS & Android. Platform-specific code isolated via plugins. |
| II | Offline-Capable | ✅ PASS | Local SQLite via drift for all core data. Sync queue with last-write-wins conflict resolution on reconnect. |
| III | Test-First | ✅ PASS | TDD with bloc_test for BLoC logic, flutter_test for widgets, integration_test for E2E, jest for Next.js API. Target ≥80% coverage on business logic. |
| IV | User Data Integrity | ✅ PASS | Destructive ops require confirmation. drift migrations are backward-compatible. All mutations logged. |
| V | Simplicity & Performance | ⚠️ JUSTIFIED | Clean Architecture adds domain/data/presentation layers — justified below in Complexity Tracking. BLoC chosen over simpler Provider because of complex async state (offline queues, sync). |

**Technology Constraints Check**:
- iOS 15+ / Android 8.0+ ✅
- Cross-platform framework (Flutter) ✅
- Dart for shared code ✅
- Embedded database for offline (drift/SQLite) ✅
- Backend provides API documentation (OpenAPI via Next.js route types) ✅
- OAuth 2.0 / Supabase Auth with guest mode ✅
- Image compression client-side ✅
- Accessibility & i18n architecture ready ✅

## Project Structure

### Documentation (this feature)

```text
specs/001-recipe-planner-app/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (API contracts)
│   ├── api-overview.md
│   ├── auth.md
│   ├── recipes.md
│   ├── meal-plans.md
│   └── grocery.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
backend/                          # Next.js API (Backend)
├── src/
│   └── app/
│       └── api/                  # Next.js Route Handlers (App Router)
│           ├── auth/
│           │   ├── register/route.ts
│           │   ├── login/route.ts
│           │   └── me/route.ts
│           ├── recipes/
│           │   ├── route.ts              # GET (list/search), POST
│           │   ├── [id]/route.ts         # GET, PUT, DELETE
│           │   └── trending/route.ts     # GET
│           ├── tags/route.ts             # GET
│           ├── meal-plans/
│           │   ├── route.ts              # GET (by date range), POST
│           │   ├── [id]/route.ts         # PUT, DELETE
│           │   └── [id]/slots/route.ts   # POST, PUT, DELETE
│           ├── grocery/
│           │   ├── route.ts              # GET (generate), POST (manual)
│           │   ├── [id]/route.ts         # PATCH (check/uncheck), DELETE
│           │   └── clear/route.ts        # DELETE (clear completed)
│           ├── cookbook/
│           │   ├── route.ts              # GET (list saved)
│           │   └── [recipeId]/route.ts   # POST (save), DELETE (unsave)
│           └── users/
│               └── profile/route.ts      # GET, PUT
├── src/lib/
│   ├── supabase/
│   │   ├── client.ts             # Supabase server client
│   │   └── admin.ts              # Supabase admin client
│   ├── middleware/
│   │   └── auth.ts               # JWT verification middleware
│   ├── validators/               # Zod schemas
│   └── utils/
│       └── grocery-merge.ts      # Ingredient merging logic
├── tests/
│   ├── unit/
│   └── integration/
├── package.json
├── tsconfig.json
└── next.config.js

app/                              # Flutter Mobile App
├── lib/
│   ├── core/
│   │   ├── error/
│   │   │   ├── exceptions.dart          # ServerException, CacheException
│   │   │   └── failures.dart            # ServerFailure, CacheFailure
│   │   ├── network/
│   │   │   └── network_info.dart        # Connectivity checker
│   │   ├── usecases/
│   │   │   └── usecase.dart             # Base UseCase<Type, Params>
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   └── app_constants.dart
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       └── app_colors.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   │   └── auth_local_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── register.dart
│   │   │   │       ├── login.dart
│   │   │   │       └── get_current_user.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── auth_bloc.dart
│   │   │       │   ├── auth_event.dart
│   │   │       │   └── auth_state.dart
│   │   │       ├── pages/
│   │   │       │   ├── login_page.dart
│   │   │       │   └── register_page.dart
│   │   │       └── widgets/
│   │   ├── home/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── recipe_detail/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── cookbook/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── planner/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── grocery/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── profile/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   ├── config/
│   │   ├── routes/
│   │   │   └── app_router.dart          # go_router configuration
│   │   └── di/
│   │       └── injection_container.dart # get_it setup
│   └── main.dart
├── test/
│   ├── core/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── home/
│   │   ├── recipe_detail/
│   │   ├── cookbook/
│   │   ├── planner/
│   │   └── grocery/
│   └── fixtures/                        # JSON fixtures for testing
├── integration_test/
├── pubspec.yaml
└── analysis_options.yaml
```

**Structure Decision**: Mobile + API pattern selected. Flutter app follows Clean Architecture with feature-based modularization (auth, home, recipe_detail, cookbook, planner, grocery, profile). Each feature has data/domain/presentation layers. Next.js backend uses App Router API routes organized by resource. Supabase provides PostgreSQL database, authentication, and file storage.

## Complexity Tracking

> Constitution Principle V (Simplicity & Performance) — violations justified below.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Clean Architecture (3 layers per feature) | Offline-first requires separate data sources (remote API + local SQLite) with repository pattern to abstract the switch. Domain layer keeps business logic (grocery merge, nutrition calc, servings adjustment) testable without framework deps. | Direct data access would tightly couple offline cache, remote API, and UI — making the sync queue and conflict resolution untestable and fragile. |
| BLoC state management (over Provider) | Complex async states: loading/error/success per screen, offline queue management, real-time sync status. BLoC's event-driven model maps cleanly to these state transitions. | Provider is simpler but lacks structured state transitions for complex scenarios like "loading from cache while fetching remote + handling sync conflicts." |
| Separate Next.js backend (over direct Supabase) | Business logic (ingredient merging, trending algorithm, search scoring) belongs server-side. RLS alone doesn't cover complex aggregation queries. Next.js also serves as a security boundary — Supabase service key never touches the client. | Direct Supabase from Flutter works for simple CRUD but cannot handle complex server-side logic without Edge Functions, which have cold-start latency and limited debugging. |
