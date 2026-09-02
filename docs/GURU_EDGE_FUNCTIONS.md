# AI Guru Edge Functions (AM-7 / AM-10)

> **Superseded — AI Guru feature removed entirely, see `docs/AI_GURU_REMOVAL_SPEC.md`.**

Server-side functions in `supabase/functions/`:

| Function | Purpose |
|----------|---------|
| `guru-sync-entitlements` | Reads RevenueCat subscriber, syncs `guru_ai_tier` (replaces client RPC) |
| `guru-grant-credits` | Verifies consumable purchase in RevenueCat, grants credits once per transaction |
| `guru-chat` | Consumes one credit + calls OpenAI (GPT key never shipped to client for AI Guru chat) |

## Deploy

```bash
supabase link --project-ref qyikatemonzykqamtvod
supabase db push

supabase secrets set REVENUECAT_SECRET_API_KEY=sk_...
supabase secrets set OPENAI_API_KEY=sk-...
supabase secrets set REVENUECAT_ENTITLEMENT_ID="Antar marg Pro"

supabase functions deploy guru-sync-entitlements
supabase functions deploy guru-grant-credits
supabase functions deploy guru-chat
```

## Client

- `GuruAiCreditsService.syncTierToProfile` → `guru-sync-entitlements`
- `grantPurchasedCredits(amount, productId)` → `guru-grant-credits`
- `GuruApiService.sendMessage` → `guru-chat`

## Security

Migration `20240101000041_guru_ai_credit_security.sql` revokes client `EXECUTE` on tier sync and credit grant RPCs. Only Edge Functions (service role) may grant tier or purchased credits.
