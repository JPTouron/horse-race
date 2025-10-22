import { Card, CardValue, Suit } from "../../../shared/types/game.types";
import { v4 as uuidv4 } from "uuid";

export class CardEntity implements Card {
  id: string;
  suit: Suit;
  value: CardValue;

  constructor(suit: Suit, value: CardValue) {
    this.id = uuidv4();
    this.suit = suit;
    this.value = value;
  }
}
