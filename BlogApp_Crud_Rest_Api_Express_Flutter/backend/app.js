// File: backend/app.js

// 1. Load core libraries
const express    = require('express');
const cors       = require('cors');
const bodyParser = require('body-parser');
const passport   = require('passport');
const multer     = require('multer');
const path       = require('path');
require('dotenv').config();

// 2. Connect to MongoDB
const config       = require('./config/config');
const DBConnection = require('./infrastructure/DBConnection');
DBConnection.connect(config.DB_URI);

// 3. Passport strategies (JWT + Google OAuth)
require('./infrastructure/PassportConfig')(passport);

// 4. Create Express app
const app = express();

// 5. Bật CORS cho mọi origin (có thể chỉ định domain nếu muốn)
app.use(cors());

// 6. Serve thư mục uploads để trả raw image bytes
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// 7. Body parsers
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ limit: '10mb', extended: true }));
app.use(passport.initialize());

// 8. Multer setup: store into ./uploads folder
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, 'uploads'));
  },
  filename: (req, file, cb) => {
    const ext = file.originalname.split('.').pop();
    cb(null, Date.now() + '.' + ext);
  }
});
const upload = multer({ storage });

// 9. Wire up Clean-Architecture pieces
const MongoUserRepo  = require('./infrastructure/MongoUserRepository');
const MongoPostRepo  = require('./infrastructure/MongoPostRepository');
const AuthGateway    = require('./infrastructure/AuthGateway');
const UserUseCases   = require('./usecases/UserUseCases');
const PostUseCases   = require('./usecases/PostUseCases');
const UserController = require('./interfaces/controllers/UserController');
const PostController = require('./interfaces/controllers/PostController');

const userRepo = new MongoUserRepo();
const postRepo = new MongoPostRepo();
const authGtw  = new AuthGateway(config.SECRET);
const userUC   = new UserUseCases(userRepo, authGtw, postRepo);
const postUC   = new PostUseCases(postRepo);
const userCtrl = new UserController(userUC);
const postCtrl = new PostController(postUC);

// 10. Routes

// Public
app.post('/register',     (req, res) => userCtrl.register(req, res));
app.post('/authenticate', (req, res) => userCtrl.authenticate(req, res));

// Protected Post routes
app.post(
  '/posts',
  passport.authenticate('jwt', { session: false }),
  upload.single('image'),
  (req, res) => postCtrl.createPost(req, res)
);
app.get(
  '/posts',
  passport.authenticate('jwt', { session: false }),
  (req, res) => postCtrl.getAllPosts(req, res)
);
app.get(
  '/posts/:id',
  passport.authenticate('jwt', { session: false }),
  (req, res) => postCtrl.getPostById(req, res)
);
app.put(
  '/posts/:id',
  passport.authenticate('jwt', { session: false }),
  (req, res) => postCtrl.updatePost(req, res)
);
app.delete(
  '/posts/:id',
  passport.authenticate('jwt', { session: false }),
  (req, res) => postCtrl.deletePost(req, res)
);
app.get(
  '/posts/:id/history',
  passport.authenticate('jwt', { session: false }),
  (req, res) => postCtrl.getEditHistory(req, res)
);

// Protected User routes
app.put(
  '/user',
  passport.authenticate('jwt', { session: false }),
  (req, res) => userCtrl.updateUser(req, res)
);
app.get(
  '/users/me',
  passport.authenticate('jwt', { session: false }),
  (req, res) => userCtrl.getCurrentUserProfile(req, res)
);
app.get(
  '/users',
  passport.authenticate('jwt', { session: false }),
  (req, res) => userCtrl.listUsers(req, res)
);
app.get(
  '/users/:id',
  passport.authenticate('jwt', { session: false }),
  (req, res) => userCtrl.getUserProfile(req, res)
);
app.delete(
  '/users/:id',
  passport.authenticate('jwt', { session: false }),
  (req, res) => userCtrl.deleteUser(req, res)
);

// Google OAuth routes
app.get('/auth/google',
  passport.authenticate('google', { scope: ['profile', 'email'] })
);

app.get('/auth/google/callback',
  passport.authenticate('google', { session: false, failureRedirect: '/login' }),
  (req, res) => {
    // Tạo JWT token cho user đã xác thực thành công
    const jwt = require('jsonwebtoken');
    const token = jwt.sign(
      { id: req.user._id, name: req.user.name },
      config.SECRET,
      { expiresIn: '1h' }
    );
    // Redirect về frontend Flutter (hoặc trả về token tuỳ ý)
    res.json({ token });
    // Nếu muốn trả về JSON:
    // res.json({ token });
  }
);

// 11. Start server
const PORT = config.PORT || 3000;
const HOST = '0.0.0.0';
app.listen(PORT, HOST, () => {
  console.log(`🚀 Server is running on http://${HOST}:${PORT}`);
});
