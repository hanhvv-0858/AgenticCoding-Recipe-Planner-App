import { z } from 'zod';

export const GroceryQuerySchema = z.object({
  week_start: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date format (YYYY-MM-DD)'),
  regenerate: z
    .string()
    .optional()
    .transform((val) => val === 'true'),
});

export const CreateGroceryItemSchema = z.object({
  name: z.string().min(1).max(100),
  quantity: z.number().positive(),
  unit: z.string().min(1).max(30),
  category: z
    .enum([
      'Vegetables',
      'Fruits',
      'Meat/Fish',
      'Dairy',
      'Spices',
      'Grains',
      'Canned',
      'Frozen',
      'Beverages',
      'Other',
    ])
    .default('Other'),
  week_start: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date format (YYYY-MM-DD)'),
});

export const UpdateGroceryItemSchema = z.object({
  is_checked: z.boolean(),
});

export const GroceryItemIdParamSchema = z.object({
  id: z.string().uuid(),
});

export const ClearGroceryQuerySchema = z.object({
  week_start: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date format (YYYY-MM-DD)'),
});

export type GroceryQuery = z.infer<typeof GroceryQuerySchema>;
export type CreateGroceryItem = z.infer<typeof CreateGroceryItemSchema>;
export type UpdateGroceryItem = z.infer<typeof UpdateGroceryItemSchema>;
