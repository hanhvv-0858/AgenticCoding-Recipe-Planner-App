# Research: Recipe Planner App

**Feature**: 001-recipe-planner-app
**Date**: 2026-02-26
**Purpose**: Resolve all NEEDS CLARIFICATION items and document technology decisions

---

## 1. State Management: BLoC vs Provider vs Riverpod

### Decision: **flutter_bloc (BLoC pattern)**

### Rationale
- **Event-driven architecture** maps naturally to Clean Architecture use cases — each user action is an event, each response is a state.
- **Predictable state transitions** with `Bloc<Event, State>` make debugging offline/online state switches straightforward.
- **First-class testing** via `bloc_test` package — `blocTest()` provides `act`, `expect`, `verify` pattern that validates state sequences.
- **Mature ecosystem** — flutter_bloc 8.x is stable, widely adopted, and well-documented with Clean Architecture examples.
- **Separation of concerns** — BLoC naturally sits in the presentation layer without leaking into domain or data layers.

### Alternatives Considered
| Alternative | Pros | Rejected Because |
|-------------|------|------------------|
| Provider | Simpler API, less boilerplate | Lacks structured state transitions for complex async flows (offline queue → sync → conflict resolution). State management becomes ad-hoc as complexity grows. |
| Riverpod | Compile-time safety, auto-dispose, no BuildContext dependency | Newer ecosystem, less established patterns with Clean Architecture. Code generation dependency (riverpod_generator) adds build complexity. |
| GetX | Minimal boilerplate, built-in navigation | Violates separation of concerns principle. Mixes state, routing, and DI in ways that conflict with Clean Architecture. Poor testability. |

### Implementation Notes
- Use `Cubit` for simple screens (Profile, Settings) where event-driven pattern is overkill.
- Use `Bloc` for complex features (Home search/filter, Planner drag-drop, Grocery sync).
- Use `BlocObserver` globally for logging all state transitions (constitution: "Every data-mutating operation MUST be logged").
- Use `HydratedBloc` for persisting BLoC state across app restarts where needed (e.g., grocery list checked state).

---

## 2. Offline Storage: drift vs sqflite vs Hive vs Isar

### Decision: **drift (formerly moor)**

### Rationale
- **Type-safe SQL** — drift generates Dart code from SQL table definitions, providing compile-time query validation.
- **Reactive streams** — `watch()` queries return `Stream<List<T>>` that automatically update UI when data changes, integrating cleanly with BLoC.
- **Migration support** — drift provides structured schema migrations (constitution: "Database migrations MUST be backward-compatible").
- **Complex queries** — supports JOINs, aggregations, and subqueries needed for grocery list merging and nutrition calculations.
- **Testing** — in-memory database support for fast unit tests without I/O.

### Alternatives Considered
| Alternative | Pros | Rejected Because |
|-------------|------|------------------|
| sqflite | Direct SQLite access, lightweight | No type safety, no reactive streams, manual serialization. Raw SQL strings are error-prone and hard to test. |
| Hive | Fast key-value store, no native deps | Not suitable for relational data (recipes ↔ ingredients ↔ meal slots). No SQL queries for complex aggregations. |
| Isar | Fast, full-text search, reactive | Less mature migration story. NoSQL-style queries don't map well to relational recipe data. Smaller community. |

### Implementation Notes
- Define tables in `lib/core/database/` shared across features.
- Each feature's `local_datasource` uses drift DAOs (Data Access Objects).
- Migration strategy: increment schema version, provide `MigrationStrategy` with `onUpgrade` steps.
- Use drift's `transaction()` for atomic operations (e.g., saving meal plan + updating grocery list).

---

## 3. Supabase Integration Architecture

### Decision: **Hybrid — Flutter → Next.js API for business logic; Flutter → Supabase Auth directly**

### Rationale
- **Authentication**: supabase_flutter provides native Auth integration (email/password, session management, token refresh) without proxying through Next.js. This reduces latency and simplifies the auth flow.
- **Data operations**: All CRUD operations go through Next.js API routes. This keeps business logic (grocery merging, trending algorithm, search scoring) server-side and allows Supabase service role key to stay on the server.
- **File storage**: Recipe images stored in Supabase Storage. Flutter uploads via Next.js API (which handles compression validation and virus scanning).
- **Realtime**: Not required for v1. If added later, Supabase Realtime can be consumed directly from Flutter.

