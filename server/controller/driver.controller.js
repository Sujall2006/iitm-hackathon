const { response } = require("express");
const { evStationModel } = require("../models/evstation.model");
const { userModel } = require("../models/user.model");
const { calculateSlots, getTodayDate } = require("../utils/utilities");
const { bookingModel } = require("../models/booking.model");

// POST -> api/driver/star
const setStar = async (req, res) => {
  try {
    const { rating, id } = req.body;
    const { username } = req.user;

    if (rating > 5 || rating < 0)
      return res.status(400).json({ error: "Invalid Rating" });

    let val = Math.floor(Number(rating));

    const oldRating = await evStationModel.findOne(
      { _id: id },
      { starInfo: 1 }
    );

    if (!oldRating)
      return res.status(404).json({ error: "Invalid EV Station ID" });

    let newArr = oldRating.starInfo;

    newArr.push({ staredBy: username, value: val });

    const response = await evStationModel.updateOne(
      { _id: id },
      { $set: { starInfo: newArr } }
    );

    if (response.modifiedCount >= 1)
      return res.status(200).json({ message: "Star Provided" });
    else return res.status(400).json({ error: "Something Went Wrong" });
  } catch (err) {
    if (err.kind === "ObjectId")
      return res.status(404).json({ error: "Invalid EV Station ID" });

    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// PUT -> api/driver/evstation/workstatus-up
const workStatusUp = async (req, res) => {
  try {
    const { username } = req.user;
    const { id } = req.body;
    const response = await evStationModel.findOne(
      { _id: id },
      { workingStatus: 1 }
    );

    if (!response)
      return res.status(404).json({ error: "Invalid EV Station ID" });

    let newArr1 = response.workingStatus.up;
    let newArr2 = response.workingStatus.down;

    if (!newArr1.includes(username)) {
      if (newArr2.includes(username)) {
        newArr2.pop(username);
      }

      newArr1.push(username);
      await evStationModel.updateOne(
        { _id: id },
        {
          $set: {
            workingStatus: {
              down: newArr2,
              up: newArr1,
            },
          },
        }
      );
    }

    return res.status(200).json({ message: "Up Work-Status Updated" });
  } catch (err) {
    if (err.kind === "ObjectId")
      return res.status(404).json({ error: "Invalid EV Station ID" });
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// PUT -> api/driver/evstation/workstatus-down
const workStatusDown = async (req, res) => {
  try {
    const { username } = req.user;
    const { id } = req.body;
    const response = await evStationModel.findOne(
      { _id: id },
      { workingStatus: 1 }
    );

    if (!response)
      return res.status(404).json({ error: "Invalid EV Station ID" });

    let newArr1 = response.workingStatus.up;
    let newArr2 = response.workingStatus.down;

    if (!newArr2.includes(username)) {
      if (newArr1.includes(username)) {
        newArr1.pop(username);
      }

      newArr2.push(username);
      await evStationModel.updateOne(
        { _id: id },
        {
          $set: {
            workingStatus: {
              up: newArr1,
              down: newArr2,
            },
          },
        }
      );
    }

    return res.status(200).json({ message: "Down Work-Status Updated" });
  } catch (err) {
    if (err.kind === "ObjectId")
      return res.status(404).json({ error: "Invalid EV Station ID" });
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// PUT -> api/driver/evstation/favourite
const addFavourite = async (req, res) => {
  try {
    const { id } = req.body;
    const { username } = req.user;

    const checkResponse = await evStationModel.findOne({ _id: id }, { _id: 1 });
    if (!checkResponse)
      return res.status(404).json({ error: "Invalid EV Station ID" });

    const response = await userModel
      .findOne({ username }, { favorites: 1 })
      .lean();

    let newArr = response.favorites;

    if (!newArr.includes(id)) {
      newArr.push(id);
      await userModel.updateOne({ username }, { $set: { favorites: newArr } });
    }

    return res.status(200).json({ message: "Added To Favourites" });
  } catch (err) {
    if (err.kind === "ObjectId")
      return res.status(404).json({ error: "Invalid EV Station ID" });
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// DELETE -> api/driver/evstation/favourite?id=value
const removeFavourite = async (req, res) => {
  try {
    const { id } = req.query;
    const { username } = req.user;

    const response = await userModel
      .findOne({ username }, { favorites: 1 })
      .lean();

    let newArr = response.favorites;

    if (newArr.includes(id)) {
      newArr.pop(id);
      await userModel.updateOne({ username }, { $set: { favorites: newArr } });
    } else return res.status(404).json({ error: "Invalid EV Station ID" });

    return res.status(200).json({ message: "Removed From Favourites" });
  } catch (err) {
    if (err.kind === "ObjectId")
      return res.status(404).json({ error: "Invalid EV Station ID" });
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// GET -> api/driver/evstation/favourite
const getFavourite = async (req, res) => {
  try {
    const { username } = req.user;

    const userResponse = await userModel
      .findOne({ username }, { favorites: 1 })
      .lean();

    const values = userResponse.favorites;

    let response = await evStationModel.find(
      { _id: { $in: values } },
      {
        location: 1,
        operatingStatus: 1,
        evStationName: 1,
        starInfo: 1,
      }
    );

    response = response.map((item) => {
      let sum = 0;

      item.starInfo.forEach((i) => {
        sum += i.value;
      });

      const json = {
        ...item.toObject(),
        stars: sum !== 0 ? Math.round(sum / item.starInfo.length) : 0,
      };
      delete json.starInfo;
      return json;
    });

    return res.status(200).json(response);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// Booking Function
// POST -> api/driver/booking
const bookSlot = async (req, res) => {
  try {
    const { username } = req.user;
    const { id = null, slot = null, portName = null } = req.body;

    if (!id || !slot || !portName || !Array.isArray(slot))
      return res.status(400).json({ error: "Please Fill All Details" });

    const response = await bookingModel.find({
      evStationId: id,
      portName,
      slotsTaken: { $elemMatch: { $in: [...slot] } },
      dateOfBooking: getTodayDate(),
    });

    if (response.length > 0)
      return res.status(400).json({ error: "Slot Is Already Taken" });

    await bookingModel.create({
      username,
      slotsTaken: slot,
      evStationId: id,
      portName,
      dateOfBooking: getTodayDate(),
    });

    return res.status(200).json({ message: "Your Slot Confirmed" });
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// GET -> api/driver/booking?id=value,portName=value
const getSlots = async (req, res) => {
  try {
    const { id, portName } = req.query;

    if (!id || !portName)
      return res.status(400).json({ error: "Please Fill All Details" });

    const response = await evStationModel
      .findOne(
        {
          _id: id,
          operatingStatus: true,
          ports: { $elemMatch: { name: portName } },
        },
        { portInfo: 1, ports: 1, workingHours: 1 }
      )
      .lean();

    if (!response)
      return res.status(404).json({ error: "EV Station Does Not Exist" });

    let slots = calculateSlots(response);

    let bookings = await bookingModel.find(
      {
        evStationId: id,
        dateOfBooking: getTodayDate(),
        portName,
      },
      { slotsTaken: 1 }
    );

    if (bookings.length === 0) return res.status(200).json(slots);

    let newArr = [];
    bookings.forEach((item) => {
      item.slotsTaken.forEach((i) => newArr.push(i));
    });

    slots = slots.map((item) => {
      if (newArr.includes(item.slot)) return { ...item, isAvailable: false };
      return { ...item };
    });

    return res.status(200).json(slots);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// GET -> api/driver/booking/history
const getBookingHistory = async (req, res) => {
  try {
    const { username } = req.user;

    const response = await bookingModel.find(
      { username },
      { updatedAt: 0, __v: 0 }
    );

    return res.status(200).json(response);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// DELETE -> api/driver/booking?id=value
const cancelBooking = async (req, res) => {
  try {
    const { username } = req.user;
    const { id } = req.query;

    const response = await bookingModel.findOne({ username, _id: id });

    if (!response)
      return res.status(400).json({ message: "Invalid EV Station ID" });

    if (getTodayDate() !== response.dateOfBooking)
      return res.status(400).json({ message: "Cannot Cancel Completed Solt" });

    await bookingModel.deleteOne({ username, _id: id });

    return res.status(200).json({ message: "Slot Canceled" });
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

module.exports = {
  setStar,
  workStatusUp,
  workStatusDown,
  addFavourite,
  removeFavourite,
  getFavourite,
  bookSlot,
  getSlots,
  getBookingHistory,
  cancelBooking,
};
