# Recipes API Contracts

**Base**: `/api/recipes` and `/api/tags`
**Related Spec**: FR-001 through FR-010, FR-026, FR-027

---

## GET `/recipes`

List and search recipes with filters.

**Auth**: None required (public recipes)

### Query Parameters

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `q` | string | No | Search query (matches title and ingredient names) |
| `tag` | string | No | Filter by tag slug (e.g., `quick-lunch`) |
| `max_time` | integer | No | Maximum cooking time in minutes |
| `max_calories` | integer | No | Maximum calories per serving |
| `ingredient` | string | No | Filter by ingredient name |
| `cursor` | string | No | Pagination cursor (last recipe ID) |
| `limit` | integer | No | Results per page (default: 20, max: 50) |

### Request Example

```
GET /api/recipes?q=salmon&max_time=30&max_calories=500&limit=20
```

### Response

**200 OK**:
```json
{
  "data": [
    {
      "id": "uuid",
      "title": "Grilled Salmon with Herbs",
      "cover_image_url": "https://storage.example.com/recipes/uuid/cover.webp",
      "cooking_time_minutes": 25,
      "calories": 380,
      "rating": 4.7,
      "default_servings": 2,
      "tags": [
        { "id": "uuid", "name": "#Healthy", "slug": "healthy" }
      ],
      "is_saved": false
    }
  ],
  "pagination": {
    "next_cursor": "uuid-of-last-item",
    "has_more": true
  }
}
```

**Notes**:
- `is_saved` is `false` for anonymous users; reflects cookbook status for authenticated users.
- Search uses PostgreSQL full-text search with trigram matching for fuzzy results.

---

## GET `/recipes/trending`

Get trending recipes ordered by popularity.

**Auth**: None required

### Query Parameters

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `tag` | string | No | Filter trending by tag slug |
| `limit` | integer | No | Number of results (default: 20, max: 50) |

### Response

**200 OK**:
```json
{
  "data": [
    {
      "id": "uuid",
      "title": "Beef Stir-Fry",
      "cover_image_url": "https://storage.example.com/recipes/uuid/cover.webp",
      "cooking_time_minutes": 20,
      "calories": 450,
      "rating": 4.8,
      "default_servings": 2,
      "tags": [
        { "id": "uuid", "name": "#QuickLunch", "slug": "quick-lunch" }
      ],
      "is_saved": false
    }
  ]
}
```

---

## GET `/recipes/:id`

Get full recipe detail with ingredients, steps, and tags.

**Auth**: None required

### Response

**200 OK**:
```json
{
  "id": "uuid",
  "title": "Grilled Salmon with Herbs",
  "description": "A light and flavorful salmon dish perfect for weeknight dinners.",
  "cover_image_url": "https://storage.example.com/recipes/uuid/cover.webp",
  "cooking_time_minutes": 25,
  "calories": 380,
  "protein_grams": 35.5,
  "carbs_grams": 12.0,
  "rating": 4.7,
  "default_servings": 2,
  "is_saved": false,
  "tags": [
    { "id": "uuid", "name": "#Healthy", "slug": "healthy" },
    { "id": "uuid", "name": "#QuickLunch", "slug": "quick-lunch" }
  ],
  "ingredients": [
    {
      "id": "uuid",
      "name": "Salmon fillet",
      "quantity": 2,
      "unit": "pieces",
      "category": "Meat/Fish",
      "display_order": 1
    },
    {
      "id": "uuid",
      "name": "Fresh dill",
      "quantity": 2,
      "unit": "tablespoons",
      "category": "Spices",
      "display_order": 2
    }
  ],
  "steps": [
    {
      "id": "uuid",
      "step_number": 1,
      "instruction": "Preheat grill to medium-high heat (200°C/400°F).",
      "media_url": null,
      "media_type": null
    },
    {
      "id": "uuid",
      "step_number": 2,
      "instruction": "Season salmon fillets with salt, pepper, and fresh dill.",
      "media_url": "https://storage.example.com/recipes/uuid/steps/2.webp",
      "media_type": "image"
    }
  ]
}
```

**404 Not Found**:
```json
{
  "error": "Recipe not found",
  "code": "NOT_FOUND"
}
```

---

## GET `/tags`

List all available tags for filtering.

**Auth**: None required

### Response

**200 OK**:
```json
{
  "data": [
    { "id": "uuid", "name": "#QuickLunch", "slug": "quick-lunch", "display_order": 1 },
    { "id": "uuid", "name": "#Healthy", "slug": "healthy", "display_order": 2 },
    { "id": "uuid", "name": "#BudgetFriendly", "slug": "budget-friendly", "display_order": 3 },
    { "id": "uuid", "name": "#Vegetarian", "slug": "vegetarian", "display_order": 4 }
  ]
}
```

---

## GET `/cookbook`

List user's saved recipes.

**Auth**: Required

### Query Parameters

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `cursor` | string | No | Pagination cursor |
| `limit` | integer | No | Results per page (default: 20) |

### Response

**200 OK**:
```json
{
  "data": [
    {
      "id": "uuid",
      "title": "Grilled Salmon with Herbs",
      "cover_image_url": "https://storage.example.com/recipes/uuid/cover.webp",
      "cooking_time_minutes": 25,
      "calories": 380,
      "rating": 4.7,
      "saved_at": "2026-02-25T14:00:00Z"
    }
  ],
  "pagination": {
    "next_cursor": "uuid-or-null",
    "has_more": false
  }
}
```

---

## POST `/cookbook/:recipeId`

Save a recipe to user's cookbook.

**Auth**: Required

### Response

**201 Created**:
```json
{
  "recipe_id": "uuid",
  "saved_at": "2026-02-26T10:30:00Z"
}
```

**409 Conflict** (already saved):
```json
{
  "error": "Recipe already in cookbook",
  "code": "ALREADY_SAVED"
}
```

---

## DELETE `/cookbook/:recipeId`

Remove a recipe from user's cookbook.

**Auth**: Required

### Response

**204 No Content**

**404 Not Found** (not in cookbook):
```json
{
  "error": "Recipe not found in cookbook",
  "code": "NOT_FOUND"
}
```
