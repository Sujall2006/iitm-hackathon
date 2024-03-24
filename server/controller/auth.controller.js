const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const { authModel } = require("../models/auth.model");
const { userModel } = require("../models/user.model");

// POST -> api/auth
const register = async (req, res) => {
  try {
    const { username, name, phoneNumber, mailId, password } = req.body;
    const data = {
      username,
      name: name.toUpperCase(),
      phoneNumber,
      mailId,
      role: "driver",
    };

    if (!username || !name || !phoneNumber || !mailId || !password)
      return res.status(400).json({ error: "Please Fill All Details" });

    const response = await userModel.create(data);
    if (response) {
      const salt = await bcrypt.genSalt(10);
      const newPassword = await bcrypt.hash(password, salt);
      const response = await authModel.create({
        username: username,
        password: newPassword,
      });
      if (response) return res.status(201).json({ message: "Account Created" });
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

// POST -> api/auth/login
const login = async (req, res) => {
  try {
    const { username, password, fcmToken } = req.body;

    if (!username || !password)
      return res.status(400).json({ error: "Invalid Credentials" });

    const response = await authModel.findOne({ username });
    if (response) {
      const passwordMatch = await bcrypt.compare(password, response.password);
      if (!passwordMatch)
        return res.status(404).json({ error: "Invalid Credentials" });

      await authModel.updateOne(
        { _id: response._id },
        { $set: { fcmToken: fcmToken } }
      );

      const userInfo = await userModel.findOne(
        { username },
        { username: 1, mailId: 1, phoneNumber: 1, role: 1, name: 1, _id: 0 }
      );
      if (!userInfo) res.status(40).json({ error: "Something Went Wrong" });

      const token = jwt.sign(
        { username: userInfo.username, role: userInfo.role },
        process.env.JWT_KEY
      );

      return res
        .status(200)
        .json({ message: "Login Successful", token: token, userInfo });
    } else return res.status(404).json({ error: "Invalid Credentials" });
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// GET -> api/auth
const getUserInfo = async (req, res) => {
  try {
    const { username } = req.user;
    let response = await userModel
      .findOne({ username }, { _id: 0, updatedAt: 0, __v: 0 })
      .lean();

    if (response) return res.status(200).json(response);
    else return res.status(404).json({ error: "User Not Found" });
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// PUT -> api/auth
const signOut = async (req, res) => {
  try {
    const { username } = req.user;

    const response = await authModel.updateOne(
      { username },
      {
        $set: {
          fcmToken: "",
        },
      }
    );

    if (response.modifiedCount > 0)
      return res.status(200).json({ message: "Sign Out Successful" });
    else return res.status(400).json({ error: "Something Went Wrong" });
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

module.exports = { register, login, getUserInfo, signOut };
