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
