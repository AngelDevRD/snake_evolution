import 'package:go_router/go_router.dart';

import '../domain/game_map.dart';
import 'screens/achievements_screen.dart';
import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_select_screen.dart';
import 'screens/missions_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/stats_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/map-select',
      builder: (context, state) => const MapSelectScreen(),
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) =>
          GameScreen(mapId: state.extra as MapId? ?? MapId.classicArena),
    ),
    GoRoute(path: '/shop', builder: (context, state) => const ShopScreen()),
    GoRoute(
      path: '/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
    GoRoute(path: '/stats', builder: (context, state) => const StatsScreen()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/missions',
      builder: (context, state) => const MissionsScreen(),
    ),
  ],
);
