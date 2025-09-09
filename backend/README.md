# CivicVoice Backend API

A comprehensive backend API for the CivicVoice social media platform, built with Node.js, Express, and MongoDB.

## 🚀 Features

- **User Management**: Registration, authentication, profiles, roles, and permissions
- **Content Management**: Posts, comments, likes, shares, and moderation
- **Admin Panel**: User management, content moderation, analytics, and system health
- **Analytics**: Platform metrics, user engagement, and performance tracking
- **Security**: JWT authentication, rate limiting, input validation, and CORS protection
- **Real-time**: WebSocket support for live updates (coming soon)

## 📋 Prerequisites

- Node.js (v16 or higher)
- MongoDB (local or MongoDB Atlas)
- npm or yarn

## 🛠 Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment Setup**
   ```bash
   cp env.example .env
   ```
   
   Edit `.env` file with your configuration:
   ```env
   PORT=3000
   NODE_ENV=development
   DATABASE_URL=mongodb://localhost:27017/civicvoice
   JWT_SECRET=your-super-secret-jwt-key-here
   JWT_EXPIRES_IN=7d
   ADMIN_EMAIL=admin@civicvoice.com
   ADMIN_PASSWORD=admin123
   ```

4. **Start MongoDB**
   ```bash
   # Local MongoDB
   mongod
   
   # Or use MongoDB Atlas (cloud)
   # Update DATABASE_URL in .env
   ```

5. **Seed the database (optional)**
   ```bash
   npm run seed
   ```

6. **Start the server**
   ```bash
   # Development
   npm run dev
   
   # Production
   npm start
   ```

## 📚 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `POST /api/auth/admin/login` - Admin login
- `POST /api/auth/refresh` - Refresh token
- `GET /api/auth/me` - Get current user
- `POST /api/auth/logout` - Logout

### Users
- `GET /api/users/:id` - Get user profile
- `PUT /api/users/:id` - Update user profile
- `POST /api/users/:id/follow` - Follow user
- `DELETE /api/users/:id/follow` - Unfollow user
- `GET /api/users/:id/followers` - Get user's followers
- `GET /api/users/:id/following` - Get user's following
- `GET /api/users/:id/posts` - Get user's posts
- `GET /api/users/search` - Search users

### Posts
- `GET /api/posts` - Get all posts
- `GET /api/posts/:id` - Get post by ID
- `POST /api/posts` - Create new post
- `PUT /api/posts/:id` - Update post
- `DELETE /api/posts/:id` - Delete post
- `POST /api/posts/:id/like` - Like/unlike post
- `POST /api/posts/:id/comments` - Add comment
- `GET /api/posts/:id/comments` - Get post comments
- `POST /api/posts/:id/report` - Report post

### Admin
- `GET /api/admin/users` - Get all users (admin)
- `GET /api/admin/users/:id` - Get user details (admin)
- `PUT /api/admin/users/:id/role` - Update user role (admin)
- `PUT /api/admin/users/:id/suspend` - Suspend user (admin)
- `PUT /api/admin/users/:id/activate` - Activate user (admin)
- `DELETE /api/admin/users/:id` - Delete user (admin)
- `GET /api/admin/reports` - Get reported content (admin)
- `PUT /api/admin/reports/:id/moderate` - Moderate content (admin)
- `GET /api/admin/analytics` - Get platform analytics (admin)
- `GET /api/admin/system/health` - Get system health (admin)
- `GET /api/admin/dashboard` - Get admin dashboard (admin)

### Analytics
- `GET /api/analytics` - Get platform analytics
- `GET /api/analytics/users/growth` - Get user growth analytics
- `GET /api/analytics/content/performance` - Get content performance
- `GET /api/analytics/system/health` - Get system health

## 🔐 Authentication

The API uses JWT (JSON Web Tokens) for authentication. Include the token in the Authorization header:

```bash
Authorization: Bearer <your-jwt-token>
```

## 📊 Database Models

### User
- Basic info (email, password, fullName, username, bio)
- Social features (followers, following, interests)
- Engagement metrics (totalVotes, totalRating, totalPosts)
- Role and permissions (role, isVerified, isActive)
- Admin fields (adminNotes, suspendedUntil, suspensionReason)

### Post
- Content (content, images, category)
- Engagement (likes, comments, shares)
- Performance reference (for linking to government data)
- Moderation (isReported, reports, isModerated, moderationNotes)
- Visibility (isPublic, isPinned)

### Analytics
- User metrics (totalUsers, activeUsers, newUsers)
- Content metrics (totalPosts, newPosts, totalComments, totalLikes)
- Engagement metrics (averageEngagement, topCategories)
- System health (status, uptime, responseTime, errorRate)

## 🛡 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: bcrypt for password security
- **Rate Limiting**: Prevent API abuse
- **Input Validation**: Express-validator for request validation
- **CORS Protection**: Configurable cross-origin resource sharing
- **Helmet**: Security headers
- **Role-based Access**: Admin, moderator, and user permissions

## 🚀 Deployment

### Using Vercel
1. Install Vercel CLI: `npm i -g vercel`
2. Run: `vercel`
3. Set environment variables in Vercel dashboard

### Using Heroku
1. Install Heroku CLI
2. Create Heroku app: `heroku create your-app-name`
3. Set environment variables: `heroku config:set KEY=value`
4. Deploy: `git push heroku main`

### Using Docker
```dockerfile
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

## 🧪 Testing

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:coverage
```

## 📝 API Documentation

The API follows RESTful conventions and returns JSON responses:

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "errors": [ ... ]
}
```

## 🔧 Configuration

### Environment Variables
- `PORT`: Server port (default: 3000)
- `NODE_ENV`: Environment (development/production)
- `DATABASE_URL`: MongoDB connection string
- `JWT_SECRET`: Secret key for JWT tokens
- `JWT_EXPIRES_IN`: Token expiration time
- `ADMIN_EMAIL`: Default admin email
- `ADMIN_PASSWORD`: Default admin password
- `CORS_ORIGIN`: Allowed CORS origins

### Rate Limiting
- Default: 100 requests per 15 minutes per IP
- Configurable via environment variables

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support, email support@civicvoice.com or create an issue in the repository.

## 🔄 Updates

- **v1.0.0**: Initial release with core features
- **v1.1.0**: Added analytics and admin panel
- **v1.2.0**: Enhanced security and performance
- **v1.3.0**: Real-time features and WebSocket support (coming soon)

---

**Built with ❤️ for civic engagement and community building**
