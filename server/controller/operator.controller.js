const { appConfig } = require("../config/app.config");
const { evStationModel } = require("../models/evstation.model");

// POST -> api/operator
const createEvStation = async (req, res) => {
  try {
    const { username } = req.user;
    const { evStationName, location, workingHours, ports, address1, address2 } =
      req.body;
    if (
      Number(workingHours.from.split(":")[0]) >=
        Number(workingHours.to.split(":")[0]) ||
      Number(workingHours.from.split(":")[1]) % 15 !== 0 ||
      Number(workingHours.to.split(":")[1]) % 15 !== 0
    )
      return res.status(400).json({ error: "Invalid Working Hours" });

    if (
      !evStationName ||
      !location ||
      !workingHours ||
      !ports ||
      !address1 ||
      !Array.isArray(ports) ||
      ports.length === 0
    )
      return res.status(400).json({ error: "Please Fill All Details" });

    const uniqueTypes = new Set(ports.map((port) => port.type));

    if (uniqueTypes.size !== ports.length)
      return res.status(400).json({ error: "Please Remove Duplicate Ports" });

    const checkPorts = appConfig.ports.map((item) => item.name);

    let flag = false;
    let newArr = [];
    for (let i = 0; i < ports.length; i++) {
      if (!checkPorts.includes(ports[i].type)) {
        flag = true;
        break;
      } else {
        for (let j = 1; j <= ports[i].count; j++) {
          const json = {
            ...ports[i],
            name: `${ports[i].type.split("|")[1]}(${j})`,
          };
          delete json.count;
          newArr.push(json);
        }
      }
    }

    if (flag) return res.status(400).json({ error: "Invalid Port Type" });

    const data = {
      username,
      evStationName: evStationName.toUpperCase(),
      location,
      workingHours,
      portInfo: ports,
      ports: newArr,
      address1,
    };

    if (address2) data.address2 = address2;

    const response = await evStationModel.create(data);

    if (response)
      return res.status(200).json({ message: "EV Station Created" });
    else return res.status(400).json({ error: "Something Went Wrong" });
  } catch (err) {
    if (err.code === 11000 && err.keyPattern["location.points"])
      return res
        .status(400)
        .json({ error: "Duplicate Latitude and Longitude Points" });

    console.log(err);
    return res.status(500).json({ error: "Invalid Ports" });
    // console.log(err);
    // res.status(500).json({ error: "Internal Server Error" });
  }
};

// GET -> api/operator
const getEvStation = async (req, res) => {
  try {
    const { username } = req.user;

    let response = await evStationModel.find(
      { username },
      { updatedAt: 0, __v: 0, "starInfo.updatedAt": 0 }
    );

    response = response.map((item) => {
      let sum = 0;

      item.starInfo.forEach((i) => {
        sum += i.value;
      });
      const json = {
        ...item.toObject(),
        stars: sum !== 0 ? Math.round(sum / item.starInfo.length) : 0,
        workDown: item.workingStatus.down.length,
        workUp: item.workingStatus.up.length,
      };

      delete json.starInfo;
      delete json.workingStatus;
      delete json.ports;
      return json;
    });

    res.status(200).json(response);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// PUT -> api/operator
const updateEvStation = async (req, res) => {
  try {
    const { username } = req.user;
    const {
      id,
      evStationName = null,
      workingHours = null,
      ports = null,
      operatingStatus = null,
    } = req.body;

    const data = {};

    if (
      Number(workingHours.from.split(":")[0]) >=
        Number(workingHours.to.split(":")[0]) ||
      Number(workingHours.from.split(":")[1]) % 15 !== 0 ||
      Number(workingHours.to.split(":")[1]) % 15 !== 0
    )
      return res.status(400).json({ error: "Invalid Working Hours" });

    const uniqueTypes = new Set(ports.map((port) => port.type));

    if (uniqueTypes.size !== ports.length)
      return res.status(400).json({ error: "Please Remove Duplicate Ports" });

    if (!id)
      return res.status(404).json({ error: "Please Provide EV Station ID" });

    const checkPorts = appConfig.ports.map((item) => item.name);

    let flag = false;
    let newArr = [];
    for (let i = 0; i < ports.length; i++) {
      if (!checkPorts.includes(ports[i].type)) {
        flag = true;
        break;
      } else {
        for (let j = 1; j <= ports[i].count; j++) {
          const json = {
            ...ports[i],
            name: `${ports[i].type.split("|")[1]}(${j})`,
          };
          delete json.count;
          newArr.push(json);
        }
      }
    }

    if (!Array.isArray(ports) || flag)
      return res.status(400).json({ error: "Invalid Port Information" });

    if (evStationName) data.evStationName = evStationName.toUpperCase();
    if (workingHours) data.workingHours = workingHours;
    if (ports) {
      data.portInfo = ports;
      data.ports = newArr;
    }
    if (operatingStatus !== null) data.operatingStatus = operatingStatus;

    const response = await evStationModel.updateOne(
      { username, _id: id },
      { $set: data }
    );

    if (response.matchedCount === 0)
      return res.status(404).json({ error: "Invalid EV Station ID" });

    if (response)
      return res.status(200).json({ message: "EV Station Updated" });
    else return res.status(400).json({ error: "Something Went Wrong" });
  } catch (err) {
    if (err.kind === "ObjectId")
      return res.status(404).json({ error: "Invalid EV Station ID" });
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

// DELETE -> api/operator?id=value
const deleteEvStation = async (req, res) => {
  try {
    const { username } = req.user;
    const { id } = req.query;

    const response = await evStationModel.deleteOne({ username, _id: id });
    if (response.deletedCount === 1)
      return res.status(200).json({ message: "EV Station Deleted" });
    else return res.status(404).json({ error: "Invalid EV Station ID" });
  } catch (err) {
    if (err.kind === "ObjectId")
      return res.status(404).json({ error: "Invalid EV Station ID" });
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

module.exports = {
  createEvStation,
  getEvStation,
  updateEvStation,
  deleteEvStation,
};
