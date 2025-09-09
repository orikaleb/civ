# CivicVoice Backend - Quick Start Guide

## 🚀 Quick Setup

### Prerequisites
- Node.js (v16 or higher)
- MongoDB (local or cloud)
- npm or yarn

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Environment Setup
```bash
cp env.example .env
# Edit .env with your configuration
```

### 3. Start the Server
```bash
# Development mode
npm run dev

# Production mode
npm start
```

## 📋 Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm start` - Start production server
- `npm run seed` - Populate database with sample data
- `npm test` - Run API tests

## 🔗 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout

### Users
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

### Posts
- `GET /api/posts` - Get all posts
- `POST /api/posts` - Create new post
- `PUT /api/posts/:id` - Update post
- `DELETE /api/posts/:id` - Delete post

### Admin
- `GET /api/admin/dashboard` - Admin dashboard data
- `GET /api/admin/users` - Admin user management
- `GET /api/admin/analytics` - Analytics data

## 🗄️ Database Schema

### Users Collection
- `_id`: ObjectId
- `username`: String (unique)
- `email`: String (unique)
- `password`: String (hashed)
- `role`: String (user/moderator/admin/superAdmin)
- `isVerified`: Boolean
- `createdAt`: Date
- `updatedAt`: Date

### Posts Collection
- `_id`: ObjectId
- `content`: String
- `author`: ObjectId (ref: User)
- `likes`: Number
- `comments`: Number
- `shares`: Number
- `createdAt`: Date

## 🔧 Configuration

### Environment Variables
- `PORT` - Server port (default: 3000)
- `MONGODB_URI` - MongoDB connection string
- `JWT_SECRET` - JWT signing secret
- `NODE_ENV` - Environment (development/production)

## 🧪 Testing

```bash
# Run all tests
npm test

# Test specific endpoint
node test-api.js
```

## 📊 Monitoring

The backend includes built-in analytics and monitoring:
- Request logging
- Error tracking
- Performance metrics
- User activity tracking

## 🚀 Deployment

### Heroku
```bash
# Add Heroku remote
heroku git:remote -a your-app-name

# Deploy
git push heroku main
```

### Docker
```bash
# Build image
docker build -t civicvoice-backend .

# Run container
docker run -p 3000:3000 civicvoice-backend
```

## 📝 API Documentation

Full API documentation is available at `/api/docs` when the server is running.

## 🆘 Troubleshooting

### Common Issues
1. **MongoDB Connection Error**: Check your MONGODB_URI
2. **Port Already in Use**: Change PORT in .env
3. **JWT Errors**: Verify JWT_SECRET is set

### Support
For issues and questions, please check the logs or contact the development team.
