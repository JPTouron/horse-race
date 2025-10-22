import React, { useEffect, useState } from "react";
import { GameState } from "../../../shared/types/game.types";
import { GameApiService } from "../services/GameApiService";
import { Card } from "./Card";
import { Horse } from "./Horse";
import "../styles/GameBoard.css";

const GAME_ID = "default-game";

export const GameBoard: React.FC = () => {
  const [gameState, setGameState] = useState<GameState | null>(null);
  const [loading, setLoading] = useState(true);
  const gameService = new GameApiService();

  useEffect(() => {
    initializeGame();
  }, []);

  const initializeGame = async () => {
    try {
      setLoading(true);
      const state = await gameService.createGame(GAME_ID);
      setGameState(state);
    } catch (error) {
      console.error("Error initializing game:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleDrawCard = async () => {
    if (!gameState || gameState.isGameOver) return;

    try {
      const state = await gameService.drawCard(GAME_ID);
      setGameState(state);
    } catch (error) {
      console.error("Error drawing card:", error);
    }
  };

  const handleReset = async () => {
    try {
      setLoading(true);
      const state = await gameService.resetGame(GAME_ID);
      setGameState(state);
    } catch (error) {
      console.error("Error resetting game:", error);
    } finally {
      setLoading(false);
    }
  };

  if (loading || !gameState) {
    return <div className="loading">Cargando...</div>;
  }

  return (
    <div className="game-container">
      <h1>Carrera de Caballos</h1>

      <div className="game-content">

        <div className="game-board">
          <div className="track">
            {Array.from({ length: 9 }).map((_, index) => {
              const position = 8 - index;
              return (
                <div key={position} className="track-row">
                  <div className="position-label">
                    {position === 0 ? "Salida" : position}
                  </div>

                  <div className="horses-lane">
                    {gameState.horses.map((horse) => (
                      horse.position === position && (
                        <Horse key={horse.suit} horse={horse} />
                      )
                    ))}
                  </div>

                  {position > 0 && (
                    <div className="square-card">
                      <Card
                        card={gameState.squares[position - 1]}
                        isHidden={gameState.squares[position - 1] !== null}
                      />
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        <div className="game-controls">
          {!gameState.isGameOver ? (
            <button onClick={handleDrawCard} className="btn btn-primary">
              Siguiente Carta
            </button>
          ) : (
            <div className="game-over">
              <h2>¡Juego Terminado!</h2>
              <p>Ganador: {gameState.winner}</p>
              <button onClick={handleReset} className="btn btn-success">
                Volver a Empezar
              </button>
            </div>
          )}

          {gameState.currentCard && (
            <div className="current-card">
              <h3>Carta actual:</h3>
              <Card card={gameState.currentCard} />
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
