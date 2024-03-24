const nodemailer = require("nodemailer");

const mailer = nodemailer.createTransport({
  from: process.env.MAIL_ID,
  host: "smtp.gmail.com",
  port: 465,
  // secure: true,
  auth: {
    user: process.env.MAIL_ID,
    pass: process.env.MAIL_PASS,
  },
  tls: {
    rejectUnauthorized: false,
  },
});

module.exports = { mailer };
