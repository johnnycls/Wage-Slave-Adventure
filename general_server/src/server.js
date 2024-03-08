import express from "express";
import cors from "cors";
import InitiateMongoServer from "./db.js";
import { PORT } from "./config.js";
import userRouter from "./routes/user.js";
import workRouter from "./routes/work.js";
import diceRouter from "./routes/dice.js";
import gameRouter from "./routes/game.js";
import adsRouter from "./routes/ads.js";

InitiateMongoServer();

const app = express();
const port = PORT || 5000;

app.use(cors());

app.use("/ads", adsRouter);

app.use(express.json());

app.use("/user", userRouter);
app.use("/work", workRouter);
app.use("/dice", diceRouter);
app.use("/game", gameRouter);
app.use("*", (req, res, next) => {
  const error = {
    status: 404,
    message: "Api endpoint does not found",
  };
  next(error);
});

app.listen(port, () => {
  console.log(`${port}`);
});
