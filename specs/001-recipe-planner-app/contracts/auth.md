# Auth API Contracts

**Base**: `/api/auth`
**Related Spec**: FR-028 through FR-033

---

## POST `/auth/register`

Create a new user account.

**Auth**: None required

### Request

```json
{
  "email": "user@example.com",
  "password": "securepass123",
  "display_name": "John Doe"
}
```

**Validation (Zod)**:
```typescript
z.object({
  email: z.string().email("Invalid email format"),
  password: z.string().min(8, "Password must be at least 8 characters"),
  display_name: z.string().min(1).max(100)
})
```

### Response

**201 Created**:
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "display_name": "John Doe",
    "avatar_url": null,
    "created_at": "2026-02-26T10:30:00Z"
  },
  "session": {
    "access_token": "jwt_token",
    "refresh_token": "refresh_token",
    "expires_at": "2026-02-26T11:30:00Z"
  }
}
```

**400 Bad Request** (validation):
```json
{
  "error": "Validation failed",
  "code": "VALIDATION_ERROR",
  "details": {
    "email": "Invalid email format",
    "password": "Password must be at least 8 characters"
  }
}
```

**409 Conflict** (duplicate email):
```json
{
  "error": "An account with this email already exists",
  "code": "EMAIL_ALREADY_EXISTS"
}
```

---

## POST `/auth/login`

Sign in with existing credentials.

**Auth**: None required

### Request

```json
{
  "email": "user@example.com",
  "password": "securepass123"
}
```

### Response

**200 OK**:
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "display_name": "John Doe",
    "avatar_url": "https://storage.example.com/avatars/uuid.webp",
    "created_at": "2026-02-26T10:30:00Z"
  },
  "session": {
    "access_token": "jwt_token",
    "refresh_token": "refresh_token",
    "expires_at": "2026-02-26T11:30:00Z"
  }
}
```

**401 Unauthorized** (wrong credentials — FR-031: generic message):
```json
{
  "error": "Invalid email or password",
  "code": "INVALID_CREDENTIALS"
}
```

---

## GET `/auth/me`

Get the current authenticated user's profile.

**Auth**: Required

### Response

**200 OK**:
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "display_name": "John Doe",
  "avatar_url": "https://storage.example.com/avatars/uuid.webp",
  "created_at": "2026-02-26T10:30:00Z"
}
```

**401 Unauthorized**:
```json
{
  "error": "Authentication required",
  "code": "UNAUTHENTICATED"
}
```
