const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    username: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    phoneNumber: {
      type: String,
      required: true,
      minlength: 10,
      maxlength: 10,
      unique: true,
    },
    mailId: { type: String, required: true, required: true, unique: true },
    role: {
      type: String,
      enum: ["driver", "operator", "admin"],
      message: "Role Must Be Either Driver or Operator",
      required: true,
    },
    // for operators
    evStations: { type: [String], default: [] },
    // for drivers
    favorites: { type: [String], default: [] },
  },
  { timestamps: true }
);

const userModel = mongoose.model("user", userSchema);

module.exports = { userModel };
