import { NextRequest } from 'next/server';
import { getSupabaseClient } from '@/lib/supabase/client';
import { UpdateGroceryItemSchema, GroceryItemIdParamSchema } from '@/lib/validators/grocery-validators';
import { formatZodError } from '@/lib/validators/error-formatter';
import { authenticateRequest } from '@/lib/middleware/auth';
import { success, badRequest, notFound, serverError } from '@/lib/utils/api-response';
import { noContent } from '@/lib/utils/api-response';

// PATCH — toggle is_checked
export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  try {
    const { user, error: authError } = await authenticateRequest(request);
    if (authError) return authError;

    const resolvedParams = await params;
    const paramParsed = GroceryItemIdParamSchema.safeParse(resolvedParams);
    if (!paramParsed.success) {
      return badRequest('Invalid grocery item ID', formatZodError(paramParsed.error).details);
    }

    const body = await request.json();
    const parsed = UpdateGroceryItemSchema.safeParse(body);
    if (!parsed.success) {
      return badRequest('Invalid request body', formatZodError(parsed.error).details);
    }

    const supabase = getSupabaseClient();
    const { id } = paramParsed.data;
    const { is_checked } = parsed.data;

    // Verify ownership and update
    const { data: item, error } = await supabase
      .from('grocery_items')
      .update({ is_checked, updated_at: new Date().toISOString() })
      .eq('id', id)
      .eq('user_id', user!.id)
      .select('id, name, quantity, unit, is_checked')
      .single();

    if (error || !item) {
      return notFound('Grocery item not found');
    }

    return success(item);
  } catch (error) {
    console.error('PATCH /api/grocery/:id error:', error);
    return serverError('Internal server error');
  }
}

// DELETE — remove a single grocery item
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  try {
    const { user, error: authError } = await authenticateRequest(request);
    if (authError) return authError;

    const resolvedParams = await params;
    const paramParsed = GroceryItemIdParamSchema.safeParse(resolvedParams);
    if (!paramParsed.success) {
      return badRequest('Invalid grocery item ID', formatZodError(paramParsed.error).details);
    }

    const supabase = getSupabaseClient();
    const { id } = paramParsed.data;

    // Verify ownership and delete
    const { data, error } = await supabase
      .from('grocery_items')
      .delete()
      .eq('id', id)
      .eq('user_id', user!.id)
      .select('id')
      .single();

    if (error || !data) {
      return notFound('Grocery item not found');
    }

    return noContent();
  } catch (error) {
    console.error('DELETE /api/grocery/:id error:', error);
    return serverError('Internal server error');
  }
}
