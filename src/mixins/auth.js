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
        } else {
          // Token is valid, fetch complete user info
          await this.fetchUserInfo()
        }
      } catch (err) {
        console.error('Token validation error:', err)
        this.logout()
      }
    },
    
    // Fetch complete user information from /me endpoint
    async fetchUserInfo() {
      try {
        const response = await fetch('/api/auth/me', {
          method: 'GET',
          headers: {
            'Authorization': `Bearer ${this.jwtToken}`,
            'Content-Type': 'application/json'
          }
        })
        
        if (response.ok) {
          const data = await response.json()
          if (data.user) {
            // Decode token to get permissions
            const tokenData = this.decodeToken(this.jwtToken)
            const permissions = tokenData ? tokenData.permissions || [] : []
            
            // Update user object with complete information
            this.user = {
              ...this.user,
              ...data.user,
              permissions: permissions // Include permissions from JWT token
            }
            // Update localStorage
            localStorage.setItem('user', JSON.stringify(this.user))
          }
        }
      } catch (err) {
        console.error('Failed to fetch user info:', err)
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
          
          // Store JWT token and basic user info
          localStorage.setItem('jwt_token', data.token)
          localStorage.setItem('isAuthenticated', 'true')
          
          // Store complete user info from login response
          const userInfo = {
            username: data.user.username,
            role: data.user.role,
            permissions: data.permissions || [], // Get permissions from the separate field
            first_name: data.user.first_name,
            last_name: data.user.last_name,
            email: data.user.email,
            is_active: data.user.is_active
          }
          
          localStorage.setItem('user', JSON.stringify(userInfo))
          
          this.isAuthenticated = true
          this.user = userInfo
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