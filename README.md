> **Note:** To access all shared projects, get information about environment setup, and view other guides, please visit [Explore-In-HMOS-Wearable Index](https://github.com/Explore-In-HMOS-Wearable/hmos-index).

# XoX Game

A Tic-Tac-Toe game for Huawei Watch 5 with single-player AI and multiplayer support.

# Preview

<div>
<img src="screenshots/1.png" width="25%" />
<img src="screenshots/2.png" width="25%" />
<img src="screenshots/3.png" width="25%" />
</div>

# Features

- **Game Modes** — choose between 2-player local or single-player vs AI before each session
- **AI Opponent** — Easy mode (random moves) or Hard mode (unbeatable minimax algorithm with alpha-beta pruning)
- **Winning Line Highlight** — the three winning cells turn yellow when a player wins
- **Haptic Feedback** — short buzz on tap, long buzz on win, medium buzz on draw or timeout
- **Move Timer** — 10-second countdown per turn; turn passes automatically on expiry
- **Score & Streak Tracking** — persistent scores and consecutive-win streaks shown above the board
- **Auto-Alternate First Player** — in 2-player mode the starting player swaps each round
- **Result Sheet** — shows winner/draw, streak milestone, restart and reset-scores buttons
- **Back to Menu** — return to mode selection at any time during a game

# Use Cases

- Solo play against an Easy or Hard AI opponent on the watch
- Two players taking turns on the same device
- Competitive play with score and streak tracking across multiple rounds

# Tech Stack

- **Languages**: ArkTS, ArkUI
- **Frameworks**: HarmonyOS SDK 5.0.2(18)
- **Tools**: DevEco Studio 5.1.0.842
- **Permissions**: `ohos.permission.VIBRATE`

# Directory Structure

```
entry/src/main/ets/
|---pages
|   |---Index.ets
|---components
|   |---GameBox.ets           # Main game UI and state management
|---ai
|   |---AiPlayer.ets          # Easy (random) and Hard (minimax) AI logic
|---model
|   |---Box.ets               # Observable cell model
|   |---WinResult.ets         # Win detection result (winner + winning indices)
|---entryability
|---entrybackupability
|---Utils.ets                 # generateBoxes, generateColor, detectWinner, boardToString
```

# Constraints and Restrictions

## Supported Device

- Huawei Watch 5

# LICENSE

**XoX Game** is distributed under the terms of the MIT License.
See the [LICENSE](/LICENSE) for more information.
