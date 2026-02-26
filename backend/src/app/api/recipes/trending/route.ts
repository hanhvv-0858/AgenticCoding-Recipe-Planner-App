import { NextRequest } from 'next/server';
import { getSupabaseClient } from '@/lib/supabase/client';
import { success, serverError } from '@/lib/utils/api-response';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const tag = searchParams.get('tag');
    const limit = Math.min(parseInt(searchParams.get('limit') ?? '20', 10), 50);

    const supabase = getSupabaseClient();

    let query = supabase
      .from('recipes')
      .select(`
        id,
        title,
        description,
        cover_image_url,
        cooking_time_minutes,
        calories,
        protein_grams,
        carbs_grams,
        rating,
        default_servings,
        view_count,
        save_count,
        tags:recipe_tags(
          tag:tags(id, name, slug)
        )
      `)
      .eq('is_published', true);

    // Filter by tag
    if (tag) {
      const { data: tagData } = await supabase
        .from('tags')
        .select('id')
        .eq('slug', tag)
        .single();

      if (tagData) {
        const { data: recipeIds } = await supabase
          .from('recipe_tags')
          .select('recipe_id')
          .eq('tag_id', tagData.id);

        if (recipeIds && recipeIds.length > 0) {
          query = query.in(
            'id',
            recipeIds.map((r: { recipe_id: string }) => r.recipe_id),
          );
        } else {
          return success([]);
        }
      }
    }

    // Order by trending score (view_count + save_count)
    query = query
      .order('view_count', { ascending: false })
      .order('save_count', { ascending: false })
      .limit(limit);

    const { data: recipes, error } = await query;

    if (error) {
      console.error('Trending recipes error:', error);
      return serverError('Failed to fetch trending recipes');
    }

    // Transform tags
    const transformed = (recipes ?? []).map((recipe: Record<string, unknown> & { tags?: Array<{ tag: unknown }> }) => ({
      ...recipe,
      tags: recipe.tags?.map((rt: { tag: unknown }) => rt.tag) ?? [],
    }));

    return success(transformed);
  } catch (error) {
    console.error('GET /api/recipes/trending error:', error);
    return serverError('Internal server error');
  }
}
