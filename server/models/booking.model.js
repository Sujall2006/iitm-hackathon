const mongoose = require("mongoose");

const Schema = mongoose.Schema;

const bookingSchema = new mongoose.Schema(
  {
    username: { type: String, required: true },
    slotsTaken: { type: [String], required: true },
    evStationId: {
      type: Schema.Types.ObjectId,
      ref: "evstations",
      required: true,
    },
    portName: { type: String, required: true },
    dateOfBooking: { type: String, required: true },
  },
  { timestamps: true }
);

const bookingModel = mongoose.model("booking", bookingSchema);

module.exports = { bookingModel };
