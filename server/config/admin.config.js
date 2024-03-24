const bcrypt = require("bcrypt");
const { userModel } = require("../models/user.model");
const { authModel } = require("../models/auth.model");
const { appConfig } = require("./app.config");

async function setUpAdmin() {
  const data = appConfig.admin;

  try {
    await userModel.updateOne(
      { username: "admin" },
      {
        $set: {
          name: "ADMIN",
          role: "admin",
          ...data,
        },
      },
      { upsert: true }
    );
    const password = appConfig.admin.password;
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    await authModel.updateOne(
      { username: "admin" },
      {
        $set: {
          password: hashedPassword,
        },
      },
      { upsert: true }
    );
  } catch (err) {
    console.log(err);
  }
}

module.exports = { setUpAdmin };
