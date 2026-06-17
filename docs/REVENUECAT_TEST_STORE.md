# RevenueCat Test Store (local purchase testing)

The app supports [RevenueCat Test Store](https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store): no App Store Connect / Play Console products are required for basic flow tests. Purchases open an in-app modal to simulate success, failure, or cancel.

## Requirements

- SDK **purchases_flutter ≥ 9.8** (see `pubspec.yaml`).
- A **Test Store** and **Test Store API key** in the RevenueCat dashboard.
- **Test Store products** attached to an **offering** (same entitlement id as production, e.g. `Antar marg Pro`).

## Dashboard setup

1. [RevenueCat](https://app.revenuecat.com) → your project → **Apps & providers** → **Test configuration** → create a **Test Store** if needed and copy the **API key**.
2. **Product catalog** → create products for the **Test Store**, then **Offerings** → attach them to your default (or `current`) offering so `Purchases.getOfferings()` returns packages.

## App configuration (`.env`)

Copy `.env.example` to `.env` and set:

```env
REVENUECAT_USE_TEST_STORE=true
REVENUECAT_TEST_STORE_API_KEY=<paste Test Store public API key from dashboard>
```

For **release / store builds**, set `REVENUECAT_USE_TEST_STORE=false` and use real keys:

```env
REVENUECAT_USE_TEST_STORE=false
REVENUECAT_API_KEY=appl_...        # or REVENUECAT_API_KEY_IOS / REVENUECAT_API_KEY_ANDROID
```

The code **ignores** the Test Store key in **release** mode (`kReleaseMode`) so a mis-set `.env` is less likely to ship with the test key.

## After upgrading native deps

From the project root:

```bash
flutter pub get
cd ios && pod install && cd ..
```

## Production / sandbox (real stores)

When testing with **Apple Sandbox** or **Google Play license testers**, use the normal **Apple / Google public SDK keys** and turn **off** `REVENUECAT_USE_TEST_STORE`. See [RevenueCat sandbox docs](https://www.revenuecat.com/docs/test-and-launch/sandbox).
