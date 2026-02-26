import {
  mergeIngredients,
  normalizeName,
  normalizeUnit,
  type RawIngredient,
} from '../../src/lib/utils/grocery-merge';

describe('normalizeName', () => {
  it('should lowercase input', () => {
    expect(normalizeName('Garlic')).toBe('garlic');
  });

  it('should strip articles', () => {
    expect(normalizeName('a clove of garlic')).toBe('clove garlic');
  });

  it('should strip basic plurals -s', () => {
    expect(normalizeName('apples')).toBe('apple');
  });

  it('should strip -es plural', () => {
    expect(normalizeName('tomatoes')).toBe('tomato');
  });

  it('should strip -ies plural', () => {
    expect(normalizeName('berries')).toBe('berry');
  });

  it('should handle extra whitespace', () => {
    expect(normalizeName('  fresh   garlic  ')).toBe('fresh garlic');
  });

  it('should not strip short words to less than 3 chars', () => {
    const result = normalizeName('gas');
    expect(result.length).toBeGreaterThanOrEqual(3);
  });
});

describe('normalizeUnit', () => {
  it('should map tbsp to tablespoon', () => {
    expect(normalizeUnit('tbsp')).toBe('tablespoon');
  });

  it('should map tsp to teaspoon', () => {
    expect(normalizeUnit('tsp')).toBe('teaspoon');
  });

  it('should map oz to ounce', () => {
    expect(normalizeUnit('oz')).toBe('ounce');
  });

  it('should map lbs to pound', () => {
    expect(normalizeUnit('lbs')).toBe('pound');
  });

  it('should map grams to gram', () => {
    expect(normalizeUnit('grams')).toBe('gram');
  });

  it('should map cups to cup', () => {
    expect(normalizeUnit('cups')).toBe('cup');
  });

  it('should return unknown units as-is (lowercased)', () => {
    expect(normalizeUnit('bunch')).toBe('bunch');
  });

  it('should be case-insensitive', () => {
    expect(normalizeUnit('TBSP')).toBe('tablespoon');
  });
});

