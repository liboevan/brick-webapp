<template>
  <header class="app-header">
    <div class="header-content">
      <!-- Left side - Logo and Title -->
      <div class="header-left">
        <router-link to="/" class="logo-link">
          <img src="/favicon.png" alt="Brick" class="logo-icon" />
          <span class="logo-text">Brick Hub</span>
        </router-link>
        
        <!-- Page Title Slot -->
        <div v-if="$slots.pageTitle" class="page-title-section">
          <slot name="pageTitle" />
        </div>
      </div>

      <!-- Center - Page Controls Slot -->
      <div v-if="$slots.pageControls" class="header-center">
        <slot name="pageControls" />
      </div>

      <!-- Right side - User Avatar and Navigation -->
      <div class="header-right">
        <!-- User Avatar with Tooltip -->
        <div class="user-avatar-container" 
             @mouseenter="handleAvatarMouseEnter"
             @mouseleave="handleAvatarMouseLeave">
          <div class="user-avatar" :title="user?.first_name && user?.last_name ? `${user.first_name} ${user.last_name}` : user?.username || 'Guest'">
            <img 
              v-if="user?.avatarUrl" 
              :src="user.avatarUrl" 
              alt="avatar" 
              class="avatar-image"
            />
            <span v-else class="avatar-initials">{{ userInitials }}</span>
          </div>
          
          <!-- User Info Tooltip -->
          <div class="user-tooltip" :class="{ visible: showAvatarTooltip }">
            <div class="tooltip-content">
              <div class="tooltip-user-info">
                <div class="tooltip-full-name">{{ user?.first_name }} {{ user?.last_name }}</div>
                <div class="tooltip-username">{{ user?.username || 'Guest' }}</div>
                <div class="tooltip-role">{{ user?.role || 'Guest' }}</div>
              </div>
              <div class="tooltip-actions">
                <button v-if="isAuthenticated" @click="handleLogout" class="tooltip-logout-btn">
                  <span class="logout-icon">🚪</span>
                  <span>Logout</span>
                </button>
                <button v-else @click="handleLogin" class="tooltip-login-btn">
                  <span class="login-icon">🔑</span>
                  <span>Login</span>
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Navigation Ball -->
        <FloatingNavigation @logout="handleLogout" />
      </div>
    </div>
  </header>
</template>

<script>
import FloatingNavigation from './FloatingNavigation.vue'
import authMixin from '../mixins/auth.js'

export default {
  name: 'Header',
  components: {
    FloatingNavigation
  },
  mixins: [authMixin],
  data() {
    return {
      showAvatarTooltip: false,
      avatarHideTimeout: null
    }
  },
  computed: {
    userInitials() {
      if (!this.user) return '👤'
      
      // Try to use first_name and last_name if available
      if (this.user.first_name && this.user.last_name) {
        return (this.user.first_name[0] + this.user.last_name[0]).toUpperCase()
      }
      
      // Fallback to username
      if (this.user.username) {
        return this.user.username
          .split(' ')
          .map(n => n[0])
          .join('')
          .toUpperCase()
          .slice(0, 2)
      }
      
      return '👤'
    }
  },
  methods: {
    handleAvatarMouseEnter() {
      // Clear any pending hide timeout
      if (this.avatarHideTimeout) {
        clearTimeout(this.avatarHideTimeout)
        this.avatarHideTimeout = null
      }
      this.showAvatarTooltip = true
    },
    
    handleAvatarMouseLeave() {
      // Add delay before hiding tooltip to prevent accidental closing
      this.avatarHideTimeout = setTimeout(() => {
        this.showAvatarTooltip = false
      }, 300) // 300ms delay
    },
    
    handleLogout() {
      this.logout()
    },

    handleLogin() {
      // Navigate to login page with current page as redirect
      this.$router.push({
        path: '/login',
        query: { redirect: this.$route.fullPath }
      })
      this.showAvatarTooltip = false
    }
  },
  
  beforeUnmount() {
    // Clean up timeout on component destruction
    if (this.avatarHideTimeout) {
      clearTimeout(this.avatarHideTimeout)
    }
  }
}
</script>

