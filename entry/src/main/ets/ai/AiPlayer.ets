import { Utils } from '../Utils';

export class AiPlayer {
  /**
   * Easy mode: picks a random empty cell.
   * Returns the chosen index (0–8), or -1 if the board is full.
   */
  static easyMove(board: string[]): number {
    const empty: number[] = [];
    for (let i = 0; i < board.length; i++) {
      if (board[i] === '') {
        empty.push(i);
      }
    }
    if (empty.length === 0) {
      return -1;
    }
    return empty[Math.floor(Math.random() * empty.length)];
  }

  /**
   * Hard mode: picks the best move using minimax with alpha-beta pruning.
   * AI always plays as 'O' (maximizer). Returns the chosen index, or -1 if full.
   * NOTE: board is a copy produced by Utils.boardToString — it is safe to mutate.
   */
  static hardMove(board: string[]): number {
    let bestScore: number = -Infinity;
    let bestIdx: number = -1;

    for (let i = 0; i < board.length; i++) {
      if (board[i] === '') {
        board[i] = 'O';
        const score = AiPlayer.minimax(board, false, 1, -Infinity, Infinity);
        board[i] = '';
        if (score > bestScore) {
          bestScore = score;
          bestIdx = i;
        }
      }
    }
    return bestIdx;
  }

  /**
   * Recursive minimax with alpha-beta pruning.
   * isMaximizing = true means it is O's turn (AI); false means X's turn (human).
   * Scoring from O's perspective:
   *   O wins at depth d → 10 - d  (prefer faster wins)
   *   X wins at depth d → d - 10  (prefer slower losses)
   *   Draw → 0
   */
  private static minimax(
    board: string[],
    isMaximizing: boolean,
    depth: number,
    alpha: number,
    beta: number
  ): number {
    const winner = Utils.detectWinnerOnBoard(board);
    if (winner === 'O') {
      return 10 - depth;
    }
    if (winner === 'X') {
      return depth - 10;
    }

    let hasEmpty = false;
    for (let i = 0; i < board.length; i++) {
      if (board[i] === '') {
        hasEmpty = true;
        break;
      }
    }
    if (!hasEmpty) {
      return 0; // draw
    }

    if (isMaximizing) {
      let best = -Infinity;
      for (let i = 0; i < board.length; i++) {
        if (board[i] === '') {
          board[i] = 'O';
          const score = AiPlayer.minimax(board, false, depth + 1, alpha, beta);
          board[i] = '';
          if (score > best) {
            best = score;
          }
          if (best > alpha) {
            alpha = best;
          }
          if (alpha >= beta) {
            break; // beta cut-off
          }
        }
      }
      return best;
    } else {
      let best = Infinity;
      for (let i = 0; i < board.length; i++) {
        if (board[i] === '') {
          board[i] = 'X';
          const score = AiPlayer.minimax(board, true, depth + 1, alpha, beta);
          board[i] = '';
          if (score < best) {
            best = score;
          }
          if (best < beta) {
            beta = best;
          }
          if (beta <= alpha) {
            break; // alpha cut-off
          }
        }
      }
      return best;
    }
  }
}
