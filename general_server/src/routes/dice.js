import express from "express";
import User from "../models/user.model.js";
import auth from "../middlewares/auth.js";

const router = express.Router();

const RATE = [
  1, 1, 5, 10, 10, 10, 10, 10, 10, 30, 180, 180, 180, 180, 180, 180,
];

router.post("/", auth, async (req, res) => {
  const name = res.locals.user;
  const { money, buyWhat } = req.body;

  try {
    // check if the user already exists
    let user = await User.findOne({ name });
    if (user.progress < 201) {
      return res.status(400).json({ msg: "Haven't unlocked level" });
    }
    if (user.money < money) {
      return res.status(400).json({ msg: "Not enough money" });
    }

    if (money <= 0) {
      return res.status(400).json({ msg: "+ve money" });
    }

    const results = [0, 0, 0].map((_) => Math.floor(Math.random() * 6) + 1);
    const wins = [];
    if ((results[0] === results[1]) === results[3]) {
      wins.push(9);
      wins.push(9 + results[0]);
    } else {
      if (results[0] === results[1] || results[0] === results[2]) {
        wins.push(2);
        wins.push(2 + results[0]);
      } else if (results[1] === results[2]) {
        wins.push(2);
        wins.push(2 + results[1]);
      }
      if (results.reduce((a, c) => a + c) <= 10) {
        wins.push(1);
      } else {
        wins.push(0);
      }
    }

    let gain = 0;
    if (wins.includes(buyWhat)) {
      gain = money * RATE[buyWhat];
    } else {
      gain = -money;
    }

    user.money = user.money + gain;
    user.highest_money = Math.max(user.money, user.highest_money);
    await user.save();

    return res.status(200).json({
      results,
      money: user.money,
      highest_money: user.highest_money,
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

export default router;
