# Recipe Planner App – Meal Plan & Grocery List

A cross-platform mobile app (iOS & Android) for recipe discovery, weekly meal planning, and automated grocery list generation.

Built with **Flutter** (Clean Architecture + BLoC) as the mobile client, **Next.js** (App Router) as the backend API, and **Supabase** (PostgreSQL + Auth) as the database and authentication layer.

---

## Features

| Feature | Description |
|---------|-------------|
| **Home & Discovery** | Search bar with filters (ingredient, time, calories), trending recipe grid, tag-based filtering, "Next Meal" sticky card |
| **Recipe Detail** | Parallax cover image, quick info (time, calories, rating), Ingredients tab with servings adjuster & checkboxes, Steps tab with media, "Start Cooking" mode |
| **Meal Planner** | 7-day horizontal calendar strip, 4 meal slots per day (Breakfast, Lunch, Dinner, Snack), recipe picker, quick notes, daily nutrition summary |
| **Grocery List** | Auto-generated from meal plan, smart ingredient merging, category grouping, check-off items, "Clear Completed", share via native share sheet, manual item entry |
| **My Cookbook** | Save/unsave recipes, browse personal collection |
| **Authentication** | Email/password registration & login, guest/offline mode, cloud sync for signed-in users, guest-to-account data migration |
| **Offline Support** | Full offline functionality with local SQLite (drift), sync queue with last-write-wins conflict resolution |

---

## Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| **Mobile App** | Flutter (Dart) | 3.41+ / Dart 3.11+ |
| **State Management** | flutter_bloc | ^8.1.6 |
| **Navigation** | go_router | ^14.2.0 |
| **Local Database** | drift (SQLite) | ^2.18.0 |
| **DI** | get_it | ^7.7.0 |
| **Backend API** | Next.js (App Router) | 14.2.5 |
| **Language** | TypeScript | ^5.5.4 |
| **Validation** | Zod | ^3.23.8 |
| **Database** | Supabase (PostgreSQL) | — |
| **Auth** | Supabase Auth | — |
| **Testing** | flutter_test, bloc_test, Jest, ts-jest | — |

---

## Project Structure

```
├── app/                        # Flutter mobile app
│   ├── lib/
│   │   ├── core/               # Shared modules
│   │   │   ├── constants/      # API URLs, app constants
│   │   │   ├── database/       # Drift (SQLite) database setup
│   │   │   ├── error/          # Failure types, exceptions
│   │   │   ├── l10n/           # Localization / i18n
│   │   │   ├── network/        # Dio HTTP client, interceptors
│   │   │   ├── sync/           # Offline sync queue
│   │   │   ├── theme/          # App theme, colors, text styles
│   │   │   ├── usecases/       # Base use-case contract
│   │   │   ├── utils/          # Helpers, formatters
│   │   │   └── widgets/        # Reusable UI components
│   │   ├── features/           # Feature modules (Clean Architecture)
│   │   │   ├── auth/           # Login, register, auth BLoC
│   │   │   ├── cookbook/        # Personal saved recipes
│   │   │   ├── grocery/        # Grocery list management
│   │   │   ├── home/           # Home screen & recipe browsing
│   │   │   ├── planner/        # Weekly meal planner
│   │   │   ├── profile/        # User profile & settings
│   │   │   ├── recipe_detail/  # Recipe detail with ingredients & steps
│   │   │   └── shell/          # Bottom navigation shell
│   │   ├── config/
│   │   │   ├── routes/         # go_router configuration
│   │   │   └── di/             # get_it dependency injection
│   │   └── main.dart
│   ├── test/                   # Unit & widget tests
│   └── integration_test/       # End-to-end tests
│
├── backend/                    # Next.js API server
│   ├── src/
│   │   ├── app/api/            # Route handlers
│   │   │   ├── auth/           # /api/auth (register, login, me)
│   │   │   ├── recipes/        # /api/recipes (CRUD, search, trending)
│   │   │   ├── tags/           # /api/tags
│   │   │   ├── cookbook/        # /api/cookbook (save/unsave)
│   │   │   ├── users/          # /api/users/profile
│   │   │   ├── meal-plans/     # /api/meal-plans (CRUD, slots)
│   │   │   └── grocery/        # /api/grocery (generate, manage)
│   │   └── lib/                # Shared utilities
│   │       ├── middleware/     # Auth middleware, error handling
│   │       ├── supabase/       # Supabase client config
│   │       ├── utils/          # Helpers, response builders
│   │       └── validators/     # Zod schemas, input validation
│   ├── scripts/                # Utility scripts (migration, API tests)
│   ├── supabase/
│   │   ├── migrations/         # PostgreSQL schema & RLS policies
│   │   ├── seed.sql            # Sample data (recipes, tags, ingredients)
│   │   └── update_images.sql   # Image URL update script
│   └── tests/unit/             # Jest unit tests
│
└── specs/                      # Feature specifications & documentation
    └── 001-recipe-planner-app/
        ├── spec.md             # Feature specification
        ├── plan.md             # Technical implementation plan
        ├── data-model.md       # Entity relationships & DB schema
        ├── tasks.md            # Task breakdown (174 tasks)
        ├── research.md         # Technical research & decisions
        ├── quickstart.md       # Quickstart guide
        ├── contracts/          # API contracts (auth, recipes, grocery, meal-plans)
        └── checklists/         # Requirements checklists
```

