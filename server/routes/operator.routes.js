const express = require("express");
const { verifyToken } = require("../middleware/verifyToken.middleware");
const {
  createEvStation,
  getEvStation,
  updateEvStation,
  deleteEvStation,
} = require("../controller/operator.controller");
const router = express.Router();

router.use(verifyToken);

// ROUTE -> api/user

router
  .route("/")
  .post(createEvStation)
  .get(getEvStation)
  .put(updateEvStation)
  .delete(deleteEvStation);

module.exports = router;
