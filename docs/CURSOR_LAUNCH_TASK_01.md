# Cursor task 01 — working bilingual About screen

Status: ready-to-paste handoff, not dispatched. Primary must reserve these files and provide an isolated baseline before Cursor writes. This bounded UI task can proceed alongside backend work.

Paste the following into a fresh Cursor Agent conversation in the prepared project copy:

---

Implement one small release-polish task for Antar Marg, a Flutter Hindi/English spiritual-practice app.

First inspect git status and AGENTS.md. Preserve existing changes. You own only:

- `lib/features/profile/presentation/screens/profile_screen.dart` — replace the empty About onTap, with minimal edits.
- New `lib/features/profile/presentation/screens/about_screen.dart`.
- New targeted widget test for the About screen.

Do not edit auth, subscriptions, core config, pubspec, app router, books, journeys, database, other tests or deployment files. Navigate with MaterialPageRoute to avoid a router ownership conflict. Do not read .env, credentials or built assets. Do not deploy or publish anything.

Behavior:

1. Tapping Profile → About opens a proper screen; Back returns to Profile.
2. Use existing AppConfig appDisplayName, appVersion and theme tokens. Never hard-code a conflicting version.
3. Follow the existing languageProvider/localization pattern. Include Hindi and English interface copy.
4. Explain accurately: Antar Marg supports daily spiritual practice, sacred reading and guided journeys. Do not claim all audio/programs are available, medical benefits, an AI chatbot, or certification.
5. Link to the existing in-app Terms and Privacy screens using their current navigation mechanism; do not invent new legal text, a business name, support email or URL.
6. Support readable large text, scrolling on smaller screens, meaningful accessibility labels and an obvious back action.
7. Keep changes small and consistent with established UI; no new dependencies or animations.

Verify with a targeted widget test: English/Hindi content, version sourced from AppConfig, legal navigation, and a large-text/small-screen layout without overflow. Run the appropriate analyzer checks. Report actual commands/results and changed files. Supply a screenshot if a simulator is available; otherwise explicitly state visual verification is outstanding.

Support contact is a separate owner-dependent follow-up. Do not fake a working support button.

---
