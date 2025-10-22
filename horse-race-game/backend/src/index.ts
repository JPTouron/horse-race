import express from 'express';
import cors from 'cors';
import { GameRoutes } from './features/game/infrastructure/GameRoutes';

const app = express();
const port = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

const gameRoutes = new GameRoutes();
app.use('/api/game', gameRoutes.router);

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});