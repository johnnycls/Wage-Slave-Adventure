import { Schema, model } from "mongoose";

const userSchema = new Schema({
  name: {
    type: String,
    required: true,
    unique: true,
  },
  password: {
    type: String,
    required: true,
  },
  money: {
    type: Number,
    default: 0,
  },
  progress: {
    type: Number,
    default: 0,
  },
  unlocked_skins: {
    type: [Number],
    default: [],
  },
  last_working_date: {
    type: Date,
    default: (d) => new Date(0),
  },
  last_transfer_date: {
    type: Date,
    default: (d) => new Date(0),
  },
  transfer_time: {
    type: Number,
    default: 0,
  },
  highest_money: {
    type: Number,
    default: 0,
  },
  highest_scores: {
    type: Object,
    default: {
      pong: 0,
      dodgeball: 0,
    },
  },
});

const User = model("User", userSchema);

export default User;
