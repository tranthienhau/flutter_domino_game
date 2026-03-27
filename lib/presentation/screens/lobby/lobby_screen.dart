import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/room.dart';
import '../../providers/providers.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  List<Room> _availableRooms = [];
  bool _isLoading = false;
  String? _roomCode;
  Room? _currentRoom;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    final gameService = ref.read(gameServiceProvider);
    try {
      final rooms = await gameService.listRooms();
      if (mounted) {
        setState(() => _availableRooms = rooms);
      }
    } catch (_) {
      // Silently handle - rooms list is optional
    }
  }

  Future<void> _createRoom() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter your name');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final gameService = ref.read(gameServiceProvider);
      final room = await gameService.createAndJoinRoom(name);
      if (mounted) {
        setState(() {
          _roomCode = room.code;
          _currentRoom = room;
        });
        ref.read(currentRoomProvider.notifier).state = room;
        ref.read(playerNameProvider.notifier).state = name;

        // Find our player in the room
        final me = gameService.findCurrentPlayer(room.players);
        if (me != null) {
          ref.read(currentPlayerProvider.notifier).state = me;
          ref.read(playersProvider.notifier).state = room.players;
        }

        // Listen for room updates (new players joining)
        gameService.listenToRoom(room.id, (data) {
          if (!mounted) return;
          try {
            final updatedRoom = Room.fromJson(data);
            setState(() => _currentRoom = updatedRoom);
            ref.read(currentRoomProvider.notifier).state = updatedRoom;
            ref.read(playersProvider.notifier).state = updatedRoom.players;
          } catch (_) {}
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to create room: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinRoom({String? code}) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter your name');
      return;
    }

    final roomCode = code ?? _codeController.text.trim().toUpperCase();
    if (roomCode.isEmpty) {
      _showError('Please enter a room code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final gameService = ref.read(gameServiceProvider);
      final room = await gameService.joinExistingRoom(roomCode, name);
      if (mounted) {
        setState(() {
          _roomCode = room.code;
          _currentRoom = room;
        });
        ref.read(currentRoomProvider.notifier).state = room;
        ref.read(playerNameProvider.notifier).state = name;

        final me = gameService.findCurrentPlayer(room.players);
        if (me != null) {
          ref.read(currentPlayerProvider.notifier).state = me;
          ref.read(playersProvider.notifier).state = room.players;
        }

        gameService.listenToRoom(room.id, (data) {
          if (!mounted) return;
          try {
            final updatedRoom = Room.fromJson(data);
            setState(() => _currentRoom = updatedRoom);
            ref.read(currentRoomProvider.notifier).state = updatedRoom;
            ref.read(playersProvider.notifier).state = updatedRoom.players;
          } catch (_) {}
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to join room: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startGame() async {
    if (_currentRoom == null) return;

    setState(() => _isLoading = true);

    try {
      final gameService = ref.read(gameServiceProvider);
      await gameService.startGame(_currentRoom!.id);
      if (mounted) {
        // Get game state with player hands
        final currentPlayer = ref.read(currentPlayerProvider);
        if (currentPlayer != null) {
          final fullState = await gameService.getGameState(
            _currentRoom!.id,
            currentPlayer.id,
          );
          ref.read(gameStateProvider.notifier).state = fullState;

          // Update player hand from API response
          final hand = gameService.lastPlayerHand;
          if (hand != null && hand.isNotEmpty) {
            ref.read(currentPlayerProvider.notifier).state =
                currentPlayer.copyWith(hand: hand);
          }
          final allPlayers = gameService.lastPlayers;
          if (allPlayers != null) {
            ref.read(playersProvider.notifier).state = allPlayers;
          }
        }

        if (mounted) {
          context.go('/game/${_currentRoom!.id}');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to start game: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fillWithAI() async {
    if (_currentRoom == null) return;

    setState(() => _isLoading = true);

    try {
      final gameService = ref.read(gameServiceProvider);
      final players = await gameService.addBots(_currentRoom!.id);

      if (mounted) {
        final updatedRoom = _currentRoom!.copyWith(players: players);
        setState(() => _currentRoom = updatedRoom);
        ref.read(currentRoomProvider.notifier).state = updatedRoom;
        ref.read(playersProvider.notifier).state = players;
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to add AI players: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _quickPlayAI() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter your name');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final gameService = ref.read(gameServiceProvider);

      // Create room
      final room = await gameService.createAndJoinRoom(name);
      ref.read(currentRoomProvider.notifier).state = room;
      ref.read(playerNameProvider.notifier).state = name;

      // Set current player
      final me = gameService.findCurrentPlayer(room.players);
      if (me != null) {
        ref.read(currentPlayerProvider.notifier).state = me;
      }

      // Add bots
      final players = await gameService.addBots(room.id);
      final fullRoom = room.copyWith(players: players);
      ref.read(currentRoomProvider.notifier).state = fullRoom;
      ref.read(playersProvider.notifier).state = players;

      // Start game
      await gameService.startGame(room.id);

      // Get full game state with player's hand
      final currentPlayer = ref.read(currentPlayerProvider);
      if (currentPlayer != null) {
        final fullState = await gameService.getGameState(room.id, currentPlayer.id);
        ref.read(gameStateProvider.notifier).state = fullState;

        // Update player hand from API response
        final hand = gameService.lastPlayerHand;
        if (hand != null && hand.isNotEmpty) {
          ref.read(currentPlayerProvider.notifier).state =
              currentPlayer.copyWith(hand: hand);
        }
        // Update all players (opponents get handCount)
        final allPlayers = gameService.lastPlayers;
        if (allPlayers != null) {
          ref.read(playersProvider.notifier).state = allPlayers;
        }
      }

      if (mounted) {
        context.go('/game/${room.id}');
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to start AI game: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Title
              _buildTitle(),
              const SizedBox(height: 48),
              // Show room view or lobby view
              if (_roomCode != null)
                _buildRoomView()
              else
                _buildLobbyView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Caribbean',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Colors.white70,
            letterSpacing: 8,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: -0.3, end: 0),
        Text(
          'DOMINO',
          style: GoogleFonts.poppins(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: AppTheme.secondary,
            letterSpacing: 4,
          ),
        )
            .animate()
            .fadeIn(duration: 800.ms, delay: 200.ms)
            .scale(begin: const Offset(0.8, 0.8)),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            color: AppTheme.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildLobbyView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name input
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            prefixIcon: Icon(Icons.person, color: AppTheme.secondary),
          ),
          style: const TextStyle(color: Colors.white),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 24),

        // Create Room button
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _createRoom,
          icon: const Icon(Icons.add_circle_outline),
          label: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Room'),
        ),
        const SizedBox(height: 12),
        // Quick Play vs AI
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _quickPlayAI,
          icon: const Icon(Icons.smart_toy, color: AppTheme.secondary),
          label: const Text('Quick Play vs AI'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: AppTheme.secondary.withValues(alpha: 0.5)),
          ),
        ),
        const SizedBox(height: 16),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
              ),
            ),
            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.2))),
          ],
        ),
        const SizedBox(height: 16),

        // Join Room
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Room Code',
                  prefixIcon: Icon(Icons.vpn_key, color: AppTheme.secondary),
                ),
                style: const TextStyle(color: Colors.white),
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: _isLoading ? null : () => _joinRoom(),
              child: const Text('Join'),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Available rooms
        if (_availableRooms.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Rooms',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white54),
                onPressed: _loadRooms,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._availableRooms.map((room) => _buildRoomCard(room)),
        ],
      ],
    );
  }

  Widget _buildRoomCard(Room room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary,
          child: Text(
            '${room.players.length}/4',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        title: Text(
          'Room ${room.code}',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          room.players.map((p) => p.name).join(", "),
          style: const TextStyle(color: Colors.white54),
        ),
        trailing: room.isFull
            ? const Chip(
                label: Text('Full', style: TextStyle(fontSize: 12)),
                backgroundColor: AppTheme.error,
              )
            : OutlinedButton(
                onPressed: () => _joinRoom(code: room.code),
                child: const Text('Join'),
              ),
      ),
    );
  }

  Widget _buildRoomView() {
    final room = _currentRoom;
    if (room == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Room code display
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              const Text(
                'Room Code',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    room.code,
                    style: GoogleFonts.robotoMono(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondary,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white54),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: room.code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Room code copied!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Share this code with other players',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Players list
        const Text(
          'Players',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...room.players.asMap().entries.map((entry) {
          final player = entry.value;
          final teamColor =
              player.team == 1 ? AppTheme.teamAColor : AppTheme.teamBColor;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: teamColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: teamColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    player.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  player.teamName,
                  style: TextStyle(
                    color: teamColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Seat ${player.seat + 1}',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: (100 * entry.key).ms)
              .slideX(begin: 0.1);
        }),

        // Waiting for players
        if (!room.isFull) ...[
          const SizedBox(height: 8),
          ...List.generate(4 - room.players.length, (i) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Waiting for player...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Waiting for ${4 - room.players.length} more player(s)...',
              style: const TextStyle(color: Colors.white54),
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Fill with AI button (when room is not full)
        if (!room.isFull)
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _fillWithAI,
            icon: const Icon(Icons.smart_toy),
            label: const Text('Fill with AI'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        if (!room.isFull)
          const SizedBox(height: 12),

        // Start Game button (only show when 4 players)
        if (room.canStart)
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _startGame,
            icon: const Icon(Icons.play_arrow),
            label: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Start Game'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

        const SizedBox(height: 12),

        // Back button
        OutlinedButton(
          onPressed: () {
            setState(() {
              _roomCode = null;
              _currentRoom = null;
            });
            ref.read(currentRoomProvider.notifier).state = null;
          },
          child: const Text('Back to Lobby'),
        ),
      ],
    );
  }
}
