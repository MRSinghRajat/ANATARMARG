# Enable the Manifestation Task in Ashram

The app already supports the Manifestation task: the daily task repository includes it via `_addIfAvailable('manifestation')`, and the Ashram screen routes the slug to `ManifestationPracticeScreen`. The task **only appears** when a matching row exists in Supabase.

## Exact steps to enable

### 1. Open Supabase

Go to your project → **Table Editor** or **SQL Editor**.

### 2. Ensure the table exists

The table must be named `daily_task_templates` with columns matching `DailyTaskTemplate` in `lib/features/ashram/data/models/daily_task_model.dart`:

- `id` (UUID, primary key)
- `slug` (text)
- `category` (text; must match your table's check constraint, e.g. one of: `scripture`, `meditation`, `seva`, `lifestyle`, `devotion`, `learning`, `custom`)
- `title` (text)
- `title_hindi` (text, nullable)
- `description` (text, nullable)
- `icon_name` (text, default e.g. `'auto_awesome'`)
- `coin_reward` (int), `karma_reward` (int), `streak_multiplier` (real)
- `is_daily` (bool), `is_system_task` (bool), `requires_verification` (bool)
- `estimated_minutes` (int)
- `available_days` (array of int, e.g. `[0,1,2,3,4,5,6]` for all days)
- `unlock_after_days` (int; 0 = available from day 1)
- `order_index` (int)
- `is_active` (bool)

### 3. Find allowed category values (if INSERT fails)

If the INSERT fails with `daily_task_templates_category_check`, your table only allows certain categories. In SQL Editor run:

```sql
SELECT DISTINCT category FROM daily_task_templates;
```

Use one of the returned values (e.g. `devotion`, `meditation`, `scripture`, `custom`) in the INSERT below. The app's task model supports: scripture, meditation, seva, lifestyle, devotion, learning, custom.

### 4. Insert the Manifestation template

**Option A — Table Editor**

Add a new row with at least:

- `slug` = `manifestation`
- `category` = `devotion` (or `meditation` / `custom` if your table's category check allows only specific values)
- `title` = `Manifestation`
- `title_hindi` = (optional)
- `is_active` = true
- `unlock_after_days` = 0
- `order_index` = desired order (e.g. 20)
- `available_days` = [0,1,2,3,4,5,6]

Fill other columns like your other task templates (e.g. same `coin_reward` / `karma_reward`).

**Option B — SQL**

Use a `category` value that your table allows. Many setups use a check like `category IN ('scripture','meditation','seva','lifestyle','devotion','learning','custom')`. If you get a category check error, try `devotion`, then `meditation`, then `custom`.

```sql
INSERT INTO daily_task_templates (
  id, slug, category, title, title_hindi, description, icon_name,
  coin_reward, karma_reward, streak_multiplier, is_daily, is_system_task,
  requires_verification, estimated_minutes, available_days, unlock_after_days,
  order_index, is_active
) VALUES (
  gen_random_uuid(),
  'manifestation',
  'devotion',
  'Manifestation',
  NULL,
  NULL,
  'auto_awesome',
  5,
  1,
  1.0,
  true,
  true,
  false,
  5,
  ARRAY[0,1,2,3,4,5,6],
  0,
  20,
  true
);
```

### 5. App side

No code change is required. Restart the app or refresh the Ashram screen (e.g. reopen Ashram tab or pull-to-refresh if implemented). The task list is built from `getAvailableTemplates(daysSinceStart)` and `_addIfAvailable('manifestation')`, so once the row exists with `is_active = true`, the Manifestation task will appear and open `ManifestationPracticeScreen` when tapped.
