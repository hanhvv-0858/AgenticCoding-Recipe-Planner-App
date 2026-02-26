-- Seed Data for Recipe Planner App
-- Tags, Sample Recipes with Ingredients and Steps

-- ============================================================
-- TAGS
-- ============================================================
INSERT INTO tags (name, slug, display_order) VALUES
  ('#QuickLunch', 'quick-lunch', 1),
  ('#Healthy', 'healthy', 2),
  ('#BudgetFriendly', 'budget-friendly', 3),
  ('#Vegetarian', 'vegetarian', 4),
  ('#Dessert', 'dessert', 5),
  ('#Breakfast', 'breakfast', 6),
  ('#HighProtein', 'high-protein', 7),
  ('#UnderThirtyMin', 'under-thirty-min', 8),
  ('#MealPrep', 'meal-prep', 9),
  ('#Comfort', 'comfort', 10);

-- ============================================================
-- RECIPES
-- ============================================================

-- Recipe 1: Classic Chicken Stir Fry
INSERT INTO recipes (id, title, description, cover_image_url, cooking_time_minutes, calories, protein_grams, carbs_grams, rating, default_servings, view_count, save_count)
VALUES ('a1b2c3d4-e5f6-7890-abcd-ef1234567801', 'Classic Chicken Stir Fry', 'A quick and flavorful chicken stir fry with fresh vegetables and savory sauce.', 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=800&h=600&fit=crop', 25, 380, 32.0, 28.0, 4.5, 2, 150, 42);

INSERT INTO ingredients (recipe_id, name, quantity, unit, category, display_order, normalized_name) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567801', 'Chicken breast', 400, 'grams', 'Meat/Fish', 1, 'chicken breast'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567801', 'Bell pepper', 2, 'pieces', 'Vegetables', 2, 'bell pepper'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567801', 'Broccoli', 200, 'grams', 'Vegetables', 3, 'broccoli'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567801', 'Soy sauce', 3, 'tablespoons', 'Spices', 4, 'soy sauce'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567801', 'Garlic', 3, 'cloves', 'Vegetables', 5, 'garlic'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567801', 'Olive oil', 2, 'tablespoons', 'Other', 6, 'olive oil'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567801', 'Rice', 200, 'grams', 'Grains', 7, 'rice');

INSERT INTO cooking_steps (recipe_id, step_number, instruction) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567801', 1, 'Slice the chicken breast into thin strips and season with salt and pepper.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567801', 2, 'Heat olive oil in a large wok or skillet over high heat.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567801', 3, 'Cook the chicken strips for 5-6 minutes until golden brown. Remove and set aside.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567801', 4, 'Add bell peppers, broccoli, and garlic to the wok. Stir fry for 3-4 minutes.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567801', 5, 'Return the chicken to the wok, add soy sauce, and toss everything together.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567801', 6, 'Serve over steamed rice.');

-- Recipe 2: Mediterranean Salad
INSERT INTO recipes (id, title, description, cover_image_url, cooking_time_minutes, calories, protein_grams, carbs_grams, rating, default_servings, view_count, save_count)
VALUES ('a1b2c3d4-e5f6-7890-abcd-ef1234567802', 'Mediterranean Salad', 'A refreshing salad with feta cheese, olives, and a light lemon dressing.', 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=800&h=600&fit=crop', 15, 280, 12.0, 18.0, 4.3, 2, 120, 35);

INSERT INTO ingredients (recipe_id, name, quantity, unit, category, display_order, normalized_name) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567802', 'Romaine lettuce', 1, 'head', 'Vegetables', 1, 'romaine lettuce'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567802', 'Cherry tomatoes', 200, 'grams', 'Vegetables', 2, 'cherry tomato'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567802', 'Cucumber', 1, 'piece', 'Vegetables', 3, 'cucumber'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567802', 'Feta cheese', 100, 'grams', 'Dairy', 4, 'feta cheese'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567802', 'Kalamata olives', 80, 'grams', 'Canned', 5, 'kalamata olive'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567802', 'Olive oil', 3, 'tablespoons', 'Other', 6, 'olive oil'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567802', 'Lemon juice', 2, 'tablespoons', 'Fruits', 7, 'lemon juice');

INSERT INTO cooking_steps (recipe_id, step_number, instruction) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567802', 1, 'Wash and chop the romaine lettuce into bite-sized pieces.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567802', 2, 'Halve the cherry tomatoes and dice the cucumber.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567802', 3, 'Crumble the feta cheese.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567802', 4, 'Combine all vegetables in a large bowl. Add olives.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567802', 5, 'Drizzle with olive oil and lemon juice. Toss gently and serve.');

-- Recipe 3: Banana Oat Pancakes
INSERT INTO recipes (id, title, description, cover_image_url, cooking_time_minutes, calories, protein_grams, carbs_grams, rating, default_servings, view_count, save_count)
VALUES ('a1b2c3d4-e5f6-7890-abcd-ef1234567803', 'Banana Oat Pancakes', 'Fluffy and healthy pancakes made with bananas and oats. No flour needed!', 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800&h=600&fit=crop', 20, 320, 14.0, 48.0, 4.7, 2, 200, 68);

INSERT INTO ingredients (recipe_id, name, quantity, unit, category, display_order, normalized_name) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567803', 'Banana', 2, 'pieces', 'Fruits', 1, 'banana'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567803', 'Oats', 100, 'grams', 'Grains', 2, 'oat'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567803', 'Eggs', 2, 'pieces', 'Dairy', 3, 'egg'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567803', 'Honey', 1, 'tablespoon', 'Other', 4, 'honey'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567803', 'Cinnamon', 0.5, 'teaspoon', 'Spices', 5, 'cinnamon'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567803', 'Butter', 1, 'tablespoon', 'Dairy', 6, 'butter');

INSERT INTO cooking_steps (recipe_id, step_number, instruction) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567803', 1, 'Blend oats into a fine flour using a blender.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567803', 2, 'Mash bananas in a bowl until smooth.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567803', 3, 'Mix mashed bananas with oat flour, eggs, honey, and cinnamon.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567803', 4, 'Heat butter in a non-stick pan over medium heat.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567803', 5, 'Pour small circles of batter and cook 2-3 minutes per side until golden.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567803', 6, 'Serve with fresh fruit and a drizzle of honey.');

-- Recipe 4: Spaghetti Aglio e Olio
INSERT INTO recipes (id, title, description, cover_image_url, cooking_time_minutes, calories, protein_grams, carbs_grams, rating, default_servings, view_count, save_count)
VALUES ('a1b2c3d4-e5f6-7890-abcd-ef1234567804', 'Spaghetti Aglio e Olio', 'Classic Italian pasta with garlic, olive oil, and chili flakes. Simple and delicious.', 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=800&h=600&fit=crop', 20, 450, 12.0, 62.0, 4.6, 2, 180, 55);

INSERT INTO ingredients (recipe_id, name, quantity, unit, category, display_order, normalized_name) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567804', 'Spaghetti', 250, 'grams', 'Grains', 1, 'spaghetti'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567804', 'Garlic', 6, 'cloves', 'Vegetables', 2, 'garlic'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567804', 'Olive oil', 5, 'tablespoons', 'Other', 3, 'olive oil'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567804', 'Red chili flakes', 1, 'teaspoon', 'Spices', 4, 'red chili flake'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567804', 'Parsley', 3, 'tablespoons', 'Vegetables', 5, 'parsley'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567804', 'Parmesan cheese', 30, 'grams', 'Dairy', 6, 'parmesan cheese');

INSERT INTO cooking_steps (recipe_id, step_number, instruction) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567804', 1, 'Cook spaghetti in salted boiling water until al dente. Reserve 1 cup pasta water.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567804', 2, 'Thinly slice the garlic cloves.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567804', 3, 'Heat olive oil in a large pan over medium-low heat. Add garlic and chili flakes.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567804', 4, 'Cook garlic until golden (about 2 minutes). Do not burn!'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567804', 5, 'Add cooked spaghetti to the pan along with a splash of pasta water. Toss well.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567804', 6, 'Top with chopped parsley and grated Parmesan. Serve immediately.');

-- Recipe 5: Grilled Salmon with Asparagus
INSERT INTO recipes (id, title, description, cover_image_url, cooking_time_minutes, calories, protein_grams, carbs_grams, rating, default_servings, view_count, save_count)
VALUES ('a1b2c3d4-e5f6-7890-abcd-ef1234567805', 'Grilled Salmon with Asparagus', 'Perfectly grilled salmon fillet served alongside roasted asparagus and lemon butter sauce.', 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=800&h=600&fit=crop', 30, 520, 42.0, 8.0, 4.8, 2, 250, 82);

INSERT INTO ingredients (recipe_id, name, quantity, unit, category, display_order, normalized_name) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567805', 'Salmon fillet', 400, 'grams', 'Meat/Fish', 1, 'salmon fillet'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567805', 'Asparagus', 300, 'grams', 'Vegetables', 2, 'asparagus'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567805', 'Lemon', 1, 'piece', 'Fruits', 3, 'lemon'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567805', 'Butter', 30, 'grams', 'Dairy', 4, 'butter'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567805', 'Garlic', 2, 'cloves', 'Vegetables', 5, 'garlic'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567805', 'Olive oil', 2, 'tablespoons', 'Other', 6, 'olive oil');

INSERT INTO cooking_steps (recipe_id, step_number, instruction) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567805', 1, 'Preheat grill or oven to 200°C (400°F).'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567805', 2, 'Season salmon with salt, pepper, and a squeeze of lemon.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567805', 3, 'Toss asparagus with olive oil, salt, and pepper.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567805', 4, 'Grill salmon for 4-5 minutes per side until cooked through.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567805', 5, 'Roast asparagus for 10-12 minutes until tender-crisp.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567805', 6, 'Melt butter with minced garlic and lemon juice for the sauce.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567805', 7, 'Plate salmon with asparagus, drizzle with lemon butter sauce.');

