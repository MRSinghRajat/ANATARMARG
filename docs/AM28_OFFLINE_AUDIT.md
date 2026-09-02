# AM-28 — Airplane-mode pass (agent code audit + your device pass)

I cannot toggle airplane mode on a physical iPhone from here. Code-level findings and a checklist for you:

## Code changes this round

- **Ashram:** `_initializeTaskSystem` now `try/timeout(8s)/finally` so a hung Supabase call cannot leave an infinite spinner.

## Already in decent shape (from code)

| Tab | Offline path |
|---|---|
| **Aangan** | Customization loads from SharedPreferences; Mandir WebView is local loopback + bundled GLB. |
| **Ashram** | Tasks/habits have local fallbacks; daily verse caches last fetch. Spinner now always clears. |
| **Granthalaya** | `_loadBooks` catch uses `repo.allBooks`; images use `AntarmargPlaceholder`. |
| **Profile** | Local progress + RevenueCat cached status; settings are local prefs. |

## Your device checklist (airplane mode on, cold start)

- [ ] Aangan: sanctuary renders, shop sheet opens, no white screen.
- [ ] Ashram: sheet shows tasks or empty state within a few seconds (no endless spinner).
- [ ] Granthalaya: Read/Listen/Journey reach a readable state (placeholders OK).
- [ ] Profile: screen loads; sign-out still works.
- [ ] Toggle airplane **off** while on Granthalaya — list fills without restart.

Re-test any failing screen after a follow-up fix.
