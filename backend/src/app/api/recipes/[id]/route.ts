import { NextRequest } from 'next/server';
import { getSupabaseClient } from '@/lib/supabase/client';
import { optionalAuth } from '@/lib/middleware/auth';
import { RecipeIdParamSchema } from '@/lib/validators/recipe-validators';
import { success, badRequest, notFound, serverError } from '@/lib/utils/api-response';
import { formatZodError } from '@/lib/validators/error-formatter';

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    // Validate ID
    const parsed = RecipeIdParamSchema.safeParse({ id: params.id });
    if (!parsed.success) {
      return badRequest(formatZodError(parsed.error).error, formatZodError(parsed.error).details);
    }

    const supabase = getSupabaseClient();
    const { id } = parsed.data;

    // Fetch recipe with ingredients, steps, and tags
    const { data: recipe, error } = await supabase
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
        ingredients (
          id,
          name,
          quantity,
          unit,
          category,
          display_order
        ),
        cooking_steps (
          id,
          step_number,
          instruction,
          media_url,
          media_type
        ),
        recipe_tags (
          tags (
            id,
            name,
            slug
          )
        )
      `)
      .eq('id', id)
      .single();

    if (error || !recipe) {
      return notFound('Recipe not found');
    }

    // Increment view_count
    await supabase
      .from('recipes')
      .update({ view_count: (recipe.view_count || 0) + 1 })
      .eq('id', id);

    // Check is_saved for authenticated user
    let isSaved = false;
    const user = await optionalAuth(request);
    if (user) {
      const { data: bookmark } = await supabase
        .from('cookbooks')
        .select('recipe_id')
        .eq('user_id', user.id)
        .eq('recipe_id', id)
        .maybeSingle();
      isSaved = !!bookmark;
    }

    // Sort nested arrays
    const ingredients = (recipe.ingredients || []).sort(
      (a: { display_order: number }, b: { display_order: number }) => a.display_order - b.display_order
    );
    const steps = (recipe.cooking_steps || []).sort(
      (a: { step_number: number }, b: { step_number: number }) => a.step_number - b.step_number
    );

    // Transform tags from nested join
    const tags = (recipe.recipe_tags || []).map((rt: { tags: unknown }) => rt.tags);

    return success({
      id: recipe.id,
      title: recipe.title,
      description: recipe.description,
      cover_image_url: recipe.cover_image_url,
      cooking_time_minutes: recipe.cooking_time_minutes,
      calories: recipe.calories,
      protein_grams: recipe.protein_grams,
      carbs_grams: recipe.carbs_grams,
      rating: recipe.rating,
      default_servings: recipe.default_servings,
      is_saved: isSaved,
      tags,
      ingredients,
      steps,
    });
  } catch (err) {
    console.error('GET /api/recipes/:id error:', err);
    return serverError('Internal server error');
  }
}
