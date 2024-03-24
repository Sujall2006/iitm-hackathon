const jwt = require("jsonwebtoken");

const verifyToken = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(" ")[1];

    const verify = jwt.verify(token, process.env.JWT_KEY);

    if (
      verify &&
      (verify.role === req.originalUrl.split("/").splice(1)[1].split("?")[0] ||
        req.originalUrl.split("/").splice(1)[1].split("?")[0] === "auth")
    ) {
      req.user = verify;
      next();
    } else return res.status(403).json({ error: "API Service Forbidden" });
  } catch (err) {
    return res.status(500).json({ error: "Internal Server Error", err });
  }
};

module.exports = { verifyToken };
