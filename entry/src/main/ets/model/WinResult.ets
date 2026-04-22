export class WinResult {
  winner: string;     // 'X' | 'O' | ''
  indices: number[];  // [a, b, c] of the winning line, or [] when no winner

  constructor(winner: string, indices: number[]) {
    this.winner = winner;
    this.indices = indices;
  }
}
