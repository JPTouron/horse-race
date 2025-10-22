import { Card, GameState, Suit } from "../../../shared/types/game.types";
import { DeckEntity } from "./Deck";
import { HorseEntity } from "./Horse";

export class GameEntity {
  private horses: HorseEntity[];
  private deck: DeckEntity;
  private squares: (Card | null)[];
  private currentCard: Card | null;
  private isGameOver: boolean;
  private winner: Suit | null;
  private horseCards: Card[];
  private drawn: Card[] = [];

  constructor() {
    this.horses = [];
    this.deck = new DeckEntity();
    
    this.squares = [];
    this.currentCard = null;
    this.isGameOver = false;
    this.winner = null;
    this.horseCards = [];
    this.initialize();
  }

  private initialize(): void {
    const suits = [Suit.ORO, Suit.BASTO, Suit.ESPADA, Suit.COPA];
    
    for (const suit of suits) {
      this.horses.push(new HorseEntity(suit));
    }

    for (let i = 0; i < 8; i++) {
      const card = this.deck.drawCard();
      this.squares.push(card);
    }
  }

  drawNextCard(): void {
    if (this.isGameOver) return;


    if (this.deck.isEmpty()) {
      console.log("Deck is empty, regenerating from drawn cards");
      // Regenerate deck from drawn cards
      this.deck = new DeckEntity(this.drawn);
      this.drawn = [];
    }
    
    const card = this.deck.drawCard();
    console.log("Drew card:", card);
    if (!card) return;

    this.currentCard = card;
    this.drawn.push(card);

    const horse = this.horses.find(h => h.suit === card.suit);
    if (horse) {
      horse.moveForward();

      if (horse.hasFinished()) {
        this.isGameOver = true;
        this.winner = horse.suit;
        return;
      }

      if (horse.position >= 1 && horse.position <= 8) {
        const squareIndex = horse.position - 1;
        if (this.squares[squareIndex]) {
          this.revealSquare(squareIndex);
        }
      }
    }
  }

  private revealSquare(index: number): void {
    const squareCard = this.squares[index];
    if (!squareCard) return;

    const horse = this.horses.find(h => h.suit === squareCard.suit);
    if (horse) {
      horse.moveBackward();
    }

    this.squares[index] = null;
  }

  getState(): GameState {
    return {
      horses: this.horses.map(h => ({ suit: h.suit, position: h.position })),
      deck: this.deck.getCards(),
      squares: this.squares,
      currentCard: this.currentCard,
      isGameOver: this.isGameOver,
      winner: this.winner
    };
  }

  reset(): void {
    this.horses = [];
    this.deck = new DeckEntity();
    this.squares = [];
    this.currentCard = null;
    this.isGameOver = false;
    this.winner = null;
    this.horseCards = [];
    this.initialize();
  }
}
