import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'core/utils/sound_manager.dart';
import 'core/services/supabase_service.dart';
import 'shared/services/avatar_growth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading .env file: $e');
  }

  // Initialize Supabase (optional - app works without it)
  try {
    await SupabaseService().initialize();
  } catch (e) {
    print('Supabase initialization failed: $e. App will use local data.');
  }

  // Initialize Inner Avatar (vision-aligned growth system)
  try {
    await AvatarGrowthService().initialize();
  } catch (e) {
    print('Avatar initialization failed: $e. App will use default avatar.');
  }

  // Initialize sound manager and start playing bird singing sound
  await SoundManager().initialize();

  runApp(
    const ProviderScope(
      child: AshraePlaygroundApp(),
    ),
  );
}

class AshraePlaygroundApp extends StatelessWidget {
  const AshraePlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.login,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
