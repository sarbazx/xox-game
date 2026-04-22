@Observed
export class Box{
  private static idCounter: number = 0;
  id: string
  value: string

  constructor(value: string = '') {
    this.id = (++Box.idCounter).toString();
    this.value = value;
  }

  static resetCounter(): void {
    Box.idCounter = 0;
  }
}
