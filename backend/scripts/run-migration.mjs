import { readFileSync } from 'fs';
import { createClient } from '@supabase/supabase-js';

// Disable SSL verification for development
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const envContent = readFileSync('.env.local', 'utf8');
const getEnv = (key) => {
  const match = envContent.match(new RegExp(`${key}=(.*)`));
  return match ? match[1].trim() : '';
};

const SUPABASE_URL = getEnv('SUPABASE_URL');
const SERVICE_KEY = getEnv('SUPABASE_SERVICE_ROLE_KEY');

if (!SUPABASE_URL || !SERVICE_KEY) {
  console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in .env.local');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SERVICE_KEY, {
  auth: { autoRefreshToken: false, persistSession: false }
});

// Read migration SQL
const migrationSQL = readFileSync('./supabase/migrations/001_initial_schema.sql', 'utf8');

// Split into individual statements
const statements = migrationSQL
  .split(/;\s*\n/)
  .map(s => s.trim())
  .filter(s => s.length > 0 && !s.startsWith('--'));

console.log(`Found ${statements.length} SQL statements to execute.`);
console.log('Supabase URL:', SUPABASE_URL);

// Execute using Supabase SQL API (via rpc)
// First, let's try creating a helper function, then run raw SQL
async function runMigration() {
  try {
    // Test connection first
    const { data, error } = await supabase.from('tags').select('id').limit(1);
    if (error && error.code === 'PGRST205') {
      console.log('Table does not exist yet — proceeding with migration...');
    } else if (data) {
      console.log('Tables already exist! Skipping migration.');
      return;
    }

    // Use the Supabase SQL endpoint directly
    const projectRef = SUPABASE_URL.match(/https:\/\/(.+)\.supabase\.co/)?.[1];
    if (!projectRef) {
      console.error('Could not extract project ref from URL');
      process.exit(1);
    }

    // Try using the database's SQL API endpoint
    const sqlApiUrl = `${SUPABASE_URL}/rest/v1/rpc/`;
    
    // We need to create a function first to execute arbitrary SQL
    // Since we can't run DDL through PostgREST, let's use the pg connection string
    // or the Supabase Management API
    
    // Alternative: Use Supabase's built-in pg endpoint
    const dbHost = `db.${projectRef}.supabase.co`;
    const connString = `postgresql://postgres.${projectRef}:${getEnv('SUPABASE_DB_PASSWORD') || 'YOUR_DB_PASSWORD'}@${dbHost}:5432/postgres`;
    
    console.log('\n========================================');
    console.log('Cannot run DDL (CREATE TABLE) via PostgREST API.');
    console.log('Please run the migration SQL manually:');
    console.log('========================================\n');
    console.log('Option 1: Supabase Dashboard SQL Editor');
    console.log(`  1. Go to: https://supabase.com/dashboard/project/${projectRef}/sql`);
    console.log('  2. Copy the content of: backend/supabase/migrations/001_initial_schema.sql');
    console.log('  3. Paste and click "Run"\n');
    console.log('Option 2: Install psql and run:');
    console.log(`  brew install libpq`);
    console.log(`  psql "${connString}" -f supabase/migrations/001_initial_schema.sql\n`);
    console.log('Option 3: Install Supabase CLI:');
    console.log('  brew install supabase/tap/supabase');
    console.log('  supabase login');
    console.log(`  supabase link --project-ref ${projectRef}`);
    console.log('  supabase db push\n');
    
  } catch (err) {
    console.error('Error:', err.message);
  }
}

runMigration();
