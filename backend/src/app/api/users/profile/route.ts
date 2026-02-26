import { NextRequest } from 'next/server';
import { getSupabaseClient } from '@/lib/supabase/client';
import { authenticateRequest } from '@/lib/middleware/auth';
import { UpdateProfileSchema } from '@/lib/validators/auth-validators';
import { formatZodError } from '@/lib/validators/error-formatter';
import { success, badRequest, notFound, serverError } from '@/lib/utils/api-response';

export async function GET(request: NextRequest) {
  try {
    const { user, error: authError } = await authenticateRequest(request);
    if (authError) return authError;

    const supabase = getSupabaseClient();

    const { data: profile, error } = await supabase
      .from('users')
      .select('id, email, display_name, avatar_url, created_at')
      .eq('id', user!.id)
      .single();

    if (error || !profile) {
      return notFound('User profile not found');
    }

    return success(profile);
  } catch (err) {
    console.error('Profile GET error:', err);
    return serverError('Internal server error');
  }
}

export async function PUT(request: NextRequest) {
  try {
    const { user, error: authError } = await authenticateRequest(request);
    if (authError) return authError;

    const body = await request.json();

    const parsed = UpdateProfileSchema.safeParse(body);
    if (!parsed.success) {
      return badRequest('Validation failed', formatZodError(parsed.error).details);
    }

    const updates = parsed.data;
    if (Object.keys(updates).length === 0) {
      return badRequest('No fields to update');
    }

    const supabase = getSupabaseClient();

    const { data: profile, error } = await supabase
      .from('users')
      .update(updates)
      .eq('id', user!.id)
      .select('id, email, display_name, avatar_url, created_at')
      .single();

    if (error || !profile) {
      return serverError('Failed to update profile');
    }

    return success(profile);
  } catch (err) {
    console.error('Profile PUT error:', err);
    return serverError('Internal server error');
  }
}
