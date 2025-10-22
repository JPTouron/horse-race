import { Card, CardValue, Suit } from "../../../shared/types/game.types";
import { CardEntity } from "./Card";

export class DeckEntity {
  private cards: Card[];

  constructor() {
    this.cards = this.createDeck();
    this.shuffle();
  }

  private createDeck(): Card[] {
    const suits = [Suit.ORO, Suit.BASTO, Suit.ESPADA, Suit.COPA];
    const values = [
      CardValue.AS,
      CardValue.DOS,
      CardValue.TRES,
      CardValue.CUATRO,
      CardValue.CINCO,
      CardValue.SEIS,
      CardValue.SIETE,
      CardValue.SOTA,
      CardValue.REY
    ];

    const deck: Card[] = [];
    
    for (const suit of suits) {
      for (const value of values) {
        deck.push(new CardEntity(suit, value));
      }
    }

    return deck;
  }

  shuffle(): void {
    for (let i = this.cards.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [this.cards[i], this.cards[j]] = [this.cards[j], this.cards[i]];
    }
  }

  drawCard(): Card | null {
    return this.cards.pop() || null;
  }

  getCards(): Card[] {
    return [...this.cards];
  }

  isEmpty(): boolean {
    return this.cards.length === 0;
  }
}
