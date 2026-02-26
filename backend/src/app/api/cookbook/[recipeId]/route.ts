import { NextRequest } from 'next/server';
import { getSupabaseClient } from '@/lib/supabase/client';
import { authenticateRequest } from '@/lib/middleware/auth';
import { created, noContent, notFound, conflict, badRequest, serverError } from '@/lib/utils/api-response';

interface RouteParams {
  params: Promise<{ recipeId: string }>;
}

export async function POST(request: NextRequest, { params }: RouteParams) {
  try {
    const { user, error: authError } = await authenticateRequest(request);
    if (authError) return authError;

    const { recipeId } = await params;

    // Validate UUID format
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(recipeId)) {
      return badRequest('Invalid recipe ID format');
    }

    const supabase = getSupabaseClient();

    // Check if recipe exists
    const { data: recipe, error: recipeError } = await supabase
      .from('recipes')
      .select('id')
      .eq('id', recipeId)
      .single();

    if (recipeError || !recipe) {
      return notFound('Recipe not found');
    }

    // Check if already saved
    const { data: existing } = await supabase
      .from('cookbooks')
      .select('recipe_id')
      .eq('user_id', user!.id)
      .eq('recipe_id', recipeId)
      .single();

    if (existing) {
      return conflict('Recipe already in cookbook');
    }

    // Insert into cookbooks
    const { data: saved, error: saveError } = await supabase
      .from('cookbooks')
      .insert({
        user_id: user!.id,
        recipe_id: recipeId,
      })
      .select('recipe_id, saved_at')
      .single();

    if (saveError) {
      console.error('Cookbook save error:', saveError);
      return serverError('Failed to save recipe');
    }

    // Increment save_count on the recipe (direct UPDATE instead of RPC)
    const { data: currentRecipe } = await supabase
      .from('recipes')
      .select('save_count')
      .eq('id', recipeId)
      .single();
    if (currentRecipe) {
      await supabase
        .from('recipes')
        .update({ save_count: (currentRecipe.save_count || 0) + 1 })
        .eq('id', recipeId);
    }

    return created({
      recipe_id: saved.recipe_id,
      saved_at: saved.saved_at,
    });
  } catch (err) {
    console.error('Cookbook POST error:', err);
    return serverError('Internal server error');
  }
}

export async function DELETE(request: NextRequest, { params }: RouteParams) {
  try {
    const { user, error: authError } = await authenticateRequest(request);
    if (authError) return authError;

    const { recipeId } = await params;

    // Validate UUID format
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(recipeId)) {
      return badRequest('Invalid recipe ID format');
    }

    const supabase = getSupabaseClient();

    // Check if saved
    const { data: existing } = await supabase
      .from('cookbooks')
      .select('recipe_id')
      .eq('user_id', user!.id)
      .eq('recipe_id', recipeId)
      .single();

    if (!existing) {
      return notFound('Recipe not found in cookbook');
    }

    // Delete from cookbooks
    const { error: deleteError } = await supabase
      .from('cookbooks')
      .delete()
      .eq('user_id', user!.id)
      .eq('recipe_id', recipeId);

    if (deleteError) {
      console.error('Cookbook delete error:', deleteError);
      return serverError('Failed to remove recipe from cookbook');
    }

    // Decrement save_count on the recipe (direct UPDATE instead of RPC)
    const { data: currentRecipe } = await supabase
      .from('recipes')
      .select('save_count')
      .eq('id', recipeId)
      .single();
    if (currentRecipe) {
      await supabase
        .from('recipes')
        .update({ save_count: Math.max((currentRecipe.save_count || 0) - 1, 0) })
        .eq('id', recipeId);
    }

    return noContent();
  } catch (err) {
    console.error('Cookbook DELETE error:', err);
    return serverError('Internal server error');
  }
}
