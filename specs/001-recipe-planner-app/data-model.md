# Data Model: Recipe Planner App

**Feature**: 001-recipe-planner-app
**Date**: 2026-02-26
**Source**: [spec.md](spec.md) Key Entities + [research.md](research.md)

---

## Entity Relationship Overview

```
┌───────────┐       ┌────────────────┐       ┌─────────────┐
│   User    │──1:N──│   MealPlan     │──1:N──│  MealSlot   │
└───────────┘       └────────────────┘       └──────┬──────┘
      │                                              │
      │ 1:N                                     0..1 │ recipe_id
      ▼                                              ▼
┌───────────┐       ┌────────────────┐       ┌─────────────┐
│ Cookbook   │──N:M──│    Recipe      │──1:N──│ Ingredient  │
│ (pivot)   │       └───────┬────────┘       └─────────────┘
└───────────┘               │
                       1:N  │  N:M
                            ▼
                    ┌───────────────┐       ┌──────────┐
                    │ CookingStep   │       │   Tag    │
                    └───────────────┘       └──────────┘
                                                 │
                                            N:M  │ recipe_tags
                                                 ▼
                                           ┌───────────┐
                                           │  Recipe    │
                                           └───────────┘

┌──────────────┐
│ GroceryItem  │──N:1── User
└──────────────┘

┌──────────────┐
│  SyncQueue   │  (local only — drift)
└──────────────┘
```

---

## Supabase (PostgreSQL) Tables

### `users`

> Extends Supabase Auth `auth.users`. This is a profile table linked via FK.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | PK, FK → auth.users.id | Matches Supabase Auth user ID |
| `display_name` | `varchar(100)` | NOT NULL | User's display name |
| `avatar_url` | `text` | NULLABLE | Profile image URL |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT now() | Account creation time |
| `updated_at` | `timestamptz` | NOT NULL, DEFAULT now() | Last profile update |

**RLS Policy**: Users can only read/update their own profile row.

---

### `recipes`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | Unique recipe ID |
| `title` | `varchar(200)` | NOT NULL | Recipe name |
| `description` | `text` | NULLABLE | Short description |
| `cover_image_url` | `text` | NULLABLE | URL to cover image in Supabase Storage |
| `cooking_time_minutes` | `integer` | NOT NULL, CHECK > 0 | Total cooking time |
| `calories` | `integer` | NULLABLE, CHECK >= 0 | Calories per default serving |
| `protein_grams` | `decimal(6,1)` | NULLABLE | Protein per default serving |
| `carbs_grams` | `decimal(6,1)` | NULLABLE | Carbs per default serving |
| `rating` | `decimal(2,1)` | NULLABLE, CHECK 0-5 | Average user rating |
| `default_servings` | `integer` | NOT NULL, DEFAULT 2, CHECK 1-50 | Default serving count |
| `view_count` | `integer` | NOT NULL, DEFAULT 0 | For trending calculation |
| `save_count` | `integer` | NOT NULL, DEFAULT 0 | For trending calculation |
| `is_published` | `boolean` | NOT NULL, DEFAULT true | Content team publish flag |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT now() | |
| `updated_at` | `timestamptz` | NOT NULL, DEFAULT now() | |

**Indexes**:
- `idx_recipes_title` — GIN trigram index on `title` for fuzzy search
- `idx_recipes_calories` — B-tree on `calories` for filter queries
- `idx_recipes_cooking_time` — B-tree on `cooking_time_minutes` for filter queries
- `idx_recipes_trending` — Composite on `(view_count DESC, save_count DESC)` for trending
- `idx_recipes_published` — Partial index `WHERE is_published = true`

**RLS Policy**: All authenticated and anonymous users can read published recipes. Only service role can insert/update.

---

### `ingredients`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | |
| `recipe_id` | `uuid` | FK → recipes.id, ON DELETE CASCADE | Parent recipe |
| `name` | `varchar(100)` | NOT NULL | Ingredient name (e.g., "garlic") |
| `quantity` | `decimal(8,2)` | NOT NULL | Amount for default servings |
| `unit` | `varchar(30)` | NOT NULL | Measurement unit (e.g., "cloves", "grams") |
| `category` | `varchar(50)` | NOT NULL, DEFAULT 'Other' | Grocery category |
| `display_order` | `integer` | NOT NULL, DEFAULT 0 | Order in recipe ingredient list |
| `normalized_name` | `varchar(100)` | NOT NULL | Lowercase, singular for merging |

**Valid Categories**: `Vegetables`, `Fruits`, `Meat/Fish`, `Dairy`, `Spices`, `Grains`, `Canned`, `Frozen`, `Beverages`, `Other`

**Indexes**:
- `idx_ingredients_recipe` — B-tree on `recipe_id`
- `idx_ingredients_normalized` — B-tree on `normalized_name` for merge lookups

---

