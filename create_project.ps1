
# Crear estructura base del proyecto
New-Item -ItemType Directory -Path "horse-race-game"
Set-Location "horse-race-game"

# Crear estructura de carpetas
New-Item -ItemType Directory -Path "backend/src/features/game/domain"
New-Item -ItemType Directory -Path "backend/src/features/game/application"
New-Item -ItemType Directory -Path "backend/src/features/game/infrastructure"
New-Item -ItemType Directory -Path "backend/src/shared/types"
New-Item -ItemType Directory -Path "frontend/src/features/game/components"
New-Item -ItemType Directory -Path "frontend/src/features/game/services"
New-Item -ItemType Directory -Path "frontend/src/features/game/styles"
New-Item -ItemType Directory -Path "frontend/src/shared/types"
New-Item -ItemType Directory -Path "frontend/public"

# Crear package.json raíz
@'
{
  "name": "horse-race-game",
  "version": "1.0.0",
  "private": true,
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

# ===== BACKEND =====

# Backend package.json
@'
{
  "name": "backend",
  "version": "1.0.0",
  "main": "dist/index.js",
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

# Backend tsconfig.json
@'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
'@ | Out-File -FilePath "backend/tsconfig.json" -Encoding utf8

# Backend - Tipos compartidos
@'
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
'@ | Out-File -FilePath "backend/src/shared/types/game.types.ts" -Encoding utf8

# Backend - Domain - Card
@'
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
'@ | Out-File -FilePath "backend/src/features/game/domain/Card.ts" -Encoding utf8

# Backend - Domain - Horse
@'
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
'@ | Out-File -FilePath "backend/src/features/game/domain/Horse.ts" -Encoding utf8

# Backend - Domain - Deck
@'
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
'@ | Out-File -FilePath "backend/src/features/game/domain/Deck.ts" -Encoding utf8

# Backend - Domain - Game
@'
import { Card, GameState, Suit } from "../../../shared/types/game.types";
import { CardEntity } from "./Card";
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

    const card = this.deck.drawCard();
    if (!card) return;

    this.currentCard = card;

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
'@ | Out-File -FilePath "backend/src/features/game/domain/Game.ts" -Encoding utf8

# Backend - Application - GameService
@'
import { GameState } from "../../../shared/types/game.types";
import { GameEntity } from "../domain/Game";

export class GameService {
  private games: Map<string, GameEntity>;

  constructor() {
    this.games = new Map();
  }

  createGame(gameId: string): GameState {
    const game = new GameEntity();
    this.games.set(gameId, game);
    return game.getState();
  }

  getGameState(gameId: string): GameState | null {
    const game = this.games.get(gameId);
    return game ? game.getState() : null;
  }

  drawCard(gameId: string): GameState | null {
    const game = this.games.get(gameId);
    if (!game) return null;

    game.drawNextCard();
    return game.getState();
  }

  resetGame(gameId: string): GameState | null {
    const game = this.games.get(gameId);
    if (!game) return null;

    game.reset();
    return game.getState();
  }
}
'@ | Out-File -FilePath "backend/src/features/game/application/GameService.ts" -Encoding utf8

# Backend - Infrastructure - GameController
@'
import { Request, Response } from "express";
import { GameService } from "../application/GameService";

export class GameController {
  private gameService: GameService;

  constructor() {
    this.gameService = new GameService();
  }

  createGame = (req: Request, res: Response): void => {
    const { gameId } = req.body;
    if (!gameId) {
      res.status(400).json({ error: "gameId is required" });
      return;
    }

    const gameState = this.gameService.createGame(gameId);
    res.json(gameState);
  };

  getGameState = (req: Request, res: Response): void => {
    const { gameId } = req.params;
    const gameState = this.gameService.getGameState(gameId);
    
    if (!gameState) {
      res.status(404).json({ error: "Game not found" });
      return;
    }

    res.json(gameState);
  };

  drawCard = (req: Request, res: Response): void => {
    const { gameId } = req.params;
    const gameState = this.gameService.drawCard(gameId);
    
    if (!gameState) {
      res.status(404).json({ error: "Game not found" });
      return;
    }

    res.json(gameState);
  };

  resetGame = (req: Request, res: Response): void => {
    const { gameId } = req.params;
    const gameState = this.gameService.resetGame(gameId);
    
    if (!gameState) {
      res.status(404).json({ error: "Game not found" });
      return;
    }

    res.json(gameState);
  };
}
'@ | Out-File -FilePath "backend/src/features/game/infrastructure/GameController.ts" -Encoding utf8

# Backend - Infrastructure - GameRoutes
@'
import { Router } from "express";
import { GameController } from "./GameController";

export class GameRoutes {
  private router: Router;
  private gameController: GameController;

  constructor() {
    this.router = Router();
    this.gameController = new GameController();
    this.setupRoutes();
  }

  private setupRoutes(): void {
    this.router.post("/create", this.gameController.createGame);
    this.router.get("/:gameId", this.gameController.getGameState);
    this.router.post("/:gameId/draw", this.gameController.drawCard);
    this.router.post("/:gameId/reset", this.gameController.resetGame);
  }

  getRouter(): Router {
    return this.router;
  }
}
'@ | Out-File -FilePath "backend/src/features/game/infrastructure/GameRoutes.ts" -Encoding utf8

# Backend - index.ts
@'
import express, { Application } from "express";
import cors from "cors";
import { GameRoutes } from "./features/game/infrastructure/GameRoutes";

const app: Application = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

const gameRoutes = new GameRoutes();
app.use("/api/game", gameRoutes.getRouter());

app.listen(PORT, () => {
  console.log(`Backend running on http://localhost:${PORT}`);
});
'@ | Out-File -FilePath "backend/src/index.ts" -Encoding utf8

# ===== FRONTEND =====

# Frontend package.json
@'
{
  "name": "frontend",
  "version": "1.0.0",
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

# Frontend tsconfig.json
@'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
'@ | Out-File -FilePath "frontend/tsconfig.json" -Encoding utf8

# Frontend tsconfig.node.json
@'
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
'@ | Out-File -FilePath "frontend/tsconfig.node.json" -Encoding utf8

# Frontend vite.config.ts
@'
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000
  }
});
'@ | Out-File -FilePath "frontend/vite.config.ts" -Encoding utf8

