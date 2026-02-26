# Quickstart: Recipe Planner App

**Feature**: 001-recipe-planner-app
**Date**: 2026-02-26

---

## Prerequisites

- **Flutter SDK** 3.24+ with Dart 3.x
- **Node.js** 20+ with npm/pnpm
- **Supabase CLI** (for local development)
- **Xcode** 15+ (for iOS builds)
- **Android Studio** / Android SDK API 26+
- **Git**

---

## 1. Clone & Setup

```bash
git clone <repo-url>
cd AgenticCoding-Recipe-Planner-App
git checkout 001-recipe-planner-app
```

---

## 2. Backend Setup (Next.js)

```bash
cd backend

# Install dependencies
npm install

# Copy environment template
cp .env.example .env.local

# Fill in Supabase credentials in .env.local:
# NEXT_PUBLIC_SUPABASE_URL=<your-supabase-url>
# SUPABASE_SERVICE_ROLE_KEY=<your-service-role-key>
# SUPABASE_JWT_SECRET=<your-jwt-secret>

# Run development server
npm run dev
# → Backend API available at http://localhost:3000/api
```

### Backend .env.local Variables

| Variable | Description |
|----------|-------------|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | Server-side service role key (never expose to client) |
| `SUPABASE_JWT_SECRET` | JWT secret for token verification |
| `SUPABASE_ANON_KEY` | Anonymous/public key |

---

## 3. Supabase Setup

### Option A: Supabase Cloud (recommended for team)

1. Create a project at [supabase.com](https://supabase.com)
2. Run SQL migrations from `backend/supabase/migrations/`
3. Copy project URL and keys to `.env.local` (backend) and app config (Flutter)

### Option B: Supabase Local (recommended for dev)

```bash
# Install Supabase CLI
brew install supabase/tap/supabase

# Start local Supabase
cd backend
supabase init
supabase start

# → Local Supabase dashboard at http://localhost:54323
# → API URL: http://localhost:54321
# → Anon Key and Service Role Key printed in terminal
```

### Database Seed

```bash
cd backend
# Apply migrations
supabase db push

# Seed sample data (recipes, tags, ingredients)
npm run db:seed
```

---

## 4. Flutter App Setup

```bash
cd app

# Install dependencies
flutter pub get

# Generate drift database code
dart run build_runner build --delete-conflicting-outputs

# Copy environment config
cp .env.example .env

# Fill in:
# SUPABASE_URL=<your-supabase-url>
# SUPABASE_ANON_KEY=<your-anon-key>
# API_BASE_URL=http://localhost:3000/api   (or production URL)
```

### Run on Simulator/Device

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Both (if connected)
flutter run
```

### Run Tests

```bash
# Unit + widget tests
flutter test

# With coverage
flutter test --coverage
lcov --remove coverage/lcov.info '*.g.dart' -o coverage/filtered.info
genhtml coverage/filtered.info -o coverage/html
open coverage/html/index.html

# Integration tests (requires emulator/device)
flutter test integration_test/
```

---

## 5. Backend Tests

```bash
cd backend

# Unit tests
npm test

# Watch mode
npm run test:watch

# Coverage
npm run test:coverage
```

---

## 6. Development Workflow

```bash
# 1. Create feature branch
git checkout -b <issue-number>-<short-description>

# 2. Write failing tests (TDD — constitution Principle III)
flutter test  # should fail

# 3. Implement feature
# 4. Run tests — all green
flutter test

# 5. Check formatting & lint
flutter analyze
dart format --set-exit-if-changed .

# 6. Create PR with at least 1 reviewer
```

---

## 7. Project Commands Reference

### Flutter (app/)

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `dart run build_runner build` | Generate drift/JSON serialization code |
| `dart run build_runner watch` | Watch & auto-generate code |
| `flutter test` | Run all tests |
| `flutter analyze` | Static analysis |
| `dart format .` | Format code |
| `flutter run` | Run app on connected device |
| `flutter build apk` | Build Android APK |
| `flutter build ios` | Build iOS app |

### Backend (backend/)

| Command | Description |
|---------|-------------|
| `npm install` | Install dependencies |
| `npm run dev` | Start dev server |
| `npm run build` | Production build |
| `npm test` | Run tests |
| `npm run lint` | Lint check |
| `npm run db:seed` | Seed sample data |

---

## 8. Key Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| State Management | BLoC (flutter_bloc) | Complex async states, testable, matches Clean Architecture |
| Local Database | drift (SQLite) | Type-safe SQL, reactive streams, migration support |
| DI | get_it | Simple service locator, no codegen, works with BLoC |
| Navigation | go_router | Declarative, ShellRoute for bottom nav, deep linking |
| API Client | dio | Interceptors for auth, retry, logging. More capable than http |
| Auth | Supabase Auth (direct) | Native Flutter integration, session management |
| Data Flow | Next.js API | Business logic server-side, Supabase key stays on server |

---

## 9. Folder Structure Quick Reference

```
backend/               ← Next.js API server
  src/app/api/         ← Route handlers (/recipes, /meal-plans, /grocery)
  src/lib/             ← Shared utilities, Supabase client
  tests/               ← Jest tests

app/                   ← Flutter mobile app
  lib/core/            ← Shared: errors, network, theme, constants
  lib/features/        ← Feature modules (Clean Architecture)
    {feature}/
      data/            ← Models, data sources, repository impl
      domain/          ← Entities, repository contracts, use cases
      presentation/    ← BLoC, pages, widgets
  lib/config/          ← DI, routing
  test/                ← Unit + widget tests
  integration_test/    ← E2E tests
```
