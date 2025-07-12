<template>
  <div class="floating-navigation" 
       @mouseenter="handleMouseEnter" 
       @mouseleave="handleMouseLeave">
    <!-- Navigation Ball -->
    <div class="nav-ball" :class="{ expanded: showMenu }">
      <span class="nav-icon">⚙️</span>
    </div>
    
    <!-- Expanded Menu -->
    <div v-if="showMenu" class="nav-menu" :class="{ expanded: showMenu }">
      <div class="menu-grid">
        <!-- NTP Service -->
        <router-link to="/ntp" class="menu-item" @click="hideMenu">
          <div class="item-icon">⏰</div>
          <div class="item-label">NTP</div>
        </router-link>
        
        <!-- Admin Management (Super Admin Only) -->
        <router-link 
          v-if="isSuperAdmin" 
          to="/admin" 
          class="menu-item" 
          @click="hideMenu"
        >
          <div class="item-icon">🔧</div>
          <div class="item-label">Admin</div>
        </router-link>
        
        <!-- Dashboard -->
        <router-link to="/" class="menu-item" @click="hideMenu">
          <div class="item-icon">📊</div>
          <div class="item-label">Dashboard</div>
        </router-link>
      </div>
    </div>
  </div>
</template>

<script>
import authMixin from '../mixins/auth.js'

export default {
  name: 'FloatingNavigation',
  mixins: [authMixin],
  data() {
    return {
      showMenu: false,
      hideTimeout: null
    }
  },
  computed: {
    isSuperAdmin() {
      return this.user && this.user.role === 'super-admin'
    }
  },
  methods: {
    handleMouseEnter() {
      // Clear any pending hide timeout
      if (this.hideTimeout) {
        clearTimeout(this.hideTimeout)
        this.hideTimeout = null
      }
      this.showMenu = true
    },
    
    handleMouseLeave() {
      // Add delay before hiding menu to prevent accidental closing
      this.hideTimeout = setTimeout(() => {
        this.showMenu = false
      }, 300) // 300ms delay
    },
    
    hideMenu() {
      this.showMenu = false
      if (this.hideTimeout) {
        clearTimeout(this.hideTimeout)
        this.hideTimeout = null
      }
    },
    
    handleLogout() {
      this.$emit('logout')
    }
  },
  
  beforeUnmount() {
    // Clean up timeout on component destruction
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout)
    }
  }
}
</script>

<style scoped>
.floating-navigation {
  position: relative;
  display: flex;
  align-items: center;
}

.nav-ball {
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3);
  position: relative;
  z-index: 1000;
}

.nav-ball:hover {
  transform: scale(1.1);
  box-shadow: 0 6px 20px rgba(76, 175, 80, 0.4);
}

.nav-ball.expanded {
  transform: scale(1.1);
  box-shadow: 0 6px 20px rgba(76, 175, 80, 0.4);
}

.nav-icon {
  font-size: 1.2rem;
  color: white;
  transition: transform 0.3s ease;
}

.nav-ball:hover .nav-icon {
  transform: rotate(90deg);
}

.nav-menu {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 0.5rem;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
  border: 1px solid rgba(255, 255, 255, 0.2);
  padding: 0.75rem;
  min-width: 200px;
  z-index: 999;
  opacity: 0;
  transform: translateY(-10px) scale(0.9);
  transition: all 0.3s ease;
  pointer-events: none;
}

.nav-menu.expanded {
  opacity: 1;
  transform: translateY(0) scale(1);
  pointer-events: all;
}

/* Extended hover area for better control */
.nav-menu::before {
  content: '';
  position: absolute;
  top: -10px;
  left: -10px;
  right: -10px;
  bottom: -10px;
  z-index: -1;
}

.menu-grid {
  display: grid;
  gap: 0.5rem;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  border-radius: 8px;
  text-decoration: none;
  color: #2c3e50;
  transition: all 0.3s ease;
  font-weight: 500;
}

.menu-item:hover {
  background: rgba(76, 175, 80, 0.1);
  transform: translateX(4px);
}

.item-icon {
  font-size: 1.2rem;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.item-label {
  font-size: 0.9rem;
  font-weight: 600;
}

/* Responsive Design */
@media (max-width: 768px) {
  .nav-ball {
    width: 36px;
    height: 36px;
  }
  
  .nav-icon {
    font-size: 1rem;
  }
  
  .nav-menu {
    min-width: 180px;
  }
}
</style> 