-- Recipe 6: Veggie Buddha Bowl
INSERT INTO recipes (id, title, description, cover_image_url, cooking_time_minutes, calories, protein_grams, carbs_grams, rating, default_servings, view_count, save_count)
VALUES ('a1b2c3d4-e5f6-7890-abcd-ef1234567806', 'Veggie Buddha Bowl', 'A nourishing bowl loaded with roasted vegetables, quinoa, chickpeas, and tahini dressing.', 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&h=600&fit=crop', 35, 420, 18.0, 55.0, 4.4, 2, 130, 39);

INSERT INTO ingredients (recipe_id, name, quantity, unit, category, display_order, normalized_name) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567806', 'Quinoa', 150, 'grams', 'Grains', 1, 'quinoa'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567806', 'Chickpeas', 200, 'grams', 'Canned', 2, 'chickpea'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567806', 'Sweet potato', 1, 'piece', 'Vegetables', 3, 'sweet potato'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567806', 'Avocado', 1, 'piece', 'Fruits', 4, 'avocado'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567806', 'Kale', 100, 'grams', 'Vegetables', 5, 'kale'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567806', 'Tahini', 2, 'tablespoons', 'Other', 6, 'tahini');

INSERT INTO cooking_steps (recipe_id, step_number, instruction) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567806', 1, 'Cook quinoa according to package directions.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567806', 2, 'Cube sweet potato and roast at 200°C for 20 minutes.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567806', 3, 'Drain and rinse chickpeas. Season and roast for 15 minutes until crispy.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567806', 4, 'Massage kale with a bit of olive oil and lemon juice.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567806', 5, 'Assemble bowls: quinoa base, topped with sweet potato, chickpeas, kale, and sliced avocado.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567806', 6, 'Drizzle with tahini dressing and serve.');

