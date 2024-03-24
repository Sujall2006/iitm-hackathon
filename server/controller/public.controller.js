const { appConfig } = require("../config/app.config");
const { evStationModel } = require("../models/evstation.model");
const { userModel } = require("../models/user.model");
const { haversineDistance, sortByDistance } = require("../utils/utilities");

// GET -> api/public/ports
const getPorts = async (req, res) => {
  try {
    res.status(200).json(appConfig.ports);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// GET -> api/public/states-cities
const getCities = async (req, res) => {
  try {
    res.status(200).json(appConfig.states);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// GET -> api/public/evstation?city=value,state=value,portType=value
const getEvStation = async (req, res) => {
  try {
    const { city = null, state = null, portType = null } = req.query;

    if ((!city && !state) || !state)
      return res.status(400).json({ error: "Please Provide State Or City" });

    const data = {};
    if (city) data["location.city"] = city;
    if (state) data["location.state"] = state;
    if (portType) findVal.portInfo = { $elemMatch: { type: portType } };

    let response = await evStationModel.find(data, {
      evStationName: 1,
      address1: 1,
      address2: 1,
      location: 1,
      workingHours: 1,
      workingStatus: 1,
      operatingStatus: 1,
      starInfo: 1,
    });

    // Alternatives Calculation
    // let allResponse =

    response = response.map((item) => {
      let sum = 0;

      item.starInfo.forEach((i) => (sum += i.value));
      const json = {
        ...item.toObject(),
        stars: sum !== 0 ? Math.round(sum / item.starInfo.length) : 0,
        starInfo: null,
        workDown: item.workingStatus.down.length,
        workUp: item.workingStatus.up.length,
      };

      delete json.starInfo;
      delete json.workingStatus;

      return json;
    });

    return res.status(200).json(response);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// GET -> api/public/evstation/nearest?lat=value,long=value,portType=value
const getNearEvStation = async (req, res) => {
  try {
    const { lat = null, long = null, portType = null } = req.query;

    if (!lat || !long)
      return res.status(404).json({ error: "Missing Co-Ordinates" });

    const coords = [Number(lat), Number(long)];

    const findVal = {};
    findVal.operatingStatus = true;
    if (portType) findVal.portInfo = { $elemMatch: { type: portType } };

    const response = await evStationModel
      .find(findVal, {
        evStationName: 1,
        location: 1,
        address1: 1,
        address2: 1,
        workingHours: 1,
        workingStatus: 1,
        operatingStatus: 1,
        starInfo: 1,
      })
      .lean();

    let newArr = [];
    response.forEach((item) => {
      let point = item.location.points.split("/");
      point = point.map((item) => Number(item));

      const distance = haversineDistance(point, coords).toFixed(3);

      newArr.push({ ...item, distance: Number(distance) });
    });

    if (newArr.length > 1) newArr = sortByDistance(newArr);

    newArr = newArr.slice(0, appConfig.showNearestCount);

    newArr = newArr.map((item) => {
      let mainPoint = item.location.points.split("/");

      let sum = 0;

      item.starInfo.forEach((i) => {
        sum += i.value;
      });

      let newArr = [];
      response.forEach((item) => {
        let point = item.location.points.split("/");
        point = point.map((item) => Number(item));

        const distance = haversineDistance(point, mainPoint).toFixed(3);

        // if (distance < appConfig.alternativeMaxKm)
        newArr.push({ ...item, distance: Number(distance) });
      });
      if (newArr.length > 1) newArr = sortByDistance(newArr);

      newArr = newArr.slice(1, appConfig.showAlternativeCount + 1);

      newArr = newArr.map((item) => {
        let sum = 0;

        item.starInfo.forEach((i) => {
          sum += i.value;
        });

        const json = {
          ...item,
          stars: sum !== 0 ? Math.round(sum / item.starInfo.length) : 0,
        };

        delete json.starInfo;
        delete json.workingStatus;
        return json;
      });

      const json = {
        ...item,
        stars: sum !== 0 ? Math.round(sum / item.starInfo.length) : 0,
        workDown: item.workingStatus.down.length,
        workUp: item.workingStatus.up.length,
        alternatives: newArr,
      };

      delete json.starInfo;
      delete json.workingStatus;
      return json;
    });

    return res.status(200).json(newArr);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// GET -> api/public/evstation/info
const getStationInfo = async (req, res) => {
  try {
    const { id } = req.query;

    let response = await evStationModel
      .findOne({ _id: id }, { updatedAt: 0, createdAt: 0, __v: 0 })
      .lean();
    const allResponse = await evStationModel
      .find({ operatingStatus: true }, { updatedAt: 0, createdAt: 0, __v: 0 })
      .lean();

    if (!response)
      return res.status(404).json({ error: "Invalid EV Station ID" });

    let sum = 0;
    response.starInfo.forEach((i) => {
      sum += i.value;
    });

    let newArr = [];
    let coords = response.location.points.split("/");
    coords = coords.map((item) => Number(item));

    allResponse.forEach((item) => {
      let point = item.location.points.split("/");
      point = point.map((item) => Number(item));

      const distance = haversineDistance(point, coords).toFixed(3);

      if (distance < appConfig.alternativeMaxKm)
        newArr.push({ ...item, distance: Number(distance) });
    });

    if (newArr.length > 1) newArr = sortByDistance(newArr);

    newArr = newArr.slice(1, appConfig.showAlternativeCount + 1);

    newArr = newArr.map((item) => {
      let sum = 0;

      item.starInfo.forEach((i) => {
        sum += i.value;
      });

      const json = {
        ...item,
        stars: sum !== 0 ? Math.round(sum / item.starInfo.length) : 0,
        workDown: item.workingStatus.down.length,
        workUp: item.workingStatus.up.length,
      };

      delete json.starInfo;
      delete json.workingStatus;
      delete json.portInfo;
      delete json.ports;
      return json;
    });

    // operator info
    const operatorInfo = await userModel
      .findOne(
        {
          role: "operator",
          username: response.username,
        },
        { _id: 0, phoneNumber: 1, name: 1, mailId: 1 }
      )
      .lean();

    response = {
      ...response,
      stars: sum !== 0 ? Math.round(sum / response.starInfo.length) : 0,
      workDown: response.workingStatus.down.length,
      workUp: response.workingStatus.up.length,
      alternatives: newArr,
      operatorInfo,
    };

    delete response.starInfo;
    delete response.workingStatus;

    return res.status(200).json(response);
  } catch (err) {
    if (err.kind === "ObjectId")
      return res.status(404).json({ error: "Invalid EV Station ID" });
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

module.exports = {
  getPorts,
  getCities,
  getEvStation,
  getNearEvStation,
  getStationInfo,
};
