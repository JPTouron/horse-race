# Navegar al proyecto
Set-Location "horse-race-game"

# Corregir App.tsx (remover import innecesario de React)
@'
import { GameBoard } from "./features/game/components/GameBoard";
import "./App.css";

function App() {
  return (
    <div className="App">
      <GameBoard />
    </div>
  );
}

export default App;
'@ | Out-File -FilePath "frontend/src/App.tsx" -Encoding utf8

# Corregir GameBoard.tsx (remover Suit no usado)
@'
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
        {gameState.currentCard && (
          <div className="current-card">
            <h3>Carta actual:</h3>
            <Card card={gameState.currentCard} />
          </div>
        )}

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
      </div>
    </div>
  );
};
'@ | Out-File -FilePath "frontend/src/features/game/components/GameBoard.tsx" -Encoding utf8

# Corregir GameApiService.ts (ruta incorrecta)
@'
import { GameState } from "../../../shared/types/game.types";

const API_BASE_URL = "http://localhost:3001/api/game";

export class GameApiService {
  async createGame(gameId: string): Promise<GameState> {
    const response = await fetch(`${API_BASE_URL}/create`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ gameId })
    });

    if (!response.ok) {
      throw new Error("Failed to create game");
    }

    return response.json();
  }

  async getGameState(gameId: string): Promise<GameState> {
    const response = await fetch(`${API_BASE_URL}/${gameId}`);

    if (!response.ok) {
      throw new Error("Failed to get game state");
    }

    return response.json();
  }

  async drawCard(gameId: string): Promise<GameState> {
    const response = await fetch(`${API_BASE_URL}/${gameId}/draw`, {
      method: "POST"
    });

    if (!response.ok) {
      throw new Error("Failed to draw card");
    }

    return response.json();
  }

  async resetGame(gameId: string): Promise<GameState> {
    const response = await fetch(`${API_BASE_URL}/${gameId}/reset`, {
      method: "POST"
    });

    if (!response.ok) {
      throw new Error("Failed to reset game");
    }

    return response.json();
  }
}
'@ | Out-File -FilePath "frontend/src/features/game/services/GameApiService.ts" -Encoding utf8

# Agregar licencia al package.json raíz
@'
{
  "name": "horse-race-game",
  "version": "1.0.0",
  "private": true,
  "license": "MIT",
  "workspaces": [
    "backend",
    "frontend"
  ],
  "scripts": {
    "install:all": "yarn install",
    "dev:backend": "yarn workspace backend dev",
    "dev:frontend": "yarn workspace frontend dev",
    "dev": "concurrently \"yarn dev:backend\" \"yarn dev:frontend\"",
    "build:backend": "yarn workspace backend build",
    "build:frontend": "yarn workspace frontend build",
    "build": "yarn build:backend && yarn build:frontend"
  },
  "devDependencies": {
    "concurrently": "^8.2.2"
  },
  "engines": {
    "node": "18.15.0"
  }
}
'@ | Out-File -FilePath "package.json" -Encoding utf8

# Agregar licencia al backend package.json
@'
{
  "name": "backend",
  "version": "1.0.0",
  "main": "dist/index.js",
  "license": "MIT",
  "scripts": {
    "dev": "ts-node-dev --respawn --transpile-only src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "uuid": "^9.0.1"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/cors": "^2.8.17",
    "@types/node": "^18.15.0",
    "@types/uuid": "^9.0.7",
    "typescript": "^5.3.3",
    "ts-node-dev": "^2.0.0"
  }
}
'@ | Out-File -FilePath "backend/package.json" -Encoding utf8

# Agregar licencia al frontend package.json
@'
{
  "name": "frontend",
  "version": "1.0.0",
  "license": "MIT",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.45",
    "@types/react-dom": "^18.2.18",
    "@vitejs/plugin-react": "^4.2.1",
    "typescript": "^5.3.3",
    "vite": "^5.0.8"
  }
}
'@ | Out-File -FilePath "frontend/package.json" -Encoding utf8

Write-Host "✅ Errores corregidos!" -ForegroundColor Green
Write-Host ""
Write-Host "Ahora ejecuta:" -ForegroundColor Yellow
Write-Host "yarn build" -ForegroundColor Cyan
