import { NextRequest } from 'next/server';
import { getSupabaseClient } from '@/lib/supabase/client';
import { checkAuthRateLimit } from '@/lib/middleware/rate-limit';
import { LoginSchema } from '@/lib/validators/auth-validators';
import { formatZodError } from '@/lib/validators/error-formatter';
import { success, badRequest, unauthorized, serverError } from '@/lib/utils/api-response';

export async function POST(request: NextRequest) {
  // Rate limiting for auth endpoints
  const rateLimitResponse = checkAuthRateLimit(request);
  if (rateLimitResponse) return rateLimitResponse;

  try {
    const body = await request.json();

    const parsed = LoginSchema.safeParse(body);
    if (!parsed.success) {
      return badRequest('Validation failed', formatZodError(parsed.error).details);
    }

    const { email, password } = parsed.data;
    const supabase = getSupabaseClient();

    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      // FR-031: Generic error message — do not reveal whether email exists
      return unauthorized('Invalid email or password');
    }

    if (!data.session || !data.user) {
      return unauthorized('Invalid email or password');
    }

    // Fetch user profile
    const { data: profile } = await supabase
      .from('users')
      .select('display_name, avatar_url, created_at')
      .eq('id', data.user.id)
      .single();

    return success({
      user: {
        id: data.user.id,
        email: data.user.email,
        display_name: profile?.display_name ?? data.user.user_metadata?.display_name ?? 'User',
        avatar_url: profile?.avatar_url ?? null,
        created_at: profile?.created_at ?? data.user.created_at,
      },
      session: {
        access_token: data.session.access_token,
        refresh_token: data.session.refresh_token,
        expires_at: new Date(data.session.expires_at! * 1000).toISOString(),
      },
    });
  } catch (err) {
    console.error('Login error:', err);
    return serverError('Internal server error');
  }
}
