const mongoose = require('mongoose');

const postSchema = new mongoose.Schema({
  // Basic Information
  author: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  content: {
    type: String,
    required: true,
    maxlength: 2000
  },
  images: [{
    type: String // URLs to uploaded images
  }],
  category: {
    type: String,
    enum: ['Politics', 'Education', 'Healthcare', 'Economy', 'Environment', 'Technology', 'Sports', 'Entertainment', 'General'],
    default: 'General'
  },
  
  // Engagement Metrics
  likes: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  comments: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    content: {
      type: String,
      required: true,
      maxlength: 500
    },
    createdAt: {
      type: Date,
      default: Date.now
    },
    likes: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    }]
  }],
  shares: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  
  // Performance Data Reference
  performanceReference: {
    kpiId: String,
    kpiTitle: String,
    dataType: String, // 'economy', 'healthcare', etc.
    timestamp: Date
  },
  
  // Moderation
  isReported: {
    type: Boolean,
    default: false
  },
  reports: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    reason: {
      type: String,
      enum: ['spam', 'inappropriate', 'harassment', 'false_information', 'other']
    },
    description: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  isModerated: {
    type: Boolean,
    default: false
  },
  moderationNotes: {
    type: String,
    default: ''
  },
  
  // Visibility
  isPublic: {
    type: Boolean,
    default: true
  },
  isPinned: {
    type: Boolean,
    default: false
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
postSchema.index({ author: 1, createdAt: -1 });
postSchema.index({ category: 1, createdAt: -1 });
postSchema.index({ isPublic: 1, createdAt: -1 });
postSchema.index({ isReported: 1 });
postSchema.index({ 'performanceReference.kpiId': 1 });

// Virtual for like count
postSchema.virtual('likeCount').get(function() {
  return this.likes.length;
});

// Virtual for comment count
postSchema.virtual('commentCount').get(function() {
  return this.comments.length;
});

// Virtual for share count
postSchema.virtual('shareCount').get(function() {
  return this.shares.length;
});

// Method to add like
postSchema.methods.addLike = function(userId) {
  const existingLike = this.likes.find(like => like.user.toString() === userId.toString());
  if (!existingLike) {
    this.likes.push({ user: userId });
    return true;
  }
  return false;
};

// Method to remove like
postSchema.methods.removeLike = function(userId) {
  this.likes = this.likes.filter(like => like.user.toString() !== userId.toString());
};

// Method to add comment
postSchema.methods.addComment = function(userId, content) {
  this.comments.push({
    user: userId,
    content: content
  });
};

// Method to add report
postSchema.methods.addReport = function(userId, reason, description) {
  this.reports.push({
    user: userId,
    reason: reason,
    description: description
  });
  this.isReported = true;
};

// Method to moderate post
postSchema.methods.moderate = function(notes) {
  this.isModerated = true;
  this.moderationNotes = notes;
  this.isReported = false;
};

module.exports = mongoose.model('Post', postSchema);
