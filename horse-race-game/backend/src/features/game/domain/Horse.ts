import { Horse, Suit } from "../../../shared/types/game.types";

export class HorseEntity implements Horse {
  suit: Suit;
  position: number;

  constructor(suit: Suit) {
    this.suit = suit;
    this.position = 0;
  }

  moveForward(): void {
    this.position++;
  }

  moveBackward(): void {
    if (this.position > 0) {
      this.position--;
    }
  }

  hasFinished(): boolean {
    return this.position > 8;
  }
}
