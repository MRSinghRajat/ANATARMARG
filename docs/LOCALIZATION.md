# Localization house rules (AM-60)

One picker. Do not invent a second way to choose English vs Hindi.

| Role | API | Use for |
|---|---|---|
| **Content fields** | `localized(ref, en: title, hi: titleHindi)` | DB/model strings: titles, subtitles, descriptions, body |
| **Already have `lang`** | `localizedLang(lang, en: title, hi: titleHindi)` | Child widgets, tests, a screen that watched `languageProvider` once |
| **Chrome keys** | `AppStrings.get('settings', lang)` | Nav labels, buttons, errors — keyed catalog, not DB columns |

**The rule:** if the app language is `hi` and the Hindi string is non-empty, use it; otherwise use English. Always pass `en`. Never `hi!` without a fallback.

```dart
import '../../../../core/l10n/localized.dart';

Text(localized(ref, en: story.title, hi: story.titleHindi));
```

**Do not:**

- Add a new `_showHindi` / `_onboardingHindi` picker that ignores `languageProvider`.
- Show `title` and `titleHindi` as two stacked labels on catalog/functional UI.
- Call `localized` from `initState` (it watches). Snapshot with `ref.read(languageProvider)` only for one-shot defaults.

**Reader override (AM-61).** Scripture readers may keep a per-session flip so the user can switch mid-read. Default that flip from `languageProvider`; do not hardcode `true` or `false`.

```dart
bool? _overrideHindi; // null = follow global setting
bool get _showHindi =>
    _overrideHindi ?? (ref.watch(languageProvider) == 'hi');
```

## Two-tier copy (AM-58)

This is intentional, not an inconsistency to “fix”:

| Surface | Behavior |
|---|---|
| **Functional UI** (setup, journey chrome, catalog cards, navigation, settings) | **Switch** via `localized` / `localizedLang` |
| **Scripture body** (Gita chapter verses, deity names/mantras, verse commentary) | **Show both** languages. Seeing Devanagari beside a translation is normal for religious texts. `book_chapter_screen.dart` stays dual-language on purpose. |

`deity_detail_screen.dart` stacked `name` + `titleHindi` is the scripture exception, not a catalog-card bug. `book_detail_screen.dart` `name` + `nameSanskrit` is Sanskrit (not Hindi) and stays beside the title.

`book_notes_screen.dart` has no Hindi fields (user-authored notes). `BookModel` has no `title_hindi`.

## What is out of this helper

- **AM-57 (parked):** `setup_schema` question/option `label_hindi` is content+schema work. Setup *intro* (JourneyType title/subtitle/description) already uses this helper.
- **Audio language** (HI/EN track URLs) is a media toggle, not this picker.
- **Sanskrit** (`nameSanskrit`) is a sacred-script label, not Hindi. It may sit beside the localized title.

## Product calls (AM-64)

No Hindi catalog exists for these surfaces today — omission, not a wasted translation.

| Surface | Decision |
|---|---|
| **Aangan / Home** | Visual/experiential first screen. Chrome can follow `AppStrings` later; do **not** invent Hindi body copy in this sweep. Worth a dedicated pass because it is the first screen after login. |
| **Paywall / legal** | Stay English/Hinglish. Store and legal copy is more defensible in one language. |
| **Streak** | Ashram already uses `AppStrings` for several chrome keys. No extra Hindi content pass here. |

## Onboarding

Live first-run is `SpiritualOnboardingScreen`. Its toggle **writes** `languageProvider` (`language_code`). Copy on that screen uses `localizedLang` with the in-progress toggle so the UI cannot flash English before prefs load.

`OnboardingScreen` + first-task / form / character-intro / home-tour are legacy (not on the splash path). They still go through this helper so they cannot drift.

## Related

- **Typography:** `docs/TYPOGRAPHY.md` (AM-51 four-role fonts, including Devanagari).
- **Overview:** `docs/CONFLUENCE_APP_OVERVIEW.md` § Language.
