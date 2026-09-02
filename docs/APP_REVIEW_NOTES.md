# App Review notes — Antar Marg (draft for App Store Connect)

**What to paste:** App Store Connect → the app version → App Review Information → Notes.

---

Antar Marg is a Hindu/Vedic daily-practice and sacred-text app. Primary tabs: Aangan (home sanctuary), Ashram (daily tasks), Granthalaya (library + journeys), Profile.

## How to reach the subscription paywall (fresh install)

1. Launch the app. Complete or skip onboarding (Skip / continue to sign-in).
2. Sign in with Apple or Google, or skip sign-in if the build allows it.
3. Open **Profile** (rightmost tab) → tap the Pro / Upgrade control, **or**
4. Open **Granthalaya** → Journey and tap a Pro-gated journey, **or** open a premium book.

The paywall is RevenueCat’s native paywall (dashboard offering “Antar marg Pro”) with a custom Flutter fallback if offerings fail to load.

## What Pro unlocks

- Premium books and stories; skip-ahead chapter access
- Full audio library (chants, audiobooks, meditations)
- All structured journeys (Garbh Sanskar, Hanuman Chalisa, Gayatri Sadhana, 21-Day Stress-Free)
- Pre-generated AI commentary on verses (static text in our database — no live chatbot)
- Exclusive Aangan/Mandir customizations and advanced Ashram practices

There is **no** in-app AI chat / consultation product.

## Subscriptions

- Auto-renewing via Apple: monthly / annual / lifetime as configured in the subscription group.
- Manage / cancel: iOS Settings → Apple ID → Subscriptions, or the in-app Customer Center from Profile.
- Restore: Profile / paywall Restore Purchases.

## Sandbox

Use a Sandbox Apple ID. Complete a purchase, force-quit, relaunch — Pro should remain active. Restore on a reinstall should return the same entitlement.

## Demo account (optional — fill in if you create one)

- Apple ID: ________________
- Password: ________________
- Notes: pre-activated Pro via RevenueCat sandbox / grant, if provided.

## Sign-in

Google Sign-In and Sign in with Apple are both supported. Reviewers can use Sign in with Apple.

## Privacy / legal URLs

- Privacy: https://antarmarg.app/legal/privacy.html
- Terms: https://antarmarg.app/legal/terms.html

(Host these after reviewing `web/legal/*.html`.)
