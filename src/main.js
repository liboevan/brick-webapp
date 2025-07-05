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
    component: CustomNTP 
  },
  { 
    path: '/clock', 
    component: CustomNTP 
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

// Navigation guard - skip authentication for now
router.beforeEach((to, from, next) => {
  // Skip authentication checks - allow direct access
  next()
})

const app = createApp(App)
app.use(router)

// Add auth mixin globally
app.mixin(authMixin)

app.mount('#app') 