import { getSupabaseClient } from '@/lib/supabase/client';
import { success, serverError } from '@/lib/utils/api-response';

export async function GET() {
  try {
    const supabase = getSupabaseClient();

    const { data: tags, error } = await supabase
      .from('tags')
      .select('*')
      .order('display_order', { ascending: true });

    if (error) {
      console.error('Tags query error:', error);
      return serverError('Failed to fetch tags');
    }

    return success(tags ?? []);
  } catch (error) {
    console.error('GET /api/tags error:', error);
    return serverError('Internal server error');
  }
}