describe('mergeIngredients', () => {
  it('should merge duplicate ingredients with same name and unit', () => {
    const ingredients: RawIngredient[] = [
      {
        name: 'Garlic',
        normalized_name: 'garlic',
        quantity: 3,
        unit: 'cloves',
        category: 'Vegetables',
        source_recipe: 'Beef Stir-Fry',
      },
      {
        name: 'Garlic',
        normalized_name: 'garlic',
        quantity: 2,
        unit: 'cloves',
        category: 'Vegetables',
        source_recipe: 'Grilled Salmon',
      },
    ];

    const result = mergeIngredients(ingredients);
    expect(result).toHaveLength(1);
    expect(result[0].name).toBe('Garlic');
    expect(result[0].quantity).toBe(5);
    expect(result[0].source_recipes).toEqual(['Beef Stir-Fry', 'Grilled Salmon']);
  });

  it('should keep items with incompatible units separate', () => {
    const ingredients: RawIngredient[] = [
      {
        name: 'Parsley',
        normalized_name: 'parsley',
        quantity: 1,
        unit: 'bunch',
        category: 'Vegetables',
        source_recipe: 'Salad',
      },
      {
        name: 'Parsley',
        normalized_name: 'parsley',
        quantity: 2,
        unit: 'tbsp',
        category: 'Vegetables',
        source_recipe: 'Soup',
      },
    ];

    const result = mergeIngredients(ingredients);
    expect(result).toHaveLength(2);
  });

  it('should handle empty input', () => {
    const result = mergeIngredients([]);
    expect(result).toHaveLength(0);
  });

  it('should sort by category then by name', () => {
    const ingredients: RawIngredient[] = [
      {
        name: 'Soy Sauce',
        normalized_name: 'soy sauce',
        quantity: 2,
        unit: 'tbsp',
        category: 'Spices',
        source_recipe: 'Stir-Fry',
      },
      {
        name: 'Broccoli',
        normalized_name: 'broccoli',
        quantity: 1,
        unit: 'head',
        category: 'Vegetables',
        source_recipe: 'Stir-Fry',
      },
      {
        name: 'Apple',
        normalized_name: 'apple',
        quantity: 3,
        unit: 'pieces',
        category: 'Fruits',
        source_recipe: 'Snack',
      },
    ];

    const result = mergeIngredients(ingredients);
    expect(result[0].category).toBe('Fruits');
    expect(result[1].category).toBe('Spices');
    expect(result[2].category).toBe('Vegetables');
  });

  it('should not duplicate source recipe names', () => {
    const ingredients: RawIngredient[] = [
      {
        name: 'Salt',
        normalized_name: 'salt',
        quantity: 1,
        unit: 'tsp',
        category: 'Spices',
        source_recipe: 'Recipe A',
      },
      {
        name: 'Salt',
        normalized_name: 'salt',
        quantity: 1,
        unit: 'tsp',
        category: 'Spices',
        source_recipe: 'Recipe A',
      },
    ];

    const result = mergeIngredients(ingredients);
    expect(result).toHaveLength(1);
    expect(result[0].source_recipes).toEqual(['Recipe A']);
    expect(result[0].quantity).toBe(2);
  });

  it('should normalize unit aliases when merging', () => {
    const ingredients: RawIngredient[] = [
      {
        name: 'Olive Oil',
        normalized_name: 'olive oil',
        quantity: 2,
        unit: 'tbsp',
        category: 'Other',
        source_recipe: 'Recipe A',
      },
      {
        name: 'Olive Oil',
        normalized_name: 'olive oil',
        quantity: 1,
        unit: 'tablespoons',
        category: 'Other',
        source_recipe: 'Recipe B',
      },
    ];

    const result = mergeIngredients(ingredients);
    expect(result).toHaveLength(1);
    expect(result[0].quantity).toBe(3);
  });

  it('should handle case-insensitive name normalization', () => {
    const ingredients: RawIngredient[] = [
      {
        name: 'Garlic',
        normalized_name: 'Garlic',
        quantity: 2,
        unit: 'cloves',
        category: 'Vegetables',
        source_recipe: 'Recipe A',
      },
      {
        name: 'garlic',
        normalized_name: 'garlic',
        quantity: 3,
        unit: 'cloves',
        category: 'Vegetables',
        source_recipe: 'Recipe B',
      },
    ];

    const result = mergeIngredients(ingredients);
    expect(result).toHaveLength(1);
    expect(result[0].quantity).toBe(5);
  });

  it('should preserve original display name from first occurrence', () => {
    const ingredients: RawIngredient[] = [
      {
        name: 'Fresh Garlic',
        normalized_name: 'fresh garlic',
        quantity: 2,
        unit: 'cloves',
        category: 'Vegetables',
        source_recipe: 'Recipe A',
      },
      {
        name: 'fresh garlic',
        normalized_name: 'fresh garlic',
        quantity: 3,
        unit: 'cloves',
        category: 'Vegetables',
        source_recipe: 'Recipe B',
      },
    ];

    const result = mergeIngredients(ingredients);
    expect(result).toHaveLength(1);
    // First occurrence has capitalized name
    expect(result[0].name).toBe('Fresh Garlic');
  });

  it('should handle single ingredient', () => {
    const ingredients: RawIngredient[] = [
      {
        name: 'Butter',
        normalized_name: 'butter',
        quantity: 50,
        unit: 'grams',
        category: 'Dairy',
        source_recipe: 'Cake',
      },
    ];

    const result = mergeIngredients(ingredients);
    expect(result).toHaveLength(1);
    expect(result[0].name).toBe('Butter');
    expect(result[0].quantity).toBe(50);
    expect(result[0].source_recipes).toEqual(['Cake']);
  });
});
