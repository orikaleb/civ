const mongoose = require('mongoose');

const analyticsSchema = new mongoose.Schema({
  // Date and time
  date: {
    type: Date,
    required: true,
    default: Date.now
  },
  
  // User Analytics
  totalUsers: {
    type: Number,
    default: 0
  },
  activeUsers: {
    type: Number,
    default: 0
  },
  newUsers: {
    type: Number,
    default: 0
  },
  
  // Content Analytics
  totalPosts: {
    type: Number,
    default: 0
  },
  newPosts: {
    type: Number,
    default: 0
  },
  totalComments: {
    type: Number,
    default: 0
  },
  totalLikes: {
    type: Number,
    default: 0
  },
  
  // Engagement Metrics
  averageEngagement: {
    type: Number,
    default: 0
  },
  topCategories: [{
    category: String,
    count: Number
  }],
  
  // System Health
  systemHealth: {
    status: {
      type: String,
      enum: ['healthy', 'warning', 'critical'],
      default: 'healthy'
    },
    uptime: {
      type: Number,
      default: 100
    },
    responseTime: {
      type: Number,
      default: 0
    },
    errorRate: {
      type: Number,
      default: 0
    }
  },
  
  // Performance Metrics
  performanceMetrics: {
    pageLoadTime: {
      type: Number,
      default: 0
    },
    apiResponseTime: {
      type: Number,
      default: 0
    },
    databaseQueryTime: {
      type: Number,
      default: 0
    }
  },
  
  // Moderation Stats
  moderationStats: {
    reportedPosts: {
      type: Number,
      default: 0
    },
    moderatedPosts: {
      type: Number,
      default: 0
    },
    suspendedUsers: {
      type: Number,
      default: 0
    }
  }
}, {
  timestamps: true
});

// Indexes
analyticsSchema.index({ date: -1 });
analyticsSchema.index({ 'systemHealth.status': 1 });

// Static method to get latest analytics
analyticsSchema.statics.getLatest = function() {
  return this.findOne().sort({ date: -1 });
};

// Static method to get analytics for date range
analyticsSchema.statics.getDateRange = function(startDate, endDate) {
  return this.find({
    date: {
      $gte: startDate,
      $lte: endDate
    }
  }).sort({ date: -1 });
};

module.exports = mongoose.model('Analytics', analyticsSchema);
