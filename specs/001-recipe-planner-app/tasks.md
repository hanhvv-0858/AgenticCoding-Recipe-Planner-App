# Tasks: Recipe Planner App – Meal Plan & Grocery List

**Input**: Design documents from `/specs/001-recipe-planner-app/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Tests**: Constitution Principle III (Test-First) requires TDD. Tests are included per user story.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, …)
- Include exact file paths in descriptions

## Path Conventions

- **Backend (Next.js)**: `backend/`
- **Mobile App (Flutter)**: `app/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Initialize both projects, install dependencies, configure tooling

- [x] T001 Create Flutter project in `app/` with `flutter create --org com.recipeplanner app` and configure `app/pubspec.yaml` with dependencies: flutter_bloc, go_router, drift, supabase_flutter, get_it, dartz, cached_network_image, equatable, json_annotation, json_serializable, build_runner, dio, connectivity_plus, share_plus, flutter_image_compress
- [x] T002 Create Next.js project in `backend/` with `npx create-next-app@latest backend --typescript --app --eslint` and install dependencies: @supabase/supabase-js, zod, uuid; devDeps: jest, @types/jest, ts-jest, supertest, @types/supertest
- [x] T003 [P] Configure Flutter linting in `app/analysis_options.yaml` with strict rules (prefer_const_constructors, avoid_dynamic_calls, require_trailing_commas) and dart format settings
- [x] T004 [P] Configure ESLint + Prettier for Next.js in `backend/.eslintrc.json` and `backend/.prettierrc`
- [x] T005 [P] Create environment configuration: `backend/.env.example` with SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, SUPABASE_ANON_KEY, SUPABASE_JWT_SECRET placeholders; `app/.env.example` with SUPABASE_URL, SUPABASE_ANON_KEY, API_BASE_URL
- [x] T006 [P] Create `.gitignore` entries for `backend/.env.local`, `app/.env`, `app/.dart_tool/`, `app/build/`, `backend/.next/`, `backend/node_modules/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can begin

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Backend Foundation

- [x] T007 Create Supabase server client utility in `backend/src/lib/supabase/client.ts` using `@supabase/supabase-js` with service role key from env vars
- [x] T008 Create Supabase admin client in `backend/src/lib/supabase/admin.ts` for admin operations (user profile creation trigger)
- [x] T009 Create JWT auth middleware in `backend/src/lib/middleware/auth.ts` — extract Bearer token from Authorization header, verify via `supabase.auth.getUser(token)`, attach user to request context; return 401 for missing/invalid token
- [x] T010 [P] Create shared Zod error formatter in `backend/src/lib/validators/error-formatter.ts` — transforms ZodError into `{ error, code, details }` consistent response format
- [x] T011 [P] Create shared API response helpers in `backend/src/lib/utils/api-response.ts` — `success()`, `created()`, `noContent()`, `badRequest()`, `unauthorized()`, `notFound()`, `conflict()` wrappers
- [x] T012 Create Supabase SQL migration for all tables in `backend/supabase/migrations/001_initial_schema.sql` — tables: users, recipes, ingredients, cooking_steps, tags, recipe_tags, cookbooks, meal_plans, meal_slots, grocery_items with all indexes, constraints, and RLS policies per data-model.md
- [x] T013 [P] Create database seed script in `backend/supabase/seed.sql` — insert sample tags (#QuickLunch, #Healthy, #BudgetFriendly, #Vegetarian, #Dessert), 10+ sample recipes with ingredients and steps, linked via recipe_tags

### Flutter Foundation

- [x] T014 Create Clean Architecture core layer — error classes in `app/lib/core/error/exceptions.dart` (ServerException, CacheException, NetworkException) and `app/lib/core/error/failures.dart` (ServerFailure, CacheFailure, NetworkFailure extending abstract Failure class)
- [x] T015 Create base UseCase class in `app/lib/core/usecases/usecase.dart` — abstract `UseCase<Type, Params>` with `Future<Either<Failure, Type>> call(Params params)` using dartz
- [x] T016 Create NetworkInfo utility in `app/lib/core/network/network_info.dart` — interface and implementation using connectivity_plus to check internet connectivity
- [x] T017 Create API constants in `app/lib/core/constants/api_constants.dart` — base URL from env, all endpoint paths as static constants; and app constants in `app/lib/core/constants/app_constants.dart` — min/max servings (1-50), meal types enum, ingredient categories list
- [x] T018 Create app theme in `app/lib/core/theme/app_theme.dart` and `app/lib/core/theme/app_colors.dart` — Material Design 3 light theme with brand colors, text styles for recipe cards, headers, body text; platform-adaptive (Material on Android, Cupertino feel on iOS)
- [x] T019 Create drift database definition in `app/lib/core/database/app_database.dart` — define all local tables: cached_recipes, local_meal_plans, local_meal_slots, local_grocery_items, local_cookbooks, sync_queue per data-model.md local schema; run `dart run build_runner build`
- [x] T020 Create API client wrapper in `app/lib/core/network/api_client.dart` — dio instance with base URL, auth interceptor (add Supabase JWT Bearer token), retry interceptor, logging interceptor, JSON content-type headers
- [x] T021 Create dependency injection container in `app/lib/config/di/injection_container.dart` — register singletons: Supabase client, drift database, NetworkInfo, API client (dio); export `initDI()` async function
- [x] T022 Create go_router configuration in `app/lib/config/routes/app_router.dart` — define `StatefulShellRoute.indexedStack` for bottom nav with 5 branches: /home, /cookbook, /planner, /grocery, /profile; plus full-screen routes: /recipe/:id, /recipe/:id/cooking, /login, /register
- [x] T023 Create MainShell scaffold widget in `app/lib/features/shell/presentation/pages/main_shell.dart` — Scaffold with BottomNavigationBar (5 tabs: Home 🏠, My Cookbook 📖, Planner 🗓️, Grocery 🛒, Profile 👤), body from router child, badge on Grocery tab (reactive from GroceryBloc)
- [x] T024 Create `app/lib/main.dart` — initialize WidgetsFlutterBinding, Supabase.initialize(), await initDI(), setup global BlocObserver for logging, runApp with MaterialApp.router using goRouter config
- [x] T025 [P] Create SyncQueue data access object in `app/lib/core/sync/sync_dao.dart` — drift DAO for sync_queue table: insertOperation(), getPendingOperations(), markProcessing(), markCompleted(), markFailed(), getRetryCount()
- [x] T026 [P] Create SyncBloc in `app/lib/core/sync/sync_bloc.dart` — listen to connectivity changes, on reconnect: process sync queue FIFO, call appropriate API endpoints, dequeue on success, retry with exponential backoff (1s, 4s, 16s), max 3 retries, emit SyncState (idle, syncing, error, completed)

**Checkpoint**: Foundation ready — both backend API structure and Flutter core layer complete. User story implementation can now begin.

---

## Phase 3: User Story 7 — App Navigation Structure (Priority: P1)

**Goal**: Bottom navigation bar with 5 tabs, tab state preservation, grocery badge

**Independent Test**: Tap each tab → correct screen loads, active tab highlighted, grocery badge updates, tab state preserved when switching

**Why first**: Navigation is the structural skeleton — all other stories render within these tabs.

### Tests for US7

- [x] T027 [P] [US7] Write widget test for MainShell bottom navigation in `app/test/features/shell/presentation/pages/main_shell_test.dart` — verify 5 tab icons render, tapping each tab switches content, active tab highlighted, badge renders with count from mock GroceryBloc
- [x] T028 [P] [US7] Write widget test for app_router navigation in `app/test/config/routes/app_router_test.dart` — verify route /home renders HomePage, /cookbook renders CookbookPage, /planner renders PlannerPage, /grocery renders GroceryPage, /profile renders ProfilePage; verify /recipe/:id renders RecipeDetailPage without bottom nav

### Implementation for US7

- [x] T029 [US7] Create placeholder pages for all tabs: `app/lib/features/home/presentation/pages/home_page.dart`, `app/lib/features/cookbook/presentation/pages/cookbook_page.dart`, `app/lib/features/planner/presentation/pages/planner_page.dart`, `app/lib/features/grocery/presentation/pages/grocery_page.dart`, `app/lib/features/profile/presentation/pages/profile_page.dart` — each with Scaffold + AppBar + Center text identifying the page
- [x] T030 [US7] Implement bottom navigation badge logic in `app/lib/features/shell/presentation/pages/main_shell.dart` — BottomNavigationBarItem for Grocery tab uses Badge widget bound to remaining grocery item count; FR-024
- [x] T031 [US7] Implement tab state preservation using `StatefulShellRoute.indexedStack` in `app/lib/config/routes/app_router.dart` — each tab maintains its own navigator stack; returning to a tab restores its previous state; FR-025
- [x] T032 [US7] Verify nested navigation: tapping recipe card (from Home) pushes /recipe/:id full-screen (no bottom nav); tapping bottom tab returns to that tab's root screen; FR-025

**Checkpoint**: App launches with working 5-tab navigation. All placeholder screens accessible.

---

## Phase 4: User Story 1 — Browse & Discover Recipes on Home Screen (Priority: P1) 🎯 MVP

**Goal**: Home screen with search bar + filters, tag row, trending recipe grid, "Next Meal" sticky card, quick-add to meal plan

**Independent Test**: Launch app → verify search bar with filters, tag scrolling, trending grid, and "Next Meal" card all render and respond to taps

### Backend — Recipes & Tags API

- [x] T033 [P] [US1] Create Zod validators in `backend/src/lib/validators/recipe-validators.ts` — RecipeQuerySchema (q: string?, tag: string?, max_time: int?, max_calories: int?, ingredient: string?, cursor: string?, limit: int default 20 max 50), RecipeIdParamSchema (id: uuid)
- [x] T034 [P] [US1] Create Zod validators in `backend/src/lib/validators/tag-validators.ts` — no input validation needed (GET only), but define TagResponseSchema for type safety
- [x] T035 [US1] Implement GET `/api/recipes` route handler in `backend/src/app/api/recipes/route.ts` — parse query params with RecipeQuerySchema, build Supabase query: fuzzy search on title (ilike), filter by tag via join recipe_tags, filter cooking_time_minutes <= max_time, filter calories <= max_calories, filter ingredient name ilike, cursor-based pagination, return recipe list with tags and is_saved status per contracts/recipes.md
- [x] T036 [US1] Implement GET `/api/recipes/trending` route handler in `backend/src/app/api/recipes/trending/route.ts` — query published recipes ordered by (view_count DESC, save_count DESC), optional tag filter, limit parameter, return array per contracts/recipes.md
- [x] T037 [US1] Implement GET `/api/tags` route handler in `backend/src/app/api/tags/route.ts` — fetch all tags ordered by display_order, return array per contracts/recipes.md
- [x] T038 [P] [US1] Write jest tests for recipes route in `backend/tests/unit/recipes.test.ts` — test search filtering, pagination, trending sort order, tag filtering, empty results
- [x] T039 [P] [US1] Write jest tests for tags route in `backend/tests/unit/tags.test.ts` — test tag list returns in order

### Flutter — Home Feature (Domain Layer)

- [x] T040 [P] [US1] Create Recipe entity in `app/lib/features/home/domain/entities/recipe.dart` — per data-model.md Recipe class with Equatable, all fields, isSaved flag
- [x] T041 [P] [US1] Create Tag entity in `app/lib/features/home/domain/entities/tag.dart` — per data-model.md Tag class with Equatable
- [x] T042 [P] [US1] Create Ingredient entity in `app/lib/features/home/domain/entities/ingredient.dart` — per data-model.md with adjustForServings() method
- [x] T043 [P] [US1] Create CookingStep entity in `app/lib/features/home/domain/entities/cooking_step.dart` — per data-model.md with MediaType enum
- [x] T044 [US1] Create HomeRepository abstract class in `app/lib/features/home/domain/repositories/home_repository.dart` — methods: searchRecipes(query, filters, cursor), getTrendingRecipes(tag?, limit), getTags(), getNextMealSlot()
- [x] T045 [P] [US1] Create use cases in `app/lib/features/home/domain/usecases/`: SearchRecipes, GetTrendingRecipes, GetTags, GetNextMealSlot — each extends UseCase with params class, returns Either<Failure, T>

### Flutter — Home Feature (Data Layer)

- [x] T046 [P] [US1] Create RecipeModel in `app/lib/features/home/data/models/recipe_model.dart` — extends Recipe entity, adds fromJson/toJson factory methods matching API response shape; create TagModel in `app/lib/features/home/data/models/tag_model.dart`
- [x] T047 [US1] Create HomeRemoteDataSource in `app/lib/features/home/data/datasources/home_remote_datasource.dart` — uses dio API client to call GET /api/recipes, GET /api/recipes/trending, GET /api/tags; parse responses into models; throw ServerException on failure
- [x] T048 [US1] Create HomeLocalDataSource in `app/lib/features/home/data/datasources/home_local_datasource.dart` — uses drift DAO to cache recipes (cached_recipes table), return cached trending recipes and tags when offline
- [x] T049 [US1] Create HomeRepositoryImpl in `app/lib/features/home/data/repositories/home_repository_impl.dart` — implements HomeRepository; checks NetworkInfo: online → remote + cache locally, offline → return from local cache; wraps in try/catch returning Either<Failure, T>

### Flutter — Home Feature (Presentation Layer)

- [x] T050 [US1] Create HomeBloc in `app/lib/features/home/presentation/bloc/home_bloc.dart` with events (LoadHome, SearchRecipes, FilterByTag, LoadMoreTrending) and states (HomeInitial, HomeLoading, HomeLoaded with nextMealSlot?, tags, trendingRecipes, searchResults; HomeError) in `home_event.dart` and `home_state.dart`
- [x] T051 [US1] Implement HomePage in `app/lib/features/home/presentation/pages/home_page.dart` — CustomScrollView with: SliverAppBar containing search bar (FR-001); SliverToBoxAdapter for NextMealCard (FR-002); SliverToBoxAdapter for horizontal tag row (FR-003); SliverGrid for trending recipe cards (FR-004)
- [x] T052 [P] [US1] Create SearchBar widget in `app/lib/features/home/presentation/widgets/search_bar_widget.dart` — text field with filter icon; tapping filter icon opens BottomSheet with ingredient, max cooking time, max calories inputs; FR-001, FR-005 acceptance
- [x] T053 [P] [US1] Create NextMealCard widget in `app/lib/features/home/presentation/widgets/next_meal_card.dart` — sticky card showing meal name, image, "Start Cooking" button; hidden when no meal planned; shows "Plan your first meal" prompt when empty; FR-002
- [x] T054 [P] [US1] Create TagRow widget in `app/lib/features/home/presentation/widgets/tag_row.dart` — horizontally scrollable row of FilterChip/ChoiceChip widgets; selected tag filters trending grid; FR-003
- [x] T055 [P] [US1] Create RecipeCard widget in `app/lib/features/home/presentation/widgets/recipe_card.dart` — full-bleed cached image, title overlay, quick-add "+" FAB; tapping card navigates to /recipe/:id; tapping "+" opens DateMealSlotPicker; FR-004
- [x] T056 [US1] Create QuickAddMealSlotPicker bottom sheet in `app/lib/features/home/presentation/widgets/quick_add_picker.dart` — date selector + meal type picker (breakfast/lunch/dinner/snack); on confirm: calls planner use case to add recipe to slot; shows success snackbar; FR-004 scenario 6
- [x] T057 [US1] Register Home feature DI in `app/lib/config/di/injection_container.dart` — add initHomeDI() registering HomeRemoteDataSource, HomeLocalDataSource, HomeRepositoryImpl, all use cases, HomeBloc as factory
- [x] T058 [US1] Wire HomePage into app_router replacing placeholder; wrap with BlocProvider<HomeBloc>

### Tests for US1

- [x] T059 [P] [US1] Write bloc_test for HomeBloc in `app/test/features/home/presentation/bloc/home_bloc_test.dart` — test LoadHome emits [HomeLoading, HomeLoaded]; SearchRecipes emits filtered results; FilterByTag filters trending; error states on failure
- [x] T060 [P] [US1] Write unit test for HomeRepositoryImpl in `app/test/features/home/data/repositories/home_repository_impl_test.dart` — mock remote+local, test online path caches data, offline path returns cache, network failure returns CacheFailure
- [x] T061 [P] [US1] Write widget test for HomePage in `app/test/features/home/presentation/pages/home_page_test.dart` — pump with mock HomeBloc, verify search bar, tag row, trending grid render; verify tap on recipe card navigates

**Checkpoint**: Home screen fully functional — user can browse trending recipes, search with filters, see next meal card. MVP entry point complete.

---

## Phase 5: User Story 2 — View Recipe Details (Priority: P1)

**Goal**: Recipe detail screen with parallax header, quick info, ingredients tab (checkboxes + servings adjuster), steps tab, "Start Cooking" mode

**Independent Test**: Navigate to any recipe → verify parallax header, quick info row, tab switching, servings dropdown adjusting quantities, ingredient checkboxes, steps with media, "Start Cooking" button

### Backend — Recipe Detail API

- [x] T062 [US2] Implement GET `/api/recipes/:id` route handler in `backend/src/app/api/recipes/[id]/route.ts` — fetch recipe by ID with ingredients (ordered by display_order), cooking_steps (ordered by step_number), tags; check is_saved for authenticated user; increment view_count; return full recipe per contracts/recipes.md
- [x] T063 [P] [US2] Write jest test for recipe detail route in `backend/tests/unit/recipe-detail.test.ts` — test valid ID returns full recipe, invalid UUID returns 400, non-existent ID returns 404, view_count increments

### Flutter — Recipe Detail Feature (Domain Layer)

- [x] T064 [US2] Create RecipeDetailRepository abstract class in `app/lib/features/recipe_detail/domain/repositories/recipe_detail_repository.dart` — methods: getRecipeById(id), saveRecipe(id), unsaveRecipe(id)
- [x] T065 [P] [US2] Create use cases in `app/lib/features/recipe_detail/domain/usecases/`: GetRecipeDetail, SaveRecipe, UnsaveRecipe — each extends UseCase

### Flutter — Recipe Detail Feature (Data Layer)

- [x] T066 [US2] Create RecipeDetailRemoteDataSource in `app/lib/features/recipe_detail/data/datasources/recipe_detail_remote_datasource.dart` — GET /api/recipes/:id via dio
- [x] T067 [US2] Create RecipeDetailLocalDataSource in `app/lib/features/recipe_detail/data/datasources/recipe_detail_local_datasource.dart` — get/cache recipe detail from drift cached_recipes table
- [x] T068 [US2] Create RecipeDetailRepositoryImpl in `app/lib/features/recipe_detail/data/repositories/recipe_detail_repository_impl.dart` — online: fetch remote + cache; offline: return cached; save/unsave: call API + update local

### Flutter — Recipe Detail Feature (Presentation Layer)

- [x] T069 [US2] Create RecipeDetailBloc in `app/lib/features/recipe_detail/presentation/bloc/recipe_detail_bloc.dart` — events: LoadRecipeDetail(id), AdjustServings(count), ToggleIngredientCheck(ingredientId), SaveRecipeToggle; states: RecipeDetailInitial, Loading, Loaded(recipe, currentServings, checkedIngredients), Error
- [x] T070 [US2] Implement RecipeDetailPage in `app/lib/features/recipe_detail/presentation/pages/recipe_detail_page.dart` — CustomScrollView with SliverAppBar (parallax flexibleSpace with cover image, Save + Add to Plan buttons in actions; FR-005), SliverToBoxAdapter for QuickInfoRow (FR-006), SliverToBoxAdapter for TabBar (Ingredients / Steps; FR-007), tab content below
- [x] T071 [P] [US2] Create ParallaxHeader widget in `app/lib/features/recipe_detail/presentation/widgets/parallax_header.dart` — SliverAppBar with expandedHeight, flexibleSpace using FlexibleSpaceBar with parallax background image (cached_network_image), overlaid Save (heart icon) and Add to Plan buttons; FR-005
- [x] T072 [P] [US2] Create QuickInfoRow widget in `app/lib/features/recipe_detail/presentation/widgets/quick_info_row.dart` — Row with ⏱️ cookingTime, 📊 calories, ⭐ rating icons with labels; FR-006
- [x] T073 [US2] Create IngredientsTab widget in `app/lib/features/recipe_detail/presentation/widgets/ingredients_tab.dart` — servings dropdown (1-50, default from recipe), ingredient list with checkboxes; adjustForServings() recalculates all quantities on dropdown change; checked items show strikethrough; FR-008
- [x] T074 [US2] Create StepsTab widget in `app/lib/features/recipe_detail/presentation/widgets/steps_tab.dart` — numbered list with large step numbers, instruction text, optional thumbnail/video beside each step; FR-009
- [x] T075 [US2] Create CookingModePage in `app/lib/features/recipe_detail/presentation/pages/cooking_mode_page.dart` — full-screen step-by-step view with large text, prominent Next/Previous buttons, step counter (e.g., "Step 2 of 8"), keep screen awake; FR-010
- [x] T076 [US2] Register RecipeDetail feature DI in `app/lib/config/di/injection_container.dart` — add initRecipeDetailDI(); wire route /recipe/:id with BlocProvider

### Tests for US2

- [x] T077 [P] [US2] Write bloc_test for RecipeDetailBloc in `app/test/features/recipe_detail/presentation/bloc/recipe_detail_bloc_test.dart` — test LoadRecipeDetail, AdjustServings updates quantities proportionally, ToggleIngredientCheck toggles, SaveRecipeToggle transitions
- [x] T078 [P] [US2] Write widget test for IngredientsTab in `app/test/features/recipe_detail/presentation/widgets/ingredients_tab_test.dart` — verify dropdown change updates quantities, checkbox toggles strikethrough
- [x] T079 [P] [US2] Write unit test for Ingredient.adjustForServings in `app/test/features/home/domain/entities/ingredient_test.dart` — test 2 servings → 4 servings doubles quantity, edge cases (servings=1, servings=50)

**Checkpoint**: User can tap any recipe → see full detail with parallax, adjust servings, check ingredients, view steps, enter cooking mode.

---

## Phase 6: User Story 3 — Plan Weekly Meals (Priority: P1)

**Goal**: Planner screen with 7-day calendar strip, meal slots per day, add recipe / quick note, nutrition summary, drag/swipe to reorder/remove

**Independent Test**: Navigate to Planner tab → select days on calendar strip, add recipes to slots, add quick note, verify nutrition summary updates

### Backend — Meal Plans API

- [x] T080 [P] [US3] Create Zod validators in `backend/src/lib/validators/meal-plan-validators.ts` — MealPlanQuerySchema (start_date, end_date), CreateMealPlanSchema (date), CreateSlotSchema (meal_type enum, recipe_id? uuid, quick_note? string max 200, servings int 1-50 default 2 with refine at least one of recipe_id/quick_note), UpdateSlotSchema
- [x] T081 [US3] Implement GET `/api/meal-plans` in `backend/src/app/api/meal-plans/route.ts` — query meal_plans by user_id and date range, join meal_slots with recipe summary (id, title, cover_image_url, cooking_time_minutes, calories), compute nutrition_summary per day, return per contracts/meal-plans.md
- [x] T082 [US3] Implement POST `/api/meal-plans` in `backend/src/app/api/meal-plans/route.ts` — create meal plan for date, check unique constraint (user_id, date), return 409 if exists
- [x] T083 [US3] Implement POST `/api/meal-plans/:id/slots` in `backend/src/app/api/meal-plans/[id]/slots/route.ts` — validate slot data, verify meal_plan belongs to user, insert meal_slot, return slot with recipe summary
- [x] T084 [US3] Implement PUT `/api/meal-plans/:id/slots/:slotId` in `backend/src/app/api/meal-plans/[id]/slots/route.ts` — update meal_type, recipe_id, quick_note, servings, display_order
- [x] T085 [US3] Implement DELETE `/api/meal-plans/:id/slots/:slotId` in `backend/src/app/api/meal-plans/[id]/slots/route.ts` — verify ownership, delete slot, return 204
- [x] T086 [P] [US3] Write jest tests for meal-plans routes in `backend/tests/unit/meal-plans.test.ts` — test CRUD operations, nutrition calculation, date range query, ownership check, validation errors

### Flutter — Planner Feature (Domain Layer)

- [x] T087 [P] [US3] Create MealPlan entity in `app/lib/features/planner/domain/entities/meal_plan.dart` and MealSlot entity in `app/lib/features/planner/domain/entities/meal_slot.dart` — per data-model.md with MealType enum, NutritionSummary computed property
- [x] T088 [US3] Create PlannerRepository abstract class in `app/lib/features/planner/domain/repositories/planner_repository.dart` — methods: getWeekMealPlans(startDate, endDate), createMealPlan(date), addSlot(planId, slot), updateSlot(planId, slotId, data), removeSlot(planId, slotId)
- [x] T089 [P] [US3] Create use cases in `app/lib/features/planner/domain/usecases/`: GetWeekMealPlans, CreateMealPlan, AddMealSlot, UpdateMealSlot, RemoveMealSlot

### Flutter — Planner Feature (Data Layer)

- [x] T090 [P] [US3] Create MealPlanModel and MealSlotModel in `app/lib/features/planner/data/models/` — fromJson/toJson matching API response, toEntity() converter
- [x] T091 [US3] Create PlannerRemoteDataSource in `app/lib/features/planner/data/datasources/planner_remote_datasource.dart` — all API calls for meal plans and slots via dio
- [x] T092 [US3] Create PlannerLocalDataSource in `app/lib/features/planner/data/datasources/planner_local_datasource.dart` — drift DAO for local_meal_plans and local_meal_slots tables; cache/retrieve/update/delete operations + enqueue sync operations
- [x] T093 [US3] Create PlannerRepositoryImpl in `app/lib/features/planner/data/repositories/planner_repository_impl.dart` — online: call remote + cache locally; offline: write to local + add to sync queue; read: try remote, fallback to local

### Flutter — Planner Feature (Presentation Layer)

- [x] T094 [US3] Create PlannerBloc in `app/lib/features/planner/presentation/bloc/planner_bloc.dart` — events: LoadWeek(startDate), SelectDay(date), AddRecipeToSlot(planId, mealType, recipeId, servings), AddQuickNote(planId, mealType, note), RemoveSlot(planId, slotId), MoveSlot(fromSlotId, toMealType); states: PlannerInitial, Loading, Loaded(weekPlans, selectedDate, selectedDayPlan, nutritionSummary), Error
- [x] T095 [US3] Implement PlannerPage in `app/lib/features/planner/presentation/pages/planner_page.dart` — Column: CalendarStrip at top, NutritionBanner, Expanded ListView of meal slot cards grouped by meal type; FR-011, FR-012
- [x] T096 [P] [US3] Create CalendarStrip widget in `app/lib/features/planner/presentation/widgets/calendar_strip.dart` — horizontal scrollable row of 7 day cards showing day name + date number, today highlighted with accent color, selected day with border; tapping changes selected day; FR-011
- [x] T097 [P] [US3] Create MealSlotCard widget in `app/lib/features/planner/presentation/widgets/meal_slot_card.dart` — shows meal type header (Breakfast/Lunch/Dinner/Snack), recipe card or quick note; "Add Recipe" and "Quick Note" buttons for empty slots; swipe-to-delete with confirmation; long-press for reorder; FR-013, FR-015
- [x] T098 [P] [US3] Create NutritionBanner widget in `app/lib/features/planner/presentation/widgets/nutrition_banner.dart` — row showing day's total Calories, Protein (g), Carbs (g) computed from assigned recipes; FR-014
- [x] T099 [US3] Create RecipePickerSheet in `app/lib/features/planner/presentation/widgets/recipe_picker_sheet.dart` — BottomSheet with search bar, shows saved cookbook recipes + search results, tapping selects recipe for the slot; FR-013 scenario 3
- [x] T100 [US3] Register Planner feature DI in `app/lib/config/di/injection_container.dart` — add initPlannerDI(); wire PlannerPage with BlocProvider, replace placeholder

### Tests for US3

- [x] T101 [P] [US3] Write bloc_test for PlannerBloc in `app/test/features/planner/presentation/bloc/planner_bloc_test.dart` — test LoadWeek, SelectDay changes selected plan, AddRecipeToSlot adds to correct slot, RemoveSlot removes, nutrition updates
- [x] T102 [P] [US3] Write widget test for CalendarStrip in `app/test/features/planner/presentation/widgets/calendar_strip_test.dart` — verify 7 days render, today highlighted, tapping changes selection

**Checkpoint**: Full meal planner working — calendar strip, meal slots, add recipe/quick note, nutrition summary, drag/swipe management.

---

## Phase 7: User Story 4 — Generate & Manage Grocery List (Priority: P1)

**Goal**: Auto-generated grocery list from meal plan, grouped by category, smart-merge duplicate ingredients, checkbox, clear completed, share, manual add

**Independent Test**: Create meal plan with 2+ recipes sharing ingredients → Grocery tab shows merged list grouped by category → check items → clear completed → share

### Backend — Grocery API

- [x] T103 [P] [US4] Create grocery merge utility in `backend/src/lib/utils/grocery-merge.ts` — function mergeIngredients(ingredients[]): normalize names (lowercase, strip plurals), group by (normalized_name, unit, category), sum quantities, collect source recipe names; per research.md algorithm
- [x] T104 [P] [US4] Create Zod validators in `backend/src/lib/validators/grocery-validators.ts` — GroceryQuerySchema (week_start date, regenerate boolean), CreateGroceryItemSchema (name, quantity, unit, category enum, week_start), UpdateGroceryItemSchema (is_checked boolean)
- [x] T105 [US4] Implement GET `/api/grocery` in `backend/src/app/api/grocery/route.ts` — if regenerate=true or no items for week: fetch week's meal plan slots with recipes, expand ingredients × servings, call mergeIngredients(), upsert grocery_items (preserve manual + checked state), return grouped by category with summary per contracts/grocery.md
- [x] T106 [US4] Implement POST `/api/grocery` in `backend/src/app/api/grocery/route.ts` — validate CreateGroceryItemSchema, insert manual grocery item (is_manual=true), return created item
- [x] T107 [US4] Implement PATCH `/api/grocery/:id` in `backend/src/app/api/grocery/[id]/route.ts` — toggle is_checked, return updated item
- [x] T108 [US4] Implement DELETE `/api/grocery/:id` in `backend/src/app/api/grocery/[id]/route.ts` — verify ownership, delete, return 204
- [x] T109 [US4] Implement DELETE `/api/grocery/clear` in `backend/src/app/api/grocery/clear/route.ts` — delete all items where is_checked=true for user's week, return cleared_count and remaining_count per contracts/grocery.md
- [x] T110 [P] [US4] Write jest tests for grocery routes in `backend/tests/unit/grocery.test.ts` — test merge algorithm (2 garlic entries → 1 merged), manual item add, check/uncheck, clear completed count, edge case: no meal plan returns empty
- [x] T111 [P] [US4] Write jest tests for grocery-merge utility in `backend/tests/unit/grocery-merge.test.ts` — test normalization (plurals, case), unit grouping, incompatible units kept separate, source recipe attribution

### Flutter — Grocery Feature (Domain Layer)

- [x] T112 [P] [US4] Create GroceryItem entity in `app/lib/features/grocery/domain/entities/grocery_item.dart` — per data-model.md with category, sourceRecipes list, isChecked, isManual
- [x] T113 [US4] Create GroceryRepository abstract class in `app/lib/features/grocery/domain/repositories/grocery_repository.dart` — methods: getGroceryList(weekStart, regenerate?), addManualItem(item), toggleItemCheck(id, checked), deleteItem(id), clearCompleted(weekStart), getRemainingCount(weekStart)
- [x] T114 [P] [US4] Create use cases in `app/lib/features/grocery/domain/usecases/`: GetGroceryList, AddManualGroceryItem, ToggleGroceryItemCheck, DeleteGroceryItem, ClearCompletedItems, GetRemainingItemCount

### Flutter — Grocery Feature (Data Layer)

- [x] T115 [P] [US4] Create GroceryItemModel in `app/lib/features/grocery/data/models/grocery_item_model.dart` — fromJson/toJson, GroceryCategoryGroup model for grouped response
- [x] T116 [US4] Create GroceryRemoteDataSource in `app/lib/features/grocery/data/datasources/grocery_remote_datasource.dart` — all API calls per contracts/grocery.md
- [x] T117 [US4] Create GroceryLocalDataSource in `app/lib/features/grocery/data/datasources/grocery_local_datasource.dart` — drift DAO for local_grocery_items; cache list, toggle check locally, add manual items locally, sync queue for offline changes
- [x] T118 [US4] Create GroceryRepositoryImpl in `app/lib/features/grocery/data/repositories/grocery_repository_impl.dart` — online/offline branching, getRemainingCount() for badge

### Flutter — Grocery Feature (Presentation Layer)

- [x] T119 [US4] Create GroceryBloc in `app/lib/features/grocery/presentation/bloc/grocery_bloc.dart` — events: LoadGroceryList(weekStart), ToggleItem(id), ClearCompleted, AddManualItem(name, quantity, unit, category), ShareList, RegenerateList; states: GroceryInitial, Loading, Loaded(categories[], summary), Error; emit remainingCount for badge via stream
- [x] T120 [US4] Implement GroceryPage in `app/lib/features/grocery/presentation/pages/grocery_page.dart` — AppBar with "Share" and "Clear Completed" action buttons; ListView.builder with category headers (emoji + name), GroceryItemTile for each item; FloatingActionButton for manual add; empty state when no items; FR-016 through FR-022
- [x] T121 [P] [US4] Create GroceryItemTile widget in `app/lib/features/grocery/presentation/widgets/grocery_item_tile.dart` — Checkbox + name + "quantity unit" + source attribution text ("Used in: ..."); checked items show strikethrough; swipe to delete; FR-019
- [x] T122 [P] [US4] Create AddGroceryItemDialog in `app/lib/features/grocery/presentation/widgets/add_grocery_item_dialog.dart` — dialog with name, quantity, unit, category dropdown; validates quantity > 0; FR-022
- [x] T123 [US4] Implement share grocery list formatting in `app/lib/features/grocery/presentation/bloc/grocery_bloc.dart` — on ShareList event: format list as text per contracts/grocery.md share format (grouped by category with emoji, checkboxes, quantities); use share_plus to invoke native share sheet; FR-021
- [x] T124 [US4] Register Grocery feature DI in `app/lib/config/di/injection_container.dart` — add initGroceryDI(); wire GroceryPage with BlocProvider, connect remainingCount stream to MainShell badge

### Tests for US4

- [x] T125 [P] [US4] Write bloc_test for GroceryBloc in `app/test/features/grocery/presentation/bloc/grocery_bloc_test.dart` — test LoadGroceryList, ToggleItem changes checked state, ClearCompleted removes checked items, AddManualItem adds to list, remaining count updates
- [x] T126 [P] [US4] Write unit test for grocery list text formatter in `app/test/features/grocery/presentation/bloc/grocery_share_format_test.dart` — verify output matches contracts/grocery.md share format

**Checkpoint**: Full grocery list functional — auto-generated from meal plan, merged duplicates, category grouping, check/clear/share/manual add all working.

---

## Phase 8: User Story 5 — Save Recipes to Personal Cookbook (Priority: P2)

**Goal**: Save/unsave recipes, My Cookbook tab listing saved recipes

**Independent Test**: Save recipe from detail screen → navigate to My Cookbook → verify it appears → unsave → verify removed

### Backend — Cookbook API

- [x] T127 [US5] Implement GET `/api/cookbook` in `backend/src/app/api/cookbook/route.ts` — fetch user's saved recipes via cookbooks join, paginated, include recipe summary (thumbnail, title, quick info, saved_at), per contracts/recipes.md
- [x] T128 [US5] Implement POST `/api/cookbook/:recipeId` in `backend/src/app/api/cookbook/[recipeId]/route.ts` — insert (user_id, recipe_id) into cookbooks, increment recipe save_count, return 201; return 409 if already saved
- [x] T129 [US5] Implement DELETE `/api/cookbook/:recipeId` in `backend/src/app/api/cookbook/[recipeId]/route.ts` — delete from cookbooks, decrement recipe save_count, return 204; return 404 if not saved
- [x] T130 [P] [US5] Write jest tests for cookbook routes in `backend/tests/unit/cookbook.test.ts` — test save, unsave, duplicate save 409, list pagination, save_count increment/decrement

### Flutter — Cookbook Feature (Domain Layer)

- [x] T131 [P] [US5] Create CookbookRepository abstract class in `app/lib/features/cookbook/domain/repositories/cookbook_repository.dart` — methods: getSavedRecipes(cursor?), saveRecipe(recipeId), unsaveRecipe(recipeId)
- [x] T132 [P] [US5] Create use cases in `app/lib/features/cookbook/domain/usecases/`: GetSavedRecipes, SaveRecipe, UnsaveRecipe

### Flutter — Cookbook Feature (Data Layer)

- [x] T133 [US5] Create CookbookRemoteDataSource in `app/lib/features/cookbook/data/datasources/cookbook_remote_datasource.dart` — API calls for list, save, unsave
- [x] T134 [US5] Create CookbookLocalDataSource in `app/lib/features/cookbook/data/datasources/cookbook_local_datasource.dart` — drift DAO for local_cookbooks + cached_recipes (is_saved flag), sync queue for offline save/unsave
- [x] T135 [US5] Create CookbookRepositoryImpl in `app/lib/features/cookbook/data/repositories/cookbook_repository_impl.dart` — online/offline branching, update isSaved on Recipe entity

### Flutter — Cookbook Feature (Presentation Layer)

- [x] T136 [US5] Create CookbookBloc in `app/lib/features/cookbook/presentation/bloc/cookbook_bloc.dart` — events: LoadCookbook, LoadMore, UnsaveFromList(recipeId); states: CookbookInitial, Loading, Loaded(recipes, hasMore), Empty, Error
- [x] T137 [US5] Implement CookbookPage in `app/lib/features/cookbook/presentation/pages/cookbook_page.dart` — AppBar "My Cookbook", GridView of recipe cards (thumbnail, title, quick info per FR-027), empty state with "Explore recipes" CTA, infinite scroll, tapping card navigates to /recipe/:id
- [x] T138 [US5] Wire save/unsave action in RecipeDetailPage — connect Save button to CookbookBloc.SaveRecipe/UnsaveRecipe, update button state (filled heart = saved), sync with CookbookBloc so list updates; FR-026
- [x] T139 [US5] Register Cookbook feature DI in `app/lib/config/di/injection_container.dart` — add initCookbookDI(); wire CookbookPage with BlocProvider, replace placeholder

### Tests for US5

- [x] T140 [P] [US5] Write bloc_test for CookbookBloc in `app/test/features/cookbook/presentation/bloc/cookbook_bloc_test.dart` — test LoadCookbook, UnsaveFromList removes from list, Empty state when no recipes
- [x] T141 [P] [US5] Write widget test for CookbookPage in `app/test/features/cookbook/presentation/pages/cookbook_page_test.dart` — verify grid renders saved recipes, empty state shows CTA, tap navigates

**Checkpoint**: Cookbook feature complete — save from detail, view in My Cookbook, unsave, offline support.

---

## Phase 9: User Story 6 — Register & Sign In (Priority: P2)

**Goal**: Email/password registration, login, guest mode, data sync on account creation

**Independent Test**: Register → sign out → sign in → verify saved data persists; use app in guest mode → all core features work locally

### Backend — Auth API

- [x] T142 [P] [US6] Create Zod validators in `backend/src/lib/validators/auth-validators.ts` — RegisterSchema (email: string.email, password: string.min(8), display_name: string.min(1).max(100)), LoginSchema (email: string.email, password: string)
- [x] T143 [US6] Implement POST `/api/auth/register` in `backend/src/app/api/auth/register/route.ts` — validate with RegisterSchema, call supabase.auth.admin.createUser(), insert into users profile table, return user + session per contracts/auth.md; handle duplicate email 409
- [x] T144 [US6] Implement POST `/api/auth/login` in `backend/src/app/api/auth/login/route.ts` — validate with LoginSchema, call supabase.auth.signInWithPassword(), return user + session; return generic "Invalid email or password" 401 per FR-031
- [x] T145 [US6] Implement GET `/api/auth/me` in `backend/src/app/api/auth/me/route.ts` — verify JWT via auth middleware, fetch user profile from users table, return user object
- [x] T146 [P] [US6] Implement GET/PUT `/api/users/profile` in `backend/src/app/api/users/profile/route.ts` — GET: return user profile; PUT: update display_name, avatar_url with validation
- [x] T147 [P] [US6] Write jest tests for auth routes in `backend/tests/unit/auth.test.ts` — test registration validation, duplicate email, login success, login failure (generic error), me endpoint auth check

### Flutter — Auth Feature (Domain Layer)

- [x] T148 [P] [US6] Create User entity in `app/lib/features/auth/domain/entities/user.dart` — per data-model.md
- [x] T149 [US6] Create AuthRepository abstract class in `app/lib/features/auth/domain/repositories/auth_repository.dart` — methods: register(email, password, displayName), login(email, password), getCurrentUser(), logout(), isAuthenticated()
- [x] T150 [P] [US6] Create use cases in `app/lib/features/auth/domain/usecases/`: Register, Login, GetCurrentUser, Logout

### Flutter — Auth Feature (Data Layer)

- [x] T151 [P] [US6] Create UserModel in `app/lib/features/auth/data/models/user_model.dart` — fromJson/toJson, fromSupabaseUser()
- [x] T152 [US6] Create AuthRemoteDataSource in `app/lib/features/auth/data/datasources/auth_remote_datasource.dart` — uses supabase_flutter for signUp, signInWithPassword, getUser, signOut; passes JWT to API client
- [x] T153 [US6] Create AuthLocalDataSource in `app/lib/features/auth/data/datasources/auth_local_datasource.dart` — cache user session info locally (supabase_flutter handles session persistence), store guest mode flag
- [x] T154 [US6] Create AuthRepositoryImpl in `app/lib/features/auth/data/repositories/auth_repository_impl.dart` — register: signUp + create profile via API; login: signIn + trigger sync of local data; guest mode: skip auth, operate on local DB only

### Flutter — Auth Feature (Presentation Layer)

- [x] T155 [US6] Create AuthBloc in `app/lib/features/auth/presentation/bloc/auth_bloc.dart` — events: CheckAuthStatus, LoginSubmitted(email, password), RegisterSubmitted(email, password, displayName), LogoutRequested; states: AuthInitial, AuthLoading, Authenticated(user), Unauthenticated, GuestMode, AuthError(message)
- [x] T156 [US6] Create LoginPage in `app/lib/features/auth/presentation/pages/login_page.dart` — email + password TextFields with inline validation (FR-029), "Sign In" button, "Create Account" link to register, "Continue as Guest" option; show generic error on failure (FR-031)
- [x] T157 [US6] Create RegisterPage in `app/lib/features/auth/presentation/pages/register_page.dart` — email + password + display name TextFields, inline validation (email format, password ≥ 8 chars), "Create Account" button, "Already have an account? Sign In" link; FR-028, FR-029
- [x] T158 [US6] Implement guest-to-account migration in `app/lib/features/auth/data/repositories/auth_repository_impl.dart` — on register/login: batch upload local meal plans, cookbook, grocery items to server; switch from local-only to synced mode
- [x] T159 [US6] Create ProfilePage in `app/lib/features/profile/presentation/pages/profile_page.dart` — show user info (name, email, avatar), "Sign Out" button for authenticated users; "Sign In / Create Account" CTA for guest users; replace profile placeholder
- [x] T160 [US6] Register Auth feature DI in `app/lib/config/di/injection_container.dart` — add initAuthDI(); wire Login/Register routes with BlocProvider; add auth-aware redirect in go_router (e.g., /profile redirects to login for guests wanting to sign in)

### Tests for US6

- [x] T161 [P] [US6] Write bloc_test for AuthBloc in `app/test/features/auth/presentation/bloc/auth_bloc_test.dart` — test CheckAuthStatus (authenticated vs guest), LoginSubmitted success/failure, RegisterSubmitted validation errors, LogoutRequested
- [x] T162 [P] [US6] Write widget test for LoginPage in `app/test/features/auth/presentation/pages/login_page_test.dart` — verify form validation (invalid email shows error, short password shows error), submit triggers event, error message displays
- [x] T163 [P] [US6] Write widget test for RegisterPage in `app/test/features/auth/presentation/pages/register_page_test.dart` — verify all validations, successful submission

**Checkpoint**: Auth complete — register, login, guest mode, profile page, data sync on account creation.

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Edge cases, empty states, performance, accessibility, final quality

- [x] T164 [P] Create empty state widgets in `app/lib/core/widgets/empty_state.dart` — reusable EmptyState widget with illustration placeholder, title, subtitle, CTA button; use in CookbookPage (no saved recipes), PlannerPage (no plans), GroceryPage (no items)
- [x] T165 [P] Implement error handling for recipes with missing data in `app/lib/features/recipe_detail/presentation/widgets/` — placeholder image when cover_image_url is null, "Nutrition not available" when calories is null, "Instructions coming soon" when steps is empty; per edge cases section
- [x] T166 [P] Add loading skeletons/shimmer effects for recipe cards in `app/lib/core/widgets/shimmer_card.dart` — used in HomePage trending grid, CookbookPage grid while data loads
- [x] T167 Implement offline indicator banner in `app/lib/core/widgets/offline_banner.dart` — persistent banner at top when no connectivity, shows sync status from SyncBloc; per FR-035
- [x] T168 [P] Add accessibility labels to all interactive elements — BottomNav items, recipe cards, checkboxes, buttons (Semantics widget wrapping); per constitution accessibility requirement
- [x] T169 [P] Setup i18n architecture in `app/lib/core/l10n/` — create ARB files for English strings, extract all hardcoded strings to localizations; per constitution i18n-ready requirement
- [x] T170 [P] Add image compression before upload in `app/lib/core/utils/image_utils.dart` — use flutter_image_compress to resize images to max 1024px width and < 1MB before any future upload; per constitution constraint
- [x] T171 Performance audit — verify ListView.builder used everywhere (not ListView with children), verify cached_network_image has placeholder and error widgets, verify drift queries use indexes, verify no unnecessary rebuilds in BLoC consumers (buildWhen optimization)
- [x] T172 [P] Write integration test: full core flow in `app/integration_test/core_flow_test.dart` — launch app → browse home → tap recipe → view detail → add to planner → navigate to planner → verify slot → navigate to grocery → verify ingredients appear; SC-004 validation
- [x] T173 Run quickstart.md validation — follow all steps in specs/001-recipe-planner-app/quickstart.md from scratch on a clean environment, verify backend starts, Flutter app builds and runs on both iOS simulator and Android emulator
- [x] T174 Security hardening — verify Supabase service role key never appears in Flutter code, verify RLS policies active on all tables, add rate limiting to auth endpoints in `backend/src/lib/middleware/rate-limit.ts`

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1: Setup ─────────────► Phase 2: Foundational ─────►┬── Phase 3: US7 (Navigation) ──►┬── Phase 4: US1 (Home)
                                                           │                                 ├── Phase 5: US2 (Recipe Detail)
                                                           │                                 ├── Phase 6: US3 (Planner)
                                                           │                                 ├── Phase 7: US4 (Grocery)
                                                           │                                 ├── Phase 8: US5 (Cookbook)
                                                           │                                 └── Phase 9: US6 (Auth)
                                                           │
                                                           └── All user stories complete ───► Phase 10: Polish
```

