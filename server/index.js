const express = require("express");
const cors = require("cors");

const { mongoConfig } = require("./config/mongo.config");

const authRouter = require("./routes/auth.routes");
const operatorRouter = require("./routes/operator.routes");
const adminRouter = require("./routes/admin.routes");
const driverRouter = require("./routes/driver.routes");
const publicRouter = require("./routes/public.routes");

const { setUpAdmin } = require("./config/admin.config");

const admin = require("firebase-admin");
const serviceAccount = require("./firebaseServiceAccount.json");
const { handleNotification } = require("./config/firebase.config");

const app = express();

app.use(express.json());
app.use(cors());

// Routes
app.use("/api/auth", authRouter);
app.use("/api/operator", operatorRouter);
app.use("/api/admin", adminRouter);
app.use("/api/driver", driverRouter);
app.use("/api/public", publicRouter);

app.get("/api", async (req, res) => {
  try {
    res.status(200).json({ message: "Welcome To EV API" });
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

const PORT = process.env.PORT || 3000;

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

console.log("Firebase Initialization Successful");

app.listen(PORT, async () => {
  try {
    await mongoConfig(process.env.DB);
    await setUpAdmin();
    console.log("Server Running On PORT:" + PORT);
  } catch (err) {
    console.log(err);
  }
});
