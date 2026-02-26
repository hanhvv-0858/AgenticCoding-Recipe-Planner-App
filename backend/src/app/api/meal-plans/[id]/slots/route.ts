import { NextRequest } from 'next/server';
import { getSupabaseClient } from '@/lib/supabase/client';
import { CreateSlotSchema, UpdateSlotSchema } from '@/lib/validators/meal-plan-validators';
import { formatZodError } from '@/lib/validators/error-formatter';
import { authenticateRequest } from '@/lib/middleware/auth';
import {
  created,
  success,
  noContent,
  badRequest,
  notFound,
  serverError,
} from '@/lib/utils/api-response';

// Helper: verify meal plan belongs to user
async function verifyMealPlanOwnership(
  planId: string,
  userId: string,
): Promise<{ valid: boolean; error?: ReturnType<typeof notFound> }> {
  const supabase = getSupabaseClient();
  const { data, error } = await supabase
    .from('meal_plans')
    .select('id')
    .eq('id', planId)
    .eq('user_id', userId)
    .single();

  if (error || !data) {
    return { valid: false, error: notFound('Meal plan not found') };
  }
  return { valid: true };
}

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  try {
    const { user, error: authError } = await authenticateRequest(request);
    if (authError) return authError;

    const { id: planId } = await params;

    // Verify ownership
    const ownership = await verifyMealPlanOwnership(planId, user!.id);
    if (!ownership.valid) return ownership.error!;

    const body = await request.json();
    const parsed = CreateSlotSchema.safeParse(body);
    if (!parsed.success) {
      return badRequest('Invalid request body', formatZodError(parsed.error).details);
    }

    const { meal_type, recipe_id, quick_note, servings } = parsed.data;
    const supabase = getSupabaseClient();

    // Get max display_order for this meal plan
    const { data: existingSlots } = await supabase
      .from('meal_slots')
      .select('display_order')
      .eq('meal_plan_id', planId)
      .order('display_order', { ascending: false })
      .limit(1);

    const nextOrder = existingSlots && existingSlots.length > 0 ? existingSlots[0].display_order + 1 : 0;

    // Insert slot
    const { data: newSlot, error } = await supabase
      .from('meal_slots')
      .insert({
        meal_plan_id: planId,
        meal_type,
        recipe_id: recipe_id ?? null,
        quick_note: quick_note ?? null,
        servings,
        display_order: nextOrder,
      })
      .select(
        `
        id,
        meal_type,
        recipe_id,
        quick_note,
        servings,
        display_order,
        recipe:recipes (
          id,
          title,
          cover_image_url,
          cooking_time_minutes,
          calories
        )
      `,
      )
      .single();

    if (error) {
      console.error('Create slot error:', error);
      return serverError('Failed to create meal slot');
    }

    return created({
      id: newSlot.id,
      meal_type: newSlot.meal_type,
      recipe: newSlot.recipe ?? null,
      quick_note: newSlot.quick_note,
      servings: newSlot.servings,
      display_order: newSlot.display_order,
    });
  } catch (error) {
    console.error('POST /api/meal-plans/:id/slots error:', error);
    return serverError('Internal server error');
  }
}

export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  try {
    const { user, error: authError } = await authenticateRequest(request);
    if (authError) return authError;

    const { id: planId } = await params;
    const { searchParams } = new URL(request.url);
    const slotId = searchParams.get('slotId');

    if (!slotId) {
      return badRequest('slotId query parameter is required');
    }

    // Verify ownership
    const ownership = await verifyMealPlanOwnership(planId, user!.id);
    if (!ownership.valid) return ownership.error!;

    const body = await request.json();
    const parsed = UpdateSlotSchema.safeParse(body);
    if (!parsed.success) {
      return badRequest('Invalid request body', formatZodError(parsed.error).details);
    }

    const supabase = getSupabaseClient();

    // Verify slot belongs to this meal plan
    const { data: existingSlot } = await supabase
      .from('meal_slots')
      .select('id')
      .eq('id', slotId)
      .eq('meal_plan_id', planId)
      .single();

    if (!existingSlot) {
      return notFound('Meal slot not found');
    }

    // Update slot
    const updateData: Record<string, unknown> = {};
    if (parsed.data.meal_type !== undefined) updateData.meal_type = parsed.data.meal_type;
    if (parsed.data.recipe_id !== undefined) updateData.recipe_id = parsed.data.recipe_id;
    if (parsed.data.quick_note !== undefined) updateData.quick_note = parsed.data.quick_note;
    if (parsed.data.servings !== undefined) updateData.servings = parsed.data.servings;
    if (parsed.data.display_order !== undefined) updateData.display_order = parsed.data.display_order;
    updateData.updated_at = new Date().toISOString();

    const { data: updatedSlot, error } = await supabase
      .from('meal_slots')
      .update(updateData)
      .eq('id', slotId)
      .select(
        `
        id,
        meal_type,
        recipe_id,
        quick_note,
        servings,
        display_order,
        recipe:recipes (
          id,
          title,
          cover_image_url,
          cooking_time_minutes,
          calories
        )
      `,
      )
      .single();

    if (error) {
      console.error('Update slot error:', error);
      return serverError('Failed to update meal slot');
    }

    return success({
      id: updatedSlot.id,
      meal_type: updatedSlot.meal_type,
      recipe: updatedSlot.recipe ?? null,
      quick_note: updatedSlot.quick_note,
      servings: updatedSlot.servings,
      display_order: updatedSlot.display_order,
    });
  } catch (error) {
    console.error('PUT /api/meal-plans/:id/slots error:', error);
    return serverError('Internal server error');
  }
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  try {
    const { user, error: authError } = await authenticateRequest(request);
    if (authError) return authError;

    const { id: planId } = await params;
    const { searchParams } = new URL(request.url);
    const slotId = searchParams.get('slotId');

    if (!slotId) {
      return badRequest('slotId query parameter is required');
    }

    // Verify ownership
    const ownership = await verifyMealPlanOwnership(planId, user!.id);
    if (!ownership.valid) return ownership.error!;

    const supabase = getSupabaseClient();

    // Verify slot belongs to this meal plan
    const { data: existingSlot } = await supabase
      .from('meal_slots')
      .select('id')
      .eq('id', slotId)
      .eq('meal_plan_id', planId)
      .single();

    if (!existingSlot) {
      return notFound('Meal slot not found');
    }

    const { error } = await supabase.from('meal_slots').delete().eq('id', slotId);

    if (error) {
      console.error('Delete slot error:', error);
      return serverError('Failed to delete meal slot');
    }

    return noContent();
  } catch (error) {
    console.error('DELETE /api/meal-plans/:id/slots error:', error);
    return serverError('Internal server error');
  }
}