-- Recipe 7: Classic Beef Burger
INSERT INTO recipes (id, title, description, cover_image_url, cooking_time_minutes, calories, protein_grams, carbs_grams, rating, default_servings, view_count, save_count)
VALUES ('a1b2c3d4-e5f6-7890-abcd-ef1234567807', 'Classic Beef Burger', 'Juicy homemade beef burger with all the fixings on a toasted bun.', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&h=600&fit=crop', 25, 650, 38.0, 42.0, 4.2, 2, 95, 28);

INSERT INTO ingredients (recipe_id, name, quantity, unit, category, display_order, normalized_name) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567807', 'Ground beef', 400, 'grams', 'Meat/Fish', 1, 'ground beef'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567807', 'Burger buns', 2, 'pieces', 'Grains', 2, 'burger bun'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567807', 'Lettuce', 4, 'leaves', 'Vegetables', 3, 'lettuce'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567807', 'Tomato', 1, 'piece', 'Vegetables', 4, 'tomato'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567807', 'Cheddar cheese', 2, 'slices', 'Dairy', 5, 'cheddar cheese'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567807', 'Onion', 1, 'piece', 'Vegetables', 6, 'onion');

INSERT INTO cooking_steps (recipe_id, step_number, instruction) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567807', 1, 'Mix ground beef with salt, pepper, and a dash of Worcestershire sauce. Form into patties.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567807', 2, 'Grill patties for 4-5 minutes per side for medium doneness.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567807', 3, 'Add cheese slices on top during the last minute to melt.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567807', 4, 'Toast the burger buns on the grill.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567807', 5, 'Assemble: bun bottom, lettuce, patty with cheese, tomato, onion, bun top.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567807', 6, 'Serve with your favorite sides.');

