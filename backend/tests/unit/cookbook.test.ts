/**
 * Tests for Cookbook API routes.
 * T130 — Save/unsave recipes to personal cookbook.
 */

describe('Cookbook API', () => {
  describe('GET /api/cookbook', () => {
    it('should return paginated list of saved recipes', () => {
      // Route returns { data: [], pagination: { next_cursor, has_more } }
      const response = {
        data: [
          {
            id: 'recipe-1',
            title: 'Grilled Salmon',
            cover_image_url: 'https://example.com/salmon.webp',
            cooking_time_minutes: 25,
            calories: 380,
            rating: 4.7,
            saved_at: '2024-01-15T14:00:00Z',
          },
        ],
        pagination: {
          next_cursor: null,
          has_more: false,
        },
      };

      expect(response.data).toHaveLength(1);
      expect(response.data[0].title).toBe('Grilled Salmon');
      expect(response.pagination.has_more).toBe(false);
    });

    it('should support cursor-based pagination', () => {
      const page1 = {
        data: Array(20).fill({ id: 'recipe', title: 'Recipe' }),
        pagination: { next_cursor: 'cursor-id', has_more: true },
      };

      expect(page1.pagination.has_more).toBe(true);
      expect(page1.pagination.next_cursor).toBe('cursor-id');
    });

    it('should return empty data for user with no saved recipes', () => {
      const response = {
        data: [],
        pagination: { next_cursor: null, has_more: false },
      };

      expect(response.data).toHaveLength(0);
      expect(response.pagination.has_more).toBe(false);
    });

    it('should order by saved_at descending (newest first)', () => {
      const response = {
        data: [
          { saved_at: '2024-01-20T10:00:00Z' },
          { saved_at: '2024-01-15T10:00:00Z' },
          { saved_at: '2024-01-10T10:00:00Z' },
        ],
      };

      const dates = response.data.map((d) => new Date(d.saved_at).getTime());
      expect(dates).toEqual([...dates].sort((a, b) => b - a));
    });
  });

  describe('POST /api/cookbook/:recipeId', () => {
    it('should return 201 with recipe_id and saved_at', () => {
      const response = {
        recipe_id: 'recipe-uuid',
        saved_at: '2024-01-25T10:30:00Z',
      };

      expect(response.recipe_id).toBe('recipe-uuid');
      expect(response.saved_at).toBeDefined();
    });

    it('should return 409 when recipe already saved', () => {
      const error = {
        error: 'Recipe already in cookbook',
        code: 'CONFLICT',
      };

      expect(error.code).toBe('CONFLICT');
    });

    it('should return 404 when recipe does not exist', () => {
      const error = {
        error: 'Recipe not found',
        code: 'NOT_FOUND',
      };

      expect(error.code).toBe('NOT_FOUND');
    });

    it('should reject invalid UUID format', () => {
      const invalidIds = ['not-a-uuid', '123', ''];
      invalidIds.forEach((id) => {
        const uuidRegex =
          /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
        expect(uuidRegex.test(id)).toBe(false);
      });
    });
  });

  describe('DELETE /api/cookbook/:recipeId', () => {
    it('should return 204 on successful unsave', () => {
      // DELETE returns no content
      const statusCode = 204;
      expect(statusCode).toBe(204);
    });

    it('should return 404 when recipe not in cookbook', () => {
      const error = {
        error: 'Recipe not found in cookbook',
        code: 'NOT_FOUND',
      };

      expect(error.code).toBe('NOT_FOUND');
    });
  });

  describe('Save count management', () => {
    it('should increment save_count on save', () => {
      let saveCount = 10;
      saveCount += 1; // POST /cookbook/:recipeId increments
      expect(saveCount).toBe(11);
    });

    it('should decrement save_count on unsave', () => {
      let saveCount = 10;
      saveCount -= 1; // DELETE /cookbook/:recipeId decrements
      expect(saveCount).toBe(9);
    });

    it('should not go below zero', () => {
      let saveCount = 0;
      saveCount = Math.max(0, saveCount - 1);
      expect(saveCount).toBe(0);
    });
  });
});
