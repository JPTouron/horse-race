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