-- Recipe 8: Chocolate Lava Cake
INSERT INTO recipes (id, title, description, cover_image_url, cooking_time_minutes, calories, protein_grams, carbs_grams, rating, default_servings, view_count, save_count)
VALUES ('a1b2c3d4-e5f6-7890-abcd-ef1234567808', 'Chocolate Lava Cake', 'Decadent chocolate cake with a molten center. Ready in under 30 minutes!', 'https://images.unsplash.com/photo-1624353365286-3f8d62daad51?w=800&h=600&fit=crop', 25, 480, 8.0, 52.0, 4.9, 2, 300, 120);

INSERT INTO ingredients (recipe_id, name, quantity, unit, category, display_order, normalized_name) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567808', 'Dark chocolate', 200, 'grams', 'Other', 1, 'dark chocolate'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567808', 'Butter', 100, 'grams', 'Dairy', 2, 'butter'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567808', 'Eggs', 3, 'pieces', 'Dairy', 3, 'egg'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567808', 'Sugar', 80, 'grams', 'Other', 4, 'sugar'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567808', 'All-purpose flour', 30, 'grams', 'Grains', 5, 'all-purpose flour'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567808', 'Vanilla extract', 1, 'teaspoon', 'Spices', 6, 'vanilla extract');

INSERT INTO cooking_steps (recipe_id, step_number, instruction) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567808', 1, 'Preheat oven to 220°C (425°F). Butter and flour two ramekins.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567808', 2, 'Melt chocolate and butter together in a double boiler.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567808', 3, 'Whisk eggs, sugar, and vanilla together until thick.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567808', 4, 'Fold the chocolate mixture into the egg mixture. Add flour and mix gently.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567808', 5, 'Pour into ramekins and bake for 12-14 minutes until edges are set but center is soft.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567808', 6, 'Let cool 1 minute, then invert onto plates. Serve immediately.');

-- Recipe 9: Thai Green Curry
INSERT INTO recipes (id, title, description, cover_image_url, cooking_time_minutes, calories, protein_grams, carbs_grams, rating, default_servings, view_count, save_count)
VALUES ('a1b2c3d4-e5f6-7890-abcd-ef1234567809', 'Thai Green Curry', 'Aromatic Thai curry with coconut milk, vegetables, and your choice of protein.', 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=800&h=600&fit=crop', 30, 410, 22.0, 32.0, 4.5, 4, 170, 48);

INSERT INTO ingredients (recipe_id, name, quantity, unit, category, display_order, normalized_name) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567809', 'Chicken thigh', 500, 'grams', 'Meat/Fish', 1, 'chicken thigh'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567809', 'Coconut milk', 400, 'ml', 'Canned', 2, 'coconut milk'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567809', 'Green curry paste', 3, 'tablespoons', 'Spices', 3, 'green curry paste'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567809', 'Bamboo shoots', 100, 'grams', 'Canned', 4, 'bamboo shoot'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567809', 'Thai basil', 15, 'leaves', 'Vegetables', 5, 'thai basil'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567809', 'Jasmine rice', 300, 'grams', 'Grains', 6, 'jasmine rice'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567809', 'Fish sauce', 2, 'tablespoons', 'Spices', 7, 'fish sauce');

INSERT INTO cooking_steps (recipe_id, step_number, instruction) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567809', 1, 'Cook jasmine rice according to package directions.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567809', 2, 'Heat a splash of coconut milk in a pot. Add green curry paste and cook for 2 minutes.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567809', 3, 'Add sliced chicken and cook until sealed on the outside.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567809', 4, 'Pour in remaining coconut milk. Add bamboo shoots and fish sauce.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567809', 5, 'Simmer for 15-20 minutes until chicken is cooked through.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567809', 6, 'Stir in Thai basil leaves and serve over jasmine rice.');

-- Recipe 10: Overnight Oats
INSERT INTO recipes (id, title, description, cover_image_url, cooking_time_minutes, calories, protein_grams, carbs_grams, rating, default_servings, view_count, save_count)
VALUES ('a1b2c3d4-e5f6-7890-abcd-ef1234567810', 'Overnight Oats', 'Prep the night before for a ready-to-eat healthy breakfast. Customize with your favorite toppings.', 'https://images.unsplash.com/photo-1517673400267-0251440c45dc?w=800&h=600&fit=crop', 10, 350, 14.0, 52.0, 4.6, 1, 220, 72);

INSERT INTO ingredients (recipe_id, name, quantity, unit, category, display_order, normalized_name) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567810', 'Oats', 80, 'grams', 'Grains', 1, 'oat'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567810', 'Milk', 200, 'ml', 'Dairy', 2, 'milk'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567810', 'Yogurt', 80, 'grams', 'Dairy', 3, 'yogurt'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567810', 'Chia seeds', 1, 'tablespoon', 'Other', 4, 'chia seed'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567810', 'Honey', 1, 'tablespoon', 'Other', 5, 'honey'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567810', 'Mixed berries', 100, 'grams', 'Fruits', 6, 'mixed berry');