# Frontend - Tipos compartidos
@'
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
'@ | Out-File -FilePath "frontend/src/shared/types/game.types.ts" -Encoding utf8

# Frontend - GameService
@'
import { GameState } from "../../shared/types/game.types";

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

# Frontend - CardComponent
@'
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
    return <div className="card card-hidden">🂠</div>;
  }

  const getSuitSymbol = (suit: Suit): string => {
    switch (suit) {
      case Suit.ORO:
        return "🪙";
      case Suit.COPA:
        return "🏆";
      case Suit.ESPADA:
        return "⚔️";
      case Suit.BASTO:
        return "🏏";
      default:
        return "";
    }
  };

  const getValueDisplay = (value: number): string => {
    if (value === 10) return "S";
    if (value === 11) return "C";
    if (value === 12) return "R";
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
'@ | Out-File -FilePath "frontend/src/features/game/components/Card.tsx" -Encoding utf8

# Frontend - HorseComponent
@'
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
      🐴
    </div>
  );
};
'@ | Out-File -FilePath "frontend/src/features/game/components/Horse.tsx" -Encoding utf8

# Frontend - GameBoardComponent
@'
import React, { useEffect, useState } from "react";
import { GameState, Suit } from "../../../shared/types/game.types";
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

# Frontend - Card.css
@'
.card {
  width: 80px;
  height: 120px;
  border: 2px solid #333;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s;
}

.card:hover {
  transform: scale(1.05);
}

.card-hidden {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-size: 48px;
}

.card-empty {
  background: #f0f0f0;
  border: 2px dashed #ccc;
}

.card-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.card-value {
  font-size: 24px;
  font-weight: bold;
}

.card-suit {
  font-size: 32px;
}

