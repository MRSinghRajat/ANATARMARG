# ANTAR MARG - The Inner Path

A gamified spiritual learning app that guides users through ancient Indian wisdom using an animated old sadhu character.

## Features

- **Animated Guide**: Old sadhu character with Rive animations
- **Daily Tasks**: 3 tasks per day (water, prayer, food) completed by reading scripture
- **Gamification**: Coins, points, items with rarity levels (common, rare, epic)
- **Books Library**: Mahabharata, Ramayan, Bhagavad Gita with AI chat
- **Home Customization**: Ancient Indian home with items and upgrades
- **Stats & Leaderboards**: Daily reset leaderboards and progress tracking
- **Ambient Sounds**: Bird chirping, sitar music, forest sounds

## Tech Stack

- Flutter 3.0+
- Riverpod (State Management)
- Rive (2D Animations)
- GPT API (Content Generation)
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
   - Update `.env` with your Supabase credentials
   - Set up GPT API key in `lib/core/config/app_config.dart`

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

🚧 **In Development** - Foundation phase

## License

Private project - All rights reserved
