import { z } from 'zod';

export const MealPlanQuerySchema = z.object({
  start_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date format (YYYY-MM-DD)'),
  end_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date format (YYYY-MM-DD)'),
});

export const CreateMealPlanSchema = z.object({
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date format (YYYY-MM-DD)'),
});

export const CreateSlotSchema = z
  .object({
    meal_type: z.enum(['breakfast', 'lunch', 'dinner', 'snack']),
    recipe_id: z.string().uuid().optional(),
    quick_note: z.string().max(200).optional(),
    servings: z.number().int().min(1).max(50).default(2),
  })
  .refine((data) => data.recipe_id || data.quick_note, {
    message: 'Either recipe_id or quick_note is required',
  });

export const UpdateSlotSchema = z.object({
  meal_type: z.enum(['breakfast', 'lunch', 'dinner', 'snack']).optional(),
  recipe_id: z.string().uuid().nullable().optional(),
  quick_note: z.string().max(200).nullable().optional(),
  servings: z.number().int().min(1).max(50).optional(),
  display_order: z.number().int().min(0).optional(),
});

export const MealPlanIdParamSchema = z.object({
  id: z.string().uuid(),
});

export const SlotIdParamSchema = z.object({
  id: z.string().uuid(),
  slotId: z.string().uuid(),
});

export type MealPlanQuery = z.infer<typeof MealPlanQuerySchema>;
export type CreateMealPlan = z.infer<typeof CreateMealPlanSchema>;
export type CreateSlot = z.infer<typeof CreateSlotSchema>;
export type UpdateSlot = z.infer<typeof UpdateSlotSchema>;
