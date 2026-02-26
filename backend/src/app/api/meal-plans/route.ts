import { NextRequest } from 'next/server';
import { getSupabaseClient } from '@/lib/supabase/client';
import { MealPlanQuerySchema, CreateMealPlanSchema } from '@/lib/validators/meal-plan-validators';
import { formatZodError } from '@/lib/validators/error-formatter';
import { authenticateRequest } from '@/lib/middleware/auth';
import { success, created, badRequest, conflict, serverError } from '@/lib/utils/api-response';

export async function GET(request: NextRequest) {
  try {
    const { user, error: authError } = await authenticateRequest(request);
    if (authError) return authError;

    const { searchParams } = new URL(request.url);
    const rawParams = Object.fromEntries(searchParams.entries());

    const parsed = MealPlanQuerySchema.safeParse(rawParams);
    if (!parsed.success) {
      return badRequest('Invalid query parameters', formatZodError(parsed.error).details);
    }

    const { start_date, end_date } = parsed.data;

    const supabase = getSupabaseClient();

    // Fetch meal plans for the date range
    const { data: mealPlans, error } = await supabase
      .from('meal_plans')
      .select(
        `
        id,
        date,
        meal_slots (
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
            calories,
            protein_grams,
            carbs_grams
          )
        )
      `,
      )
      .eq('user_id', user!.id)
      .gte('date', start_date)
      .lte('date', end_date)
      .order('date', { ascending: true });

    if (error) {
      console.error('Meal plans query error:', error);
      return serverError('Failed to fetch meal plans');
    }

    // Build response with nutrition summary for each day
    // Also fill in days without plans as empty
    const startDate = new Date(start_date);
    const endDate = new Date(end_date);
    const result: Array<Record<string, unknown>> = [];

    for (let d = new Date(startDate); d <= endDate; d.setDate(d.getDate() + 1)) {
      const dateStr = d.toISOString().split('T')[0];
      const plan = (mealPlans ?? []).find((p) => p.date === dateStr);

      if (plan) {
        const slots = (plan.meal_slots ?? []).map(
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          (slot: any) => ({
            id: slot.id,
            meal_type: slot.meal_type,
            recipe: slot.recipe
              ? {
                  id: Array.isArray(slot.recipe) ? slot.recipe[0]?.id : slot.recipe.id,
                  title: Array.isArray(slot.recipe) ? slot.recipe[0]?.title : slot.recipe.title,
                  cover_image_url: Array.isArray(slot.recipe) ? slot.recipe[0]?.cover_image_url : slot.recipe.cover_image_url,
                  cooking_time_minutes: Array.isArray(slot.recipe) ? slot.recipe[0]?.cooking_time_minutes : slot.recipe.cooking_time_minutes,
                  calories: Array.isArray(slot.recipe) ? slot.recipe[0]?.calories : slot.recipe.calories,
                }
              : null,
            quick_note: slot.quick_note,
            servings: slot.servings,
            display_order: slot.display_order,
          }),
        );

        // Compute nutrition summary from recipes in slots
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const nutritionSummary = computeNutritionSummary((plan.meal_slots ?? []) as any[]);

        result.push({
          id: plan.id,
          date: plan.date,
          slots,
          nutrition_summary: nutritionSummary,
        });
      } else {
        result.push({
          id: null,
          date: dateStr,
          slots: [],
          nutrition_summary: {
            calories: 0,
            protein_grams: 0,
            carbs_grams: 0,
          },
        });
      }
    }

    return success({ data: result });
  } catch (error) {
    console.error('GET /api/meal-plans error:', error);
    return serverError('Internal server error');
  }
}

export async function POST(request: NextRequest) {
  try {
    const { user, error: authError } = await authenticateRequest(request);
    if (authError) return authError;

    const body = await request.json();
    const parsed = CreateMealPlanSchema.safeParse(body);
    if (!parsed.success) {
      return badRequest('Invalid request body', formatZodError(parsed.error).details);
    }

    const { date } = parsed.data;
    const supabase = getSupabaseClient();

    // Check for existing plan on this date
    const { data: existing } = await supabase
      .from('meal_plans')
      .select('id')
      .eq('user_id', user!.id)
      .eq('date', date)
      .single();

    if (existing) {
      return conflict('A meal plan already exists for this date');
    }

    // Create new meal plan
    const { data: newPlan, error } = await supabase
      .from('meal_plans')
      .insert({
        user_id: user!.id,
        date,
      })
      .select('id, date')
      .single();

    if (error) {
      console.error('Create meal plan error:', error);
      return serverError('Failed to create meal plan');
    }

    return created({
      id: newPlan.id,
      date: newPlan.date,
      slots: [],
      nutrition_summary: {
        calories: 0,
        protein_grams: 0,
        carbs_grams: 0,
      },
    });
  } catch (error) {
    console.error('POST /api/meal-plans error:', error);
    return serverError('Internal server error');
  }
}

function computeNutritionSummary(
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  slots: Array<any>,
) {
  let calories = 0;
  let proteinGrams = 0;
  let carbsGrams = 0;

  for (const slot of slots) {
    const recipe = Array.isArray(slot.recipe) ? slot.recipe[0] : slot.recipe;
    if (recipe) {
      const servingMultiplier = slot.servings / 2; // default_servings is 2
      calories += Math.round((recipe.calories ?? 0) * servingMultiplier);
      proteinGrams += Math.round(((recipe.protein_grams ?? 0) * servingMultiplier) * 10) / 10;
      carbsGrams += Math.round(((recipe.carbs_grams ?? 0) * servingMultiplier) * 10) / 10;
    }
  }

  return {
    calories,
    protein_grams: proteinGrams,
    carbs_grams: carbsGrams,
  };
}
