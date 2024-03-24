const express = require("express");
const {
  register,
  login,
  getUserInfo,
  signOut,
} = require("../controller/auth.controller");
const { verifyToken } = require("../middleware/verifyToken.middleware");
const router = express.Router();

// ROUTE -> api/auth

router.route("/").post(register).get(verifyToken, getUserInfo);

router.post("/login", login);

router.put("/signout", verifyToken, signOut);

router.post("/otp", login);

module.exports = router;
