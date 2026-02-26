import { z } from 'zod';

export const TagResponseSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  slug: z.string(),
  display_order: z.number().int(),
});

export type TagResponse = z.infer<typeof TagResponseSchema>;
