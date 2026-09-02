# Remove the AI Guru feature entirely (free and premium)

**Decision:** cut the AI Guru chat tab completely — no free tier, no paid tier, nothing gated, just gone. Collapse bottom nav from 5 tabs to 4 (Aangan, Ashram, Granthalaya, Profile). This supersedes stories `AM-7`, `AM-8` (the journey-link half only — the journey premium-gate widget itself stays, it's used by non-Guru entry points too), `AM-10`, `AM-12`, and the AI-Guru portion of `AM-16` in `docs/JIRA_STORY_BACKLOG.md` — mark those as **cancelled, superseded by this spec** rather than continuing them.

**Explicitly out of scope — do not touch:** the "AI Commentary" section in `book_chapter_screen.dart` (lines ~1272, ~1404, ~1580) is pre-generated static text already stored in `verse_translations` — it makes no live OpenAI call and is unrelated to AI Guru. Leave it and its `PremiumFeatures` bullet ("AI Commentary on Every Verse") exactly as-is.

---

## Step 0 — safest possible order

Remove `chat` from the `NavItem` enum **first** (`lib/shared/widgets/bottom_nav_bar.dart:11`), then run `flutter analyze`. Dart's exhaustive-switch checking will surface every call site that still references `NavItem.chat` as a compile error — that's the authoritative list of what else needs editing. Fix each reported error, re-run `flutter analyze` until clean, then `flutter test`.

## Step 1 — delete the two feature folders wholesale

```
rm -rf lib/features/ai_guru/
rm -rf lib/features/chat/
```

This removes (confirmed via full grep, nothing outside these two folders implements AI Guru logic):
- `ai_guru/`: `config/guru_credit_pack_config.dart`, `constants/guru_prompts.dart`, `repositories/guru_repository.dart`, `models/guru_message.dart`, `services/guru_user_tier.dart`, `services/guru_context_builder.dart`, `services/guru_link_navigation.dart`, `services/guru_link_parser.dart`, `services/guru_api_service.dart`, `services/guru_ai_credits_service.dart`, `services/guru_spiritual_service_ext.dart`, `presentation/providers/guru_providers.dart`
- `chat/`: `data/config/spiritual_service_prompts.dart`, `data/repositories/feeling_repository.dart`, `data/models/{chat_message,feeling_suggestion_model,feeling_responses,spiritual_service,conversation_history}.dart`, `data/services/{consultation_usage_service,spiritual_chat_service}.dart`, `presentation/screens/spiritual_chat_screen.dart`, `presentation/widgets/{chat_message_bubble,service_selector_modal,chat_input_bar,conversation_history_list,service_form_sheet}.dart`

## Step 2 — bottom nav (4 tabs)

**`lib/shared/widgets/bottom_nav_bar.dart`**
- Remove `chat` from `enum NavItem { home, books, chat, ashram, profile }`.
- Remove the `_buildNavItem(context, NavItem.chat, Icons.auto_awesome, AppStrings.get('nav_ai_guru', lang), tourHighlight)` call (~line 58).

**`lib/features/navigation/presentation/screens/main_navigation_screen.dart`**
- Remove `import '../../../chat/presentation/screens/spiritual_chat_screen.dart';`
- Remove `NavItem.chat: GlobalKey(debugLabel: 'nav_tab_chat')` from `_navTabItemKeys`.
- Remove the `int _chatTabAnimationSeed = 0;` field and the `if (newIndex == 1) _chatTabAnimationSeed++;` line — re-derive the correct remaining condition once the tab list is 4-wide (there is no longer an index that needs this).
- Remove the `child = SpiritualChatScreen(..., animationSeed: _chatTabAnimationSeed)` branch from the lazy tab builder.
- Update `_initializedTabs`/index math for the new 4-tab layout.

**`lib/features/onboarding/data/app_intro_chapters.dart`** — remove the `AppIntroChapter` entry titled `'AI Guru — gentle guidance'` (~line 34).

**`lib/features/onboarding/presentation/widgets/first_run_coach_overlay.dart`** — remove the `MainTabTourStep` entry titled `'AI Guru — ask gently'` with `navigateTo: NavItem.chat` (~line 46).

**`lib/features/ashram/presentation/screens/ashram_screen.dart`** — remove `import '../../../ai_guru/presentation/providers/guru_providers.dart';` (line 40) and the `ref.invalidate(guruUserTierProvider);` call (line 139) — this was just cache invalidation on premium-status change, safe to delete outright.

## Step 3 — strings, theme, config, paywall copy

- **`lib/core/l10n/app_strings.dart`** — remove keys `nav_ai_guru` (EN + HI, ~lines 17, 162) and `ai_guru` (EN + HI, ~lines 102, 248), and their surrounding `// Chat / AI Guru` comment markers.
- **`lib/core/theme/app_colors.dart`** — the AI-Guru-labeled color comments (~lines 95, 103, 116, 142) describe colors that may still be used by other screens (e.g. modal/sheet styling) — check each token's actual usages before deleting; if a color constant is now unused, remove it, otherwise just drop the stale "(AI Guru)" wording from the comment.
- **`lib/core/services/revenuecat_service.dart`** — remove the `REVENUECAT_GURU_ENTITLEMENT_ID` read (~line 105) and whatever branch of the plus/pro entitlement resolution existed solely for it (re-read the surrounding function first — the main Pro entitlement resolution must stay, only the Guru-specific legacy entitlement lookup goes).
- **`.env.example`** — remove the commented `# REVENUECAT_GURU_ENTITLEMENT_ID=` line.
- **`lib/shared/services/feature_gate_config.dart`** — remove the entire `AI Guru` constant block: `freeConsultationsPerMonth`, `freeAskAnythingPerMonth`, `premiumAskAnythingPerMonth`, `guruWeeklyIncludedFree/Plus/Pro`, `guruCreditPackAmounts`, `freeMaxTokens`, `freeHistoryMessages`, `plusMaxTokens`, `plusHistoryMessages`, `proMaxTokens`, `proHistoryMessages`. Check `visionMaxTokens(UserTier tier)` right below this block (it may be used by a non-Guru vision feature, e.g. palmistry image analysis inside the removed chat — if so it can go too; if something else calls it, keep it).
- **`lib/features/subscription/data/models/subscription_models.dart`** — remove the `PremiumFeature` bullet titled `'Unlimited AI Consultations'` (~line 206) from `PremiumFeatures.features`. **Keep** the `'AI Commentary on Every Verse'` bullet (out of scope, see top of doc).
- **`lib/main.dart`** — remove the debug log line `print('AI Guru (GPT) API: ...')` (~line 66).

## Step 4 — Supabase: Edge Functions (never deployed — just delete)

Per the earlier work log, `guru-sync-entitlements`, `guru-grant-credits`, and `guru-chat` were built but never `supabase functions deploy`ed. Confirm with `supabase functions list` (functions deployed to the linked project) — if any of the three show up as deployed, run `supabase functions delete <name>` for each before removing the local files. Then:

```
rm -rf supabase/functions/guru-sync-entitlements
rm -rf supabase/functions/guru-grant-credits
rm -rf supabase/functions/guru-chat
rm -f supabase/functions/_shared/revenuecat.ts   # only used by the three guru-* functions
```

Keep `supabase/functions/_shared/cors.ts` and `_shared/supabase.ts` — both are generic, function-agnostic helpers worth keeping for future Edge Functions.

If `REVENUECAT_SECRET_API_KEY` / `OPENAI_API_KEY` / `REVENUECAT_ENTITLEMENT_ID` were ever set as Supabase secrets for these functions (`supabase secrets list`), unset the ones not needed elsewhere: `supabase secrets unset REVENUECAT_SECRET_API_KEY OPENAI_API_KEY`.

## Step 5 — Supabase: drop the schema

Check which of the relevant migrations have already been applied to the linked production project (`supabase migration list`) before deciding how to proceed:

- **If `20240101000041_guru_ai_credit_security.sql` was never pushed to production:** just delete that file (`rm supabase/migrations/20240101000041_guru_ai_credit_security.sql`) — cleanest, since it never left this machine.
- **For everything else below** (`20240101000015`, `20240101000023`, `20240101000031`, `20240101000032`, `20240101000034`, and 041 if it *was* already pushed): these are very likely already applied to production. **Do not edit or delete the old migration files** — write one new forward migration instead, following the pattern already used elsewhere in this repo (e.g. `20240101000042_lock_down_public_write_rls.sql`).

Create `supabase/migrations/20240101000043_remove_ai_guru_feature.sql`:

```sql
-- Remove the AI Guru chat feature entirely (product decision: cut from both free and premium).
-- Drops everything created by 20240101000015 (spiritual_chat_schema), 20240101000023
-- (feeling_and_suggestions), 20240101000031/32 (spiritual_chat_service expand/reapply),
-- 20240101000034 (guru_ai_weekly_credits), and 20240101000041 (guru_ai_credit_security),
-- assuming those migrations are already applied to production. If 041 was never pushed,
-- delete that migration file instead of relying on this one to undo it.

-- Guru AI credit system (034 + 041)
DROP FUNCTION IF EXISTS public.grant_guru_ai_purchased_credits_for_user(uuid, integer, text, text);
DROP FUNCTION IF EXISTS public.sync_guru_ai_tier_for_user(uuid, text);
DROP FUNCTION IF EXISTS public.consume_guru_ai_credit();
DROP FUNCTION IF EXISTS public.peek_guru_ai_credits();
DROP FUNCTION IF EXISTS public.grant_guru_ai_purchased_credits(integer);
DROP FUNCTION IF EXISTS public.sync_guru_ai_tier_to_profile(text);
DROP TABLE IF EXISTS public.guru_credit_grant_log;
DROP TABLE IF EXISTS public.user_guru_ai_weekly;
ALTER TABLE public.app_profiles DROP COLUMN IF EXISTS guru_ai_tier;

-- Spiritual chat / multi-service consultation schema (015, 031, 032)
DROP TABLE IF EXISTS public.spiritual_chat_messages CASCADE;
DROP TABLE IF EXISTS public.spiritual_readings_archive CASCADE;
DROP TABLE IF EXISTS public.spiritual_chat_conversations CASCADE;
DROP TABLE IF EXISTS public.spiritual_user_profiles CASCADE;
DROP TABLE IF EXISTS public.user_consultation_usage CASCADE;
DROP FUNCTION IF EXISTS public.increment_consultation_count(uuid);
DROP FUNCTION IF EXISTS public.get_consultation_count(uuid);
DROP FUNCTION IF EXISTS public.update_spiritual_chat_updated_at() CASCADE;

-- Feeling check-in + weekday suggestions (023) — confirmed used only by the removed chat UI
DROP TABLE IF EXISTS public.user_feeling_log CASCADE;
DROP TABLE IF EXISTS public.feeling_weekday_suggestions CASCADE;
```

Run it with `supabase db push` (or through your normal migration deploy path) once you're satisfied it matches the linked project.

## Step 6 — verify

1. `flutter analyze` — must be clean of new errors (pre-existing lint noise like `withOpacity` deprecation warnings is unrelated and fine).
2. `flutter test` — all existing tests still pass. Delete `test/features/subscription/premium_grant_all_test.dart`'s coverage is unaffected (unrelated to Guru); no test currently covers AI Guru directly, so nothing to remove there.
3. Manually launch the app: bottom nav shows exactly 4 tabs (Aangan, Ashram, Granthalaya, Profile), onboarding no longer mentions AI Guru, first-run tour skips straight from Aangan to Ashram.
4. `grep -rin "guru" lib/ supabase/functions/ supabase/migrations/20240101000041* supabase/migrations/20240101000043*` should return nothing (aside from unrelated "gurukul"/"Guru mantra"/"Guru Drona" religious-content hits elsewhere in migrations — those are correct and must stay).

## Optional bonus cleanup (adjacent dead code, not required)

Once `chat/` is gone, `lib/features/content/data/datasources/gpt_api_service.dart` loses its last real (if unreachable) importer. Its only remaining reference becomes `lib/features/books/presentation/screens/book_chat_screen.dart`, which is itself dead code (no navigation call site anywhere, confirmed earlier). If you want to fully close this out: delete `book_chat_screen.dart` and `content/data/datasources/gpt_api_service.dart`, at which point `GPT_API_KEY` has zero remaining client-side consumers and can be removed from `.env`/`.env.example` entirely. Not required for the AI Guru removal itself — flagging it because it becomes truly dead as a direct consequence of this change.

## Housekeeping

Add a one-line note at the top of `docs/JIRA_STORY_BACKLOG.md` above `AM-7` and at the top of `docs/GURU_EDGE_FUNCTIONS.md`: **"Superseded — AI Guru feature removed entirely, see `docs/AI_GURU_REMOVAL_SPEC.md`."** Don't delete those docs; they're useful history of what was tried.
