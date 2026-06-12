import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_domino_game/core/constants/api_config.dart';
import 'package:flutter_domino_game/core/theme/app_theme.dart';
import 'package:flutter_domino_game/data/models/domino_tile.dart';
import 'package:flutter_domino_game/data/models/game_state.dart';
import 'package:flutter_domino_game/data/models/player.dart';
import 'package:flutter_domino_game/data/models/room.dart';
import 'package:flutter_domino_game/presentation/providers/providers.dart';
import 'package:flutter_domino_game/presentation/screens/game/game_screen.dart';
import 'package:flutter_domino_game/presentation/screens/lobby/lobby_screen.dart';
import 'package:flutter_domino_game/presentation/screens/results/results_screen.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Supabase init is offline-safe; network calls (which the screens make in
    // initState) simply throw and are caught, so the seeded UI still renders.
    await Supabase.initialize(
      url: ApiConfig.supabaseUrl,
      anonKey: ApiConfig.supabaseAnonKey,
    );
  });

  Future<void> shoot(WidgetTester tester, String name) async {
    await binding.convertFlutterSurfaceToImage();
    await tester.pump(const Duration(milliseconds: 600));
    await binding.takeScreenshot(name);
  }

  // ---- Mock data ----------------------------------------------------------
  final players = <Player>[
    const Player(
      id: 'p1',
      name: 'You',
      team: 0,
      seat: 0,
      hand: [
        DominoTile(left: 6, right: 6),
        DominoTile(left: 6, right: 3),
        DominoTile(left: 3, right: 1),
        DominoTile(left: 5, right: 2),
        DominoTile(left: 4, right: 0),
        DominoTile(left: 2, right: 2),
        DominoTile(left: 1, right: 0),
      ],
    ),
    const Player(
      id: 'p2',
      name: 'Marisol',
      team: 1,
      seat: 1,
      hand: [
        DominoTile(left: 0, right: 0),
        DominoTile(left: 0, right: 0),
        DominoTile(left: 0, right: 0),
        DominoTile(left: 0, right: 0),
        DominoTile(left: 0, right: 0),
      ],
      isBot: true,
    ),
    const Player(
      id: 'p3',
      name: 'Andre',
      team: 0,
      seat: 2,
      hand: [
        DominoTile(left: 0, right: 0),
        DominoTile(left: 0, right: 0),
        DominoTile(left: 0, right: 0),
        DominoTile(left: 0, right: 0),
        DominoTile(left: 0, right: 0),
        DominoTile(left: 0, right: 0),
      ],
      isBot: true,
    ),
    const Player(
      id: 'p4',
      name: 'Keisha',
      team: 1,
      seat: 3,
      hand: [
        DominoTile(left: 0, right: 0),
        DominoTile(left: 0, right: 0),
        DominoTile(left: 0, right: 0),
        DominoTile(left: 0, right: 0),
      ],
      isBot: true,
    ),
  ];

  Map<String, dynamic> boardTile(int left, int right, {bool flipped = false}) => {
        'tile': {'left': left, 'right': right},
        'end': 'right',
        'flipped': flipped,
      };

  final playingState = GameState(
    roomId: 'room1',
    phase: 'playing',
    round: 2,
    currentPlayerId: 'p1',
    openLeft: 6,
    openRight: 2,
    scores: const {'teamA': 72, 'teamB': 45},
    board: [
      boardTile(2, 2),
      boardTile(2, 5),
      boardTile(5, 5),
      boardTile(5, 1),
      boardTile(1, 4),
      boardTile(4, 6),
    ],
  );

  final finishedState = playingState.copyWith(
    phase: 'game_over',
    scores: const {'teamA': 100, 'teamB': 68},
  );

  final room = Room(
    id: 'room1',
    code: 'JAMB7',
    players: players.sublist(0, 3),
    status: 'waiting',
  );

  List<Override> seed({GameState? gameState}) => [
        currentPlayerProvider.overrideWith((ref) => players.first),
        playersProvider.overrideWith((ref) => players),
        currentRoomProvider.overrideWith((ref) => room),
        gameStateProvider.overrideWith((ref) => gameState),
      ];

  Widget host(Widget child, List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: child,
      ),
    );
  }

  testWidgets('capture domino game flow', (tester) async {
    // ---- 01 Lobby (title, name field, Create Room, Quick Play vs AI) ------
    await tester.pumpWidget(host(const LobbyScreen(), seed()));
    // Let the title entrance animation settle so it is fully opaque.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await shoot(tester, '01-lobby');

    // ---- 02 Gameplay (board chain, hands, scores, your turn) --------------
    await tester.pumpWidget(host(const GameScreen(roomId: 'room1'), seed(gameState: playingState)));
    await tester.pump(const Duration(milliseconds: 700));
    await shoot(tester, '02-gameplay');

    // ---- 03 Results / scoreboard ------------------------------------------
    // The results screen staggers entrance animations (trophy elasticOut,
    // winner text + scoreboard + player rows fade in up to ~1.1s, then an
    // infinite shimmer). Pump in steps so every element is fully visible.
    await tester.pumpWidget(host(const ResultsScreen(roomId: 'room1'), seed(gameState: finishedState)));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await shoot(tester, '03-results');
  });
}
