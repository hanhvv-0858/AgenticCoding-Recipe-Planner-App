import { NextRequest } from 'next/server';
import { getSupabaseClient } from '@/lib/supabase/client';
import { ClearGroceryQuerySchema } from '@/lib/validators/grocery-validators';
import { formatZodError } from '@/lib/validators/error-formatter';
import { authenticateRequest } from '@/lib/middleware/auth';
import { success, badRequest, serverError } from '@/lib/utils/api-response';

export async function DELETE(request: NextRequest) {
  try {
    const { user, error: authError } = await authenticateRequest(request);
    if (authError) return authError;

    const { searchParams } = new URL(request.url);
    const rawParams = Object.fromEntries(searchParams.entries());

    const parsed = ClearGroceryQuerySchema.safeParse(rawParams);
    if (!parsed.success) {
      return badRequest('Invalid query parameters', formatZodError(parsed.error).details);
    }

    const { week_start } = parsed.data;
    const supabase = getSupabaseClient();

    // Count checked items before deleting
    const { count: checkedCount, error: countError } = await supabase
      .from('grocery_items')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', user!.id)
      .eq('week_start_date', week_start)
      .eq('is_checked', true);

    if (countError) {
      console.error('Grocery count error:', countError);
      return serverError('Failed to count checked items');
    }

    // Delete all checked items for the week
    const { error: deleteError } = await supabase
      .from('grocery_items')
      .delete()
      .eq('user_id', user!.id)
      .eq('week_start_date', week_start)
      .eq('is_checked', true);

    if (deleteError) {
      console.error('Grocery clear error:', deleteError);
      return serverError('Failed to clear completed items');
    }

    // Count remaining items
    const { count: remainingCount, error: remainError } = await supabase
      .from('grocery_items')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', user!.id)
      .eq('week_start_date', week_start);

    if (remainError) {
      console.error('Grocery remaining count error:', remainError);
      return serverError('Failed to count remaining items');
    }

    return success({
      cleared_count: checkedCount ?? 0,
      remaining_count: remainingCount ?? 0,
    });
  } catch (error) {
    console.error('DELETE /api/grocery/clear error:', error);
    return serverError('Internal server error');
  }
}
