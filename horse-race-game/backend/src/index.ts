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
