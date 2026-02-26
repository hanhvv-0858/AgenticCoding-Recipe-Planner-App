import { NextRequest } from 'next/server';
import { getSupabaseClient } from '@/lib/supabase/client';
import { authenticateRequest } from '@/lib/middleware/auth';
import { success, serverError } from '@/lib/utils/api-response';

export async function GET(request: NextRequest) {
  try {
    const { user, error: authError } = await authenticateRequest(request);
    if (authError) return authError;

    const supabase = getSupabaseClient();

    const { data: profile, error: profileError } = await supabase
      .from('users')
      .select('id, email, display_name, avatar_url, created_at')
      .eq('id', user!.id)
      .single();

    if (profileError || !profile) {
      return success({
        id: user!.id,
        email: user!.email,
        display_name: 'User',
        avatar_url: null,
        created_at: null,
      });
    }

    return success(profile);
  } catch (err) {
    console.error('Auth me error:', err);
    return serverError('Internal server error');
  }
}
