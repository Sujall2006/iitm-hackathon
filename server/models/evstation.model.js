const mongoose = require("mongoose");
const { appConfig } = require("../config/app.config");

const timeSchema = new mongoose.Schema(
  {
    from: { type: String },
    to: { type: String },
  },
  { _id: false }
);

const portSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      required: true,
    },
    output: { type: String, required: true },
    cost: { type: Number, required: true },
  },
  { _id: false }
);

const portInfoSchema = new mongoose.Schema(
  {
    type: {
      type: String,
      required: true,
    },
    output: {
      type: Number,
      required: true,
    },
    cost: { type: Number, required: true },
    count: { type: Number, required: true },
  },
  { _id: false }
);

const starSchema = new mongoose.Schema(
  {
    staredBy: {
      type: String,
      required: true,
    },
    value: { type: Number, required: true }, // star value
  },
  { _id: false, timestamps: true }
);

const evStationSchema = new mongoose.Schema(
  {
    username: { type: String, required: true },
    evStationName: { type: String, required: true },
    location: {
      points: { type: String, required: true, unique: true },
      city: { type: String, required: true },
      state: { type: String, required: true },
    },
    address1: { type: String, required: true },
    address2: { type: String },

    workingHours: { type: timeSchema, required: true },
    starInfo: { type: [starSchema], default: [] },
    workingStatus: {
      up: { type: [String], default: [] },
      down: { type: [String], default: [] },
    },
    operatingStatus: { type: Boolean, default: true }, // Active or Not Available Currently
    ports: { type: [portSchema], required: true },
    portInfo: { type: [portInfoSchema], required: true },
    isVerified: { type: Boolean, default: false },
  },
  { timestamps: true }
);

const evStationModel = mongoose.model("evstation", evStationSchema);

module.exports = { evStationModel };
