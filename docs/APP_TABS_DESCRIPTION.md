# Antarmarg — Complete Description of All Tabs

The app has **4 main tabs** in the bottom navigation bar (left to right):

---

## 1. **AANGAN** (Home) — Tab index 0  
**Icon:** Home  
**Label:** AANGAN (English) / आँगन (Hindi)

**What it shows:**
- **Your sacred space** — Animated Om sanctuary with customizable elements (rings, glow, deity, background). Animations include aurora background, sacred geometry, floating particles, lotus petals, god rays, and energy pulse.
- **Two sub-tabs:**
  - **AATMA** — Customizable Om symbol and sanctuary; draggable bottom sheet to **shop** for customizations (Om style, ring style, colors, animation style, deity image, etc.). Purchases use in-app coins. Customization syncs to Ashram when applied.
  - **MANDIR** — 3D temple view (WebView) with floor/customization from Aangan; same draggable shop for Mandir-specific items (e.g. ground type).
- **No in-app notification on Aangan** — Notifications were moved to Ashram.

**Purpose:** Personalize your sacred space (Aatma + Mandir), spend coins on visual customizations, and enjoy the animated Om experience. All animation in the app is concentrated here.

---

## 2. **ASHRAM** — Tab index 1  
**Icon:** Temple (Buddhist temple)  
**Label:** ASHRAM

**What it shows:**
- **Simple top bar** — User name (from onboarding), **Level** (spiritual level from progress), and **Karma** (points) count on the right side of the draggable card.
- **In-app notification** — Small transparent pill on the **right, below the top bar** (e.g. “Happy Holi”, “New update coming soon”). Comes from Supabase or local/festival fallback. Stays until user dismisses; cross = “don’t show again”.
- **Draggable task sheet** — Main content in a sheet that can be dragged up/down. Includes:
  - **Today’s Tasks** — Daily tasks (e.g. gratitude, meditation, japa) with checkmarks; completing grants Karma points and XP; some tasks open a practice screen (verse, meditation guide, gratitude, dana, japa, etc.).
  - **My Habits** — Custom habits the user added; track completion for today.
  - **Daily Story** — Link/card to today’s sacred story (opens story reader).
  - **Daily Verse** — Link to today’s verse (opens verse detail).
- **FAB (+)** — Add new custom habit.
- **Karma (points)** — Shown on the right side of the draggable card (e.g. “125 Karma”); earned by completing tasks/habits.
- **No OM animation** — Ashram is static (no CustomizableOmSanctuary or geometry overlay); reserved for tasks, habits, and future features.

**Purpose:** Daily spiritual practice hub — tasks, habits, verse, story, and in-app announcements (notification). Currency here is "Karma" (Karma points system).

---

## 3. **GRANTHALYA** (Books / Library) — Tab index 2  
**Icon:** Menu book  
**Label:** GRANTHALYA

**What it shows:**
- **Sacred library** with three toggle segments (v1 ships Read + Journey; Listen is Coming Soon):
  - **Read** — Sacred texts, sacred library (books/chapters), sacred stories, Explore Deities; continue reading, bookmarks; open texts/stories in reader.
  - **Listen** — Coming Soon placeholder (same gold `COMING SOON` badge as journey cards). Does not open the audio library or a paywall. Full Listen (chants, narrations, mini player) is a fast-follow once recorded audio is uploaded.
  - **Journey** — Life-stage journeys (e.g. pregnancy, parenting, student); start/continue/pause journeys; today’s journey tasks; “Sacred journeys for every stage of life”. Free users can open the full catalog; journeys with `is_premium: true` show a lock and upgrade on tap; five catalog journeys are free (Navratri, Shravan Maas, Kartik Maas, Little Sadhu, Pitru Paksha).
- **Featured / categories** — Sacred texts on top, then library sections, stories, deities (Read mode).
- **Premium** — Per-item gates on premium books/chapters and premium journeys; Listen is not sold as Pro until audio exists.

**Purpose:** Read sacred texts and stories, and follow structured life-stage journeys (e.g. Garbh Sanskar). Listening is announced as Coming Soon for v1.

---

## 4. **PROFILE** — Tab index 3  
**Icon:** Person  
**Label:** PROFILE

**What it shows:**
- **Header** — User avatar/name, optional dev/subscription shortcut.
- **Streak & stats card** — Current streak, level, XP progress; total tasks completed, verses read, meditation time, seva acts; level badge (e.g. Lv.5).
- **Timeline / history** — Past days with completed tasks listed.
- **Coins & Premium** — Karma/coins balance; subscription status; upgrade / restore / manage subscription (customer center).
- **Achievements** — Unlocked achievements (from Ashram tasks, streaks, etc.); progress (e.g. X/Y unlocked).
- **Bookmarked** — Bookmarked notes or content (e.g. verse notes from Granthalaya).
- **Settings** — Background sound, notifications, language, clear image cache, restore Aangan/Aatma customization to default, etc.

**Purpose:** Account and progress overview, streaks, achievements, subscription, and app settings.

---

## Summary Table

| Tab | Name (UI) | Main content |
|-----|-----------|--------------|
| 0 | AANGAN | Animated Om sanctuary (Aatma + Mandir), customization shop |
| 1 | ASHRAM | Name + Level bar, notification pill, Today’s Tasks, My Habits, verse/story, Karma |
| 2 | GRANTHALYA | Read (texts, stories, deities) / Listen (Coming Soon) / Journey (life-stage journeys) |
| 3 | PROFILE | Streak, level, stats, timeline, coins, premium, achievements, bookmarks, settings |

---

## Navigation details

- **IndexedStack** — All 4 tabs are kept in memory; only the selected tab is visible; **TickerMode** disables animations on non-visible tabs (e.g. Aangan animations pause when you switch away).
- **Order in bar** — Aangan → Ashram → Granthalaya → Profile.
- **Daily streak** — On app launch, streak logic may show dialogs (e.g. first day, missed you, streak count); these are not a tab but overlay flows.

## Monetization (free vs Pro)

**Free tier:** Full daily-practice loop (Ashram tasks, habits, streaks), Aangan sanctuary with coin economy, sequential book/chapter unlock in Granthalaya, Journey catalog plus free journeys, and limited custom habits.

**Pro tier ("Antar marg Pro") via RevenueCat:** Premium books/stories, AI Commentary on every verse (pre-generated static text in Supabase), premium journeys, advanced Ashram practices, and exclusive sanctuary customizations. Full Granthalaya Listen audio is Coming Soon (not a launch Pro entitlement). Quests/parvas are not a shipped tab (AM-14) and are not sold on the paywall.

There is **no live AI chat** in the app — OpenAI is not called from the client and `GPT_API_KEY` is not bundled in release builds.
