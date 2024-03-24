const express = require("express");
const {
  getPorts,
  getEvStation,
  getNearEvStation,
  getStationInfo,
  getCities,
} = require("../controller/public.controller");
const router = express.Router();

// ROUTE -> api/public

router.get("/ports", getPorts);
router.get("/states-cities", getCities);

router.get("/evstation", getEvStation);
router.get("/evstation/nearest", getNearEvStation);
router.get("/evstation/info", getStationInfo);

module.exports = router;
