import { NextRequest } from 'next/server';
import { getSupabaseAdmin } from '@/lib/supabase/admin';
import { getSupabaseClient } from '@/lib/supabase/client';
import { checkAuthRateLimit } from '@/lib/middleware/rate-limit';
import { RegisterSchema } from '@/lib/validators/auth-validators';
import { formatZodError } from '@/lib/validators/error-formatter';
import { created, badRequest, conflict, serverError } from '@/lib/utils/api-response';

export async function POST(request: NextRequest) {
  // Rate limiting for auth endpoints
  const rateLimitResponse = checkAuthRateLimit(request);
  if (rateLimitResponse) return rateLimitResponse;

  try {
    const body = await request.json();

    const parsed = RegisterSchema.safeParse(body);
    if (!parsed.success) {
      return badRequest('Validation failed', formatZodError(parsed.error).details);
    }

    const { email, password, display_name } = parsed.data;
    const admin = getSupabaseAdmin();

    // Create the auth user
    const { data: authData, error: authError } = await admin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { display_name },
    });

    if (authError) {
      if (authError.message.includes('already') || authError.message.includes('duplicate')) {
        return conflict('An account with this email already exists');
      }
      console.error('Auth registration error:', authError);
      return serverError('Failed to create account');
    }

    const userId = authData.user.id;

    // Insert user profile (users table has no email column — email lives in auth.users)
    const supabase = getSupabaseClient();
    const { error: profileError } = await supabase.from('users').insert({
      id: userId,
      display_name,
    });

    if (profileError) {
      console.error('Profile creation error:', profileError);
      // Clean up auth user on profile failure
      await admin.auth.admin.deleteUser(userId);
      return serverError('Failed to create user profile');
    }

    // Sign in to get session tokens
    await admin.auth.admin.generateLink({
      type: 'magiclink',
      email,
    });

    // Instead of magic link, just sign in with password to get tokens
    const clientSupabase = getSupabaseClient();
    const { data: sessionData, error: sessionError } =
      await clientSupabase.auth.signInWithPassword({ email, password });

    if (sessionError || !sessionData.session) {
      // User created but session not obtained — still a success
      return created({
        user: {
          id: userId,
          email,
          display_name,
          avatar_url: null,
          created_at: authData.user.created_at,
        },
        session: null,
      });
    }

    return created({
      user: {
        id: userId,
        email,
        display_name,
        avatar_url: null,
        created_at: authData.user.created_at,
      },
      session: {
        access_token: sessionData.session.access_token,
        refresh_token: sessionData.session.refresh_token,
        expires_at: new Date(sessionData.session.expires_at! * 1000).toISOString(),
      },
    });
  } catch (err) {
    console.error('Register error:', err);
    return serverError('Internal server error');
  }
}
