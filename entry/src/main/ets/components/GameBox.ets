import { Box } from '../model/Box';
import { WinResult } from '../model/WinResult';
import { Utils } from '../Utils';
import { AiPlayer } from '../ai/AiPlayer';
import vibrator from '@ohos.vibrator';

@Component
export struct GameBox {
  // ── Game state ────────────────────────────────────────────────────────────
  @State boxes: Box[] = Utils.generateBoxes()
  @State pen: string = 'X';
  @State winner: string = '';
  @State isShow: boolean = false;

  // ── Mode & setup ─────────────────────────────────────────────────────────
  @State gameMode: string = 'human';    // 'human' | 'easy' | 'hard'
  @State modeSelected: boolean = false; // false = show mode picker, true = playing

  // ── Scores & streaks ──────────────────────────────────────────────────────
  @State scoreX: number = 0;
  @State scoreO: number = 0;
  @State streakX: number = 0;
  @State streakO: number = 0;

  // ── Winning-line highlight ────────────────────────────────────────────────
  @State winIndices: number[] = [];     // [a, b, c] of the 3 winning cells

  // ── Timer ─────────────────────────────────────────────────────────────────
  @State timeLeft: number = 10;
  private timerId: number = -1;

  // ── AI ────────────────────────────────────────────────────────────────────
  @State isAiThinking: boolean = false;

  // ── Auto-alternate first player (human mode only) ─────────────────────────
  @State firstPlayer: string = 'X';    // who starts the next round

