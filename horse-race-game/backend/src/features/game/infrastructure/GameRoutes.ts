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
