/**
 * Grocery merge utility — normalizes and merges ingredients from meal plan recipes.
 *
 * Algorithm (per research.md):
 * 1. Fetch all meal plan slots for the selected week
 * 2. For each slot with a recipe, fetch ingredients and multiply by servings factor
 * 3. Normalize: lowercase name, strip plurals/articles, map unit aliases
 * 4. Group by (normalized_name, unit, category)
 * 5. Sum quantities within each group
 * 6. Track source recipes for attribution
 * 7. Return grouped, sorted by category
 */

export interface RawIngredient {
  name: string;
  normalized_name: string;
  quantity: number;
  unit: string;
  category: string;
  source_recipe: string;
}

export interface MergedGroceryItem {
  name: string;
  quantity: number;
  unit: string;
  category: string;
  source_recipes: string[];
}

// Unit aliases for normalization
const UNIT_ALIASES: Record<string, string> = {
  tbsp: 'tablespoon',
  tbs: 'tablespoon',
  tablespoons: 'tablespoon',
  tsp: 'teaspoon',
  teaspoons: 'teaspoon',
  oz: 'ounce',
  ounces: 'ounce',
  lb: 'pound',
  lbs: 'pound',
  pounds: 'pound',
  g: 'gram',
  grams: 'gram',
  kg: 'kilogram',
  kilograms: 'kilogram',
  ml: 'milliliter',
  milliliters: 'milliliter',
  l: 'liter',
  liters: 'liter',
  cups: 'cup',
  cloves: 'clove',
  pieces: 'piece',
  slices: 'slice',
  heads: 'head',
  bunches: 'bunch',
  stalks: 'stalk',
  sprigs: 'sprig',
  cans: 'can',
  bottles: 'bottle',
  packets: 'packet',
  rolls: 'roll',
};

// Common plural patterns to strip (order matters — most specific first)
const PLURAL_PATTERNS: [RegExp, string][] = [
  [/ies$/, 'y'],      // berries → berry
  [/ves$/, 'f'],      // leaves → leaf
  [/oes$/, 'o'],      // tomatoes → tomato, potatoes → potato
  [/shes$/, 'sh'],    // dishes → dish
  [/ches$/, 'ch'],    // peaches → peach
  [/xes$/, 'x'],      // boxes → box
  [/sses$/, 'ss'],    // grasses → grass
  [/s$/, ''],          // apples → apple, carrots → carrot
];

/**
 * Normalize an ingredient name for merging.
 * - Lowercase
 * - Strip articles ("a", "an", "the", "of")
 * - Strip basic plurals
 */
export function normalizeName(name: string): string {
  let normalized = name
    .toLowerCase()
    .trim()
    .replace(/\s+/g, ' ')
    // Remove articles
    .replace(/\b(a|an|the|of)\b/g, '')
    .trim()
    .replace(/\s+/g, ' ');

  // Don't strip plurals from very short words or known exceptions
  if (normalized.length > 3) {
    for (const [pattern, replacement] of PLURAL_PATTERNS) {
      if (!pattern.test(normalized)) continue;
      const stripped = normalized.replace(pattern, replacement);
      // Only apply if we don't reduce to less than 3 chars
      if (stripped.length >= 3) {
        normalized = stripped;
        break;
      }
    }
  }

  return normalized;
}

/**
 * Normalize a unit string.
 * Maps common aliases to canonical forms.
 */
export function normalizeUnit(unit: string): string {
  const lower = unit.toLowerCase().trim();
  return UNIT_ALIASES[lower] ?? lower;
}

/**
 * Create a merge key from normalized name + unit + category.
 */
function getMergeKey(normalizedName: string, unit: string, category: string): string {
  return `${normalizedName}|${unit}|${category}`;
}

/**
 * Merge an array of raw ingredients into deduplicated grocery items.
 *
 * Groups by (normalized_name, normalized_unit, category).
 * Items with the same normalized name but INCOMPATIBLE units
 * (e.g., "1 bunch parsley" + "2 tablespoon parsley") are kept separate.
 */
export function mergeIngredients(ingredients: RawIngredient[]): MergedGroceryItem[] {
  const mergedMap = new Map<string, MergedGroceryItem>();

  for (const ingredient of ingredients) {
    const normalizedName = normalizeName(ingredient.normalized_name || ingredient.name);
    const normalizedUnit = normalizeUnit(ingredient.unit);
    const category = ingredient.category || 'Other';
    const key = getMergeKey(normalizedName, normalizedUnit, category);

    const existing = mergedMap.get(key);
    if (existing) {
      existing.quantity += ingredient.quantity;
      if (!existing.source_recipes.includes(ingredient.source_recipe)) {
        existing.source_recipes.push(ingredient.source_recipe);
      }
    } else {
      mergedMap.set(key, {
        // Use the original display name (first occurrence) — capitalized properly
        name: ingredient.name,
        quantity: ingredient.quantity,
        unit: ingredient.unit,
        category,
        source_recipes: [ingredient.source_recipe],
      });
    }
  }

  // Sort by category, then by name
  const result = Array.from(mergedMap.values());
  result.sort((a, b) => {
    const catCompare = a.category.localeCompare(b.category);
    if (catCompare !== 0) return catCompare;
    return a.name.localeCompare(b.name);
  });

  return result;
}

// Category emoji mapping
export const CATEGORY_EMOJI: Record<string, string> = {
  Vegetables: '🥦',
  Fruits: '🍎',
  'Meat/Fish': '🥩',
  Dairy: '🧀',
  Spices: '🥫',
  Grains: '🌾',
  Canned: '🥫',
  Frozen: '🧊',
  Beverages: '🥤',
  Other: '📦',
};