### Architecture Diagram
```
┌─────────────────────┐
│   Flutter App        │
│  ┌────────────────┐  │
│  │ Supabase Auth   │──────────► Supabase Auth (direct)
│  │ (supabase_flutter)│  │
│  └────────────────┘  │
│  ┌────────────────┐  │
│  │ API Client      │──────────► Next.js API Routes ──► Supabase DB
│  │ (http/dio)     │  │         (business logic)       (PostgreSQL)
│  └────────────────┘  │
│  ┌────────────────┐  │
│  │ Local DB        │  │
│  │ (drift/SQLite)  │  │
│  └────────────────┘  │
└─────────────────────┘
```

### Implementation Notes
- Flutter passes Supabase JWT in `Authorization: Bearer <token>` header to Next.js.
- Next.js middleware validates JWT using Supabase's `getUser()` server-side.
- Guest mode: Flutter operates entirely on local drift database. No API calls until account creation.
- Sync strategy: On login/reconnect, local changes are pushed to Next.js API. Server responds with latest data. Last-write-wins based on `updated_at` timestamps.

---

## 4. Next.js Backend Design

### Decision: **Next.js 14+ App Router with Route Handlers**

### Rationale
- **App Router** is the current standard for Next.js, providing better performance and simpler API route organization.
- **Route Handlers** (`route.ts`) provide clean RESTful endpoints organized by resource.
- **Edge-compatible** — can deploy on Vercel Edge for low-latency API responses.
- **TypeScript-first** with Zod for request validation ensures type safety end-to-end.

### API Design Principles
1. **RESTful resources**: `/api/recipes`, `/api/meal-plans`, `/api/grocery`
2. **Consistent error format**: `{ error: string, code: string, details?: object }`
3. **Pagination**: Cursor-based pagination for recipe lists (`?cursor=<id>&limit=20`)
4. **Filtering**: Query parameters for search (`?q=salmon&maxTime=30&maxCalories=500`)
5. **Authentication**: All mutable endpoints require valid Supabase JWT. Read endpoints support anonymous access for public recipes.

### Implementation Notes
- Use `@supabase/supabase-js` with service role key for server-side operations.
- Use Zod schemas for request body and query parameter validation.
- Implement rate limiting middleware for auth endpoints.
- Grocery merge algorithm: aggregate ingredients by normalized name + unit, sum quantities, track source recipes.

---

## 5. Offline Sync Strategy

### Decision: **Queue-based sync with last-write-wins conflict resolution**

### Rationale
- Constitution requires offline-capable (NON-NEGOTIABLE).
- Users interact with meal plans and grocery lists in locations with poor connectivity (kitchen, grocery store).
- Last-write-wins is simple, predictable, and sufficient for single-user data (meal plans, cookbook, grocery lists are personal — no collaborative editing).

### Sync Architecture
```
                  ┌──────────────────┐
                  │   Sync Queue     │
                  │  (drift table)   │
                  └──────┬───────────┘
                         │
    ┌────────────────────┼────────────────────┐
    │                    │                     │
    ▼                    ▼                     ▼
CREATE/UPDATE/DELETE   On Reconnect          On Conflict
 → Write to local DB   → Process queue       → Compare updated_at
 → Add to sync queue    → POST/PUT/DELETE     → Keep latest
 → Update UI instantly    to Next.js API      → Notify user if merge
                       → On success: dequeue
                       → On failure: retry with backoff
```

### Implementation Notes
- `SyncQueue` drift table: `id`, `entity_type`, `entity_id`, `operation` (create/update/delete), `payload` (JSON), `created_at`, `retry_count`.
- `SyncBloc` manages queue processing: listens to connectivity changes, processes queue in FIFO order.
- Max retry: 3 attempts with exponential backoff (1s, 4s, 16s). After max retries, mark as failed and notify user.
- Conflict notification: show a snackbar "Your [meal plan/grocery list] was updated on another device" with option to review.

