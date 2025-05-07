const mongoose = require('mongoose');
const config   = require('../config/config');

// Tắt strictQuery (nếu cần, Mongoose 7 sẽ đổi default)
mongoose.set('strictQuery', false);  // :contentReference[oaicite:13]{index=13}

class DBConnection {
  static async connect(uri = config.MONGO_URI) {
    // 1) Định nghĩa options
    const options = {
      serverSelectionTimeoutMS: 10000,
      connectTimeoutMS:        30000,
      socketTimeoutMS:         45000,
      family:                  4
    };

    // 2) Diagnostic listeners
    mongoose.connection
      .on('connected',    () => console.log('✅ MongoDB connected'))
      .on('error',        err => console.error('❌ MongoDB error:', err))
      .on('disconnected', () => console.warn('⚠️ MongoDB disconnected'));

    try {
      // 3) Kết nối
      await mongoose.connect(uri, options);
      console.log('🔥 DBConnection options:', options);
      console.log(`🚀 Connected to MongoDB at ${uri}`);
    } catch (error) {
      console.error('❌ Error connecting to MongoDB', error);
      process.exit(1);
    }
  }
}

module.exports = DBConnection;
