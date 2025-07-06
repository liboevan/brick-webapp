<template>
  <div class="dashboard">
    <!-- Header -->
    <header class="dashboard-header">
      <div class="header-content">
        <h1 class="dashboard-title">{{ config.title }}</h1>
        <p class="dashboard-subtitle">{{ config.subtitle }}</p>
        <div class="system-status">
          <span class="status-indicator" :class="config.system.status"></span>
          <span class="status-text">{{ config.system.name }} v{{ config.system.version }}</span>
        </div>
        <div class="user-info">
          <span class="user-name">Welcome, Guest</span>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="dashboard-main">
      <div class="features-grid">
        <div 
          v-for="feature in enabledFeatures" 
          :key="feature.id"
          class="feature-card"
          :style="feature.id === 'ntp' ? '--card-color: #388E3C' : `--card-color: ${feature.color}`"
          @click="navigateToFeature(feature)"
        >
          <div class="feature-icon">{{ feature.icon }}</div>
          <div class="feature-content">
            <h3 class="feature-title">{{ feature.title }}</h3>
            <p class="feature-description">{{ feature.description }}</p>
          </div>
          <div class="feature-arrow">→</div>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="quick-actions">
        <h2 class="section-title">Quick Actions</h2>
        <div class="actions-grid">
          <button class="action-btn" @click="refreshStatus">
            <span class="action-icon">🔄</span>
            <span>Refresh Status</span>
          </button>
          <button class="action-btn" @click="showSystemInfo">
            <span class="action-icon">ℹ️</span>
            <span>System Info</span>
          </button>
        </div>
      </div>
    </main>

    <!-- Footer -->
    <footer class="dashboard-footer">
      <p>&copy; 2024 Brick System. Built with modular architecture.</p>
    </footer>
  </div>
</template>

<script>
import { getConfig } from '../config/dashboard.js'

export default {
  name: 'Dashboard',
  data() {
    return {
      config: getConfig()
    }
  },
  computed: {
    enabledFeatures() {
      return this.config.features.filter(feature => feature.enabled)
    }
  },
  mounted() {
    // Ensure auth state is up to date
    this.checkAuth && this.checkAuth()
  },
  methods: {
    navigateToFeature(feature) {
      // 直接跳转到 feature.url
      if (feature.url) {
        this.$router.push(feature.url)
      } else {
        alert(`Feature: ${feature.title}\nURL: ${feature.url}\n\nThis would navigate to the actual feature.`)
      }
    },
    refreshStatus() {
      // Implement status refresh logic
      console.log('Refreshing system status...')
    },
    showSystemInfo() {
      // Implement system info display
      console.log('Showing system information...')
    }
  }
}
</script>

<style scoped>
.dashboard {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* Header Styles */
.dashboard-header {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  padding: 2rem 0;
  text-align: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
}

.header-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
}

.dashboard-title {
  font-size: 3rem;
  font-weight: 700;
  color: var(--white);
  margin-bottom: 0.5rem;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.dashboard-subtitle {
  font-size: 1.2rem;
  color: rgba(255, 255, 255, 0.9);
  margin-bottom: 1rem;
}

.system-status {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  font-size: 0.9rem;
  color: rgba(255, 255, 255, 0.8);
}

.user-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-top: 1rem;
}

.user-name {
  color: rgba(255, 255, 255, 0.9);
  font-size: 0.9rem;
}

.logout-btn {
  background: rgba(255, 255, 255, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.3);
  color: var(--white);
  padding: 0.5rem 1rem;
  border-radius: var(--border-radius);
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 0.8rem;
}

.logout-btn:hover {
  background: rgba(255, 255, 255, 0.3);
}

.status-indicator {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #4CAF50;
  animation: pulse 2s infinite;
}

.status-indicator.online {
  background: #4CAF50;
}

.status-indicator.offline {
  background: #f44336;
}

@keyframes pulse {
  0% { opacity: 1; }
  50% { opacity: 0.5; }
  100% { opacity: 1; }
}

/* Main Content */
.dashboard-main {
  flex: 1;
  max-width: 1200px;
  margin: 0 auto;
  padding: 3rem 2rem;
  width: 100%;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  margin-bottom: 3rem;
}

.feature-card {
  background: var(--white);
  border-radius: var(--border-radius);
  padding: 2rem;
  box-shadow: var(--shadow);
  cursor: pointer;
  transition: all 0.3s ease;
  border-left: 4px solid var(--card-color);
  display: flex;
  align-items: center;
  gap: 1rem;
  position: relative;
  overflow: hidden;
}

.feature-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.feature-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: var(--card-color);
}

.feature-icon {
  font-size: 2.5rem;
  flex-shrink: 0;
}

.feature-content {
  flex: 1;
}

.feature-title {
  font-size: 1.3rem;
  font-weight: 600;
  color: var(--dark-gray);
  margin-bottom: 0.5rem;
}

.feature-description {
  color: #666;
  font-size: 0.9rem;
  line-height: 1.4;
}

.feature-arrow {
  font-size: 1.5rem;
  color: var(--card-color);
  font-weight: bold;
  transition: transform 0.3s ease;
}

.feature-card:hover .feature-arrow {
  transform: translateX(4px);
}

/* Quick Actions */
.quick-actions {
  background: rgba(255, 255, 255, 0.1);
  border-radius: var(--border-radius);
  padding: 2rem;
  backdrop-filter: blur(10px);
}

.section-title {
  color: var(--white);
  font-size: 1.5rem;
  margin-bottom: 1.5rem;
  text-align: center;
}

.actions-grid {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

.action-btn {
  background: rgba(255, 255, 255, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.3);
  color: var(--white);
  padding: 0.75rem 1.5rem;
  border-radius: var(--border-radius);
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
}

.action-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-2px);
}

.action-icon {
  font-size: 1.1rem;
}

/* Footer */
.dashboard-footer {
  background: rgba(0, 0, 0, 0.1);
  color: rgba(255, 255, 255, 0.7);
  text-align: center;
  padding: 1rem;
  font-size: 0.9rem;
}

/* Responsive Design */
@media (max-width: 768px) {
  .dashboard-title {
    font-size: 2rem;
  }
  
  .features-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .feature-card {
    padding: 1.5rem;
  }
  
  .actions-grid {
    flex-direction: column;
    align-items: center;
  }
  
  .action-btn {
    width: 200px;
    justify-content: center;
  }
}
</style> 