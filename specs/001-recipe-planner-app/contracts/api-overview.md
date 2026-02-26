# API Contracts Overview

**Feature**: 001-recipe-planner-app
**Base URL**: `https://api.recipeplanner.app/api` (production) | `http://localhost:3000/api` (dev)
**Protocol**: REST over HTTPS
**Auth**: Supabase JWT Bearer token
**Content-Type**: `application/json`

---

## Common Patterns

### Authentication

All endpoints that modify data require a valid JWT in the `Authorization` header:
```
Authorization: Bearer <supabase_jwt_token>
```

Read endpoints for public data (recipes, tags) support anonymous access.

### Error Response Format

All errors follow a consistent structure:

```json
{
  "error": "Human-readable error message",
  "code": "MACHINE_READABLE_CODE",
  "details": {}  // Optional, field-level validation errors
}
```

### HTTP Status Codes

| Code | Usage |
|------|-------|
| 200 | Success (GET, PUT, PATCH) |
| 201 | Created (POST) |
| 204 | No Content (DELETE) |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (missing/invalid token) |
| 403 | Forbidden (accessing another user's data) |
| 404 | Not Found |
| 409 | Conflict (duplicate entry) |
| 422 | Unprocessable Entity (business logic error) |
| 429 | Too Many Requests (rate limit) |
| 500 | Internal Server Error |

### Pagination

List endpoints use cursor-based pagination:

```
GET /api/recipes?cursor=<last_id>&limit=20
```

Response includes:
```json
{
  "data": [...],
  "pagination": {
    "next_cursor": "uuid-or-null",
    "has_more": true
  }
}
```

### Timestamps

All timestamps are ISO 8601 in UTC: `"2026-02-26T10:30:00Z"`

---

## Endpoint Summary

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/auth/register` | No | Create new account |
| POST | `/auth/login` | No | Sign in |
| GET | `/auth/me` | Yes | Get current user profile |
| GET | `/recipes` | No | List/search recipes |
| GET | `/recipes/trending` | No | Get trending recipes |
| GET | `/recipes/:id` | No | Get recipe detail |
| GET | `/tags` | No | List all tags |
| GET | `/cookbook` | Yes | List saved recipes |
| POST | `/cookbook/:recipeId` | Yes | Save recipe |
| DELETE | `/cookbook/:recipeId` | Yes | Unsave recipe |
| GET | `/meal-plans` | Yes | Get meal plans by date range |
| POST | `/meal-plans` | Yes | Create meal plan for a day |
| PUT | `/meal-plans/:id` | Yes | Update meal plan |
| DELETE | `/meal-plans/:id` | Yes | Delete meal plan |
| POST | `/meal-plans/:id/slots` | Yes | Add slot to meal plan |
| PUT | `/meal-plans/:id/slots/:slotId` | Yes | Update meal slot |
| DELETE | `/meal-plans/:id/slots/:slotId` | Yes | Remove meal slot |
| GET | `/grocery` | Yes | Get/generate grocery list |
| POST | `/grocery` | Yes | Add manual grocery item |
| PATCH | `/grocery/:id` | Yes | Toggle check/uncheck item |
| DELETE | `/grocery/:id` | Yes | Delete grocery item |
| DELETE | `/grocery/clear` | Yes | Clear all checked items |
| GET | `/users/profile` | Yes | Get user profile |
| PUT | `/users/profile` | Yes | Update user profile |

See individual contract files for detailed request/response schemas.
