export default {
  data() {
    return {
      isAuthenticated: false,
      user: null
    }
  },
  
  created() {
    this.checkAuth()
  },
  
  methods: {
    checkAuth() {
      const auth = localStorage.getItem('isAuthenticated')
      const user = localStorage.getItem('user')
      
      this.isAuthenticated = auth === 'true'
      this.user = user ? JSON.parse(user) : null
    },
    
    login(username, password) {
      // Demo authentication
      if (username === 'admin' && password === 'password') {
        localStorage.setItem('isAuthenticated', 'true')
        localStorage.setItem('user', JSON.stringify({
          username: username,
          role: 'admin'
        }))
        
        this.isAuthenticated = true
        this.user = { username, role: 'admin' }
        return true
      }
      return false
    },
    
    logout() {
      localStorage.removeItem('isAuthenticated')
      localStorage.removeItem('user')
      
      this.isAuthenticated = false
      this.user = null
      
      // Redirect to login
      this.$router.push('/login')
    },
    
    requireAuth() {
      if (!this.isAuthenticated) {
        this.$router.push('/login')
        return false
      }
      return true
    }
  }
} 