import React from "react";
import { Horse as HorseType, Suit } from "../../../shared/types/game.types";
import "../styles/Horse.css";

interface HorseProps {
  horse: HorseType;
}

export const Horse: React.FC<HorseProps> = ({ horse }) => {
  const getSuitColor = (suit: Suit): string => {
    switch (suit) {
      case Suit.ORO:
        return "#FFD700";
      case Suit.COPA:
        return "#4169E1";
      case Suit.ESPADA:
        return "#808080";
      case Suit.BASTO:
        return "#8B4513";
      default:
        return "#000";
    }
  };

  return (
    <div 
      className="horse" 
      style={{ 
        backgroundColor: getSuitColor(horse.suit),
        gridRow: 9 - horse.position
      }}
    >
      ðŸ´
    </div>
  );
};