.card-oro {
  border-color: #FFD700;
  background: linear-gradient(to bottom, #ffffff, #FFF8DC);
}

.card-copa {
  border-color: #4169E1;
  background: linear-gradient(to bottom, #ffffff, #E6F2FF);
}

.card-espada {
  border-color: #808080;
  background: linear-gradient(to bottom, #ffffff, #F5F5F5);
}

.card-basto {
  border-color: #8B4513;
  background: linear-gradient(to bottom, #ffffff, #FFF5EE);
}
'@ | Out-File -FilePath "frontend/src/features/game/styles/Card.css" -Encoding utf8

# Frontend - Horse.css
@'
.horse {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  border: 3px solid #333;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
  transition: all 0.3s ease;
  animation: bounce 0.5s;
}

@keyframes bounce {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

.horse:hover {
  transform: scale(1.1);
}
'@ | Out-File -FilePath "frontend/src/features/game/styles/Horse.css" -Encoding utf8

# Frontend - GameBoard.css
@'
.game-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  font-family: Arial, sans-serif;
}

h1 {
  text-align: center;
  color: #333;
  margin-bottom: 30px;
}

.loading {
  text-align: center;
  font-size: 24px;
  padding: 50px;
}

.game-board {
  display: flex;
  justify-content: center;
  margin-bottom: 30px;
}

.track {
  display: flex;
  flex-direction: column;
  gap: 10px;
  background: #f9f9f9;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.track-row {
  display: flex;
  align-items: center;
  gap: 20px;
  min-height: 80px;
}

.position-label {
  width: 80px;
  text-align: center;
  font-weight: bold;
  font-size: 18px;
  color: #555;
}

.horses-lane {
  display: flex;
  gap: 10px;
  min-width: 300px;
  align-items: center;
}

.square-card {
  display: flex;
  align-items: center;
}

.game-controls {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}

.current-card {
  text-align: center;
}

.current-card h3 {
  margin-bottom: 10px;
  color: #555;
}

.btn {
  padding: 12px 24px;
  font-size: 18px;
  font-weight: bold;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
}

.btn-primary {
  background: #4CAF50;
  color: white;
}

.btn-primary:hover {
  background: #45a049;
}

.btn-success {
  background: #2196F3;
  color: white;
}

.btn-success:hover {
  background: #0b7dda;
}

.game-over {
  text-align: center;
  padding: 20px;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.game-over h2 {
  color: #4CAF50;
  margin-bottom: 10px;
}

.game-over p {
  font-size: 20px;
  margin-bottom: 20px;
  color: #555;
}
'@ | Out-File -FilePath "frontend/src/features/game/styles/GameBoard.css" -Encoding utf8

# Frontend - App.tsx
@'
import React from "react";
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

# Frontend - App.css
@'
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", "Oxygen",
    "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue",
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
}

.App {
  min-height: 100vh;
  padding: 20px;
}
'@ | Out-File -FilePath "frontend/src/App.css" -Encoding utf8

# Frontend - main.tsx
@'
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
'@ | Out-File -FilePath "frontend/src/main.tsx" -Encoding utf8

# Frontend - index.html
@'
<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Carrera de Caballos</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
'@ | Out-File -FilePath "frontend/public/index.html" -Encoding utf8

# Crear archivo README
@'
# Carrera de Caballos - Juego en TypeScript

Juego de carrera de caballos con cartas españolas.

## Requisitos
- Node.js 18.15.0
- Yarn

## Instalación

yarn install:all

## Ejecución

### Desarrollo (ambos servicios simultáneamente)
yarn dev

### Desarrollo (servicios separados)
Terminal 1 - Backend
yarn dev:backend

Terminal 2 - Frontend
yarn dev:frontend


## Acceso
- Frontend: http://localhost:3000
- Backend: http://localhost:3001

## Estructura del Proyecto
- `/backend` - Servidor Express con TypeScript
- `/frontend` - Aplicación React con Vite y TypeScript
'@ | Out-File -FilePath "README.md" -Encoding utf8

Write-Host "✅ Estructura del proyecto creada exitosamente!" -ForegroundColor Green
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "1. cd horse-race-game" -ForegroundColor Cyan
Write-Host "2. yarn install:all" -ForegroundColor Cyan
Write-Host "3. yarn dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "El juego estará disponible en:" -ForegroundColor Yellow
Write-Host "- Frontend: http://localhost:3000" -ForegroundColor Green
Write-Host "- Backend: http://localhost:3001" -ForegroundColor Green
