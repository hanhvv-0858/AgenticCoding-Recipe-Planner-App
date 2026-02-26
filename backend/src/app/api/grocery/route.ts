import { NextRequest } from 'next/server';
import { getSupabaseClient } from '@/lib/supabase/client';
import { GroceryQuerySchema, CreateGroceryItemSchema } from '@/lib/validators/grocery-validators';
import { formatZodError } from '@/lib/validators/error-formatter';
import { authenticateRequest } from '@/lib/middleware/auth';
import { success, created, badRequest, serverError } from '@/lib/utils/api-response';
import { mergeIngredients, CATEGORY_EMOJI, type RawIngredient } from '@/lib/utils/grocery-merge';

export async function GET(request: NextRequest) {
  try {
    const { user, error: authError } = await authenticateRequest(request);
    if (authError) return authError;

    const { searchParams } = new URL(request.url);
    const rawParams = Object.fromEntries(searchParams.entries());

    const parsed = GroceryQuerySchema.safeParse(rawParams);
    if (!parsed.success) {
      return badRequest('Invalid query parameters', formatZodError(parsed.error).details);
    }

    const { week_start, regenerate } = parsed.data;
    const supabase = getSupabaseClient();

    // Calculate week end (Sunday)
    const weekStartDate = new Date(week_start);
    const weekEndDate = new Date(weekStartDate);
    weekEndDate.setDate(weekEndDate.getDate() + 6);
    const weekEnd = weekEndDate.toISOString().split('T')[0];

    // Check if we need to regenerate
    if (regenerate) {
      // Delete existing auto-generated items (keep manual ones)
      await supabase
        .from('grocery_items')
        .delete()
        .eq('user_id', user!.id)
        .eq('week_start_date', week_start)
        .eq('is_manual', false);
    }

    // Check existing items for the week
    const { data: existingItems, error: existingError } = await supabase
      .from('grocery_items')
      .select('*')
      .eq('user_id', user!.id)
      .eq('week_start_date', week_start)
      .order('category')
      .order('name');

    if (existingError) {
      console.error('Grocery items query error:', existingError);
      return serverError('Failed to fetch grocery items');
    }

    // If no auto-generated items exist (or regenerate), generate from meal plan
    const hasAutoItems = (existingItems ?? []).some((item) => !item.is_manual);
    if (!hasAutoItems || regenerate) {
      // Fetch meal plan slots for the week with recipes + ingredients
      const { data: mealPlans, error: planError } = await supabase
        .from('meal_plans')
        .select(
          `
          id,
          date,
          meal_slots (
            id,
            recipe_id,
            servings,
            recipe:recipes (
              id,
              title,
              default_servings,
              ingredients (
                name,
                normalized_name,
                quantity,
                unit,
                category
              )
            )
          )
        `,
        )
        .eq('user_id', user!.id)
        .gte('date', week_start)
        .lte('date', weekEnd);

      if (planError) {
        console.error('Meal plans query for grocery:', planError);
        return serverError('Failed to generate grocery list');
      }

      // Collect all raw ingredients
      const rawIngredients: RawIngredient[] = [];

      for (const plan of mealPlans ?? []) {
        for (const slot of plan.meal_slots ?? []) {
          const rawRecipe = slot.recipe;
          const recipe = (Array.isArray(rawRecipe) ? rawRecipe[0] : rawRecipe) as {
            id: string;
            title: string;
            default_servings: number;
            ingredients: Array<{
              name: string;
              normalized_name: string;
              quantity: number;
              unit: string;
              category: string;
            }>;
          } | null;

          if (recipe && recipe.ingredients) {
            const servingsFactor = slot.servings / (recipe.default_servings || 2);

            for (const ing of recipe.ingredients) {
              rawIngredients.push({
                name: ing.name,
                normalized_name: ing.normalized_name,
                quantity: ing.quantity * servingsFactor,
                unit: ing.unit,
                category: ing.category || 'Other',
                source_recipe: recipe.title,
              });
            }
          }
        }
      }

      // Merge ingredients
      const mergedItems = mergeIngredients(rawIngredients);

      // Upsert merged items
      if (mergedItems.length > 0) {
        const groceryRows = mergedItems.map((item) => ({
          user_id: user!.id,
          name: item.name,
          quantity: item.quantity,
          unit: item.unit,
          category: item.category,
          source_recipes: item.source_recipes,
          is_checked: false,
          is_manual: false,
          week_start_date: week_start,
        }));

        const { error: insertError } = await supabase
          .from('grocery_items')
          .insert(groceryRows);

        if (insertError) {
          console.error('Grocery items insert error:', insertError);
          return serverError('Failed to save generated grocery items');
        }
      }

      // Re-fetch all items after generation
      const { data: allItems, error: refetchError } = await supabase
        .from('grocery_items')
        .select('*')
        .eq('user_id', user!.id)
        .eq('week_start_date', week_start)
        .order('category')
        .order('name');

      if (refetchError) {
        console.error('Grocery re-fetch error:', refetchError);
        return serverError('Failed to fetch grocery items');
      }

      return success(buildGroceryResponse(week_start, allItems ?? []));
    }

    return success(buildGroceryResponse(week_start, existingItems ?? []));
  } catch (error) {
    console.error('GET /api/grocery error:', error);
    return serverError('Internal server error');
  }
}