<style scoped>
.app-header {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-bottom: 2px solid rgba(76, 175, 80, 0.2);
  padding: 0.5rem 1.5rem;
  box-shadow: 0 1px 6px rgba(0, 0, 0, 0.07);
  position: sticky;
  top: 0;
  z-index: 100;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1400px;
  margin: 0 auto;
  gap: 1rem;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 2rem;
  flex: 1;
}

.logo-link {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  text-decoration: none;
  color: inherit;
  transition: all 0.3s ease;
  flex-shrink: 0;
}

.logo-link:hover {
  transform: scale(1.05);
}

.logo-icon {
  width: 2rem;
  height: 2rem;
  object-fit: contain;
}

.logo-text {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--primary-green);
}

/* Page Title Section */
.page-title-section {
  display: flex;
  align-items: center;
  gap: 1rem;
}

/* Header Center */
.header-center {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  flex: 1;
  padding-right: 1rem;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex-shrink: 0;
  min-width: 120px;
  justify-content: flex-end;
}

/* User Avatar Styles */
.user-avatar-container {
  position: relative;
  display: flex;
  align-items: center;
}

.user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 8px rgba(76, 175, 80, 0.2);
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
}

.user-avatar:hover {
  transform: scale(1.1);
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3);
}

.avatar-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;
}

.avatar-initials {
  color: white;
  font-weight: 600;
  font-size: 1rem;
  text-align: center;
}

/* User Tooltip */
.user-tooltip {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 0.5rem;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
  border: 1px solid rgba(255, 255, 255, 0.2);
  padding: 1rem;
  min-width: 200px;
  z-index: 1000;
  opacity: 0;
  transform: translateY(-10px) scale(0.9);
  transition: all 0.3s ease;
  pointer-events: none;
}

.user-tooltip.visible {
  opacity: 1;
  transform: translateY(0) scale(1);
  pointer-events: all;
}

/* Extended hover area for better control */
.user-tooltip::before {
  content: '';
  position: absolute;
  top: -15px;
  left: -15px;
  right: -15px;
  bottom: -15px;
  z-index: -1;
}

.tooltip-content {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.tooltip-user-info {
  text-align: center;
  padding-bottom: 0.75rem;
  border-bottom: 1px solid #e9ecef;
}

.tooltip-full-name {
  font-size: 1rem;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 0.25rem;
}

.tooltip-username {
  font-size: 0.9rem;
  color: #6c757d;
  margin-bottom: 0.25rem;
}

.tooltip-role {
  font-size: 0.8rem;
  color: #6c757d;
  text-transform: capitalize;
}

.tooltip-actions {
  display: flex;
  justify-content: center;
}

.tooltip-logout-btn {
  background: #f44336;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
  font-weight: 500;
}

.tooltip-logout-btn:hover {
  background: #d32f2f;
  transform: translateY(-1px);
}

.logout-icon {
  font-size: 1rem;
}

.tooltip-login-btn {
  background: #4CAF50;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
  font-weight: 500;
}

.tooltip-login-btn:hover {
  background: #388e3c;
  transform: translateY(-1px);
}

.login-icon {
  font-size: 1rem;
}

/* Responsive Design */
@media (max-width: 1024px) {
  .header-left {
    gap: 1rem;
  }
  
  .page-title-section {
    gap: 0.5rem;
  }
}

@media (max-width: 768px) {
  .app-header {
    padding: 0.5rem 1rem;
  }

  .header-content {
    gap: 0.5rem;
  }

  .header-left {
    gap: 0.75rem;
  }

  .logo-text {
    font-size: 1.2rem;
  }

  .header-right {
    gap: 0.75rem;
    min-width: 100px;
  }

  .user-avatar {
    width: 36px;
    height: 36px;
  }

  .avatar-initials {
    font-size: 0.9rem;
  }
  
  .header-center {
    display: none;
  }
}

@media (max-width: 480px) {
  .logo-text {
    display: none;
  }

  .header-right {
    gap: 0.5rem;
    min-width: 80px;
  }
  
  .page-title-section {
    display: none;
  }
}
</style> 