# Email sign-up (OOB / magic link) setup

The app supports **sign up with email and name** using Supabase **OOB (Out of Band)** authentication: the user enters email and name, receives a **magic link** by email, and taps the link to open the app and sign in.

## 1. Supabase Dashboard

1. Go to your project → **Authentication** → **URL Configuration**.
2. Under **Redirect URLs**, add:
   - `antarmarg://auth-callback`
   (Or the value you set in `.env` as `SUPABASE_AUTH_REDIRECT_URL`.)
3. Ensure **Email** provider is enabled (Authentication → Providers → Email).
4. (Optional) In **Email Templates** → **Magic Link**, you can customize the email; the default uses `{{ .ConfirmationURL }}`, which redirects to your app after verification.

## 2. App flow

- **Login screen** → “Sign up with Email” opens the **Sign up** screen.
- **Sign up screen**: user enters **Name** and **Email**, taps “Send sign-in link”.
- Supabase sends an email with a link. User taps the link → app opens (or comes to foreground) → session is recovered and user is taken to onboarding.

## 3. Deep link scheme

- **Android**: `AndroidManifest.xml` has an intent-filter for `antarmarg://auth-callback`.
- **iOS**: `Info.plist` has `CFBundleURLSchemes` with `antarmarg`.

The redirect URL you add in Supabase must match this scheme and host (e.g. `antarmarg://auth-callback`).

## 4. Optional .env

In `.env` you can set:

```env
SUPABASE_AUTH_REDIRECT_URL=antarmarg://auth-callback
```

If unset, the app uses `antarmarg://auth-callback` by default.

## 5. User metadata

The **name** entered on sign-up is sent as **user_metadata** (`full_name`) and is available on the user after sign-in via `SupabaseService().client?.auth.currentUser?.userMetadata?['full_name']`.