### User Story Dependencies

- **US7 (Navigation)**: MUST complete first — all other stories render within the shell
- **US1 (Home)**: Depends on US7. Provides recipe browsing for US2, US3, US5
- **US2 (Recipe Detail)**: Depends on US7. Uses Recipe entities from US1 (shared). Provides save action for US5
- **US3 (Planner)**: Depends on US7. Uses recipe picker (can reuse US1 search). Drives US4 (grocery generation)
- **US4 (Grocery)**: Depends on US7, US3 (needs meal plan data to generate list). Can work independently with empty state
- **US5 (Cookbook)**: Depends on US7, US2 (save button on detail). Can work independently
- **US6 (Auth)**: Depends on US7. Independent of other stories. Enhances all stories with sync

### Recommended Sequential Order (single developer)

US7 → US1 → US2 → US5 → US3 → US4 → US6 → Polish

### Parallel Opportunities (team)

After Phase 2 + US7:
- **Dev A**: US1 (Home) → US2 (Recipe Detail)
- **Dev B**: US3 (Planner) → US4 (Grocery)
- **Dev C**: US5 (Cookbook) + US6 (Auth)

### Within Each User Story

1. Backend API routes + tests (can parallelize route implementation)
2. Flutter Domain layer (entities + repository interface + use cases) — parallelize entities
3. Flutter Data layer (models + datasources + repository impl) — sequential (datasource → repo)
4. Flutter Presentation layer (BLoC → Page → widgets) — parallelize widgets
5. Tests (BLoC tests + widget tests) — parallelize all tests
6. DI registration + wiring

