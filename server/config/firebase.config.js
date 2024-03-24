const admin = require("firebase-admin");

const handleNotification = async (title, body, token) => {
  try {
    const message = {
      notification: {
        title,
        body,
      },
      token,
    };
    await admin.messaging().send(message);
  } catch (err) {
    return;
  }
};

module.exports = { handleNotification };
