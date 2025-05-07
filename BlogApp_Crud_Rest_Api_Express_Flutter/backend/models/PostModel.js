// File: backend/models/PostModel.js
const mongoose = require('mongoose');
const { Schema } = mongoose;

const PostSchema = new Schema({
  image: {
    type: String,   // URL hoặc path đến ảnh (optional)
    trim: true
  },
  text: {
    type: String,
    trim: true
  },
  address: {
    type: String,
    trim: true
  },
  authorId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  author: {
    type: String,
    required: true
  },
  postedAt: {
    type: Date,
    default: Date.now,
    select: false
  },
  editCount: { type: Number, default: 0 },
  editHistory: [
    {
      editedAt: { type: Date, default: Date.now },
      diff: Schema.Types.Mixed
    }
  ]
});

// – ensure ít nhất một trong `image` hoặc `text` phải có
PostSchema.pre('validate', function(next) {
  if (!this.image && !this.text) {
    this.invalidate('text', 'Phải có ít nhất ảnh hoặc nội dung văn bản.');
  }
  next();
});

// postedAt không thể sửa sau khi khởi tạo
PostSchema.path('postedAt').immutable(true);

module.exports = mongoose.model('Post', PostSchema);
