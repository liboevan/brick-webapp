# API Integration Guide

**For Frontend Developers**

This guide explains how to integrate with the backend APIs in the Brick system.

## 🔌 Available APIs

### **Clock API** (`brick-clock`)
- **URL**: `http://localhost:8001`
- **Purpose**: NTP time synchronization management
- **Documentation**: See `../brick-clock/README.md`

### **Sentinel API** (`brick-sentinel`)
- **URL**: `http://localhost:8002`
- **Purpose**: Authentication and security management
- **Documentation**: See `../brick-sentinel/README.md`

## 🚀 Quick Start

### **1. Start Backend Services**
```bash
# Start Clock API
cd ../brick-clock
docker-compose up -d

# Start Sentinel API
cd ../brick-sentinel
docker-compose up -d
```

### **2. Configure Frontend**
```bash
# Copy environment template
cp env.example .env

# Edit API URLs
VITE_CLOCK_API_URL=http://localhost:8001
VITE_SENTINEL_API_URL=http://localhost:8002
```

### **3. Start Frontend Development**
```bash
npm run dev
# Visit http://localhost:3000
```

## 📡 API Endpoints

### **Clock API Endpoints**
```javascript
// Get NTP status
GET /chrony/status

// Get NTP servers
GET /chrony/servers

// Set NTP servers
PUT /chrony/servers
{
  "servers": ["pool.ntp.org", "time.google.com"]
}

// Enable/disable server mode
PUT /chrony/server-mode
{
  "enabled": true
}
```

### **Sentinel API Endpoints**
```javascript
// Authenticate user
POST /auth
Authorization: Basic <base64(username:password)>

// Get user list (admin only)
POST /account/list
Authorization: Basic <base64(username:password)>

// Create user (admin only)
POST /account/create
{
  "username": "newuser",
  "password": "password",
  "role": "user"
}
```

## 🔧 Integration Examples

### **Clock API Integration**
```javascript
// In your Vue component
async fetchNtpStatus() {
  try {
    const response = await fetch(`${import.meta.env.VITE_CLOCK_API_URL}/chrony/status`)
    const data = await response.json()
    this.ntpStatus = data
  } catch (error) {
    console.error('Failed to fetch NTP status:', error)
  }
}

async setNtpServers(servers) {
  try {
    const response = await fetch(`${import.meta.env.VITE_CLOCK_API_URL}/chrony/servers`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ servers })
    })
    return await response.json()
  } catch (error) {
    console.error('Failed to set NTP servers:', error)
  }
}
```

### **Sentinel API Integration**
```javascript
// Authentication
async login(username, password) {
  try {
    const credentials = btoa(`${username}:${password}`)
    const response = await fetch(`${import.meta.env.VITE_SENTINEL_API_URL}/auth`, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${credentials}`
      }
    })
    
    if (response.ok) {
      // Store authentication state
      localStorage.setItem('isAuthenticated', 'true')
      localStorage.setItem('user', JSON.stringify({ username, role: 'admin' }))
      return true
    }
    return false
  } catch (error) {
    console.error('Login failed:', error)
    return false
  }
}

// Get user list (admin only)
async getUserList() {
  try {
    const credentials = btoa('admin:adminpass')
    const response = await fetch(`${import.meta.env.VITE_SENTINEL_API_URL}/account/list`, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${credentials}`
      }
    })
    return await response.json()
  } catch (error) {
    console.error('Failed to get user list:', error)
  }
}
```

## 🧪 Testing APIs

### **Using curl**
```bash
# Test Clock API
curl http://localhost:8001/chrony/status

# Test Sentinel API
curl -u admin:adminpass -X POST http://localhost:8002/auth
```

### **Using Browser DevTools**
```javascript
// In browser console
fetch('http://localhost:8001/chrony/status')
  .then(response => response.json())
  .then(data => console.log(data))
```

## 🔒 Authentication

### **Current Implementation**
- Uses localStorage for session management
- Basic authentication with username/password
- Demo credentials: `admin` / `password`

### **Production Considerations**
- Implement proper JWT tokens
- Add refresh token mechanism
- Secure cookie storage
- CSRF protection

## 🐛 Troubleshooting

### **Common Issues**

1. **CORS Errors**
   - Backend services must enable CORS
   - Check if APIs are running on correct ports

2. **Connection Refused**
   - Verify backend services are running
   - Check port numbers in environment variables

3. **Authentication Failures**
   - Verify credentials
   - Check if Sentinel API is running

### **Debug Tips**
- Use browser Network tab to inspect requests
- Check browser console for errors
- Verify API responses with curl
- Test with Postman or similar tools

## 📚 Resources

- [Clock API Documentation](../brick-clock/README.md)
- [Sentinel API Documentation](../brick-sentinel/README.md)
- [Vue.js HTTP Client Guide](https://vuejs.org/guide/scaling-up/ssr.html#http-client)
- [Fetch API Documentation](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API) 