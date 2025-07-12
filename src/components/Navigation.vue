<template>
  <nav class="navigation" :class="{ 'navigation-collapsed': collapsed }">
    <div class="nav-header">
      <button @click="toggleCollapse" class="nav-toggle" :title="collapsed ? 'Expand' : 'Collapse'">
        <span class="nav-toggle-icon">{{ collapsed ? '→' : '←' }}</span>
      </button>
      <div v-if="!collapsed" class="nav-title">
        <img src="/favicon.png" alt="Brick" class="nav-logo" />
        <span class="nav-text">Brick</span>
      </div>
    </div>

    <div class="nav-content">
      <div class="nav-section">
        <h3 v-if="!collapsed" class="nav-section-title">Services</h3>
        <ul class="nav-list">
          <!-- NTP - Available to all authenticated users -->
          <li v-if="isAuthenticated" class="nav-item">
            <router-link 
              to="/ntp" 
              class="nav-link"
              :class="{ active: $route.path === '/ntp' }"
              :title="collapsed ? 'NTP Management' : ''"
            >
              <span class="nav-icon">🕐</span>
              <span v-if="!collapsed" class="nav-label">NTP</span>
            </router-link>
          </li>

          <!-- Admin Management - Only for super-admin -->
          <li v-if="isSuperAdmin" class="nav-item">
            <router-link 
              to="/admin" 
              class="nav-link"
              :class="{ active: $route.path === '/admin' }"
              :title="collapsed ? 'Admin Management' : ''"
            >
              <span class="nav-icon">⚙️</span>
              <span v-if="!collapsed" class="nav-label">Admin</span>
            </router-link>
          </li>
        </ul>
      </div>

      <!-- User section -->
      <div v-if="isAuthenticated" class="nav-section">
        <h3 v-if="!collapsed" class="nav-section-title">Account</h3>
        <ul class="nav-list">
          <li class="nav-item">
            <div class="nav-user-info" :title="collapsed ? user?.username : ''">
              <span class="nav-icon">👤</span>
              <div v-if="!collapsed" class="nav-user-details">
                <span class="nav-user-name">{{ user?.username }}</span>
                <span class="nav-user-role">{{ user?.role }}</span>
              </div>
            </div>
          </li>
          <li class="nav-item">
            <button @click="logout" class="nav-link nav-logout" :title="collapsed ? 'Logout' : ''">
              <span class="nav-icon">🚪</span>
              <span v-if="!collapsed" class="nav-label">Logout</span>
            </button>
          </li>
        </ul>
      </div>

      <!-- Login section for unauthenticated users -->
      <div v-else class="nav-section">
        <h3 v-if="!collapsed" class="nav-section-title">Access</h3>
        <ul class="nav-list">
          <li class="nav-item">
            <router-link 
              to="/login" 
              class="nav-link"
              :class="{ active: $route.path === '/login' }"
              :title="collapsed ? 'Login' : ''"
            >
              <span class="nav-icon">🔑</span>
              <span v-if="!collapsed" class="nav-label">Login</span>
            </router-link>
          </li>
        </ul>
      </div>
    </div>

    <!-- Home button always visible -->
    <div class="nav-footer">
      <router-link to="/" class="nav-home" :title="collapsed ? 'Home' : ''">
        <span class="nav-icon">🏠</span>
        <span v-if="!collapsed" class="nav-label">Home</span>
      </router-link>
    </div>
  </nav>
</template>

<script>
import authMixin from '../mixins/auth'

export default {
  name: 'Navigation',
  mixins: [authMixin],
  data() {
    return {
      collapsed: false
    }
  },
  computed: {
    isSuperAdmin() {
      return this.user && this.user.role === 'super-admin'
    }
  },
  methods: {
    toggleCollapse() {
      this.collapsed = !this.collapsed
      // Store preference in localStorage
      localStorage.setItem('navCollapsed', this.collapsed.toString())
      // Emit collapse change event
      this.$emit('collapse-change', this.collapsed)
    },
    logout() {
      this.$emit('logout')
    }
  },
  mounted() {
    // Restore collapse state from localStorage
    const savedState = localStorage.getItem('navCollapsed')
    if (savedState !== null) {
      this.collapsed = savedState === 'true'
    }
  }
}
</script>

<style scoped>
.navigation {
  width: 280px;
  height: 100vh;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-right: 2px solid rgba(76, 175, 80, 0.2);
  display: flex;
  flex-direction: column;
  transition: width 0.3s ease;
  position: fixed;
  left: 0;
  top: 0;
  z-index: 1000;
  box-shadow: 2px 0 8px rgba(0, 0, 0, 0.1);
}

.navigation-collapsed {
  width: 60px;
}

.nav-header {
  padding: 1rem;
  border-bottom: 1px solid rgba(76, 175, 80, 0.1);
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.nav-toggle {
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 6px;
  color: #666;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.nav-toggle:hover {
  background: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
}

.nav-toggle-icon {
  font-size: 1.2rem;
  font-weight: bold;
}

.nav-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.nav-logo {
  width: 24px;
  height: 24px;
  object-fit: contain;
}

.nav-text {
  font-weight: 700;
  color: #4CAF50;
  font-size: 1.2rem;
}

.nav-content {
  flex: 1;
  padding: 1rem 0;
  overflow-y: auto;
}

.nav-section {
  margin-bottom: 2rem;
}

.nav-section-title {
  padding: 0 1rem;
  font-size: 0.8rem;
  font-weight: 600;
  color: #666;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 0.5rem;
}

.nav-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.nav-item {
  margin: 0.25rem 0;
}

.nav-link {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem 1rem;
  color: #333;
  text-decoration: none;
  border-radius: 0 8px 8px 0;
  transition: all 0.2s ease;
  margin-right: 0.5rem;
}

.nav-link:hover {
  background: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
}

.nav-link.active {
  background: #4CAF50;
  color: white;
}

.nav-icon {
  font-size: 1.2rem;
  min-width: 1.2rem;
  text-align: center;
}

.nav-label {
  font-weight: 500;
  white-space: nowrap;
}

.nav-user-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem 1rem;
  color: #333;
}

.nav-user-details {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.nav-user-name {
  font-weight: 600;
  font-size: 0.9rem;
}

.nav-user-role {
  font-size: 0.75rem;
  color: #666;
  text-transform: capitalize;
}

.nav-logout {
  background: none;
  border: none;
  cursor: pointer;
  width: 100%;
  text-align: left;
  font-family: inherit;
  font-size: inherit;
}

.nav-logout:hover {
  background: rgba(244, 67, 54, 0.1);
  color: #f44336;
}

.nav-footer {
  padding: 1rem;
  border-top: 1px solid rgba(76, 175, 80, 0.1);
}

.nav-home {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  color: #333;
  text-decoration: none;
  border-radius: 6px;
  transition: all 0.2s ease;
}

.nav-home:hover {
  background: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
}

/* Responsive design */
@media (max-width: 768px) {
  .navigation {
    width: 60px;
  }
  
  .navigation:not(.navigation-collapsed) {
    width: 280px;
  }
}

/* Scrollbar styling */
.nav-content::-webkit-scrollbar {
  width: 4px;
}

.nav-content::-webkit-scrollbar-track {
  background: transparent;
}

.nav-content::-webkit-scrollbar-thumb {
  background: rgba(76, 175, 80, 0.3);
  border-radius: 2px;
}

.nav-content::-webkit-scrollbar-thumb:hover {
  background: rgba(76, 175, 80, 0.5);
}
</style> 