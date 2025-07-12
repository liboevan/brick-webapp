import { createApp } from 'vue'
import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import App from './App.vue'
import Dashboard from './components/Dashboard.vue'
import Login from './components/Login.vue'
import CustomNTP from './components/CustomNTP.vue'
import AdminManagement from './components/AdminManagement.vue'
import type { RouteMeta } from './types'

const routes: RouteRecordRaw[] = [
  { 
    path: '/', 
    component: Dashboard,
    meta: { requiresAuth: false } as RouteMeta
  },
  { 
    path: '/login', 
    component: Login 
  },
  { 
    path: '/ntp', 
    component: CustomNTP,
    meta: { requiresAuth: true, title: 'Brick - NTP' } as RouteMeta
  },
  { 
    path: '/clock', 
    component: CustomNTP,
    meta: { requiresAuth: true } as RouteMeta
  },
  { 
    path: '/admin', 
    component: AdminManagement,
    meta: { requiresAuth: true, requiresSuperAdmin: true, title: 'Brick - Admin Management' } as RouteMeta
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

// Navigation guard for authentication
router.beforeEach((to, from, next) => {
  const isAuthenticated = localStorage.getItem('isAuthenticated') === 'true'
  const token = localStorage.getItem('jwt_token')
  
  // Check if route requires authentication
  if (to.meta?.requiresAuth && !isAuthenticated) {
    next('/login')
    return
  }
  
  // Check if route requires super-admin
  if (to.meta?.requiresSuperAdmin) {
    const user = localStorage.getItem('user')
    if (user) {
      try {
        const userData = JSON.parse(user)
        if (userData.role !== 'super-admin') {
          next('/')
          return
        }
      } catch (e) {
        next('/login')
        return
      }
    } else {
      next('/login')
      return
    }
  }
  
  // If user is authenticated and trying to access login page, redirect to home
  if (to.path === '/login' && isAuthenticated && token) {
    next('/')
    return
  }
  
  next()
})

// Create Vue app
const app = createApp(App)

// Use router
app.use(router)

// Mount app
app.mount('#app') 