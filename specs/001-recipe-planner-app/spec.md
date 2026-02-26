# Feature Specification: Recipe Planner App – Meal Plan & Grocery List

**Feature Branch**: `001-recipe-planner-app`  
**Created**: 2026-02-26  
**Status**: Draft  
**Input**: User description: "Mobile app Recipe Planner – Lên thực đơn & danh sách mua sắm cho iOS & Android. Gồm trang Home, Chi tiết Công thức, Meal Planner, Grocery List, Bottom Navigation, đăng ký/đăng nhập cơ bản."

## Assumptions

- Recipe content (images, text, nutrition data) is pre-seeded or sourced from a backend content team; the app is not a user-generated-content platform (users save/bookmark recipes but do not author public ones in v1).
- Nutrition data (calories, protein, carbs) is stored per recipe and per ingredient; the app does not calculate nutrition from scratch — it relies on pre-populated data.
- "Trending Recipes" ranking is determined server-side based on popularity metrics (views, saves); the algorithm is outside the scope of this spec.
- Guest/offline-only mode allows full read access and local meal plan/grocery list management without an account.  Creating an account enables cross-device sync and cloud backup.
- The "Share" grocery list action uses the native OS share sheet (text format); no in-app messaging is required.
- Servings adjustment uses a simple linear multiplier (e.g., 2× servings = 2× each ingredient quantity).
- Tags (e.g., #QuickLunch, #Healthy) are curated by the content team, not user-created.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 – Browse & Discover Recipes on Home Screen (Priority: P1)

A user opens the app and lands on the Home screen. They see their next planned meal at the top (if any), browse suggested tags, and scroll through trending recipes. They can tap a tag to filter, or use the search bar with filters (ingredient, time, calories) to find a specific recipe.

**Why this priority**: The Home screen is the app's entry point and primary discovery mechanism. Without it, users have no way to find recipes — it enables every downstream feature.

**Independent Test**: Can be fully tested by launching the app, verifying the search bar with filters, tag scrolling, trending grid, and "next meal" sticky card all render and respond to taps.

**Acceptance Scenarios**:

1. **Given** the user has a meal planned for tonight, **When** they open the Home screen, **Then** a sticky card at the top shows the meal name, image, and a "Start Cooking" shortcut button.
2. **Given** the user has no upcoming meal planned, **When** they open the Home screen, **Then** the sticky card section is hidden or shows a prompt to "Plan your first meal."
3. **Given** the user taps a tag (e.g., #QuickLunch), **When** the tag is selected, **Then** the trending grid below filters to show only recipes matching that tag.
4. **Given** the user types "salmon" in the search bar, **When** results load, **Then** only recipes containing "salmon" as an ingredient or in the title are displayed.
5. **Given** the user taps the filter icon in the search bar, **When** the filter panel opens, **Then** they can set constraints for ingredient, max cooking time, and max calories, and the results update accordingly.
6. **Given** the user taps the "+" quick-add button on a trending recipe card, **When** a date/meal-slot picker appears, **Then** the recipe is added to the selected meal plan slot and a confirmation is shown.

---

### User Story 2 – View Recipe Details (Priority: P1)

A user taps on a recipe (from Home, search results, or their cookbook) and navigates to the Recipe Detail screen. They see a large cover image with parallax scrolling, quick info (time, calories, rating), and two tabs: Ingredients (with checkbox list and servings adjuster) and Steps (with numbered step-by-step instructions and optional media). A "Start Cooking" button is fixed at the bottom.

**Why this priority**: Recipe details are the core content consumption experience. Users must be able to read ingredients and instructions to cook — this is the fundamental value of the app.

**Independent Test**: Can be tested by navigating to any recipe detail and verifying: parallax header, quick info row, tab switching, servings dropdown adjusting quantities, ingredient checkboxes, step numbering with media, and "Start Cooking" button presence.

**Acceptance Scenarios**:

1. **Given** the user opens a recipe detail, **When** they scroll down, **Then** the cover image exhibits a parallax effect and the "Save" and "Add to Plan" buttons remain accessible in the header area.
2. **Given** the user views the quick-info row, **When** the detail loads, **Then** cooking time, calorie count, and rating are displayed as icons with labels (e.g., ⏱️ 30 min | 📊 450 kcal | ⭐ 4.8).
3. **Given** the user is on the Ingredients tab with servings set to 2, **When** they change servings to 4 via the dropdown, **Then** all ingredient quantities double proportionally.
4. **Given** the user checks off an ingredient, **When** the checkbox is toggled, **Then** the ingredient row is visually marked as completed (strikethrough or dimmed).
5. **Given** the user switches to the Steps tab, **When** the tab renders, **Then** each step is displayed with a large step number, text instruction, and an optional thumbnail image or video beside it.
6. **Given** the user taps "Start Cooking," **When** the cooking mode activates, **Then** the app enters a step-by-step view optimized for hands-free use (large text, prominent next/previous controls).

---

### User Story 3 – Plan Weekly Meals (Priority: P1)

A user navigates to the Planner screen and sees a horizontal calendar strip showing 7 days. They tap a day to view its meal slots (Breakfast, Lunch, Dinner, Snack). They can add a recipe from their cookbook/search or type a quick note (e.g., "Eat out"). A nutrition summary tooltip shows the day's estimated totals.

**Why this priority**: Meal planning is one of the two headline features (alongside grocery list). It directly drives the grocery list generation and is central to the app's value proposition.

**Independent Test**: Can be tested by navigating to the Planner tab, selecting different days on the calendar strip, adding recipes to meal slots, adding a quick note, and verifying the nutrition summary updates.

**Acceptance Scenarios**:

1. **Given** the user opens the Planner screen, **When** it loads, **Then** a horizontal calendar strip at the top displays 7 days of the current week with today highlighted.
2. **Given** the user taps a specific day (e.g., Wednesday), **When** the day is selected, **Then** the content below updates to show that day's meal slots: Breakfast, Lunch, Dinner, and Snack.
3. **Given** the user taps "Add Recipe" on the Dinner slot, **When** the recipe picker opens, **Then** the user can search or browse their saved cookbook and select a recipe to assign to that slot.
4. **Given** the user taps "Quick Note" on a meal slot, **When** a text input appears, **Then** they can type a freeform note (e.g., "Pizza from Mario's") and it saves to that slot.
5. **Given** the user has added recipes to multiple slots for a day, **When** they view the day's summary tooltip, **Then** they see the estimated total Calories, Protein (g), and Carbs (g) for that day.
6. **Given** a recipe is assigned to a meal slot, **When** the user long-presses or swipes the item, **Then** they can remove it or move it to a different slot/day.

---

### User Story 4 – Generate & Manage Grocery List (Priority: P1)

Based on the current week's meal plan, the app generates a grocery list that groups ingredients by category (Vegetables, Meat/Fish, Spices, etc.). Identical ingredients across recipes are merged with totals and source attribution. Users can check off purchased items and clear completed ones. They can also share the list via the native share sheet.

**Why this priority**: The grocery list is the second headline feature and the natural output of meal planning. It closes the loop from "plan what to eat" to "buy what you need."

**Independent Test**: Can be tested by creating a meal plan with at least two recipes sharing common ingredients, navigating to the Grocery tab, verifying category grouping, smart-merge behavior, checkbox toggling, "Clear Completed" action, and "Share" export.

**Acceptance Scenarios**:

1. **Given** the user has a weekly meal plan with multiple recipes, **When** they open the Grocery screen, **Then** all required ingredients are listed, grouped by category (e.g., 🥦 Vegetables, 🥩 Meat/Fish, 🥫 Spices).
2. **Given** two recipes both require garlic (2 cloves + 1 clove), **When** the grocery list is generated, **Then** the list shows a single merged entry: "Garlic: 3 cloves (Used in: Beef Stir-fry, Salad)."
3. **Given** the user taps the checkbox next to an ingredient, **When** it is checked, **Then** the item is visually marked as purchased (strikethrough or dimmed) and moves to a "Completed" section or stays in place with a checked state.
4. **Given** the user taps "Clear Completed," **When** confirmed, **Then** all checked-off items are removed from the visible list.
5. **Given** the user taps "Share," **When** the native share sheet opens, **Then** the grocery list is formatted as readable text (grouped by category with quantities) ready to send via messaging, email, or notes apps.
6. **Given** the user manually adds an item that is not from any recipe, **When** they type a custom item and quantity, **Then** it appears in the appropriate category (or an "Other" category) on the list.

---

### User Story 5 – Save Recipes to Personal Cookbook (Priority: P2)

A user discovers a recipe they like and taps "Save." The recipe is added to their personal cookbook (My Cookbook tab). They can browse and organize their saved recipes from the dedicated cookbook screen accessible via the bottom navigation bar.

**Why this priority**: Saving recipes is the bridge between discovery (Home) and planning (Planner). Without a personal collection, users would have to search for recipes every time they want to plan a meal.

**Independent Test**: Can be tested by saving a recipe from the detail screen, navigating to My Cookbook, verifying it appears, and confirming unsaving removes it.

**Acceptance Scenarios**:

1. **Given** the user is viewing a recipe detail, **When** they tap the "Save" button, **Then** the recipe is added to their personal cookbook and the button state changes to "Saved."
2. **Given** the user has saved multiple recipes, **When** they navigate to the My Cookbook tab, **Then** all saved recipes are listed with thumbnail, title, and quick-info summary.
3. **Given** the user taps "Saved" (toggle) on a recipe they previously saved, **When** confirmed, **Then** the recipe is removed from their personal cookbook.

---

### User Story 6 – Register & Sign In (Priority: P2)

A new user can create an account using email and password. An existing user can sign in with their credentials. Authentication enables cloud sync of recipes, meal plans, and grocery lists across devices. The app remains fully usable in guest/offline mode for core features.

**Why this priority**: Account management enables data persistence across devices and is a prerequisite for future social/sharing features. However, core functionality must work without sign-in to avoid blocking first-time users.

**Independent Test**: Can be tested by registering a new account, signing out, signing back in, and verifying that saved data (cookbook, meal plan) persists across sessions and devices.

**Acceptance Scenarios**:

1. **Given** a new user taps "Create Account," **When** they enter a valid email and a password (minimum 8 characters), **Then** the account is created and the user is signed in.
2. **Given** the user enters an invalid email format, **When** they submit the form, **Then** an inline error message indicates the email format is incorrect.
3. **Given** the user enters a password shorter than 8 characters, **When** they submit the form, **Then** an inline error message indicates the minimum length requirement.
4. **Given** a registered user enters correct credentials, **When** they tap "Sign In," **Then** they are authenticated and their synced data (cookbook, meal plans, grocery list) loads.
5. **Given** a user enters incorrect credentials, **When** they tap "Sign In," **Then** an error message is displayed without revealing which field (email or password) is wrong.
6. **Given** a user is using the app without an account (guest mode), **When** they use core features (browse, plan, grocery), **Then** everything works locally without requiring sign-in.

---

### User Story 7 – App Navigation Structure (Priority: P1)

The app provides a bottom navigation bar with five tabs: Home, My Cookbook, Planner, Grocery, and Profile. The Grocery tab shows a badge with the count of items remaining to buy. Navigation is persistent across all screens within each tab.

**Why this priority**: Navigation is the structural skeleton of the app. All other features depend on the user being able to move between sections reliably.

**Independent Test**: Can be tested by tapping each tab and verifying the correct screen loads, the active tab is highlighted, the grocery badge updates, and tab state is preserved when switching.

**Acceptance Scenarios**:

1. **Given** the app is open, **When** the user looks at the bottom of the screen, **Then** five tab icons are visible: Home (🏠), My Cookbook (📖), Planner (🗓️), Grocery (🛒), and Profile (👤).
2. **Given** the user has 5 unchecked items on the grocery list, **When** they view the bottom bar, **Then** the Grocery tab icon shows a badge with the number "5."
3. **Given** the user taps the "Planner" tab, **When** the Planner screen loads, **Then** the Planner tab icon is highlighted as active and the previously viewed tab state is preserved.
4. **Given** the user is on a nested screen (e.g., Recipe Detail opened from Home), **When** they tap "My Cookbook" in the bottom bar, **Then** they navigate to the Cookbook tab's root screen.

---

### Edge Cases

- **Empty states**: What happens when the user has no saved recipes, no meal plan, or an empty grocery list? Each screen displays a friendly empty-state illustration with a call-to-action (e.g., "Explore recipes to get started").
- **Offline with pending sync**: What happens when the user makes changes offline and then reconnects? Local changes are queued and synced automatically; conflicts are resolved with a last-write-wins strategy and the user is notified of any merge issues.
- **Servings edge values**: What happens when the user sets servings to 0 or a very large number (e.g., 100)? The minimum servings value is capped at 1; maximum is capped at 50. Values outside this range are rejected with an inline message.
- **Duplicate account registration**: What happens when a user tries to register with an email already in use? An error message informs them the email is already registered and offers a "Sign In" link.
- **Network failure during sign-in**: What happens if the network drops mid-authentication? The app shows a retry prompt with a clear error message; no partial state is saved.
- **Recipe with missing data**: What happens if a recipe has no image, no nutrition data, or no steps? The app displays placeholder content (default image, "Nutrition not available," "Instructions coming soon") instead of crashing or showing blank areas.
- **Grocery list with no meal plan**: What happens if the user navigates to Grocery without any planned meals? The screen shows an empty state with a prompt to "Plan meals first" or allows manual item entry.

---

## Requirements *(mandatory)*

### Functional Requirements

**Home Screen**

- **FR-001**: The Home screen MUST display a search bar with integrated filter options for ingredient, maximum cooking time, and maximum calories.
- **FR-002**: The Home screen MUST display a sticky "Next Meal" card showing the user's nearest upcoming planned meal (name, image, and a shortcut to open the recipe). If no meal is planned, the card MUST be hidden or show a "Plan your first meal" prompt.
- **FR-003**: The Home screen MUST display a horizontally scrollable row of tag buttons (e.g., #QuickLunch, #Healthy, #BudgetFriendly) that filter the recipe grid when tapped.
- **FR-004**: The Home screen MUST display a grid of trending recipe cards with full-bleed images and a quick-add "+" button on each card to add the recipe to a meal plan slot.

**Recipe Detail**

- **FR-005**: The Recipe Detail screen MUST display a large cover image with a parallax scroll effect, and "Save" and "Add to Plan" action buttons.
- **FR-006**: The Recipe Detail screen MUST display a quick-info row with cooking time, calorie count, and rating as icons with labels.
- **FR-007**: The Recipe Detail screen MUST provide a tab switcher with two tabs: Ingredients and Steps.
- **FR-008**: The Ingredients tab MUST list all ingredients with checkboxes and a servings dropdown (range 1–50) that proportionally adjusts all ingredient quantities.
- **FR-009**: The Steps tab MUST display numbered, sequential cooking instructions, each with an optional thumbnail image or video beside the text.
- **FR-010**: A "Start Cooking" button MUST be fixed at the bottom of the Recipe Detail screen and activate a step-by-step cooking mode.

**Meal Planner**

- **FR-011**: The Planner screen MUST display a horizontal calendar strip showing 7 days of the current week, with today highlighted by default.
- **FR-012**: Tapping a day on the calendar strip MUST update the content below to show that day's meal slots: Breakfast, Lunch, Dinner, and Snack.
- **FR-013**: Each meal slot MUST offer an "Add Recipe" action (opens recipe picker) and a "Quick Note" action (freeform text input).
- **FR-014**: The Planner screen MUST display a nutrition summary tooltip/banner for the selected day showing estimated total Calories, Protein (g), and Carbs (g).
- **FR-015**: Users MUST be able to remove or rearrange recipes/notes within and across meal slots via long-press or swipe gesture.

**Grocery List**

- **FR-016**: The Grocery List MUST be auto-generated from the current week's meal plan, aggregating all recipe ingredients.
- **FR-017**: Ingredients MUST be grouped by category (e.g., Vegetables, Meat/Fish, Spices, Dairy, Other).
- **FR-018**: Identical ingredients across multiple recipes MUST be merged into a single entry with combined quantity and source attribution (e.g., "Garlic: 3 cloves — Used in: Beef Stir-fry, Salad").
- **FR-019**: Each ingredient item MUST have a checkbox; checked items MUST be visually marked as purchased.
- **FR-020**: The Grocery List MUST provide a "Clear Completed" button that removes all checked items after confirmation.
- **FR-021**: The Grocery List MUST provide a "Share" button that exports the list as formatted text via the native OS share sheet.
- **FR-022**: Users MUST be able to manually add custom items to the grocery list that do not originate from recipes.

**Navigation**

- **FR-023**: The app MUST provide a bottom navigation bar with five tabs: Home, My Cookbook, Planner, Grocery, and Profile.
- **FR-024**: The Grocery tab icon MUST display a badge showing the count of unchecked (remaining) grocery items.
- **FR-025**: Each tab MUST preserve its navigation state when the user switches between tabs.

**My Cookbook**

- **FR-026**: Users MUST be able to save/unsave recipes to/from their personal cookbook from the Recipe Detail screen.
- **FR-027**: The My Cookbook screen MUST list all saved recipes with thumbnail, title, and quick-info summary.

**Authentication**

- **FR-028**: Users MUST be able to create an account with email and password (minimum 8 characters).
- **FR-029**: The registration form MUST validate email format and password length inline before submission.
- **FR-030**: Users MUST be able to sign in with registered email and password credentials.
- **FR-031**: Authentication errors MUST NOT reveal whether the email or password was incorrect.
- **FR-032**: All core features (browse, plan, grocery, cookbook) MUST be fully functional in guest/offline mode without requiring an account.
- **FR-033**: Signed-in users MUST have their data (cookbook, meal plans, grocery list) synced to the cloud for cross-device access.

**Cross-Platform**

- **FR-034**: The app MUST be available on both iOS (15+) and Android (8.0+ / API 26+).
- **FR-035**: The app MUST function offline for all core features (recipe browsing of cached/saved content, meal plan management, grocery list management) with automatic sync when connectivity is restored.

### Key Entities

- **Recipe**: The central content unit. Attributes: title, cover image, cooking time (minutes), calories, rating, list of tags, servings (default), list of ingredients, list of cooking steps. A recipe can belong to many tags and appear in many meal plan slots.
- **Ingredient**: A single component of a recipe. Attributes: name, quantity, unit, category (Vegetable, Meat, Spice, etc.). An ingredient belongs to one recipe but can be merged across recipes in the grocery list.
- **CookingStep**: A single instruction within a recipe. Attributes: step number, text description, optional media (image URL or video URL). Steps are ordered sequentially within a recipe.
- **Tag**: A label for recipe categorization. Attributes: name (e.g., #QuickLunch), display order. A tag can be associated with many recipes.
- **MealPlan**: A day-level plan. Attributes: date, user reference. A meal plan has many meal slots.
- **MealSlot**: A single slot within a meal plan. Attributes: meal type (Breakfast, Lunch, Dinner, Snack), reference to a recipe (optional), quick note text (optional). A meal slot belongs to one meal plan.
- **GroceryItem**: An aggregated shopping item. Attributes: ingredient name, total quantity, unit, category, list of source recipe names, checked/purchased status. Generated from meal plan data but can also be manually created.
- **User**: An app user. Attributes: email, hashed password, profile name. A user owns meal plans, a cookbook (saved recipes), and grocery lists.
- **Cookbook**: A personal collection of saved recipes. Attributes: user reference, list of saved recipe references. Acts as a many-to-many relationship between User and Recipe.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can discover and open a recipe from the Home screen within 10 seconds of launching the app.
- **SC-002**: Users can create a full 7-day meal plan (at least 1 meal per day) in under 5 minutes.
- **SC-003**: The grocery list is accurately generated from the meal plan with 100% of ingredients present and correctly merged (no duplicates, no missing items).
- **SC-004**: 90% of first-time users successfully complete the core flow (find recipe → plan meal → view grocery list) without external guidance.
- **SC-005**: Account registration and sign-in can each be completed in under 60 seconds.
- **SC-006**: The app starts up and displays the Home screen within 2 seconds on a mid-range device.
- **SC-007**: All list views (recipes, ingredients, grocery items) scroll at 60 fps with no perceptible jank.
- **SC-008**: All core features (browse saved recipes, manage meal plan, manage grocery list) remain fully functional without network connectivity.
- **SC-009**: The app delivers feature parity across iOS and Android — every feature available on one platform is available on the other.
