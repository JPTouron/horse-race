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
