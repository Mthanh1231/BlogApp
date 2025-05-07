// backend/config/config.js
require('dotenv').config();

const config = {
  DB_URI: process.env.DB_URI,
  SECRET: process.env.SECRET || '1312',
  PORT: process.env.PORT || 3000,
  GOOGLE_CLIENT_ID: process.env.GOOGLE_CLIENT_ID,
  GOOGLE_CLIENT_SECRET: process.env.GOOGLE_CLIENT_SECRET,
  GOOGLE_CALLBACK_URL: process.env.GOOGLE_CALLBACK_URL,
};

module.exports = config;