  // ─────────────────────────────────────────────────────────────────────────
  // Haptic
  // ─────────────────────────────────────────────────────────────────────────
  private triggerHaptic(type: string): void {
    try {
      if (type === 'win') {
        vibrator.startVibration({ type: 'time', duration: 300 }, { id: 0, usage: 'alarm' });
      } else if (type === 'draw' || type === 'timeout') {
        vibrator.startVibration({ type: 'time', duration: 150 }, { id: 0, usage: 'notification' });
      } else {
        // 'tap'
        vibrator.startVibration({ type: 'time', duration: 50 }, { id: 0, usage: 'touch' });
      }
    } catch (_e) {
      // Vibrator unavailable in emulator — fail silently
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Timer
  // ─────────────────────────────────────────────────────────────────────────
  private stopTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private startTimer(): void {
    if (this.winner !== '' || !this.modeSelected) {
      return;
    }
    this.stopTimer(); // prevent double-interval
    this.timeLeft = 10;
    this.timerId = setInterval(() => {
      this.timeLeft -= 1;
      if (this.timeLeft <= 0) {
        this.stopTimer();
        this.triggerHaptic('timeout');
        this.autoPassTurn();
      }
    }, 1000);
  }

  private autoPassTurn(): void {
    if (this.winner !== '') {
      return;
    }
    this.pen = this.pen === 'X' ? 'O' : 'X';
    if (this.gameMode !== 'human' && this.pen === 'O') {
      this.scheduleAiMove();
    } else {
      this.startTimer();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AI
  // ─────────────────────────────────────────────────────────────────────────
  private scheduleAiMove(): void {
    if (this.winner !== '') {
      return;
    }
    this.isAiThinking = true;
    setTimeout(() => {
      if (this.winner !== '') {
        this.isAiThinking = false;
        return;
      }
      const board: string[] = Utils.boardToString(this.boxes);
      let idx: number = -1;
      if (this.gameMode === 'easy') {
        idx = AiPlayer.easyMove(board);
      } else {
        idx = AiPlayer.hardMove(board);
      }
      if (idx !== -1) {
        this.triggerHaptic('tap');
        this.boxes[idx] = new Box('O');
        this.pen = 'X';
        this.checkWin();
      }
      this.isAiThinking = false;
      if (this.winner === '') {
        this.startTimer();
      }
    }, 300);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Game logic
  // ─────────────────────────────────────────────────────────────────────────
  private checkWin(): void {
    if (this.winner !== '') {
      return;
    }

    const result: WinResult = Utils.detectWinner(this.boxes);

    if (result.winner !== '') {
      this.winIndices = result.indices;
      this.winner = result.winner;
      this.stopTimer();
      this.triggerHaptic('win');
      if (result.winner === 'X') {
        this.scoreX += 1;
        this.streakX += 1;
        this.streakO = 0;
      } else {
        this.scoreO += 1;
        this.streakO += 1;
        this.streakX = 0;
      }
      this.isShow = true;
      return;
    }

    let isDraw = true;
    for (let i = 0; i < this.boxes.length; i++) {
      if (this.boxes[i].value === '') {
        isDraw = false;
        break;
      }
    }
    if (isDraw) {
      this.winner = 'Draw';
      this.stopTimer();
      this.triggerHaptic('draw');
      this.isShow = true;
    }
  }

  private refresh(): void {
    this.stopTimer();
    Box.resetCounter();
    this.boxes = Utils.generateBoxes();
    this.winner = '';
    this.winIndices = [];
    this.isShow = false;
    this.isAiThinking = false;

    // Auto-alternate first player in human mode; AI mode always starts with human (X)
    if (this.gameMode === 'human') {
      this.pen = this.firstPlayer;
      this.firstPlayer = this.firstPlayer === 'X' ? 'O' : 'X';
    } else {
      this.pen = 'X';
      this.firstPlayer = 'X';
    }

    this.startTimer();
  }

  private resultColor(): ResourceColor {
    if (this.winner === 'Draw') {
      return Color.Gray;
    }
    return Utils.generateColor(this.winner);
  }

  private resetAll(): void {
    this.scoreX = 0;
    this.scoreO = 0;
    this.streakX = 0;
    this.streakO = 0;
    this.firstPlayer = 'X';
    this.refresh();
  }

  private backToMenu(): void {
    this.stopTimer();
    this.scoreX = 0;
    this.scoreO = 0;
    this.streakX = 0;
    this.streakO = 0;
    this.firstPlayer = 'X';
    this.pen = 'X';
    Box.resetCounter();
    this.boxes = Utils.generateBoxes();
    this.winner = '';
    this.winIndices = [];
    this.isShow = false;
    this.isAiThinking = false;
    this.modeSelected = false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Result sheet
  // ─────────────────────────────────────────────────────────────────────────
  @Builder
  ShowResult() {
    Column() {
      if (this.winner === 'Draw') {
        Text($r('app.string.draw_result'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .padding(8)
          .fontColor(Color.Gray)
      } else {
        Text(this.winner === 'X' ? $r('app.string.winner_x') : $r('app.string.winner_o'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .padding(8)
          .fontColor(this.resultColor())
      }

      // Streak line — only shown when the winner is on a multi-game streak
      if (this.winner === 'X' && this.streakX > 1) {
        Text($r('app.string.streak_label', this.streakX))
          .fontSize(12)
          .fontColor(Color.Blue)
          .padding({ bottom: 4 })
      } else if (this.winner === 'O' && this.streakO > 1) {
        Text($r('app.string.streak_label', this.streakO))
          .fontSize(12)
          .fontColor(Color.Red)
          .padding({ bottom: 4 })
      }

      Column({ space: 6 }) {
        Button($r('app.string.btn_restart'))
          .backgroundColor(Color.White)
          .fontColor(this.resultColor())
          .borderColor(this.resultColor())
          .borderWidth(1)
          .fontSize(11)
          .height(22)
          .onClick(() => {
            this.refresh();
          })
        Button($r('app.string.btn_reset_scores'))
          .backgroundColor(Color.White)
          .fontColor(Color.Gray)
          .borderColor(Color.Gray)
          .borderWidth(1)
          .fontSize(11)
          .height(22)
          .onClick(() => {
            this.resetAll();
          })
      }
      .padding({ left: 8, right: 8 })
      .width('100%')
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────
  build() {
    RelativeContainer() {

      // ── Mode selection screen ─────────────────────────────────────────────
      if (!this.modeSelected) {
        Column({ space: 10 }) {
          Text($r('app.string.select_mode'))
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Black)

          Button($r('app.string.mode_human'))
            .backgroundColor(Color.White)
            .fontColor(Color.Black)
            .borderColor(Color.Gray)
            .borderWidth(1)
            .fontSize(12)
            .height(28)
            .width('70%')
            .onClick(() => {
              this.gameMode = 'human';
              this.modeSelected = true;
              this.startTimer();
            })

          Button($r('app.string.mode_easy'))
            .backgroundColor(Color.White)
            .fontColor(Color.Blue)
            .borderColor(Color.Blue)
            .borderWidth(1)
            .fontSize(12)
            .height(28)
            .width('70%')
            .onClick(() => {
              this.gameMode = 'easy';
              this.modeSelected = true;
              this.startTimer();
            })

          Button($r('app.string.mode_hard'))
            .backgroundColor(Color.White)
            .fontColor(Color.Red)
            .borderColor(Color.Red)
            .borderWidth(1)
            .fontSize(12)
            .height(28)
            .width('70%')
            .onClick(() => {
              this.gameMode = 'hard';
              this.modeSelected = true;
              this.startTimer();
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {

        // ── Game screen ─────────────────────────────────────────────────────
        Column() {

          // Back-to-menu button
          Row() {
            Text($r('app.string.btn_menu'))
              .fontSize(14)
              .fontColor(Color.Gray)
              .onClick(() => { this.backToMenu(); })
          }
          .width('100%')
          .padding({ bottom: 1 })

          // Score row with optional streak badges
          Row() {
            Text(`X:${this.scoreX}`)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.Blue)
            if (this.streakX > 1) {
              Text(` *${this.streakX}`)
                .fontSize(11)
                .fontColor(Color.Blue)
            }
            Text(`  O:${this.scoreO}`)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.Red)
            if (this.streakO > 1) {
              Text(` *${this.streakO}`)
                .fontSize(11)
                .fontColor(Color.Red)
            }
          }.padding({ bottom: 2 })

          // Turn indicator + timer on one row
          if (!this.winner) {
            Row() {
              if (this.isAiThinking) {
                Text($r('app.string.turn_ai'))
                  .fontSize(12)
                  .fontColor(Color.Gray)
              } else {
                Text(this.pen === 'X' ? $r('app.string.turn_x') : $r('app.string.turn_o'))
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Utils.generateColor(this.pen))
              }
              Text(`  ${this.timeLeft}s`)
                .fontSize(12)
                .fontColor(this.timeLeft <= 3 ? Color.Red : Color.Gray)
            }.padding({ bottom: 2 })
          }

          // 3×3 game grid
          Grid() {
            ForEach(this.boxes, (item: Box, index: number) => {
              GridItem() {
                Text(item.value)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Utils.generateColor(item.value))
                  .fontSize(28)
                  .width('100%')
                  .height('100%')
                  .textAlign(TextAlign.Center)
              }
              .border({ color: Color.Gray, width: 1 })
              .backgroundColor(
                this.winIndices.length === 3 &&
                (this.winIndices[0] === index ||
                  this.winIndices[1] === index ||
                  this.winIndices[2] === index)
                  ? Color.Yellow : Color.Transparent
              )
              .onClick(() => {
                if (!item.value && !this.winner && !this.isAiThinking) {
                  this.triggerHaptic('tap');
                  this.boxes[index] = new Box(this.pen);
                  this.stopTimer();
                  this.pen = this.pen === 'X' ? 'O' : 'X';
                  this.checkWin();
                  if (this.winner === '') {
                    if (this.gameMode !== 'human' && this.pen === 'O') {
                      this.scheduleAiMove();
                    } else {
                      this.startTimer();
                    }
                  }
                }
              })
            }, (item: Box) => item.id)
          }
          .columnsTemplate('1fr 1fr 1fr')
          .rowsTemplate('1fr 1fr 1fr')
          .width('100%')
          .layoutWeight(1)

        }
        .bindSheet(this.isShow, this.ShowResult(), {
          height: '50%',
          onDisappear: () => this.refresh(),
          showClose: false
        })
        .justifyContent(FlexAlign.Center)
        .border({ color: Color.Gray, width: 2 })
        .width('70%')
        .height('70%')
        .margin('15%')
      }

    }
    .height('100%')
    .width('100%')
    .backgroundColor(Color.White)
  }
}
