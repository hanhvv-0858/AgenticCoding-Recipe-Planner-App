-- Migration: 001_initial_schema
-- Recipe Planner App initial database schema
-- Tables: users, recipes, ingredients, cooking_steps, tags, recipe_tags, cookbooks, meal_plans, meal_slots, grocery_items

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ============================================================
-- USERS (extends Supabase Auth)
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name VARCHAR(100) NOT NULL,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================================
-- RECIPES
-- ============================================================
CREATE TABLE IF NOT EXISTS recipes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(200) NOT NULL,
  description TEXT,
  cover_image_url TEXT,
  cooking_time_minutes INTEGER NOT NULL CHECK (cooking_time_minutes > 0),
  calories INTEGER CHECK (calories >= 0),
  protein_grams DECIMAL(6,1),
  carbs_grams DECIMAL(6,1),
  rating DECIMAL(2,1) CHECK (rating >= 0 AND rating <= 5),
  default_servings INTEGER NOT NULL DEFAULT 2 CHECK (default_servings >= 1 AND default_servings <= 50),
  view_count INTEGER NOT NULL DEFAULT 0,
  save_count INTEGER NOT NULL DEFAULT 0,
  is_published BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes for recipes
CREATE INDEX idx_recipes_title ON recipes USING gin (title gin_trgm_ops);
CREATE INDEX idx_recipes_calories ON recipes (calories);
CREATE INDEX idx_recipes_cooking_time ON recipes (cooking_time_minutes);
CREATE INDEX idx_recipes_trending ON recipes (view_count DESC, save_count DESC);
CREATE INDEX idx_recipes_published ON recipes (id) WHERE is_published = true;

ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read published recipes" ON recipes
  FOR SELECT USING (is_published = true);

CREATE POLICY "Service role can manage recipes" ON recipes
  FOR ALL USING (auth.role() = 'service_role');

-- ============================================================
-- INGREDIENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS ingredients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  quantity DECIMAL(8,2) NOT NULL,
  unit VARCHAR(30) NOT NULL,
  category VARCHAR(50) NOT NULL DEFAULT 'Other',
  display_order INTEGER NOT NULL DEFAULT 0,
  normalized_name VARCHAR(100) NOT NULL
);

CREATE INDEX idx_ingredients_recipe ON ingredients (recipe_id);
CREATE INDEX idx_ingredients_normalized ON ingredients (normalized_name);

ALTER TABLE ingredients ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read ingredients" ON ingredients
  FOR SELECT USING (true);

CREATE POLICY "Service role can manage ingredients" ON ingredients
  FOR ALL USING (auth.role() = 'service_role');

-- ============================================================
-- COOKING STEPS
-- ============================================================
CREATE TABLE IF NOT EXISTS cooking_steps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  step_number INTEGER NOT NULL CHECK (step_number > 0),
  instruction TEXT NOT NULL,
  media_url TEXT,
  media_type VARCHAR(10) CHECK (media_type IN ('image', 'video')),
  UNIQUE (recipe_id, step_number)
);

CREATE INDEX idx_steps_recipe_order ON cooking_steps (recipe_id, step_number);

ALTER TABLE cooking_steps ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read cooking steps" ON cooking_steps
  FOR SELECT USING (true);

CREATE POLICY "Service role can manage cooking steps" ON cooking_steps
  FOR ALL USING (auth.role() = 'service_role');

-- ============================================================
-- TAGS
-- ============================================================
CREATE TABLE IF NOT EXISTS tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(50) NOT NULL UNIQUE,
  slug VARCHAR(50) NOT NULL UNIQUE,
  display_order INTEGER NOT NULL DEFAULT 0
);

ALTER TABLE tags ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read tags" ON tags
  FOR SELECT USING (true);

CREATE POLICY "Service role can manage tags" ON tags
  FOR ALL USING (auth.role() = 'service_role');

-- ============================================================
-- RECIPE_TAGS (junction)
-- ============================================================
CREATE TABLE IF NOT EXISTS recipe_tags (
  recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (recipe_id, tag_id)
);

ALTER TABLE recipe_tags ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read recipe tags" ON recipe_tags
  FOR SELECT USING (true);

CREATE POLICY "Service role can manage recipe tags" ON recipe_tags
  FOR ALL USING (auth.role() = 'service_role');

-- ============================================================
-- COOKBOOKS (user saved recipes)
-- ============================================================
CREATE TABLE IF NOT EXISTS cookbooks (
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  saved_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, recipe_id)
);

ALTER TABLE cookbooks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own cookbook" ON cookbooks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can save recipes" ON cookbooks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unsave recipes" ON cookbooks
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================================
-- MEAL PLANS
-- ============================================================
CREATE TABLE IF NOT EXISTS meal_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, date)
);

CREATE INDEX idx_meal_plans_user_date ON meal_plans (user_id, date);

ALTER TABLE meal_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own meal plans" ON meal_plans
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own meal plans" ON meal_plans
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own meal plans" ON meal_plans
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own meal plans" ON meal_plans
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================================
-- MEAL SLOTS
-- ============================================================
CREATE TABLE IF NOT EXISTS meal_slots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meal_plan_id UUID NOT NULL REFERENCES meal_plans(id) ON DELETE CASCADE,
  meal_type VARCHAR(20) NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
  recipe_id UUID REFERENCES recipes(id),
  quick_note TEXT,
  servings INTEGER NOT NULL DEFAULT 2 CHECK (servings >= 1 AND servings <= 50),
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT at_least_recipe_or_note CHECK (recipe_id IS NOT NULL OR quick_note IS NOT NULL)
);

CREATE INDEX idx_slots_meal_plan ON meal_slots (meal_plan_id);
CREATE INDEX idx_slots_recipe ON meal_slots (recipe_id);

ALTER TABLE meal_slots ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own meal slots" ON meal_slots
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM meal_plans mp WHERE mp.id = meal_slots.meal_plan_id AND mp.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create own meal slots" ON meal_slots
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM meal_plans mp WHERE mp.id = meal_slots.meal_plan_id AND mp.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own meal slots" ON meal_slots
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM meal_plans mp WHERE mp.id = meal_slots.meal_plan_id AND mp.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own meal slots" ON meal_slots
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM meal_plans mp WHERE mp.id = meal_slots.meal_plan_id AND mp.user_id = auth.uid()
    )
  );

-- ============================================================
-- GROCERY ITEMS
-- ============================================================
CREATE TABLE IF NOT EXISTS grocery_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  quantity DECIMAL(8,2) NOT NULL,
  unit VARCHAR(30) NOT NULL,
  category VARCHAR(50) NOT NULL DEFAULT 'Other',
  source_recipes TEXT[] NOT NULL DEFAULT '{}',
  is_checked BOOLEAN NOT NULL DEFAULT false,
  is_manual BOOLEAN NOT NULL DEFAULT false,
  week_start_date DATE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_grocery_user_week ON grocery_items (user_id, week_start_date);
CREATE INDEX idx_grocery_checked ON grocery_items (user_id) WHERE is_checked = false;

ALTER TABLE grocery_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own grocery items" ON grocery_items
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own grocery items" ON grocery_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own grocery items" ON grocery_items
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own grocery items" ON grocery_items
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================================
-- TRIGGERS for updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_recipes_updated_at
  BEFORE UPDATE ON recipes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_meal_plans_updated_at
  BEFORE UPDATE ON meal_plans
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_meal_slots_updated_at
  BEFORE UPDATE ON meal_slots
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_grocery_items_updated_at
  BEFORE UPDATE ON grocery_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