export async function POST(request: NextRequest) {
  try {
    const { user, error: authError } = await authenticateRequest(request);
    if (authError) return authError;

    const body = await request.json();
    const parsed = CreateGroceryItemSchema.safeParse(body);
    if (!parsed.success) {
      return badRequest('Invalid request body', formatZodError(parsed.error).details);
    }

    const { name, quantity, unit, category, week_start } = parsed.data;
    const supabase = getSupabaseClient();

    const { data: item, error } = await supabase
      .from('grocery_items')
      .insert({
        user_id: user!.id,
        name,
        quantity,
        unit,
        category,
        source_recipes: [],
        is_checked: false,
        is_manual: true,
        week_start_date: week_start,
      })
      .select()
      .single();

    if (error) {
      console.error('Grocery item insert error:', error);
      return serverError('Failed to add grocery item');
    }

    return created({
      id: item.id,
      name: item.name,
      quantity: item.quantity,
      unit: item.unit,
      category: item.category,
      source_recipes: item.source_recipes,
      is_checked: item.is_checked,
      is_manual: item.is_manual,
    });
  } catch (error) {
    console.error('POST /api/grocery error:', error);
    return serverError('Internal server error');
  }
}

// Build grouped grocery response per contracts/grocery.md
interface GroceryItemRow {
  id: string;
  name: string;
  quantity: number;
  unit: string;
  category: string;
  source_recipes: string[];
  is_checked: boolean;
  is_manual: boolean;
}

function buildGroceryResponse(weekStart: string, items: GroceryItemRow[]) {
  // Group by category
  const categoryMap = new Map<string, GroceryItemRow[]>();
  for (const item of items) {
    const cat = item.category || 'Other';
    if (!categoryMap.has(cat)) {
      categoryMap.set(cat, []);
    }
    categoryMap.get(cat)!.push(item);
  }

  // Build category groups sorted alphabetically
  const categories = Array.from(categoryMap.entries())
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([name, catItems]) => ({
      name,
      emoji: CATEGORY_EMOJI[name] || '📦',
      items: catItems.map((item) => ({
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        unit: item.unit,
        source_recipes: item.source_recipes,
        is_checked: item.is_checked,
        is_manual: item.is_manual,
      })),
    }));

  const totalItems = items.length;
  const checkedItems = items.filter((i) => i.is_checked).length;

  return {
    week_start: weekStart,
    categories,
    summary: {
      total_items: totalItems,
      checked_items: checkedItems,
      remaining_items: totalItems - checkedItems,
    },
  };
}
