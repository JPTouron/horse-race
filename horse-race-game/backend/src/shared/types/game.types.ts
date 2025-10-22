export enum Suit {
  ORO = "ORO",
  BASTO = "BASTO",
  ESPADA = "ESPADA",
  COPA = "COPA"
}

export enum CardValue {
  AS = 1,
  DOS = 2,
  TRES = 3,
  CUATRO = 4,
  CINCO = 5,
  SEIS = 6,
  SIETE = 7,
  SOTA = 10,
  CABALLO = 11,
  REY = 12
}

export interface Card {
  suit: Suit;
  value: CardValue;
  id: string;
}

export interface Horse {
  suit: Suit;
  position: number;
}

export interface GameState {
  horses: Horse[];
  deck: Card[];
  squares: (Card | null)[];
  currentCard: Card | null;
  isGameOver: boolean;
  winner: Suit | null;
}
