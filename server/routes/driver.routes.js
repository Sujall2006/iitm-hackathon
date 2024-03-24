const express = require("express");
const { verifyToken } = require("../middleware/verifyToken.middleware");
const {
  setStar,
  workStatusUp,
  workStatusDown,
  addFavourite,
  removeFavourite,
  getFavourite,
  getSlots,
  bookSlot,
  getBookingHistory,
  cancelBooking,
} = require("../controller/driver.controller");

const router = express.Router();

router.use(verifyToken);

// ROUTE -> api/driver

router.post("/star", setStar);
router.put("/evstation/workstatus-up", workStatusUp);
router.put("/evstation/workstatus-down", workStatusDown);

router
  .route("/evstation/favourite")
  .put(addFavourite)
  .delete(removeFavourite)
  .get(getFavourite);

router.route("/booking").post(bookSlot).delete(cancelBooking).get(getSlots);
router.route("/booking/history").get(getBookingHistory);

module.exports = router;
