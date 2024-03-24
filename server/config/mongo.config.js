const mongoose = require("mongoose");

const mongoConfig = async (url) => {
  try {
    await mongoose.connect(url);
    console.log("MongoDB Connected");
  } catch (err) {
    console.log(err);
  }
};

module.exports = { mongoConfig };
