import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'
import Dashboard from './components/Dashboard.vue'
import Login from './components/Login.vue'
import CustomNTP from './components/CustomNTP.vue'
import AdminManagement from './components/AdminManagement.vue'
import authMixin from './mixins/auth.js'

const routes = [
  { 
    path: '/', 
    component: Dashboard,
    meta: { requiresAuth: false }
  },
  { 
    path: '/login', 
    component: Login 
  },
  { 
    path: '/ntp', 
    component: CustomNTP,
    meta: { requiresAuth: true, title: 'Brick - NTP' }
  },
  { 
    path: '/clock', 
    component: CustomNTP,
    meta: { requiresAuth: true }
  },
  { 
    path: '/admin', 
    component: AdminManagement,
    meta: { requiresAuth: true, requiresSuperAdmin: true, title: 'Brick - Admin Management' }
  },
  { 
    path: '/:pathMatch(.*)*', 
    redirect: '/' 
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Navigation guard with authentication
router.beforeEach((to, from, next) => {
  const isAuthenticated = localStorage.getItem('isAuthenticated') === 'true' && localStorage.getItem('jwt_token')
  
  // Set page title
  if (to.meta.title) {
    document.title = to.meta.title
  } else {
    document.title = 'Brick Hub'
  }
  
  // Public routes (home page and login)
  if (to.path === '/' || to.path === '/login') {
    next()
    return
  }
  
  // Protected routes require authentication
  if (to.meta.requiresAuth && !isAuthenticated) {
    next({ path: '/login', query: { redirect: to.fullPath } })
    return
  }
  
  // Super admin routes require super-admin role
  if (to.meta.requiresSuperAdmin) {
    const user = localStorage.getItem('user')
    if (!user) {
      next({ path: '/login', query: { redirect: to.fullPath } })
      return
    }
    
    try {
      const userData = JSON.parse(user)
      if (userData.role !== 'super-admin') {
        next('/')
        return
      }
    } catch (error) {
      console.error('Error parsing user data:', error)
      next({ path: '/login', query: { redirect: to.fullPath } })
      return
    }
  }
  
  // If user is authenticated and trying to access login page, redirect to home
  if (to.path === '/login' && isAuthenticated) {
    next('/')
    return
  }
  
  next()
})

const app = createApp(App)
app.use(router)

// Add auth mixin globally
app.mixin(authMixin)

app.mount('#app') 