---

## 6. Authentication Flow

### Decision: **Supabase Auth (email/password) with local session persistence**

### Rationale
- Supabase Auth provides email/password authentication out of the box with JWT tokens.
- `supabase_flutter` handles session persistence, token refresh, and auth state changes natively.
- No need for a separate auth service or custom JWT implementation.
- Constitution requires guest mode — app works without auth, enabling account later syncs local data.

### Auth Flow
```
Guest Mode:
  App Launch → Check local session → No session → Guest mode (local only)

Registration:
  Enter email + password → supabase.auth.signUp() → JWT received
  → Upload local data to server → Switch to synced mode

Login:
  Enter email + password → supabase.auth.signInWithPassword() → JWT received
  → Fetch remote data → Merge with local (last-write-wins) → Synced mode

Token Refresh:
  supabase_flutter handles automatically via refresh token
  → On failure → Prompt re-login → Preserve local data
```

### Implementation Notes
- Supabase JWT passed to Next.js in `Authorization` header.
- Next.js validates via `supabase.auth.getUser(token)` — no custom JWT parsing.
- Password requirements: minimum 8 characters (per spec FR-029).
- Error messages: generic "Invalid credentials" (per spec FR-031 — don't reveal which field is wrong).
- Guest-to-account migration: batch upload local data after signup, then enable sync queue.

---

## 7. Image Handling & Caching

### Decision: **Supabase Storage + cached_network_image + client-side compression**

### Rationale
- Recipe images stored in Supabase Storage buckets (public for recipe covers, private for user uploads).
- `cached_network_image` provides disk & memory caching with placeholder support.
- Constitution requires image compression client-side (<1 MB before upload).

### Implementation Notes
- Use `image_picker` for camera/gallery access (future: user recipe photos).
- Use `flutter_image_compress` to resize and compress before upload.
- Cache strategy: LRU cache with 100 MB disk limit. Cached images survive offline mode.
- Placeholder images: use shimmer effect during load, fallback to app icon on error.
- Supabase Storage bucket structure: `recipes/{recipe_id}/cover.webp`, `recipes/{recipe_id}/steps/{step_number}.webp`.

---

## 8. Grocery List Merge Algorithm

### Decision: **Server-side aggregation with normalization**

### Rationale
- Ingredient merging requires normalizing different representations ("garlic cloves" vs "clove of garlic") and compatible unit conversion.
- Server-side processing ensures consistency and can leverage PostgreSQL aggregation functions.
- Client caches the generated list locally for offline access.

### Algorithm
```
1. Fetch all meal plan slots for the selected week
2. For each slot with a recipe:
   a. Fetch recipe ingredients
   b. Multiply quantities by servings factor
3. Normalize ingredients:
   a. Lowercase ingredient name
   b. Strip plurals and articles
   c. Map unit aliases (tbsp → tablespoon, oz → ounce)
4. Group by (normalized_name, unit, category)
5. Sum quantities within each group
6. Track source recipes for attribution
7. Return grouped, sorted by category
```

### Implementation Notes
- Normalization dictionary maintained server-side (expandable).
- Categories: Vegetables, Fruits, Meat/Fish, Dairy, Spices, Grains, Canned, Frozen, Other.
- Manual items added by user get category "Other" unless user specifies.
- Edge case: incompatible units (e.g., "1 bunch parsley" + "2 tbsp parsley") — keep as separate entries with a note.

---

## 9. Navigation Architecture

### Decision: **go_router with ShellRoute for bottom navigation**

### Rationale
- `go_router` is the recommended Flutter navigation package, supporting declarative routing.
- `ShellRoute` pattern wraps the bottom navigation bar around tab content, preserving tab state.
- Deep linking support for future features (share recipe links, push notification deep links).

### Route Structure
```dart
GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: ...),
        GoRoute(path: '/cookbook', builder: ...),
        GoRoute(path: '/planner', builder: ...),
        GoRoute(path: '/grocery', builder: ...),
        GoRoute(path: '/profile', builder: ...),
      ],
    ),
    GoRoute(path: '/recipe/:id', builder: ...),       // Full-screen detail
    GoRoute(path: '/recipe/:id/cooking', builder: ...), // Cooking mode
    GoRoute(path: '/login', builder: ...),
    GoRoute(path: '/register', builder: ...),
  ],
);
```

### Implementation Notes
- Bottom nav preserves state per tab using `StatefulShellRoute.indexedStack`.
- Recipe detail and cooking mode are full-screen routes (no bottom nav).
- Auth guard: redirect to login only for profile-specific actions, not for guest browsing.
- Badge on Grocery tab: reactive count from `GroceryBloc` state.

---

## 10. Dependency Injection

### Decision: **get_it (service locator)**

### Rationale
- Simple, widely adopted service locator for Dart with no code generation required.
- Clean Architecture requires injecting repositories, use cases, BLoCs, and data sources — get_it handles this with lazy singletons and factories.
- Works well with flutter_bloc's `BlocProvider` for providing BLoCs to widget tree.

### Registration Strategy
```
// Singletons (one instance for app lifetime):
- Supabase client
- drift database
- NetworkInfo
- API client (http.Client)

// Lazy singletons (created on first access):
- Repositories (each feature)
- Data sources (remote + local, each feature)

// Factories (new instance each time):
- Use cases
- BLoCs (so each screen gets a fresh BLoC)
```

### Implementation Notes
- All DI registration in `lib/config/di/injection_container.dart`.
- Feature-level registration functions: `initAuthDI()`, `initHomeDI()`, etc.
- Call `await initDI()` in `main()` before `runApp()`.
- In tests: override registrations with mocks via `get_it.registerSingleton<T>(mockInstance)`.

---

## 11. Testing Strategy

### Decision: **Multi-layer testing aligned with Clean Architecture**

### Rationale
- Constitution requires TDD with ≥80% coverage on business logic.
- Clean Architecture enables isolated testing at each layer without mocking the whole app.

### Test Plan

| Layer | Tool | What to Test | Target Coverage |
|-------|------|-------------|-----------------|
| Domain (use cases) | flutter_test | Business logic, input validation, error mapping | ≥90% |
| Domain (entities) | flutter_test | Equality, serialization, computed properties | ≥90% |
| Data (repositories) | flutter_test + mockito | Remote/local switching, error handling, caching | ≥80% |
| Data (models) | flutter_test | JSON serialization/deserialization round-trips | 100% |
| Data (datasources) | flutter_test + mockito | API calls, DB queries, error mapping | ≥80% |
| Presentation (BLoC) | bloc_test | State transitions, event handling, error states | ≥90% |
| Presentation (widgets) | flutter_test | Widget rendering, user interaction, navigation | ≥70% |
| Integration | integration_test | Full flows: browse → plan → grocery | Key flows |
| Backend (Next.js) | jest + supertest | Route handlers, validation, merge algorithm | ≥80% |

### Implementation Notes
- Use `mocktail` (preferred over mockito — no code generation needed) for mocking.
- Test fixtures: JSON files in `test/fixtures/` matching API response shapes.
- BLoC tests: verify exact state sequence (Initial → Loading → Loaded/Error).
- Widget tests: use `BlocProvider` with fake BLoCs (no mocking, just emit states).

---

## 12. Performance Optimization

### Decision: **Lazy loading + pagination + image caching**

### Key Strategies
1. **List virtualization**: Flutter's `ListView.builder` and `SliverList` for recipe grids (only renders visible items).
2. **Pagination**: Load 20 recipes per page, infinite scroll with cursor-based pagination.
3. **Image caching**: `cached_network_image` with 100 MB disk cache + memory cache.
4. **Startup optimization**: 
   - Minimal work in `main()` — only DI setup and route initialization.
   - Defer heavy operations (sync check, analytics) to post-first-frame callback.
   - Use `compute()` isolate for JSON parsing of large recipe lists.
5. **Parallax performance**: Use `SliverAppBar` with `flexibleSpace` for recipe detail parallax — Flutter handles this natively at 60 fps.
6. **Database performance**: drift batched inserts for sync, indexed columns for queries (`recipe.title`, `ingredient.name`, `meal_plan.date`).
