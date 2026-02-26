const { createClient } = require('@supabase/supabase-js');
const s = createClient(
  'https://ldbqztnpwajelkrrivab.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxkYnF6dG5wd2FqZWxrcnJpdmFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxMTQ0MjQsImV4cCI6MjA4NzY5MDQyNH0.d2JwhBk9suvr7a6XSSsYsmCsThc-LcrG4-HX8AvIbig'
);

(async () => {
  try {
    const r = await s.auth.signInWithPassword({
      email: 'vmhanh062@gmail.com',
      password: '123456@X',
    });
    if (r.error) {
      console.log('ERROR:', r.error.message, r.error.status);
    } else {
      console.log('OK user:', r.data.user.id);
      console.log('session:', !!r.data.session);
    }
  } catch (e) {
    console.log('CATCH:', e.message);
  }
  process.exit(0);
})();
