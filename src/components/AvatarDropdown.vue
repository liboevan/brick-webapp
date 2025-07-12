<template>
  <div class="avatar-dropdown" @click="toggleDropdown" @blur="closeDropdown" tabindex="0">
    <div class="avatar" :title="isAuthenticated ? fullName : 'Not logged in'">
      <template v-if="isAuthenticated">
        <img v-if="user && user.avatarUrl" :src="user.avatarUrl" alt="avatar" />
        <span v-else>{{ initials }}</span>
      </template>
      <template v-else>
        <span class="avatar-icon">👤</span>
      </template>
    </div>
    <div v-if="dropdownOpen" class="dropdown-menu">
      <template v-if="isAuthenticated">
        <div class="dropdown-header">
          <span class="dropdown-username">{{ fullName }}</span>
        </div>
        <div class="dropdown-item" @click="goProfile">
          <span class="dropdown-icon">👤</span> Profile
        </div>
        <div class="dropdown-item" @click="logout">
          <span class="dropdown-icon">🚪</span> Logout
        </div>
      </template>
      <template v-else>
        <div class="dropdown-item" @click="goLogin">
          <span class="dropdown-icon">🔑</span> Login
        </div>
      </template>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AvatarDropdown',
  props: {
    isAuthenticated: Boolean,
    user: Object
  },
  data() {
    return {
      dropdownOpen: false
    }
  },
  computed: {
    initials() {
      if (!this.user) return '👤'
      
      // Try to use first_name and last_name if available
      if (this.user.first_name && this.user.last_name) {
        return (this.user.first_name[0] + this.user.last_name[0]).toUpperCase()
      }
      
      // Fallback to username
      if (this.user.username) {
        return this.user.username.split(' ').map(n => n[0]).join('').toUpperCase()
      }
      
      return '👤'
    },
    
    fullName() {
      if (!this.user) return 'Guest'
      
      if (this.user.first_name && this.user.last_name) {
        return `${this.user.first_name} ${this.user.last_name}`
      }
      
      return this.user.username || 'Guest'
    }
  },
  methods: {
    toggleDropdown() {
      this.dropdownOpen = !this.dropdownOpen
    },
    closeDropdown() {
      this.dropdownOpen = false
    },
    goProfile() {
      this.$router.push('/profile')
      this.closeDropdown()
    },
    goLogin() {
      this.$router.push('/login')
      this.closeDropdown()
    },
    logout() {
      this.$emit('logout')
      this.closeDropdown()
    }
  }
}
</script>

<style scoped>
.avatar-dropdown {
  position: relative;
  display: inline-block;
  outline: none;
  z-index: 9999;
}
.avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: #e0e0e0;
  color: #333;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 1.1rem;
  cursor: pointer;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  overflow: hidden;
}
.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;
}
.avatar-icon {
  font-size: 1.2rem;
}
.dropdown-menu {
  position: absolute;
  right: 0;
  top: 44px;
  min-width: 140px;
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.13);
  z-index: 10000;
  padding: 0.5rem 0;
  animation: fadeIn 0.2s;
}
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(-8px);}
  to { opacity: 1; transform: translateY(0);}
}
.dropdown-header {
  padding: 0.5rem 1rem;
  font-weight: 600;
  color: #333;
  border-bottom: 1px solid #eee;
}
.dropdown-item {
  padding: 0.5rem 1rem;
  cursor: pointer;
  color: #333;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  transition: background 0.15s;
}
.dropdown-item:hover {
  background: #f5f5f5;
}
</style> 