### `cooking_steps`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | |
| `recipe_id` | `uuid` | FK → recipes.id, ON DELETE CASCADE | Parent recipe |
| `step_number` | `integer` | NOT NULL, CHECK > 0 | Sequential order |
| `instruction` | `text` | NOT NULL | Step text |
| `media_url` | `text` | NULLABLE | Image or video URL |
| `media_type` | `varchar(10)` | NULLABLE, CHECK IN ('image', 'video') | Type of media |

**Indexes**:
- `idx_steps_recipe_order` — Composite on `(recipe_id, step_number)` UNIQUE

---

### `tags`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | |
| `name` | `varchar(50)` | NOT NULL, UNIQUE | Tag display name (e.g., "#QuickLunch") |
| `slug` | `varchar(50)` | NOT NULL, UNIQUE | URL-safe slug (e.g., "quick-lunch") |
| `display_order` | `integer` | NOT NULL, DEFAULT 0 | Order in tag row |

---

### `recipe_tags` (junction)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `recipe_id` | `uuid` | FK → recipes.id, ON DELETE CASCADE | |
| `tag_id` | `uuid` | FK → tags.id, ON DELETE CASCADE | |

**PK**: Composite `(recipe_id, tag_id)`

---

### `cookbooks` (user saved recipes — junction)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | `uuid` | FK → users.id, ON DELETE CASCADE | |
| `recipe_id` | `uuid` | FK → recipes.id, ON DELETE CASCADE | |
| `saved_at` | `timestamptz` | NOT NULL, DEFAULT now() | When user saved the recipe |

**PK**: Composite `(user_id, recipe_id)`

**RLS Policy**: Users can only read/insert/delete their own cookbook entries.

---

### `meal_plans`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | |
| `user_id` | `uuid` | FK → users.id, ON DELETE CASCADE | Plan owner |
| `date` | `date` | NOT NULL | The calendar day |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT now() | |
| `updated_at` | `timestamptz` | NOT NULL, DEFAULT now() | |

**Unique Constraint**: `(user_id, date)` — one plan per user per day

**Indexes**:
- `idx_meal_plans_user_date` — Composite on `(user_id, date)` for week queries

**RLS Policy**: Users can only CRUD their own meal plans.

---

### `meal_slots`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | |
| `meal_plan_id` | `uuid` | FK → meal_plans.id, ON DELETE CASCADE | Parent day plan |
| `meal_type` | `varchar(20)` | NOT NULL, CHECK IN ('breakfast', 'lunch', 'dinner', 'snack') | Slot type |
| `recipe_id` | `uuid` | FK → recipes.id, NULLABLE | Assigned recipe (optional) |
| `quick_note` | `text` | NULLABLE | Freeform note (e.g., "Eat out") |
| `servings` | `integer` | NOT NULL, DEFAULT 2, CHECK 1-50 | Servings for this slot |
| `display_order` | `integer` | NOT NULL, DEFAULT 0 | Order within meal type |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT now() | |
| `updated_at` | `timestamptz` | NOT NULL, DEFAULT now() | |

**Validation**: At least one of `recipe_id` or `quick_note` must be non-null.

**Indexes**:
- `idx_slots_meal_plan` — B-tree on `meal_plan_id`
- `idx_slots_recipe` — B-tree on `recipe_id` (for "which plans use this recipe?" queries)

**RLS Policy**: Inherits from meal_plans (user can only access their own).

---

### `grocery_items`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | |
| `user_id` | `uuid` | FK → users.id, ON DELETE CASCADE | Owner |
| `name` | `varchar(100)` | NOT NULL | Ingredient display name |
| `quantity` | `decimal(8,2)` | NOT NULL | Total merged quantity |
| `unit` | `varchar(30)` | NOT NULL | |
| `category` | `varchar(50)` | NOT NULL, DEFAULT 'Other' | Grocery aisle category |
| `source_recipes` | `text[]` | NOT NULL, DEFAULT '{}' | Array of recipe names for attribution |
| `is_checked` | `boolean` | NOT NULL, DEFAULT false | Purchased status |
| `is_manual` | `boolean` | NOT NULL, DEFAULT false | User-added (not from recipes) |
| `week_start_date` | `date` | NOT NULL | Week this list belongs to |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT now() | |
| `updated_at` | `timestamptz` | NOT NULL, DEFAULT now() | |

**Indexes**:
- `idx_grocery_user_week` — Composite on `(user_id, week_start_date)`
- `idx_grocery_checked` — Partial index on `(user_id) WHERE is_checked = false` for badge count

**RLS Policy**: Users can only CRUD their own grocery items.

---

## Local Database (drift / SQLite) — Flutter

The local database mirrors the Supabase schema for offline support. Additional tables:

### `sync_queue` (local only)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `integer` | PK, autoincrement |
| `entity_type` | `text` | 'meal_plan', 'meal_slot', 'grocery_item', 'cookbook' |
| `entity_id` | `text` | UUID of the entity |
| `operation` | `text` | 'create', 'update', 'delete' |
| `payload` | `text` | JSON serialized data |
| `created_at` | `integer` | Unix timestamp |
| `retry_count` | `integer` | Default 0, max 3 |
| `status` | `text` | 'pending', 'processing', 'failed' |

