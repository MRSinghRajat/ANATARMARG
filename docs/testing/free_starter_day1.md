## Free starter — Day 1 smoke test (fresh install)

Goal: a fresh tester can start the free starter and complete Day 1 without Pro.

### Preconditions

- App launches (debug/simulator/TestFlight).
- If Supabase credentials are present, sign in is available; if not, the starter should still be startable (fallback local journey).

### Steps

1. Open app → go to **Granthalaya** → **Journey** tab (“Our Spiritual Circle”).
2. Find **Free 7‑Day Starter Journey** and tap to start.
3. Tap **Start Journey**.
4. Open the single daily task (“Today’s practice”).
5. Confirm Day 1 content renders:
   - Title: “Day 1 — Make a little space”
   - English + Hindi text present (toggle in task detail when both are available).
6. Tap **Mark Complete**.
7. Confirm you return to the Journey home and the task shows as completed for today.

### Expected

- No paywall / Pro gate appears.
- Day 1 content resolves (no “Content not found”, no dead links).
- Completion is recorded:
  - Supabase-backed if DB rows exist
  - Otherwise locally via SharedPreferences (starter-only fallback)

