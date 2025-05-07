// backend\infrastructure\PassportConfig.js

const { Strategy: JwtStrategy, ExtractJwt } = require('passport-jwt');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const config         = require('../config/config');
const MongoUserRepo  = require('./MongoUserRepository');

module.exports = (passport, authGateway) => {
  // JWT strategy
  const opts = {
    jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
    secretOrKey:    config.SECRET,
  };
  passport.use(new JwtStrategy(opts, async (jwt_payload, done) => {
    try {
      const user = await new MongoUserRepo().findById(jwt_payload.id);
      if (user) return done(null, user);
      return done(null, false);
    } catch (err) {
      return done(err, false);
    }
  }));

 // Google OAuth strategy
 passport.use(new GoogleStrategy({
  clientID:     config.GOOGLE_CLIENT_ID,
  clientSecret: config.GOOGLE_CLIENT_SECRET,
  callbackURL:  config.GOOGLE_CALLBACK_URL,
}, async (accessToken, refreshToken, profile, done) => {
  try {
    const repo = new MongoUserRepo();
    let user = await repo.findByGoogleId(profile.id);
    if (!user) {
      user = await repo.createUser({
        googleId: profile.id,
        name:     profile.displayName,
        email:    profile.emails[0].value,
      });
    }
    return done(null, user);
  } catch (err) {
    return done(err, false);
  }
}));
};