import { NextRequest } from 'next/server';
import { getSupabaseClient } from '@/lib/supabase/client';
import { RecipeQuerySchema } from '@/lib/validators/recipe-validators';
import { formatZodError } from '@/lib/validators/error-formatter';
import { success, badRequest, serverError } from '@/lib/utils/api-response';
import { optionalAuth } from '@/lib/middleware/auth';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const rawParams = Object.fromEntries(searchParams.entries());

    const parsed = RecipeQuerySchema.safeParse(rawParams);
    if (!parsed.success) {
      return badRequest('Invalid query parameters', formatZodError(parsed.error).details);
    }

    const { q, tag, max_time, max_calories, ingredient, cursor, limit } = parsed.data;

    const supabase = getSupabaseClient();
    const user = await optionalAuth(request);

    // Build base query
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
        created_at,
        tags:recipe_tags(
          tag:tags(id, name, slug)
        )
      `)
      .eq('is_published', true);

    // Full-text search on title
    if (q) {
      query = query.ilike('title', `%${q}%`);
    }

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
          return success({ recipes: [], next_cursor: null });
        }
      }
    }

    // Filter by max cooking time
    if (max_time) {
      query = query.lte('cooking_time_minutes', max_time);
    }

    // Filter by max calories
    if (max_calories) {
      query = query.lte('calories', max_calories);
    }

    // Filter by ingredient name
    if (ingredient) {
      const { data: recipeIds } = await supabase
        .from('ingredients')
        .select('recipe_id')
        .ilike('name', `%${ingredient}%`);

      if (recipeIds && recipeIds.length > 0) {
        query = query.in(
          'id',
          recipeIds.map((r: { recipe_id: string }) => r.recipe_id),
        );
      } else {
        return success({ recipes: [], next_cursor: null });
      }
    }

    // Cursor-based pagination
    if (cursor) {
      query = query.gt('id', cursor);
    }

    query = query.order('created_at', { ascending: false }).limit(limit);

    const { data: recipes, error } = await query;

    if (error) {
      console.error('Recipe query error:', error);
      return serverError('Failed to fetch recipes');
    }

    // Check saved status for authenticated user
    let savedRecipeIds: string[] = [];
    if (user && recipes && recipes.length > 0) {
      const { data: savedData } = await supabase
        .from('cookbooks')
        .select('recipe_id')
        .eq('user_id', user.id)
        .in(
          'recipe_id',
          recipes.map((r: { id: string }) => r.id),
        );
      savedRecipeIds = (savedData ?? []).map((s: { recipe_id: string }) => s.recipe_id);
    }

    // Transform recipes
    const transformedRecipes = (recipes ?? []).map((recipe: Record<string, unknown> & { tags?: Array<{ tag: unknown }>; id: string }) => ({
      ...recipe,
      tags: recipe.tags?.map((rt: { tag: unknown }) => rt.tag) ?? [],
      is_saved: savedRecipeIds.includes(recipe.id),
    }));

    // Determine next cursor
    const nextCursor =
      transformedRecipes.length === limit
        ? transformedRecipes[transformedRecipes.length - 1].id
        : null;

    return success({
      recipes: transformedRecipes,
      next_cursor: nextCursor,
    });
  } catch (error) {
    console.error('GET /api/recipes error:', error);
    return serverError('Internal server error');
  }
}
