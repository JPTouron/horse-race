import React from "react";
import { Card as CardType, Suit } from "../../../shared/types/game.types";
import "../styles/Card.css";

interface CardProps {
  card: CardType | null;
  isHidden?: boolean;
}

export const Card: React.FC<CardProps> = ({ card, isHidden = false }) => {
  if (!card) {
    return <div className="card card-empty"></div>;
  }

  if (isHidden) {
    return <div className="card card-hidden"></div>;
  }

  const getSuitSymbol = (suit: Suit): string => {
    switch (suit) {
      case Suit.ORO:
        return "Oro";
      case Suit.COPA:
        return "Copa";
      case Suit.ESPADA:
        return "Espada";
      case Suit.BASTO:
        return "Basto";
      default:
        return "";
    }
  };

  const getValueDisplay = (value: number): string => {
    // if (value === 10) return "S";
    // if (value === 11) return "C";
    // if (value === 12) return "R";
    return value.toString();
  };

  return (
    <div className={`card card-${card.suit.toLowerCase()}`}>
      <div className="card-content">
        <div className="card-value">{getValueDisplay(card.value)}</div>
        <div className="card-suit">{getSuitSymbol(card.suit)}</div>
      </div>
    </div>
  );
};
