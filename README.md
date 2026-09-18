# ANTAR MARG - The Inner Path

A gamified spiritual learning app that guides users through ancient Indian wisdom using an animated old sadhu character.

## Features

- **Animated Guide**: Old sadhu character (CustomPainter)
- **Daily Tasks**: 3 tasks per day (water, prayer, food) completed by reading scripture
- **Books Library**: Mahabharata, Ramayan, Bhagavad Gita (read / journeys; listen is Coming Soon)
- **Sanctuary**: Aangan customization (traditional / festival / sacred / exclusive looks)
- **Stats & Leaderboards**: Daily reset leaderboards and progress tracking
- **Ambient Sounds**: Bird chirping, sitar music, forest sounds

## Tech Stack

- Flutter 3.0+
- Riverpod (State Management)
- Supabase (auth + content)
- RevenueCat (subscriptions)
- SQLite (Local Database)
- AudioPlayers (Ambient Sounds)

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart 3.0 or higher
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up configuration:
   - Copy `.env.example` to `.env`:
     ```bash
     cp .env.example .env
     ```
   - Update `.env` with the public Supabase client configuration, Google OAuth
     client IDs, and RevenueCat public SDK key.
   - Generate the distributable configuration before running Flutter:
     ```bash
     python3 scripts/prepare_app_config.py
     python3 scripts/verify_app_config.py
     ```
   - Flutter bundles `.env.app`, an ignored file containing only allowlisted
     client settings. Root `.env` is reserved for local configuration/tooling.
     Never put private tokens or service-role keys in distributable settings.
   - Regenerate `.env.app` when changing runtime settings or setting up a new
     checkout. `run_app.sh` and `scripts/build_testflight.sh` do this for you.

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/           # Core utilities, theme, config
├── features/       # Feature modules (auth, home, books, etc.)
└── shared/         # Shared widgets and services
```

## Development Status

MVP launch preparation is in progress. See [the execution plan](docs/MVP_LAUNCH_PLAN.md),
[agent assignments](docs/LAUNCH_AGENT_TASKS.md), and
[owner dependencies](docs/LAUNCH_OWNER_ACTIONS.md).

The release command is `bash scripts/build_testflight.sh`. It verifies the
generated configuration and scans the resulting IPA before it can be uploaded.
Existing older builds are not made safe by regenerating configuration; rebuild
and verify every distributed candidate.

## License

Private project - All rights reserved