INSERT INTO cooking_steps (recipe_id, step_number, instruction) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567810', 1, 'In a jar, combine oats, milk, yogurt, chia seeds, and honey.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567810', 2, 'Stir well, cover, and refrigerate overnight (at least 6 hours).'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567810', 3, 'In the morning, stir and top with mixed berries.'),
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567810', 4, 'Enjoy cold or microwave for 1-2 minutes if you prefer warm oats.');

-- ============================================================
-- RECIPE-TAG associations
-- ============================================================
INSERT INTO recipe_tags (recipe_id, tag_id) 
SELECT 'a1b2c3d4-e5f6-7890-abcd-ef1234567801', id FROM tags WHERE slug IN ('quick-lunch', 'high-protein');

INSERT INTO recipe_tags (recipe_id, tag_id)
SELECT 'a1b2c3d4-e5f6-7890-abcd-ef1234567802', id FROM tags WHERE slug IN ('healthy', 'vegetarian', 'quick-lunch');

INSERT INTO recipe_tags (recipe_id, tag_id)
SELECT 'a1b2c3d4-e5f6-7890-abcd-ef1234567803', id FROM tags WHERE slug IN ('breakfast', 'healthy', 'vegetarian');

INSERT INTO recipe_tags (recipe_id, tag_id)
SELECT 'a1b2c3d4-e5f6-7890-abcd-ef1234567804', id FROM tags WHERE slug IN ('quick-lunch', 'budget-friendly', 'vegetarian', 'under-thirty-min');

INSERT INTO recipe_tags (recipe_id, tag_id)
SELECT 'a1b2c3d4-e5f6-7890-abcd-ef1234567805', id FROM tags WHERE slug IN ('healthy', 'high-protein');

INSERT INTO recipe_tags (recipe_id, tag_id)
SELECT 'a1b2c3d4-e5f6-7890-abcd-ef1234567806', id FROM tags WHERE slug IN ('healthy', 'vegetarian', 'meal-prep');

INSERT INTO recipe_tags (recipe_id, tag_id)
SELECT 'a1b2c3d4-e5f6-7890-abcd-ef1234567807', id FROM tags WHERE slug IN ('comfort');

INSERT INTO recipe_tags (recipe_id, tag_id)
SELECT 'a1b2c3d4-e5f6-7890-abcd-ef1234567808', id FROM tags WHERE slug IN ('dessert');

INSERT INTO recipe_tags (recipe_id, tag_id)
SELECT 'a1b2c3d4-e5f6-7890-abcd-ef1234567809', id FROM tags WHERE slug IN ('comfort', 'high-protein');

INSERT INTO recipe_tags (recipe_id, tag_id)
SELECT 'a1b2c3d4-e5f6-7890-abcd-ef1234567810', id FROM tags WHERE slug IN ('breakfast', 'healthy', 'meal-prep', 'under-thirty-min');
