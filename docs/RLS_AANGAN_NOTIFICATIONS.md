# RLS (Row Level Security) for Aangan Notifications

## What is RLS?

**Row Level Security** in Supabase/PostgreSQL controls **who can read or write which rows**.  
When RLS is **enabled** on a table, **no row is visible or writable** unless a **policy** allows it.

- Your Flutter app usually uses the **anon** (public) key.
- The Supabase **Dashboard** (Table Editor, SQL Editor) can use the **service_role** key, which **bypasses RLS**.

---

## Current setup for `aangan_notifications`

In `supabase/migrations/20240101000023_aangan_notifications.sql` you already have:

1. **RLS enabled**  
   `ALTER TABLE public.aangan_notifications ENABLE ROW LEVEL SECURITY;`

2. **One policy: read only**  
   - **Policy:** `"Allow read active aangan notifications"`
   - **Operation:** `SELECT`
   - **Condition:** `USING (is_active = true)`  
   So the app (anon key) can **only read** rows where `is_active = true`. It **cannot** INSERT, UPDATE, or DELETE.

3. **No write policies for anon**  
   So only **service_role** (e.g. Dashboard, or a backend using the service key) can INSERT/UPDATE/DELETE. That’s why you create notifications in the Dashboard.

---

## How to “do” RLS (options)

### Option A: Keep current behaviour (recommended)

- **Read:** App can read active notifications (already done).
- **Write:** Only via Supabase Dashboard (Table Editor) or a backend with **service_role** key.

No code changes needed. Just run the migration if you haven’t:

```bash
supabase db push
```

Or run the SQL from `20240101000023_aangan_notifications.sql` in **Supabase Dashboard → SQL Editor**.

---

### Option B: Let only authenticated users read

If you want only logged-in users to see notifications:

```sql
-- Replace existing SELECT policy
DROP POLICY IF EXISTS "Allow read active aangan notifications" ON public.aangan_notifications;

CREATE POLICY "Authenticated read active aangan notifications"
ON public.aangan_notifications
FOR SELECT
TO authenticated
USING (is_active = true);
```

Anonymous users will get no rows from this table.

---

### Option C: Let admins insert/update from the app

If you have an `is_admin` (or similar) flag and want admins to manage notifications from the app using the **anon** key:

1. Store admin state (e.g. in `auth.users.raw_app_meta_data` or a `profiles` table with `is_admin`).

2. Add policies that allow **only admins** to write, for example:

```sql
-- Example: allow insert/update/delete only for users marked as admin in public.profiles
CREATE POLICY "Admins can insert aangan notifications"
ON public.aangan_notifications
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = auth.uid() AND profiles.is_admin = true
  )
);

CREATE POLICY "Admins can update aangan notifications"
ON public.aangan_notifications
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = auth.uid() AND profiles.is_admin = true
  )
);

CREATE POLICY "Admins can delete aangan notifications"
ON public.aangan_notifications
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = auth.uid() AND profiles.is_admin = true
  )
);
```

(Adjust table/column names to match your schema.)

---

## Quick reference

| Goal                         | What to do |
|-----------------------------|------------|
| App can **read** notifications | Keep policy `Allow read active aangan notifications` (already in migration). |
| App **cannot** write         | Don’t add INSERT/UPDATE/DELETE policies for `anon` (current setup). |
| **Create** notifications     | Use Supabase Dashboard → Table Editor, or backend with **service_role**. |
| Only **authenticated** read  | Use Option B (policy with `TO authenticated`). |
| **Admins** write from app    | Use Option C (policies that check `profiles.is_admin` or similar). |

---

## Verify RLS

In **Supabase Dashboard**:

1. **Authentication → Policies** (or **Table Editor → table → “RLS”**): confirm `aangan_notifications` has RLS enabled and the SELECT policy.
2. **SQL Editor**: run `SELECT * FROM public.aangan_notifications;` with “Run as” set to the anon key (or from the app); you should see only rows with `is_active = true` and no ability to INSERT/UPDATE/DELETE from the app unless you added Option C.

Your current migration already “does” RLS for this table: read-only for the app, writes via Dashboard or service_role.
