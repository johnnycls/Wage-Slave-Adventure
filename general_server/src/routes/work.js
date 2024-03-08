import express from "express";
import User from "../models/user.model.js";
import auth from "../middlewares/auth.js";

const router = express.Router();
const PERFORMANCE = [800, 900, 1000];

function isSameDay(date1, date2) {
  return (
    date1.getDate() === date2.getDate() &&
    date1.getMonth() === date2.getMonth() &&
    date1.getYear() === date2.getYear()
  );
}

router.get("/", auth, async (req, res) => {
  const name = res.locals.user;

  try {
    let user = await User.findOne({ name });
    let performance = -1;

    if (isSameDay(user.last_working_date, new Date())) {
      performance = PERFORMANCE.length;
    } else {
      performance = Math.floor(Math.random() * (PERFORMANCE.length - 1));
      user.money = user.money + PERFORMANCE[performance];
      user.highest_money = Math.max(user.money, user.highest_money);

      user.last_working_date = new Date();
      await user.save();
    }

    return res.status(200).json({
      money: user.money,
      highest_money: user.highest_money,
      performance,
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

export default router;
