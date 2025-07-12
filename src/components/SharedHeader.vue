<template>
  <header class="shared-header">
    <div class="header-left">
      <button @click="goToMain" class="brick-logo-btn" title="Back to Main Page">
        <div class="brick-logo">
          <img src="/favicon.png" alt="Brick Logo" class="brick-icon-img" />
          <span class="brick-text">BRICK</span>
        </div>
      </button>
      <h1 class="page-title">{{ title }}</h1>
    </div>
    <div class="header-right">
      <div class="header-controls">
        <slot name="controls"></slot>
      </div>
      <AvatarDropdown :isAuthenticated="isAuthenticated" :user="user" @logout="logout" />
    </div>
  </header>
</template>

<script>
import AvatarDropdown from './AvatarDropdown.vue'
import authMixin from '../mixins/auth'

export default {
  name: 'SharedHeader',
  props: {
    title: {
      type: String,
      required: true
    }
  },
  mixins: [authMixin],
  components: {
    AvatarDropdown
  },
  methods: {
    goToMain() {
      this.$router.push('/')
    }
  }
}
</script>

<style scoped>
/* Header Styles */
.shared-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.25rem 0.75rem;
  min-height: 28px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(8px);
  border-bottom: 2px solid rgba(76, 175, 80, 0.4);
  box-shadow: 0 1px 6px rgba(0, 0, 0, 0.07);
  flex-shrink: 0;
  position: relative;
  z-index: 11000;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.brick-logo-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 8px;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
}

.brick-logo-btn:hover {
  background: rgba(76, 175, 80, 0.1);
  transform: scale(1.05);
}

.brick-logo {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.brick-icon-img {
  width: 1.5rem;
  height: 1.5rem;
  object-fit: contain;
}

.brick-text {
  font-weight: 700;
  color: #2c3e50;
  font-size: 0.9rem;
  letter-spacing: 0.5px;
}

.page-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: #2c3e50;
  margin: 0;
  letter-spacing: 0.3px;
}

.header-controls {
  display: flex;
  align-items: center;
  gap: 1rem;
}

/* Responsive Design */
@media (max-width: 768px) {
  .page-title {
    font-size: 1rem;
  }
  
  .header-left {
    gap: 1rem;
  }
  
  .header-right {
    gap: 1rem;
  }
  
  .header-controls {
    display: none;
  }
}
</style> 