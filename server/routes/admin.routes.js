const express = require("express");
const { verifyToken } = require("../middleware/verifyToken.middleware");
const {
  addOperator,
  deleteOperator,
  listOperator,
  getStat,
} = require("../controller/admin.controller");
const router = express.Router();

router.use(verifyToken);

// ROUTE -> api/admin

router.route("/").post(addOperator).get(listOperator).delete(deleteOperator);

router.route("/stat").get(getStat);

module.exports = router;
