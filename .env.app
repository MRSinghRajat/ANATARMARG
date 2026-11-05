# Public, client-distributable configuration (allowlisted).
# This file is intentionally safe to bundle as a Flutter asset.
#
# In production, regenerate from a local `.env` via:
#   python3 scripts/prepare_app_config.py
#
# NOTE: Do not put secrets (service_role keys, client secrets, passwords) here.

SUPABASE_URL=
SUPABASE_ANON_KEY=

LEGAL_PRIVACY_URL=https://antarmarg.com/privacy
LEGAL_TERMS_URL=https://antarmarg.com/terms

# RevenueCat (public SDK keys). Leave blank in repo; fill via generation for real builds.
REVENUECAT_API_KEY_IOS=
REVENUECAT_ENTITLEMENT_ID=
REVENUECAT_PLUS_ENTITLEMENT_ID=
REVENUECAT_PRO_ENTITLEMENT_ID=

# Debug/test flags (must remain false for release builds).
PREMIUM_GRANT_ALL=false
REVENUECAT_DEBUG_MODE=false
REVENUECAT_USE_TEST_STORE=false

