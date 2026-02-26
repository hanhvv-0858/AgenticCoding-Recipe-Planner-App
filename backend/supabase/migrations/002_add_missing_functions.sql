-- Migration: 002_add_missing_functions
-- Adds: 
--   1. Auto-create user profile trigger (when Flutter registers via Supabase SDK)
--   2. increment_save_count / decrement_save_count RPC functions
--   3. email column to users table (needed by register endpoint)

-- ============================================================
-- 1. Add email column to users table
-- ============================================================
ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR(255);

-- Backfill email from auth.users
UPDATE users
SET email = auth_users.email
FROM auth.users AS auth_users
WHERE users.id = auth_users.id
  AND users.email IS NULL;

-- ============================================================
-- 2. Auto-create user profile on auth.users insert
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, display_name, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'display_name', 'User'),
    NEW.email
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if it already exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- 3. RPC: increment_save_count
-- ============================================================
CREATE OR REPLACE FUNCTION public.increment_save_count(p_recipe_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE recipes
  SET save_count = save_count + 1
  WHERE id = p_recipe_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- 4. RPC: decrement_save_count
-- ============================================================
CREATE OR REPLACE FUNCTION public.decrement_save_count(p_recipe_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE recipes
  SET save_count = GREATEST(save_count - 1, 0)
  WHERE id = p_recipe_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- 5. RPC: increment_view_count (atomic version)
-- ============================================================
CREATE OR REPLACE FUNCTION public.increment_view_count(p_recipe_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE recipes
  SET view_count = view_count + 1
  WHERE id = p_recipe_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- 6. Service role policy for users table INSERT (for backend register)
-- ============================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'users' AND policyname = 'Service role can manage users'
  ) THEN
    CREATE POLICY "Service role can manage users" ON users
      FOR ALL USING (auth.role() = 'service_role');
  END IF;
END $$;
