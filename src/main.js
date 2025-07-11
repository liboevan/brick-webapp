import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'
import Dashboard from './components/Dashboard.vue'
import Login from './components/Login.vue'
import CustomNTP from './components/CustomNTP.vue'
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
    meta: { requiresAuth: true }
  },
  { 
    path: '/clock', 
    component: CustomNTP,
    meta: { requiresAuth: true }
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