---

## Prerequisites

| Tool | Version | Installation |
|------|---------|-------------|
| **Flutter SDK** | 3.41+ | [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) |
| **Dart** | 3.11+ | Included with Flutter SDK |
| **Node.js** | 20+ | `brew install node` or [nodejs.org](https://nodejs.org) |
| **npm** | 10+ | Included with Node.js |
| **Supabase CLI** | Latest | `brew install supabase/tap/supabase` (optional) |
| **Xcode** | 15+ | Mac App Store (for iOS builds) |
| **Java JDK** | 21 | `brew install openjdk@21` (for Android builds) |
| **Android SDK** | 36 | See [Android Setup](#android-development-setup) below |
| **Git** | Latest | `brew install git` |

---

## Getting Started

### 1. Clone the Repository

```bash
git clone <repo-url>
cd AgenticCoding-Recipe-Planner-App
```

### 2. Supabase Setup

#### Option A: Supabase Cloud

1. Create a project at [supabase.com](https://supabase.com)
2. Run the SQL migrations in order from `backend/supabase/migrations/` in the Supabase SQL Editor:
   - `001_initial_schema.sql` — Tables, RLS policies, functions
   - `002_add_missing_functions.sql` — Additional database functions
3. Optionally run `backend/supabase/seed.sql` for sample data
4. Copy your project URL and keys for the next steps

#### Option B: Supabase Local

```bash
# Install Supabase CLI
brew install supabase/tap/supabase

# Start local Supabase (from backend/ directory)
cd backend
supabase init
supabase start

# Apply migrations
supabase db push

# Dashboard: http://localhost:54323
# API URL:   http://localhost:54321
# Keys are printed in terminal output
```

### 3. Backend Setup (Next.js)

```bash
cd backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env.local
```

Edit `.env.local` with your Supabase credentials:

```env
NEXT_PUBLIC_SUPABASE_URL=<your-supabase-url>
SUPABASE_SERVICE_ROLE_KEY=<your-service-role-key>
SUPABASE_JWT_SECRET=<your-jwt-secret>
SUPABASE_ANON_KEY=<your-anon-key>
```

Start the development server:

```bash
npm run dev
# → API available at http://localhost:3000/api
```

### 4. Flutter App Setup

```bash
cd app

# Install dependencies
flutter pub get

# Generate drift database & JSON serialization code
dart run build_runner build --delete-conflicting-outputs

# Create environment file
cp .env.example .env
```

Edit `.env` with your configuration:

```env
SUPABASE_URL=<your-supabase-url>
SUPABASE_ANON_KEY=<your-anon-key>
API_BASE_URL=http://localhost:3000/api
```

### 5. Android Development Setup

If you don't have Android Studio installed, you can set up the Android toolchain via command line:

```bash
# 1. Install Java JDK 21
brew install openjdk@21

# 2. Download Android command-line tools
mkdir -p ~/Library/Android/sdk
cd /tmp
curl -L -o cmdline-tools.zip "https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip"
unzip -o cmdline-tools.zip -d android-cmdline
mkdir -p ~/Library/Android/sdk/cmdline-tools/latest
cp -R android-cmdline/cmdline-tools/* ~/Library/Android/sdk/cmdline-tools/latest/

# 3. Set environment variables (add to ~/.zshrc for persistence)
export ANDROID_HOME=~/Library/Android/sdk
export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

# 4. Accept licenses & install SDK components
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0" \
  "emulator" "system-images;android-34;google_apis;arm64-v8a"

# 5. Configure Flutter
flutter config --android-sdk ~/Library/Android/sdk
flutter config --jdk-dir "$JAVA_HOME"
flutter doctor --android-licenses

# 6. Create an Android emulator (Pixel 7, API 34)
echo "no" | avdmanager create avd -n "Pixel_7_API_34" \
  -k "system-images;android-34;google_apis;arm64-v8a" -d "pixel_7" --force

# 7. Verify with flutter doctor
flutter doctor -v
# Should show: [✓] Android toolchain
```

### 6. Run the App

```bash
cd app

# Run on default connected device
flutter run

# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
# Start the emulator first:
emulator -avd Pixel_7_API_34 &
# Then run the app:
flutter run -d emulator-5554

# Run on a specific device (list devices first)
flutter devices
flutter run -d <device-id>
```

> **Note**: The app automatically detects the platform and adjusts the API URL.
> On Android emulator, `localhost` is replaced with `10.0.2.2` to reach the host machine's backend server.

---

## Running Tests

### Backend Tests (Jest)

```bash
cd backend

# Run all tests
npm test

# Watch mode
npm run test:watch

# With coverage report
npm run test:coverage
```

### Flutter Tests

```bash
cd app

# Run all unit & widget tests
flutter test

# Run with coverage
flutter test --coverage

# Generate HTML coverage report
lcov --remove coverage/lcov.info '*.g.dart' -o coverage/filtered.info
genhtml coverage/filtered.info -o coverage/html
open coverage/html/index.html

# Integration tests (requires emulator or device)
flutter test integration_test/
```

---

## Available Commands

### Flutter (`app/`)

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `dart run build_runner build --delete-conflicting-outputs` | Generate drift/JSON code |
| `dart run build_runner watch` | Watch & auto-generate code |
| `flutter test` | Run unit & widget tests |
| `flutter test --coverage` | Run tests with coverage |
| `flutter analyze` | Run static analysis (lint) |
| `dart format .` | Format Dart code |
| `flutter run` | Run app on connected device |
| `flutter build apk` | Build Android APK |
| `flutter build ios` | Build iOS app |
| `flutter test integration_test/` | Run integration tests |

### Backend (`backend/`)

| Command | Description |
|---------|-------------|
| `npm install` | Install dependencies |
| `npm run dev` | Start development server (port 3000) |
| `npm run build` | Production build |
| `npm start` | Start production server |
| `npm test` | Run Jest tests |
| `npm run test:watch` | Run tests in watch mode |
| `npm run test:coverage` | Run tests with coverage |
| `npm run lint` | Run ESLint |

---

## API Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register new user (email, password, display name) |
| POST | `/api/auth/login` | Sign in with email & password |
| GET | `/api/auth/me` | Get current authenticated user |

### Recipes

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/recipes` | List/search recipes (supports filters) |
| GET | `/api/recipes/[id]` | Get recipe detail with ingredients & steps |
| GET | `/api/recipes/trending` | Get trending recipes |
| GET | `/api/tags` | List all tags |

### Cookbook

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/cookbook` | List saved recipes |
| POST | `/api/cookbook/[recipeId]` | Save recipe to cookbook |
| DELETE | `/api/cookbook/[recipeId]` | Remove recipe from cookbook |

### Meal Plans

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/meal-plans` | Get meal plans (by date range) |
| POST | `/api/meal-plans` | Create meal plan |
| PUT | `/api/meal-plans/[id]` | Update meal plan |
| DELETE | `/api/meal-plans/[id]` | Delete meal plan |
| POST | `/api/meal-plans/[id]/slots` | Add meal slot |

### Grocery

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/grocery` | Get/generate grocery list |
| POST | `/api/grocery` | Add manual item |
| PATCH | `/api/grocery/[id]` | Check/uncheck item |
| DELETE | `/api/grocery/[id]` | Delete item |
| DELETE | `/api/grocery/clear` | Clear completed items |

### User Profile

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users/profile` | Get user profile |
| PUT | `/api/users/profile` | Update user profile |

---

## Architecture

### Flutter App – Clean Architecture

Each feature follows a 3-layer structure:

```
feature/
├── data/               # Implementation layer
│   ├── datasources/    # Remote (API) + Local (drift/SQLite) data sources
│   ├── models/         # Data transfer objects (JSON ↔ Dart)
│   └── repositories/   # Repository implementations
├── domain/             # Business logic layer
│   ├── entities/       # Core business objects
│   ├── repositories/   # Repository contracts (abstract)
│   └── usecases/       # Single-responsibility use cases
└── presentation/       # UI layer
    ├── bloc/           # BLoC (events, states, logic)
    ├── pages/          # Full-screen pages
    └── widgets/        # Reusable UI components
```

### Key Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| State Management | BLoC (flutter_bloc) | Complex async states, offline queues, testable |
| Local Database | drift (SQLite) | Type-safe SQL, reactive streams, migration support |
| DI | get_it | Simple service locator, no codegen |
| Navigation | go_router | Declarative routing, ShellRoute for bottom nav |
| API Client | dio | Interceptors for auth, retry, logging |
| Auth | Supabase Auth | Native Flutter integration, session management |
| Backend | Next.js API Routes | Business logic server-side, Supabase keys stay on server |

---

## Database Schema

The app uses 9 key entities stored in Supabase PostgreSQL with Row Level Security (RLS):

- **users** – User profiles (extends Supabase Auth)
- **recipes** – Recipe content (title, image, time, calories, rating)
- **ingredients** – Recipe ingredients (name, quantity, unit, category)
- **cooking_steps** – Step-by-step instructions with optional media
- **tags** – Curated recipe tags (#QuickLunch, #Healthy, etc.)
- **recipe_tags** – Many-to-many: recipes ↔ tags
- **cookbooks** – Personal saved recipes (user ↔ recipe)
- **meal_plans** – Daily meal plans per user
- **meal_slots** – Individual meal slots (Breakfast, Lunch, Dinner, Snack)
- **grocery_items** – Shopping list items with source attribution

See [specs/001-recipe-planner-app/data-model.md](specs/001-recipe-planner-app/data-model.md) for the full ER diagram and schema details.

---

## Environment Variables

### Backend (`backend/.env.local`)

| Variable | Required | Description |
|----------|----------|-------------|
| `NEXT_PUBLIC_SUPABASE_URL` | Yes | Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | Yes | Service role key (server-side only) |
| `SUPABASE_JWT_SECRET` | Yes | JWT secret for token verification |
| `SUPABASE_ANON_KEY` | Yes | Public/anonymous key |

### Flutter App (`app/.env`)

| Variable | Required | Description |
|----------|----------|-------------|
| `SUPABASE_URL` | Yes | Supabase project URL |
| `SUPABASE_ANON_KEY` | Yes | Public/anonymous key |
| `API_BASE_URL` | Yes | Backend API URL (e.g., `http://localhost:3000/api`) |

---

## Supported Platforms

| Platform | Status | Min Version | Device/Emulator |
|----------|--------|-------------|-----------------|
| **iOS** | ✅ Tested | iOS 15+ | iPhone 17 Simulator (iOS 26.2) |
| **Android** | ✅ Tested | API 23 (Android 6.0) | Pixel 7 Emulator (API 34) |
| **macOS** | ⚠️ Builds | macOS 12+ | Native desktop |
| **Web** | ⚠️ Builds | Chrome 90+ | Chrome browser |

---

## Platform-Specific Notes

### Android

- **minSdkVersion**: 23 (Android 6.0+)
- **targetSdkVersion**: 36 (Android 16)
- **Cleartext HTTP**: Enabled in AndroidManifest for local development (`android:usesCleartextTraffic="true"`)
- **API URL**: Automatically uses `10.0.2.2` on emulator to reach host `localhost`
- **Permissions**: `INTERNET`, `ACCESS_NETWORK_STATE`

### iOS

- **Deployment target**: iOS 15.0+
- **ATS**: `NSAllowsLocalNetworking` enabled for local development
- **CocoaPods**: Required for native dependencies

---

## Performance Targets

- **App startup**: < 2 seconds to display Home screen
- **API response**: < 200ms p95 response time
- **List scrolling**: 60 fps with no jank
- **App bundle**: < 100 MB

---

## Troubleshooting

### Android: "Unable to locate Android SDK"

```bash
flutter config --android-sdk ~/Library/Android/sdk
```

### Android: ClassNotFoundException / wrong package

Ensure `applicationId` and `namespace` in `app/android/app/build.gradle.kts` match the Kotlin package in `app/android/app/src/main/kotlin/`.

### Android emulator: Can't connect to backend API

The Android emulator uses `10.0.2.2` to access the host machine's `localhost`. The app handles this automatically via `ApiConstants`. Make sure the backend is running on port 3000.

### iOS: Cleartext HTTP blocked

Verify that `NSAppTransportSecurity` with `NSAllowsLocalNetworking = true` is set in `app/ios/Runner/Info.plist`.

### Flutter: `dart:io` not available on web

The `Platform.isAndroid` check in `api_constants.dart` uses `dart:io`, which is not available on web. If targeting web, override the API URL via dart-define:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api
```

---

## License

This project is private and not licensed for public distribution.
