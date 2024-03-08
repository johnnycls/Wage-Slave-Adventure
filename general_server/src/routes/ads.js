import express from "express";
import User from "../models/user.model.js";

const router = express.Router();

router.get("/", async (req, res) => {
  const { user_id } = req.query;

  try {
    let user = await User.findOne({ name: user_id });

    user.money = user.money + 1000;
    user.highest_money = Math.max(user.money, user.highest_money);
    await user.save();

    return res.status(200).json({});
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

export default router;