### `cached_recipes` (local only)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `text` | Recipe UUID |
| `data` | `text` | Full recipe JSON (including ingredients, steps, tags) |
| `cached_at` | `integer` | Unix timestamp |
| `is_saved` | `integer` | 1 if in user's cookbook |

### `local_meal_plans` (local only)

Mirrors `meal_plans` + `meal_slots` for offline editing.

### `local_grocery_items` (local only)

Mirrors `grocery_items` for offline checking/adding.

---

## Dart Domain Entities (Clean Architecture)

### Recipe

```dart
class Recipe extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? coverImageUrl;
  final int cookingTimeMinutes;
  final int? calories;
  final double? proteinGrams;
  final double? carbsGrams;
  final double? rating;
  final int defaultServings;
  final List<Ingredient> ingredients;
  final List<CookingStep> steps;
  final List<Tag> tags;
  final bool isSaved; // UI state — is in user's cookbook

  @override
  List<Object?> get props => [id];
}
```

### Ingredient

```dart
class Ingredient extends Equatable {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final int displayOrder;

  /// Returns a new Ingredient with quantity adjusted for [servings].
  Ingredient adjustForServings(int defaultServings, int targetServings) {
    return copyWith(
      quantity: quantity * targetServings / defaultServings,
    );
  }

  @override
  List<Object?> get props => [id];
}
```

### CookingStep

```dart
class CookingStep extends Equatable {
  final String id;
  final int stepNumber;
  final String instruction;
  final String? mediaUrl;
  final MediaType? mediaType; // enum: image, video

  @override
  List<Object?> get props => [id];
}
```

### Tag

```dart
class Tag extends Equatable {
  final String id;
  final String name;
  final String slug;
  final int displayOrder;

  @override
  List<Object?> get props => [id];
}
```

### MealPlan

```dart
class MealPlan extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final List<MealSlot> slots;

  /// Computed: total nutrition for the day.
  NutritionSummary get nutritionSummary => NutritionSummary(
    calories: slots.where((s) => s.recipe != null)
      .fold(0, (sum, s) => sum + (s.recipe!.calories ?? 0)),
    proteinGrams: slots.where((s) => s.recipe != null)
      .fold(0.0, (sum, s) => sum + (s.recipe!.proteinGrams ?? 0)),
    carbsGrams: slots.where((s) => s.recipe != null)
      .fold(0.0, (sum, s) => sum + (s.recipe!.carbsGrams ?? 0)),
  );

  @override
  List<Object?> get props => [id];
}
```

### MealSlot

```dart
class MealSlot extends Equatable {
  final String id;
  final MealType mealType; // enum: breakfast, lunch, dinner, snack
  final Recipe? recipe;
  final String? quickNote;
  final int servings;
  final int displayOrder;

  @override
  List<Object?> get props => [id];
}
```

### GroceryItem

```dart
class GroceryItem extends Equatable {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final List<String> sourceRecipes;
  final bool isChecked;
  final bool isManual;

  @override
  List<Object?> get props => [id];
}
```

### User

```dart
class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id];
}
```

---

## State Transitions

### Recipe Save State

```
Unsaved ──[tap Save]──► Saving ──[success]──► Saved
                              └──[failure]──► Unsaved (show error)
Saved ──[tap Unsaved]──► Removing ──[success]──► Unsaved
                                  └──[failure]──► Saved (show error)
```

### Meal Plan Editing State

```
Viewing ──[tap Add Recipe]──► PickingRecipe ──[select]──► Saving ──[success]──► Viewing (updated)
                                            └──[cancel]──► Viewing
Viewing ──[tap Quick Note]──► EditingNote ──[save]──► Saving ──[success]──► Viewing (updated)
Viewing ──[long-press slot]──► Reordering ──[drop]──► Saving ──[success]──► Viewing (updated)
Viewing ──[swipe slot]──► Confirming Delete ──[confirm]──► Deleting ──[success]──► Viewing (updated)
```

### Grocery Sync State

```
Synced ──[offline edit]──► LocalModified ──[reconnect]──► Syncing ──[success]──► Synced
                                                                  └──[conflict]──► Resolved (last-write-wins + notify)
                                                                  └──[failure]──► PendingRetry ──[retry]──► Syncing
```

---

## Validation Rules

| Entity | Field | Rule |
|--------|-------|------|
| User | email | Valid email format (RFC 5322 basic) |
| User | password | Minimum 8 characters |
| Recipe | default_servings | 1 ≤ value ≤ 50 |
| MealSlot | servings | 1 ≤ value ≤ 50 |
| MealSlot | recipe_id / quick_note | At least one must be non-null |
| Ingredient | quantity | > 0 |
| CookingStep | step_number | > 0, unique per recipe |
| GroceryItem | quantity | > 0 |
| MealPlan | date | Valid date, not more than 1 year in the past |
