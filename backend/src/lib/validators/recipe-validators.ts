import { z } from 'zod';

export const RecipeQuerySchema = z.object({
  q: z.string().optional(),
  tag: z.string().optional(),
  max_time: z.coerce.number().int().positive().optional(),
  max_calories: z.coerce.number().int().nonnegative().optional(),
  ingredient: z.string().optional(),
  cursor: z.string().uuid().optional(),
  limit: z.coerce.number().int().min(1).max(50).default(20),
});

export const RecipeIdParamSchema = z.object({
  id: z.string().uuid(),
});

export type RecipeQuery = z.infer<typeof RecipeQuerySchema>;
export type RecipeIdParam = z.infer<typeof RecipeIdParamSchema>;
