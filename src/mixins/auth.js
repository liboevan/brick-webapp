export default {
  data() {
    return {
      isAuthenticated: false,
      user: null,
      jwtToken: null
    }
  },
  
  created() {
    this.checkAuth()
  },
  
  methods: {
    checkAuth() {
      const auth = localStorage.getItem('isAuthenticated')
      const user = localStorage.getItem('user')
      const token = localStorage.getItem('jwt_token')
      
      this.isAuthenticated = auth === 'true' && token
      this.user = user ? JSON.parse(user) : null
      this.jwtToken = token
      
      // Validate token if we have one
      if (token) {
        this.validateToken()
      }
    },
    
    async validateToken() {
      try {
        const response = await fetch('/api/auth/validate', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${this.jwtToken}`,
            'Content-Type': 'application/json'
          }
        })
        
        if (!response.ok) {
          // Token is invalid, clear auth state
          this.logout()
        }
      } catch (err) {
        console.error('Token validation error:', err)
        this.logout()
      }
    },
    
    // Decode JWT token to get user information
    decodeToken(token) {
      try {
        const base64Url = token.split('.')[1]
        const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/')
        const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
          return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)
        }).join(''))
        return JSON.parse(jsonPayload)
      } catch (err) {
        console.error('Token decode error:', err)
        return null
      }
    },
    
    async login(username, password) {
      try {
        const response = await fetch('/api/auth/login', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            username: username,
            password: password
          })
        })

        if (response.ok) {
          const data = await response.json()
          
          // Decode token to get user information
          const tokenData = this.decodeToken(data.token)
          if (!tokenData) {
            console.error('Failed to decode token')
            return false
          }
          
          // Store JWT token and user info
          localStorage.setItem('jwt_token', data.token)
          localStorage.setItem('isAuthenticated', 'true')
          localStorage.setItem('user', JSON.stringify({
            username: tokenData.username,
            role: tokenData.role,
            permissions: tokenData.permissions
          }))
          
          this.isAuthenticated = true
          this.user = { 
            username: tokenData.username, 
            role: tokenData.role, 
            permissions: tokenData.permissions 
          }
          this.jwtToken = data.token
          return true
        }
        return false
      } catch (err) {
        console.error('Login error:', err)
        return false
      }
    },
    
    logout() {
      localStorage.removeItem('jwt_token')
      localStorage.removeItem('isAuthenticated')
      localStorage.removeItem('user')
      
      this.isAuthenticated = false
      this.user = null
      this.jwtToken = null
      
      // Redirect to home
      this.$router.push('/')
    },
    
    requireAuth() {
      if (!this.isAuthenticated) {
        this.$router.push('/login')
        return false
      }
      return true
    },
    
    // Helper method to get auth headers for API calls
    getAuthHeaders() {
      if (this.jwtToken) {
        return {
          'Authorization': `Bearer ${this.jwtToken}`,
          'Content-Type': 'application/json'
        }
      }
      return {
        'Content-Type': 'application/json'
      }
    },
    
    // Check if user has specific permission
    hasPermission(permission) {
      if (!this.user || !this.user.permissions) {
        return false
      }
      return this.user.permissions.includes(permission)
    },
    
    // Check if user has admin role
    isAdmin() {
      return this.user && this.user.role === 'admin'
    },
    
    // Check if user has super-admin role
    isSuperAdmin() {
      return this.user && this.user.role === 'super-admin'
    }
  }
} 