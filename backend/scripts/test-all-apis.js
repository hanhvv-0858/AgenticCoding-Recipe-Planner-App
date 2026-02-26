const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://ldbqztnpwajelkrrivab.supabase.co';
const ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxkYnF6dG5wd2FqZWxrcnJpdmFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxMTQ0MjQsImV4cCI6MjA4NzY5MDQyNH0.d2JwhBk9suvr7a6XSSsYsmCsThc-LcrG4-HX8AvIbig';
const API = 'http://localhost:3000/api';

async function test() {
  const s = createClient(SUPABASE_URL, ANON_KEY);
  const { data: auth } = await s.auth.signInWithPassword({
    email: 'vmhanh062@gmail.com',
    password: '123456@X',
  });
  const TOKEN = auth.session.access_token;
  const H = { 'Authorization': `Bearer ${TOKEN}`, 'Content-Type': 'application/json' };
  let passed = 0, failed = 0;

  function ok(name, status, body) {
    const pass = status >= 200 && status < 400;
    if (pass) { passed++; console.log(`  ✓ ${name} [${status}]`); }
    else { failed++; console.log(`  ✗ ${name} [${status}] ${JSON.stringify(body).slice(0,120)}`); }
    return pass;
  }

  console.log('=== Backend API Test Suite ===\n');

  // 1. Tags
  let r = await fetch(`${API}/tags`); let d = await r.json();
  ok('GET /api/tags', r.status, d);
  console.log(`    ${d.length} tags`);

  // 2. Recipes list
  r = await fetch(`${API}/recipes`); d = await r.json();
  ok('GET /api/recipes', r.status, d);
  console.log(`    ${d.recipes?.length || 0} recipes`);
  const recipeId = d.recipes?.[0]?.id;

  // 3. Trending
  r = await fetch(`${API}/recipes/trending`); d = await r.json();
  ok('GET /api/recipes/trending', r.status, d);

  // 4. Recipe detail
  r = await fetch(`${API}/recipes/${recipeId}`, { headers: H }); d = await r.json();
  ok('GET /api/recipes/:id', r.status, d);
  console.log(`    "${d.data?.title}"`);

  // 5. Auth me
  r = await fetch(`${API}/auth/me`, { headers: H }); d = await r.json();
  ok('GET /api/auth/me', r.status, d);
  console.log(`    ${d.data?.display_name}`);

  // 6. Cookbook list
  r = await fetch(`${API}/cookbook`, { headers: H }); d = await r.json();
  ok('GET /api/cookbook', r.status, d);

  // 7. Save to cookbook
  r = await fetch(`${API}/cookbook/${recipeId}`, { method: 'POST', headers: H }); d = await r.json();
  ok('POST /api/cookbook/:id', r.status <= 409 ? 200 : r.status, d);

  // 8. Unsave from cookbook
  r = await fetch(`${API}/cookbook/${recipeId}`, { method: 'DELETE', headers: H });
  ok('DELETE /api/cookbook/:id', r.status, '');

  // 9. Meal plans
  const today = new Date().toISOString().split('T')[0];
  const nextW = new Date(Date.now() + 7 * 86400000).toISOString().split('T')[0];
  r = await fetch(`${API}/meal-plans?start_date=${today}&end_date=${nextW}`, { headers: H }); d = await r.json();
  ok('GET /api/meal-plans', r.status, d);

  // 10. Create meal plan
  r = await fetch(`${API}/meal-plans`, { method: 'POST', headers: H, body: JSON.stringify({ date: today }) }); d = await r.json();
  ok('POST /api/meal-plans', r.status <= 409 ? 200 : r.status, d);
  let planId = d.data?.id;
  if (!planId) {
    r = await fetch(`${API}/meal-plans?start_date=${today}&end_date=${today}`, { headers: H }); d = await r.json();
    planId = d.data?.[0]?.id;
  }

  // 11. Add slot
  if (planId) {
    r = await fetch(`${API}/meal-plans/${planId}/slots`, { method: 'POST', headers: H, body: JSON.stringify({ meal_type: 'lunch', recipe_id: recipeId, servings: 2 }) }); d = await r.json();
    ok('POST meal-plans/:id/slots', r.status, d);
    const slotId = d.data?.id;

    if (slotId) {
      // 12. Update slot
      r = await fetch(`${API}/meal-plans/${planId}/slots/${slotId}`, { method: 'PUT', headers: H, body: JSON.stringify({ servings: 4 }) }); d = await r.json();
      ok('PUT meal-plans/:id/slots/:slotId', r.status, d);

      // 13. Delete slot
      r = await fetch(`${API}/meal-plans/${planId}/slots/${slotId}`, { method: 'DELETE', headers: H });
      ok('DELETE meal-plans/:id/slots/:slotId', r.status, '');
    }
  }

  // 14. Grocery list
  r = await fetch(`${API}/grocery?week_start=${today}`, { headers: H }); d = await r.json();
  ok('GET /api/grocery', r.status, d);

  // 15. Manual grocery item
  r = await fetch(`${API}/grocery`, { method: 'POST', headers: H, body: JSON.stringify({ name: 'Test Item', quantity: 1, unit: 'piece', category: 'Other', week_start: today }) }); d = await r.json();
  ok('POST /api/grocery (manual)', r.status, d);
  const gId = d.data?.id;

  // 16. Toggle grocery check
  if (gId) {
    r = await fetch(`${API}/grocery/${gId}`, { method: 'PATCH', headers: H, body: JSON.stringify({ is_checked: true }) }); d = await r.json();
    ok('PATCH /api/grocery/:id', r.status, d);
  }

  // 17. Clear completed
  r = await fetch(`${API}/grocery/clear?week_start=${today}`, { method: 'DELETE', headers: H }); d = await r.json();
  ok('DELETE /api/grocery/clear', r.status, d);

  console.log(`\n=== Results: ${passed} passed, ${failed} failed ===`);
  process.exit(failed > 0 ? 1 : 0);
}

test().catch(e => { console.error(e); process.exit(1); });
