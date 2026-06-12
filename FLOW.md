# Screenshot capture flow

Real captures from the iOS Simulator via an integration-test driver (no mockups).

## Steps

1. Boot the simulator:
   ```bash
   xcrun simctl boot "iPhone 17 Pro"
   open -a Simulator
   ```
2. Scaffold the iOS platform folder (if missing) and get dependencies:
   ```bash
   flutter create . --platforms=ios --project-name flutter_domino_game
   flutter pub get
   ```
3. Drive the screenshot test:
   ```bash
   flutter drive \
     --driver test_driver/integration_test.dart \
     --target integration_test/screenshot_test.dart \
     -d "iPhone 17 Pro"
   ```
4. Build the demo GIF from the PNGs:
   ```bash
   cd screenshots
   ffmpeg -y -framerate 1 -pattern_type glob -i '*.png' \
     -vf "scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
     -loop 0 demo.gif
   ```

PNGs + `demo.gif` are written to `screenshots/` and embedded in `README.md`.

## How it works

- `test_driver/integration_test.dart` - `integrationDriver(onScreenshot:)` writes each PNG to `screenshots/<name>.png`.
- `integration_test/screenshot_test.dart` - the game's screens read live state from Riverpod providers, so the test seeds a realistic 2v2 match with `ProviderScope(overrides: [...])` (current player + a full 7-tile hand, three bot opponents, an in-progress board chain, and a 72-45 scoreboard) instead of hitting the network. Supabase is initialized once in `setUpAll` so the screens' `initState` calls construct cleanly; the actual network fetches throw and are caught, leaving the seeded UI on screen.
  - `01-lobby` - pumps `LobbyScreen` and lets the gold "DOMINO" title entrance animation settle.
  - `02-gameplay` - pumps `GameScreen` with the seeded playing state: the rendered domino chain, opponent tile counts, the live team scores, and the "Your Turn!" indicator.
  - `03-results` - pumps `ResultsScreen` with a finished game and pumps in fixed steps so the staggered trophy/scoreboard/player-summary fade-in animations all complete before the shot.
- Each shot calls `binding.convertFlutterSurfaceToImage()`, a fixed `pump(Duration)` (not `pumpAndSettle`, which would hang on the screens' always-on shimmer/glow animations), then `binding.takeScreenshot('NN-name')`.
