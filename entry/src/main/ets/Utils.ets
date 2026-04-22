import { Box } from './model/Box';
import { WinResult } from './model/WinResult';

export class Utils {
  static generateBoxes(): Box[] {
    const list: Box[] = [];
    for (let index = 0; index < 9; index++) {
      list.push(new Box(''));
    }
    return list;
  }

  static generateColor(value: string): ResourceColor {
    if (value === 'X') {
      return Color.Blue;
    } else if (value === 'O') {
      return Color.Red;
    } else {
      return Color.Gray;
    }
  }

  /**
   * Returns a WinResult with the winning player and the three winning cell indices,
   * or WinResult('', []) if no winner yet.
   * Does not detect draw — caller checks all boxes filled separately.
   */
  static detectWinner(boxes: Box[]): WinResult {
    const winPatterns: number[][] = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (let i = 0; i < winPatterns.length; i++) {
      const a = winPatterns[i][0];
      const b = winPatterns[i][1];
      const c = winPatterns[i][2];

      if (
        boxes[a].value !== '' &&
        boxes[a].value === boxes[b].value &&
        boxes[a].value === boxes[c].value
      ) {
        return new WinResult(boxes[a].value, [a, b, c]);
      }
    }
    return new WinResult('', []);
  }

  /**
   * Same 8-pattern scan on a plain string[] board (used by AI minimax to avoid
   * Box object allocation during recursive calls).
   * Returns 'X', 'O', or ''.
   */
  static detectWinnerOnBoard(board: string[]): string {
    const winPatterns: number[][] = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (let i = 0; i < winPatterns.length; i++) {
      const a = winPatterns[i][0];
      const b = winPatterns[i][1];
      const c = winPatterns[i][2];

      if (board[a] !== '' && board[a] === board[b] && board[a] === board[c]) {
        return board[a];
      }
    }
    return '';
  }

  /**
   * Converts a Box[] to a plain string[] for use by the AI.
   */
  static boardToString(boxes: Box[]): string[] {
    const result: string[] = [];
    for (let i = 0; i < boxes.length; i++) {
      result.push(boxes[i].value);
    }
    return result;
  }
}
