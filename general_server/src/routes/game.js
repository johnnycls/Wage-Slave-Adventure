import express from "express";
import User from "../models/user.model.js";
import auth from "../middlewares/auth.js";
import { GAME_SERVER_PW } from "../config.js";

const router = express.Router();

router.get("/money", auth, async (req, res) => {
  try {
    const name = res.locals.user;
    const user = await User.findOne({ name });
    if (user) {
      return res.status(200).json({
        user_id: name,
        money: user.money,
      });
    }
  } catch (error) {
    return res.status(500).json(error);
  }
});

router.post("/endgame", async (req, res) => {
  try {
    const { name, password, gain_money, unlocked_skin } = req.body;
    if (password === GAME_SERVER_PW) {
      const user = await User.findOne({ name });
      if (gain_money !== undefined) {
        user.money += gain_money;
        user.highest_money = Math.max(user.money, user.highest_money);
      }
      if (
        unlocked_skin !== undefined &&
        !user.unlocked_skins.includes(unlocked_skin)
      )
        user.unlocked_skins = [...user.unlocked_skins, unlocked_skin];
      await user.save();
      return res.status(200).json({
        money: user.money,
        unlocked_skins: user.unlocked_skins,
      });
    }
  } catch (error) {
    return res.status(500).json(error);
  }
});

export default router;
