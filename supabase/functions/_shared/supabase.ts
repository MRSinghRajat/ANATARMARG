import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';

export function supabaseAdmin(): SupabaseClient {
  const url = Deno.env.get('SUPABASE_URL') ?? '';
  const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
  return createClient(url, key, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

export function supabaseUserClient(authHeader: string | null): SupabaseClient {
  const url = Deno.env.get('SUPABASE_URL') ?? '';
  const anon = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
  return createClient(url, anon, {
    global: {
      headers: authHeader ? { Authorization: authHeader } : {},
    },
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

export async function requireUser(authHeader: string | null) {
  if (!authHeader) return null;
  const client = supabaseUserClient(authHeader);
  const { data, error } = await client.auth.getUser();
  if (error || !data.user) return null;
  return data.user;
}
