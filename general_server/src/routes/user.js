import express from "express";
import jwt from "jsonwebtoken";
import bcrypt from "bcrypt";
import User from "../models/user.model.js";
import auth from "../middlewares/auth.js";
import { JWT_SECRET } from "../config.js";

const router = express.Router();

const LEVELS = {
  0: 0,
  1: 0,
  100: 0,
  101: 0,
  200: 10000,
  201: 10000,
};

function isSameDay(date1, date2) {
  return (
    date1.getDate() === date2.getDate() &&
    date1.getMonth() === date2.getMonth() &&
    date1.getYear() === date2.getYear()
  );
}

router.post("/register", async (req, res) => {
  const { name, password } = req.body;

  try {
    // check if the user already exists
    let user = await User.findOne({ name });
    if (user) {
      return res.status(400).json({ msg: "Already Exists" });
    }

    // hash user password
    const salt = await bcrypt.genSalt(10);
    const pw = await bcrypt.hash(password, salt);
    user = new User({ name, password: pw });
    await user.save();

    // return jwt
    const payload = {
      name: user.name,
      money: user.money,
      highest_money: user.highest_money,
      progress: user.progress,
      unlocked_skins: user.unlocked_skins,
      highest_scores: user.highest_scores,
    };

    jwt.sign(payload, JWT_SECRET, {}, (err, token) => {
      if (err) console.log(err.message);
      res.json({ token, ...payload });
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

router.post("/login", async (req, res) => {
  const { name, password } = req.body;

  try {
    // check if the user exists
    let user = await User.findOne({ name });
    if (!user) {
      return res.status(400).json({ msg: `user ${name} doesn't exist` });
    }

    // check is the encrypted password matches
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: "username or password incorrect" });
    }

    // return jwt
    const payload = {
      name: user.name,
      money: user.money,
      highest_money: user.highest_money,
      progress: user.progress,
      unlocked_skins: user.unlocked_skins,
      highest_scores: user.highest_scores,
    };

    jwt.sign(payload, JWT_SECRET, {}, (err, token) => {
      if (err) console.log(err.message);
      res.json({ token, ...payload });
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server error");
  }
});

router.get("/", auth, async (req, res) => {
  try {
    const name = res.locals.user;
    const user = await User.findOne({ name });
    return res.status(200).json({
      name: user.name,
      money: user.money,
      highest_money: user.highest_money,
      progress: user.progress,
      unlocked_skins: user.unlocked_skins,
      highest_scores: user.highest_scores,
    });
  } catch (error) {
    return res.status(500).json(error);
  }
});

router.post("/transfer", auth, async (req, res) => {
  try {
    const name = res.locals.user;
    const { receiver_name, money } = req.body;
    const giver = await User.findOne({ name });
    const receiver = await User.findOne({ name: receiver_name });

    if (money === undefined || receiver === null) {
      return res.status(400).json({ msg: "Bad Request" });
    }

    if (giver.name === receiver.name) {
      return res.status(400).json({ msg: "Bad Request" });
    }

    if (giver.money >= money && money > 0) {
      if (isSameDay(receiver.last_transfer_date, new Date())) {
        if (receiver.transfer_time > 3) {
          return res.status(400).json("cannot receive more than 3 times a day");
        } else {
          receiver.transfer_time += 1;
          receiver.last_transfer_date = new Date();
        }
      } else {
        receiver.transfer_time = 1;
        receiver.last_transfer_date = new Date();
      }
      giver.money -= money;
      receiver.money += money;
      receiver.highest_money = Math.max(receiver.money, receiver.highest_money);
      await giver.save();
      await receiver.save();
      return res.status(200).json({ money: giver.money });
    } else {
      return res.status(400).json({ msg: "Bad Request" });
    }
  } catch (error) {
    return res.status(500).json(error);
  }
});

router.post("/unlocklevel", auth, async (req, res) => {
  try {
    const name = res.locals.user;
    const { unlocked_level } = req.body;
    const user = await User.findOne({ name });
    if (
      unlocked_level !== undefined &&
      LEVELS.hasOwnProperty(unlocked_level) &&
      user.money >= LEVELS[unlocked_level]
    ) {
      user.progress = unlocked_level;
      await user.save();
    }
    return res.status(200).json({ progress: user.progress });
  } catch (error) {
    return res.status(500).json(error);
  }
});

router.post("/minigames", auth, async (req, res) => {
  try {
    const name = res.locals.user;
    const { highest_scores } = req.body;
    const user = await User.findOne({ name });
    if (highest_scores !== undefined) {
      user.highest_scores = highest_scores;
      await user.save();
    }
    return res.status(200).json({ highest_scores: user.highest_scores });
  } catch (error) {
    return res.status(500).json(error);
  }
});

// router.post("/unlockskin", auth, async (req, res) => {
//   try {
//     const name = res.locals.user;
//     const { unlocked_skin } = req.body;
//     const user = await User.findOne({ name });
//     if (unlocked_skin !== undefined) {
//       user.unlocked_skins = [...user.unlocked_skins, unlocked_skin];
//       await user.save();
//       return res.status(200).json({ unlocked_skins: user.unlocked_skins });
//     }
//   } catch (error) {
//     return res.status(500).json(error);
//   }
// });

export default router;
