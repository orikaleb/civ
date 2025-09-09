# 🚀 CivicVoice Backend Deployment Guide

This guide will help you deploy your CivicVoice backend to various cloud platforms.

## 📋 Prerequisites

- Node.js project with all dependencies
- MongoDB database (local or cloud)
- Environment variables configured
- Git repository (for most deployments)

## 🌐 Deployment Options

### 1. Vercel (Recommended for Frontend + API)

Vercel is perfect for full-stack applications and provides excellent performance.

#### Setup:
```bash
# Install Vercel CLI
npm i -g vercel

# Login to Vercel
vercel login

# Deploy
vercel

# Set environment variables
vercel env add DATABASE_URL
vercel env add JWT_SECRET
vercel env add ADMIN_EMAIL
vercel env add ADMIN_PASSWORD
```

#### Configuration:
- **Build Command**: `npm install`
- **Output Directory**: `./`
- **Install Command**: `npm install`

### 2. Heroku

Heroku provides easy deployment with built-in database options.

#### Setup:
```bash
# Install Heroku CLI
# Download from: https://devcenter.heroku.com/articles/heroku-cli

# Login to Heroku
heroku login

# Create Heroku app
heroku create your-civicvoice-backend

# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set DATABASE_URL=your-mongodb-url
heroku config:set JWT_SECRET=your-jwt-secret
heroku config:set ADMIN_EMAIL=admin@civicvoice.com
heroku config:set ADMIN_PASSWORD=your-admin-password

# Deploy
git push heroku main
```

#### Procfile:
Create a `Procfile` in your backend directory:
```
web: node server.js
```

### 3. Railway

Railway offers simple deployment with automatic database provisioning.

#### Setup:
1. Go to [Railway.app](https://railway.app)
2. Connect your GitHub repository
3. Add environment variables in the dashboard
4. Deploy automatically

### 4. DigitalOcean App Platform

DigitalOcean provides scalable deployment options.

#### Setup:
1. Go to [DigitalOcean App Platform](https://cloud.digitalocean.com/apps)
2. Create new app from GitHub
3. Configure build settings
4. Set environment variables
5. Deploy

### 5. AWS (Advanced)

For production-scale applications, AWS provides comprehensive services.

#### Using AWS Elastic Beanstalk:
```bash
# Install EB CLI
pip install awsebcli

# Initialize EB
eb init

# Create environment
eb create production

# Deploy
eb deploy
```

#### Using AWS Lambda (Serverless):
```bash
# Install Serverless Framework
npm install -g serverless

# Deploy
serverless deploy
```

## 🗄️ Database Setup

### MongoDB Atlas (Recommended)

1. **Create Account**: Go to [MongoDB Atlas](https://www.mongodb.com/atlas)
2. **Create Cluster**: Choose free tier for development
3. **Get Connection String**: Copy the connection URL
4. **Update Environment**: Set `DATABASE_URL` in your deployment

### Local MongoDB

For development only:
```bash
# Install MongoDB
brew install mongodb-community

# Start MongoDB
brew services start mongodb-community

# Connection string
DATABASE_URL=mongodb://localhost:27017/civicvoice
```

## 🔐 Environment Variables

### Required Variables:
```env
NODE_ENV=production
PORT=3000
DATABASE_URL=mongodb+srv://username:password@cluster.mongodb.net/civicvoice
JWT_SECRET=your-super-secret-jwt-key-here
JWT_EXPIRES_IN=7d
ADMIN_EMAIL=admin@civicvoice.com
ADMIN_PASSWORD=your-secure-admin-password
```

### Optional Variables:
```env
CORS_ORIGIN=https://your-frontend-domain.com
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
```

## 🚀 Quick Deployment Steps

### 1. Prepare Your Code
```bash
# Ensure all dependencies are in package.json
npm install

# Test locally
npm run dev

# Check for any build errors
npm run build
```

### 2. Choose Deployment Platform
- **Quick Start**: Vercel or Railway
- **Production**: Heroku or DigitalOcean
- **Enterprise**: AWS or Google Cloud

### 3. Set Up Database
- **Development**: MongoDB Atlas (free tier)
- **Production**: MongoDB Atlas (paid plan) or self-hosted

### 4. Configure Environment
- Set all required environment variables
- Test API endpoints
- Verify database connection

### 5. Deploy
- Push to your chosen platform
- Monitor deployment logs
- Test production API

## 🔍 Post-Deployment Checklist

- [ ] API health check: `GET /health`
- [ ] Database connection working
- [ ] Authentication endpoints working
- [ ] Admin endpoints accessible
- [ ] CORS configured correctly
- [ ] Rate limiting active
- [ ] Environment variables set
- [ ] SSL certificate active (HTTPS)
- [ ] Monitoring set up

## 📊 Monitoring & Maintenance

### Health Monitoring
```bash
# Check API health
curl https://your-api-domain.com/health

# Monitor logs
# Platform-specific log commands
```

### Database Maintenance
- Regular backups
- Monitor connection limits
- Optimize queries
- Update indexes

### Security Updates
- Keep dependencies updated
- Monitor security advisories
- Regular security audits
- Update JWT secrets periodically

## 🆘 Troubleshooting

### Common Issues:

1. **Database Connection Failed**
   - Check DATABASE_URL format
   - Verify network access
   - Check MongoDB Atlas IP whitelist

2. **Environment Variables Not Loading**
   - Verify variable names
   - Check deployment platform settings
   - Restart application

3. **CORS Errors**
   - Update CORS_ORIGIN
   - Check frontend domain
   - Verify HTTPS/HTTP mismatch

4. **Rate Limiting Issues**
   - Adjust rate limit settings
   - Check IP restrictions
   - Monitor usage patterns

## 📞 Support

- **Documentation**: Check README.md
- **Issues**: Create GitHub issue
- **Community**: Join our Discord
- **Email**: support@civicvoice.com

---

**Happy Deploying! 🚀**
