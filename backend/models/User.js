const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  // Basic Information
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  fullName: {
    type: String,
    required: true,
    trim: true
  },
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true
  },
  bio: {
    type: String,
    maxlength: 500,
    default: ''
  },
  profileImage: {
    type: String,
    default: ''
  },
  coverImage: {
    type: String,
    default: ''
  },
  
  // Social Information
  followers: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  following: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  interests: [{
    type: String,
    enum: ['Politics', 'Education', 'Healthcare', 'Economy', 'Environment', 'Technology', 'Sports', 'Entertainment']
  }],
  
  // Engagement Metrics
  totalVotes: {
    type: Number,
    default: 0
  },
  totalRating: {
    type: Number,
    default: 0
  },
  totalPosts: {
    type: Number,
    default: 0
  },
  
  // Role and Permissions
  role: {
    type: String,
    enum: ['user', 'moderator', 'admin', 'superAdmin'],
    default: 'user'
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  isActive: {
    type: Boolean,
    default: true
  },
  lastActive: {
    type: Date,
    default: Date.now
  },
  
  // Admin specific fields
  adminNotes: {
    type: String,
    default: ''
  },
  suspendedUntil: {
    type: Date,
    default: null
  },
  suspensionReason: {
    type: String,
    default: ''
  },
  
  // Timestamps
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Indexes for better performance
userSchema.index({ email: 1 });
userSchema.index({ username: 1 });
userSchema.index({ role: 1 });
userSchema.index({ isActive: 1 });
userSchema.index({ createdAt: -1 });

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Update lastActive on login
userSchema.methods.updateLastActive = function() {
  this.lastActive = new Date();
  return this.save();
};

// Compare password method
userSchema.methods.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

// Get user stats
userSchema.methods.getStats = function() {
  return {
    followers: this.followers.length,
    following: this.following.length,
    totalVotes: this.totalVotes,
    totalRating: this.totalRating,
    totalPosts: this.totalPosts
  };
};

// Check if user is admin
userSchema.methods.isAdmin = function() {
  return ['admin', 'superAdmin'].includes(this.role);
};

// Check if user is moderator
userSchema.methods.isModerator = function() {
  return ['moderator', 'admin', 'superAdmin'].includes(this.role);
};

// Get role permissions
userSchema.methods.getPermissions = function() {
  const permissions = {
    user: ['viewPosts', 'createPosts', 'vote', 'comment'],
    moderator: ['viewPosts', 'createPosts', 'vote', 'comment', 'moderateContent', 'viewReports'],
    admin: ['viewPosts', 'createPosts', 'vote', 'comment', 'moderateContent', 'viewReports', 'manageUsers', 'viewAnalytics'],
    superAdmin: ['viewPosts', 'createPosts', 'vote', 'comment', 'moderateContent', 'viewReports', 'manageUsers', 'viewAnalytics', 'systemSettings', 'manageAdmins']
  };
  
  return permissions[this.role] || permissions.user;
};

// Remove password from JSON output
userSchema.methods.toJSON = function() {
  const user = this.toObject();
  delete user.password;
  return user;
};

module.exports = mongoose.model('User', userSchema);
