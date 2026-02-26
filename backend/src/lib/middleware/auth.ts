import { NextRequest } from 'next/server';
import { getSupabaseClient } from '@/lib/supabase/client';
import { unauthorized } from '@/lib/utils/api-response';

export interface AuthenticatedUser {
  id: string;
  email: string;
}

export interface AuthResult {
  user: AuthenticatedUser | null;
  error: ReturnType<typeof unauthorized> | null;
}

export async function authenticateRequest(request: NextRequest): Promise<AuthResult> {
  const authHeader = request.headers.get('Authorization');

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return {
      user: null,
      error: unauthorized('Missing or invalid Authorization header'),
    };
  }

  const token = authHeader.replace('Bearer ', '');

  try {
    const supabase = getSupabaseClient();
    const { data, error } = await supabase.auth.getUser(token);

    if (error || !data.user) {
      return {
        user: null,
        error: unauthorized('Invalid or expired token'),
      };
    }

    return {
      user: {
        id: data.user.id,
        email: data.user.email ?? '',
      },
      error: null,
    };
  } catch {
    return {
      user: null,
      error: unauthorized('Authentication failed'),
    };
  }
}

export async function optionalAuth(request: NextRequest): Promise<AuthenticatedUser | null> {
  const authHeader = request.headers.get('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }

  const token = authHeader.replace('Bearer ', '');

  try {
    const supabase = getSupabaseClient();
    const { data, error } = await supabase.auth.getUser(token);

    if (error || !data.user) return null;

    return {
      id: data.user.id,
      email: data.user.email ?? '',
    };
  } catch {
    return null;
  }
}