---

## Parallel Example: User Story 1 (Home)

```bash
# Phase 1: Launch in parallel — Backend
T033: Zod recipe validators          ← parallel
T034: Zod tag validators             ← parallel
T038: Jest recipe tests              ← parallel
T039: Jest tag tests                 ← parallel

# Phase 2: Sequential — Backend routes (depend on validators)
T035: GET /api/recipes
T036: GET /api/recipes/trending
T037: GET /api/tags

# Phase 3: Launch in parallel — Flutter Domain entities
T040: Recipe entity                  ← parallel
T041: Tag entity                     ← parallel
T042: Ingredient entity              ← parallel
T043: CookingStep entity             ← parallel
T045: Use cases                      ← parallel (after T044 repository interface)

# Phase 4: Sequential — Flutter Data layer
T046: Models (parallel: RecipeModel + TagModel)
T047: Remote DataSource
T048: Local DataSource
T049: Repository Impl

# Phase 5: Sequential then parallel — Flutter Presentation
T050: HomeBloc (must be first)
T051: HomePage
T052: SearchBar widget               ← parallel with T053-T056
T053: NextMealCard widget            ← parallel
T054: TagRow widget                  ← parallel
T055: RecipeCard widget              ← parallel
T056: QuickAddPicker

# Phase 6: All tests in parallel
T059: HomeBloc test                  ← parallel
T060: Repository test                ← parallel
T061: Widget test                    ← parallel
```

---

## Implementation Strategy

### MVP First (US7 + US1 + US2)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: US7 (Navigation shell)
4. Complete Phase 4: US1 (Home — recipe browsing)
5. Complete Phase 5: US2 (Recipe Detail — content consumption)
6. **STOP and VALIDATE**: User can browse, search, and read recipes
7. Deploy/demo MVP

### Incremental Delivery

1. **MVP**: Setup + Foundation + US7 + US1 + US2 → Browse & read recipes
2. **+Planner**: US3 → Plan weekly meals
3. **+Grocery**: US4 → Auto-generated grocery list from plan
4. **+Cookbook**: US5 → Save favorites
5. **+Auth**: US6 → Cross-device sync
6. **+Polish**: Phase 10 → Edge cases, empty states, performance, a11y

---

## Notes

- Total tasks: **174**
- Tasks per user story: US7=6, US1=30, US2=18, US3=22, US4=24, US5=15, US6=22, Setup=6, Foundation=20, Polish=11
- All `[P]` tasks within the same phase can run concurrently
- Constitution: TDD required — write failing tests before implementation within each story
- Commit after each task or logical group
- Run `flutter analyze` and `npm run lint` before each commit
