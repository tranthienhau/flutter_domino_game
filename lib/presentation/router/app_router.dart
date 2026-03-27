import 'package:go_router/go_router.dart';
import '../screens/lobby/lobby_screen.dart';
import '../screens/game/game_screen.dart';
import '../screens/results/results_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LobbyScreen(),
    ),
    GoRoute(
      path: '/game/:roomId',
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        return GameScreen(roomId: roomId);
      },
    ),
    GoRoute(
      path: '/results/:roomId',
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        return ResultsScreen(roomId: roomId);
      },
    ),
  ],
);
