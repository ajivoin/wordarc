import 'package:go_router/go_router.dart';
import 'package:wordarc/features/game/game_screen.dart';
import 'package:wordarc/features/home/home_screen.dart';
import 'package:wordarc/features/packs/pack_detail_screen.dart';
import 'package:wordarc/features/packs/packs_screen.dart';
import 'package:wordarc/features/splash/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/packs',
      builder: (context, state) => const PacksScreen(),
      routes: [
        GoRoute(
          path: ':packId',
          builder: (context, state) => PackDetailScreen(
            packId: state.pathParameters['packId']!,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/play/:levelId',
      builder: (context, state) => GameScreen(
        levelId: state.pathParameters['levelId']!,
      ),
    ),
  ],
);
