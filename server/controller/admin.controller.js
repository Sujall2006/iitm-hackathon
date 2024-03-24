const bcrypt = require("bcrypt");

const { appConfig } = require("../config/app.config");
const { authModel } = require("../models/auth.model");
const { userModel } = require("../models/user.model");
const { bookingModel } = require("../models/booking.model");

// POST -> api/admin
const addOperator = async (req, res) => {
  try {
    const { username, name, mailId, phoneNumber } = req.body;

    if (!username || !name || !mailId || !phoneNumber)
      return res.status(400).json({ error: "Please Fill All Details" });

    const data = {
      username,
      name: name.toUpperCase(),
      mailId,
      phoneNumber,
      role: "operator",
    };

    const response = await userModel.create(data);

    if (response) {
      const salt = await bcrypt.genSalt(10);
      const newPassword = await bcrypt.hash(appConfig.operator.password, salt);
      const response = await authModel.create({
        username: username,
        password: newPassword,
      });
      if (response)
        return res.status(201).json({ message: "Operator Created" });
      else return res.status(400).json({ error: "Something Went Wrong" });
    } else return res.status(400).json({ error: "Something Went Wrong" });
  } catch (err) {
    if (err.code === 11000 && err.keyPattern.username)
      return res.status(400).json({ error: "Duplicate Username" });
    else if (err.code === 11000 && err.keyPattern.mailId)
      return res.status(400).json({ error: "Duplicate Mail ID" });
    else if (err.code === 11000 && err.keyPattern.phoneNumber)
      return res.status(400).json({ error: "Duplicate Phone Number" });

    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// DELETE -> api/admin?username=value
const deleteOperator = async (req, res) => {
  try {
    const { username } = req.query;

    const response = await userModel.deleteOne({ username });
    if (response.deletedCount === 1) {
      const response = await authModel.deleteOne({ username });
      if (response.deletedCount === 1)
        return res
          .status(200)
          .json({ message: `Operator ${username} Deleted` });
      else return res.status(400).json({ error: "Something Went Wrong" });
    } else
      return res
        .status(400)
        .json({ error: `Operator ${username} Does Not Exist` });
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// GET -> api/admin
const listOperator = async (req, res) => {
  try {
    const response = await userModel.find(
      { role: "operator" },
      { updatedAt: 0, __v: 0, favorites: 0, evStations: 0 }
    );

    return res.status(200).json(response);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// GET -> api/admin/stat
const getStat = async (req, res) => {
  try {
    const response = await bookingModel.aggregate([
      {
        $lookup: {
          from: "evstations",
          localField: "evStationId",
          foreignField: "_id",
          as: "evStationInfo",
        },
      },
      {
        $project: {
          "evStationInfo.location": 1,
          "evStationInfo.workingStatus": 1,
          "evStationInfo.workingHours": 1,
          evStationId: 1,
        },
      },
      {
        $unwind: "$evStationInfo",
      },
      {
        $group: {
          _id: {
            city: "$evStationInfo.location.city",
            state: "$evStationInfo.location.state",
          },
          count: { $sum: 1 },
        },
      },
    ]);

    return res.status(200).json(response);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

module.exports = { addOperator, deleteOperator, listOperator, getStat };
