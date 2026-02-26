import { NextRequest } from 'next/server';
import { getSupabaseClient } from '@/lib/supabase/client';
import { authenticateRequest } from '@/lib/middleware/auth';
import { success, badRequest, serverError } from '@/lib/utils/api-response';

export async function GET(request: NextRequest) {
  try {
    const { user, error: authError } = await authenticateRequest(request);
    if (authError) return authError;

    const { searchParams } = new URL(request.url);
    const cursor = searchParams.get('cursor') || undefined;
    const limit = Math.min(parseInt(searchParams.get('limit') || '20', 10), 50);

    if (isNaN(limit) || limit < 1) {
      return badRequest('Invalid limit parameter');
    }

    const supabase = getSupabaseClient();

    let query = supabase
      .from('cookbooks')
      .select(
        `
        recipe_id,
        saved_at,
        recipe:recipes (
          id,
          title,
          cover_image_url,
          cooking_time_minutes,
          calories,
          rating
        )
      `,
      )
      .eq('user_id', user!.id)
      .order('saved_at', { ascending: false })
      .limit(limit + 1);

    if (cursor) {
      // Cursor-based pagination: fetch items saved before cursor timestamp
      const { data: cursorRow } = await supabase
        .from('cookbooks')
        .select('saved_at')
        .eq('user_id', user!.id)
        .eq('recipe_id', cursor)
        .single();

      if (cursorRow) {
        query = query.lt('saved_at', cursorRow.saved_at);
      }
    }

    const { data, error } = await query;

    if (error) {
      console.error('Cookbook query error:', error);
      return serverError('Failed to fetch cookbook');
    }

    const items = data ?? [];
    const hasMore = items.length > limit;
    const resultItems = hasMore ? items.slice(0, limit) : items;

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const recipes = resultItems.map((item: any) => ({
      id: item.recipe?.id ?? item.recipe_id,
      title: item.recipe?.title ?? 'Unknown',
      cover_image_url: item.recipe?.cover_image_url ?? null,
      cooking_time_minutes: item.recipe?.cooking_time_minutes ?? null,
      calories: item.recipe?.calories ?? null,
      rating: item.recipe?.rating ?? null,
      saved_at: item.saved_at,
    }));

    const lastItem = resultItems[resultItems.length - 1];

    return success({
      data: recipes,
      pagination: {
        next_cursor: hasMore ? lastItem?.recipe_id : null,
        has_more: hasMore,
      },
    });
  } catch (err) {
    console.error('Cookbook GET error:', err);
    return serverError('Internal server error');
  }
}
