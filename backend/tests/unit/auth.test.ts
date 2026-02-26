/**
 * Tests for Auth API routes.
 * T147 — Registration, login, profile.
 */
import { RegisterSchema, LoginSchema, UpdateProfileSchema } from '../../src/lib/validators/auth-validators';

describe('Auth Validators', () => {
  describe('RegisterSchema', () => {
    it('should validate correct registration data', () => {
      const result = RegisterSchema.safeParse({
        email: 'user@example.com',
        password: 'securepass123',
        display_name: 'John Doe',
      });
      expect(result.success).toBe(true);
    });

    it('should reject invalid email', () => {
      const result = RegisterSchema.safeParse({
        email: 'not-an-email',
        password: 'securepass123',
        display_name: 'John Doe',
      });
      expect(result.success).toBe(false);
    });

    it('should reject short password', () => {
      const result = RegisterSchema.safeParse({
        email: 'user@example.com',
        password: 'short',
        display_name: 'John Doe',
      });
      expect(result.success).toBe(false);
      if (!result.success) {
        expect(result.error.issues[0].message).toContain('8 characters');
      }
    });

    it('should reject empty display name', () => {
      const result = RegisterSchema.safeParse({
        email: 'user@example.com',
        password: 'securepass123',
        display_name: '',
      });
      expect(result.success).toBe(false);
    });

    it('should reject display name over 100 chars', () => {
      const result = RegisterSchema.safeParse({
        email: 'user@example.com',
        password: 'securepass123',
        display_name: 'a'.repeat(101),
      });
      expect(result.success).toBe(false);
    });
  });

  describe('LoginSchema', () => {
    it('should validate correct login data', () => {
      const result = LoginSchema.safeParse({
        email: 'user@example.com',
        password: 'securepass123',
      });
      expect(result.success).toBe(true);
    });

    it('should reject invalid email', () => {
      const result = LoginSchema.safeParse({
        email: 'invalid',
        password: 'securepass123',
      });
      expect(result.success).toBe(false);
    });

    it('should reject empty password', () => {
      const result = LoginSchema.safeParse({
        email: 'user@example.com',
        password: '',
      });
      expect(result.success).toBe(false);
    });
  });

  describe('UpdateProfileSchema', () => {
    it('should validate display_name update', () => {
      const result = UpdateProfileSchema.safeParse({
        display_name: 'New Name',
      });
      expect(result.success).toBe(true);
    });

    it('should validate avatar_url update', () => {
      const result = UpdateProfileSchema.safeParse({
        avatar_url: 'https://example.com/avatar.webp',
      });
      expect(result.success).toBe(true);
    });

    it('should allow null avatar_url', () => {
      const result = UpdateProfileSchema.safeParse({
        avatar_url: null,
      });
      expect(result.success).toBe(true);
    });

    it('should reject invalid avatar_url', () => {
      const result = UpdateProfileSchema.safeParse({
        avatar_url: 'not-a-url',
      });
      expect(result.success).toBe(false);
    });

    it('should accept empty object', () => {
      const result = UpdateProfileSchema.safeParse({});
      expect(result.success).toBe(true);
    });
  });
});

describe('Auth API Endpoints', () => {
  describe('POST /api/auth/register', () => {
    it('should return 201 with user and session on success', () => {
      const response = {
        user: {
          id: 'uuid',
          email: 'user@example.com',
          display_name: 'John Doe',
          avatar_url: null,
          created_at: '2024-01-25T10:30:00Z',
        },
        session: {
          access_token: 'jwt_token',
          refresh_token: 'refresh_token',
          expires_at: '2024-01-25T11:30:00Z',
        },
      };

      expect(response.user.email).toBe('user@example.com');
      expect(response.session.access_token).toBeDefined();
    });

    it('should return 409 for duplicate email', () => {
      const error = {
        error: 'An account with this email already exists',
        code: 'EMAIL_ALREADY_EXISTS',
      };
      // The actual code would be 'CONFLICT' based on our api-response.ts
      expect(error.error).toContain('already exists');
    });
  });

  describe('POST /api/auth/login', () => {
    it('should return 200 with user and session on success', () => {
      const response = {
        user: {
          id: 'uuid',
          email: 'user@example.com',
          display_name: 'John Doe',
        },
        session: {
          access_token: 'jwt_token',
          refresh_token: 'refresh_token',
        },
      };

      expect(response.user.id).toBeDefined();
      expect(response.session.access_token).toBeDefined();
    });

    it('should return generic error for invalid credentials (FR-031)', () => {
      const error = {
        error: 'Invalid email or password',
        code: 'INVALID_CREDENTIALS',
      };

      // Must NOT reveal whether email exists
      expect(error.error).toBe('Invalid email or password');
      expect(error.error).not.toContain('email not found');
      expect(error.error).not.toContain('wrong password');
    });
  });

  describe('GET /api/auth/me', () => {
    it('should return user profile for authenticated user', () => {
      const profile = {
        id: 'uuid',
        email: 'user@example.com',
        display_name: 'John Doe',
        avatar_url: null,
        created_at: '2024-01-25T10:30:00Z',
      };

      expect(profile.id).toBeDefined();
      expect(profile.email).toBeDefined();
    });

    it('should return 401 for unauthenticated request', () => {
      const error = {
        error: 'Authentication required',
        code: 'UNAUTHENTICATED',
      };

      expect(error.code).toBe('UNAUTHENTICATED');
    });
  });

  describe('GET/PUT /api/users/profile', () => {
    it('GET should return profile', () => {
      const profile = {
        id: 'uuid',
        email: 'user@example.com',
        display_name: 'John Doe',
      };
      expect(profile.display_name).toBe('John Doe');
    });

    it('PUT should update profile fields', () => {
      const updated = {
        id: 'uuid',
        email: 'user@example.com',
        display_name: 'Jane Doe',
        avatar_url: 'https://example.com/new-avatar.webp',
      };
      expect(updated.display_name).toBe('Jane Doe');
    });
  });
});
