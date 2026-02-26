# Meal Plans API Contracts

**Base**: `/api/meal-plans`
**Related Spec**: FR-011 through FR-015

---

## GET `/meal-plans`

Get meal plans for a date range (typically a week).

**Auth**: Required

### Query Parameters

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `start_date` | string (YYYY-MM-DD) | Yes | Start of date range |
| `end_date` | string (YYYY-MM-DD) | Yes | End of date range |

### Request Example

```
GET /api/meal-plans?start_date=2026-02-23&end_date=2026-03-01
```

### Response

**200 OK**:
```json
{
  "data": [
    {
      "id": "uuid",
      "date": "2026-02-23",
      "slots": [
        {
          "id": "uuid",
          "meal_type": "breakfast",
          "recipe": {
            "id": "uuid",
            "title": "Avocado Toast",
            "cover_image_url": "https://storage.example.com/recipes/uuid/cover.webp",
            "cooking_time_minutes": 10,
            "calories": 320
          },
          "quick_note": null,
          "servings": 2,
          "display_order": 0
        },
        {
          "id": "uuid",
          "meal_type": "lunch",
          "recipe": null,
          "quick_note": "Pizza from Mario's",
          "servings": 1,
          "display_order": 0
        },
        {
          "id": "uuid",
          "meal_type": "dinner",
          "recipe": {
            "id": "uuid",
            "title": "Grilled Salmon with Herbs",
            "cover_image_url": "https://storage.example.com/recipes/uuid/cover.webp",
            "cooking_time_minutes": 25,
            "calories": 380
          },
          "quick_note": null,
          "servings": 4,
          "display_order": 0
        }
      ],
      "nutrition_summary": {
        "calories": 700,
        "protein_grams": 55.0,
        "carbs_grams": 62.5
      }
    },
    {
      "id": "uuid",
      "date": "2026-02-24",
      "slots": [],
      "nutrition_summary": {
        "calories": 0,
        "protein_grams": 0,
        "carbs_grams": 0
      }
    }
  ]
}
```

**Notes**:
- Days without a meal plan return with empty `slots` array.
- `nutrition_summary` is computed server-side from assigned recipes × servings.
- Quick-note-only slots don't contribute to nutrition.

---

## POST `/meal-plans`

Create a meal plan for a specific day.

**Auth**: Required

### Request

```json
{
  "date": "2026-02-25"
}
```

### Response

**201 Created**:
```json
{
  "id": "uuid",
  "date": "2026-02-25",
  "slots": [],
  "nutrition_summary": {
    "calories": 0,
    "protein_grams": 0,
    "carbs_grams": 0
  }
}
```

**409 Conflict** (plan already exists for this date):
```json
{
  "error": "A meal plan already exists for this date",
  "code": "PLAN_EXISTS"
}
```

---

## PUT `/meal-plans/:id`

Update a meal plan (currently only used if extending to multi-day plans).

**Auth**: Required

### Request

```json
{
  "date": "2026-02-26"
}
```

### Response

**200 OK**: Returns updated meal plan object (same shape as GET).

---

## DELETE `/meal-plans/:id`

Delete a meal plan and all its slots.

**Auth**: Required

### Response

**204 No Content**

---

## POST `/meal-plans/:id/slots`

Add a meal slot to a meal plan.

**Auth**: Required

### Request (recipe slot)

```json
{
  "meal_type": "dinner",
  "recipe_id": "recipe-uuid",
  "servings": 4
}
```

### Request (quick note slot)

```json
{
  "meal_type": "lunch",
  "quick_note": "Pizza from Mario's"
}
```

**Validation (Zod)**:
```typescript
z.object({
  meal_type: z.enum(['breakfast', 'lunch', 'dinner', 'snack']),
  recipe_id: z.string().uuid().optional(),
  quick_note: z.string().max(200).optional(),
  servings: z.number().int().min(1).max(50).default(2)
}).refine(
  data => data.recipe_id || data.quick_note,
  "Either recipe_id or quick_note is required"
)
```

### Response

**201 Created**:
```json
{
  "id": "slot-uuid",
  "meal_type": "dinner",
  "recipe": {
    "id": "recipe-uuid",
    "title": "Grilled Salmon with Herbs",
    "cover_image_url": "https://storage.example.com/recipes/uuid/cover.webp",
    "cooking_time_minutes": 25,
    "calories": 380
  },
  "quick_note": null,
  "servings": 4,
  "display_order": 0
}
```

---

## PUT `/meal-plans/:id/slots/:slotId`

Update a meal slot (change recipe, servings, note, or meal type).

**Auth**: Required

### Request

```json
{
  "meal_type": "dinner",
  "recipe_id": "new-recipe-uuid",
  "servings": 2,
  "display_order": 1
}
```

### Response

**200 OK**: Returns updated slot object.

---

## DELETE `/meal-plans/:id/slots/:slotId`

Remove a meal slot.

**Auth**: Required

### Response

**204 No Content**
