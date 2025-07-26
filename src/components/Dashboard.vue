<template>
  <Layout>
    <!-- Page Title in Header -->
    <template #pageTitle>
      <h1 class="page-title">Dashboard</h1>
    </template>
    
    <!-- Page Controls in Header -->
    <template #pageControls>
      <div class="dashboard-info">
        <span class="welcome-text">Welcome back, {{ user?.username || 'Guest' }}!</span>
        <span class="last-login">Last login: {{ lastLoginTime }}</span>
      </div>
    </template>
    
    <!-- Main Content -->
    <div class="dashboard">
      <!-- Quick Stats -->
      <div class="stats-grid">
        
        <div class="stat-card">
          <div class="stat-icon">👥</div>
          <div class="stat-content">
            <div class="stat-value">{{ stats.activeUsers || 0 }}</div>
            <div class="stat-label">Active Users</div>
          </div>
        </div>
        
        <div class="stat-card">
          <div class="stat-icon">🔐</div>
          <div class="stat-content">
            <div class="stat-value">{{ stats.totalRoles || 0 }}</div>
            <div class="stat-label">Roles</div>
          </div>
        </div>
        
        <div class="stat-card">
          <div class="stat-icon">🔑</div>
          <div class="stat-content">
            <div class="stat-value">{{ stats.totalPermissions || 0 }}</div>
            <div class="stat-label">Permissions</div>
          </div>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="quick-actions">
        <h2>Quick Actions</h2>
        <div class="actions-grid">
          
          <router-link v-if="isSuperAdmin" to="/admin" class="action-card">
            <div class="action-icon">🔧</div>
            <div class="action-content">
              <h3>Admin Panel</h3>
              <p>Manage users, roles, and permissions</p>
            </div>
          </router-link>
          
          <div class="action-card">
            <div class="action-icon">📊</div>
            <div class="action-content">
              <h3>System Status</h3>
              <p>View system health and performance</p>
            </div>
          </div>
          
          <div class="action-card">
            <div class="action-icon">⚙️</div>
            <div class="action-content">
              <h3>Settings</h3>
              <p>Configure application preferences</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Recent Activity -->
      <div class="recent-activity">
        <h2>Recent Activity</h2>
        <div class="activity-list">
          <div v-for="activity in recentActivities" :key="activity.id" class="activity-item">
            <div class="activity-icon" :class="activity.type">{{ activity.icon }}</div>
            <div class="activity-content">
              <div class="activity-title">{{ activity.title }}</div>
              <div class="activity-time">{{ formatTime(activity.timestamp) }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </Layout>
</template>

<script>
import authMixin from '../mixins/auth'
import Layout from './Layout.vue'

export default {
  name: 'Dashboard',
  mixins: [authMixin],
  components: {
    Layout
  },
  data() {
    return {
      stats: {
        activeUsers: 5,
        totalRoles: 3,
        totalPermissions: 12
      },
      lastLoginTime: new Date().toLocaleString(),
      recentActivities: [
        {
          id: 2,
          type: 'info',
          icon: '👤',
          title: 'User login: admin',
          timestamp: new Date(Date.now() - 600000) // 10 minutes ago
        },
        {
          id: 3,
          type: 'warning',
          icon: '⚠️',
          title: 'System backup completed',
          timestamp: new Date(Date.now() - 1800000) // 30 minutes ago
        },
        {
          id: 4,
          type: 'info',
          icon: '🔧',
          title: 'Configuration updated',
          timestamp: new Date(Date.now() - 3600000) // 1 hour ago
        }
      ]
    }
  },
  computed: {
    isSuperAdmin() {
      return this.user && this.user.role === 'super-admin'
    }
  },
  mounted() {
    // Set browser title
    document.title = 'Brick - Dashboard'
  },
  methods: {
    formatTime(timestamp) {
      const now = new Date()
      const diff = now - timestamp
      const minutes = Math.floor(diff / 60000)
      const hours = Math.floor(diff / 3600000)
      const days = Math.floor(diff / 86400000)
      
      if (minutes < 1) return 'Just now'
      if (minutes < 60) return `${minutes}m ago`
      if (hours < 24) return `${hours}h ago`
      return `${days}d ago`
    }
  }
}
</script>

<style scoped>
.dashboard {
  padding: 1rem;
  background: #f5f5f5;
  min-height: calc(100vh - 80px);
}

/* Page Title Styles */
.page-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--primary-green);
  margin: 0;
}

/* Dashboard Info Styles */
.dashboard-info {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 0.25rem;
  margin-left: auto;
  padding-right: 1rem;
  min-height: 1.5rem;
  justify-content: center;
}

.welcome-text {
  color: #4CAF50;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  background: rgba(76, 175, 80, 0.1);
  padding: 0.2rem 0.5rem;
  border-radius: 12px;
  white-space: nowrap;
}

.last-login {
  color: #6c757d;
  font-size: 0.75rem;
  font-weight: 500;
  white-space: nowrap;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 12px;
  padding: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
}

.stat-icon {
  font-size: 2rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
  color: white;
  border-radius: 12px;
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #2c3e50;
  margin-bottom: 0.25rem;
}

.stat-label {
  color: #6c757d;
  font-size: 0.9rem;
  font-weight: 500;
}

/* Quick Actions */
.quick-actions {
  margin-bottom: 2rem;
}

.quick-actions h2 {
  color: #2c3e50;
  font-size: 1.25rem;
  margin-bottom: 1rem;
  font-weight: 600;
}

.actions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1rem;
}

.action-card {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 12px;
  padding: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  text-decoration: none;
  color: inherit;
}

.action-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
  background: rgba(255, 255, 255, 1);
}

.action-icon {
  font-size: 2rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
  color: white;
  border-radius: 12px;
}

.action-content h3 {
  color: #2c3e50;
  font-size: 1.1rem;
  margin: 0 0 0.5rem 0;
  font-weight: 600;
}

.action-content p {
  color: #6c757d;
  font-size: 0.9rem;
  margin: 0;
  line-height: 1.4;
}

/* Recent Activity */
.recent-activity h2 {
  color: #2c3e50;
  font-size: 1.25rem;
  margin-bottom: 1rem;
  font-weight: 600;
}

.activity-list {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 12px;
  padding: 1rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.activity-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  border-bottom: 1px solid #e9ecef;
  transition: background-color 0.3s ease;
}

.activity-item:last-child {
  border-bottom: none;
}

.activity-item:hover {
  background: rgba(76, 175, 80, 0.05);
}

.activity-icon {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
  font-size: 1.2rem;
}

.activity-icon.success {
  background: rgba(76, 175, 80, 0.2);
  color: #4CAF50;
}

.activity-icon.info {
  background: rgba(33, 150, 243, 0.2);
  color: #2196F3;
}

.activity-icon.warning {
  background: rgba(255, 152, 0, 0.2);
  color: #FF9800;
}

.activity-content {
  flex: 1;
}

.activity-title {
  color: #2c3e50;
  font-weight: 500;
  margin-bottom: 0.25rem;
}

.activity-time {
  color: #6c757d;
  font-size: 0.8rem;
}

/* Responsive Design */
@media (max-width: 768px) {
  .dashboard {
    padding: 0.5rem;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .actions-grid {
    grid-template-columns: 1fr;
  }
  
  .stat-card,
  .action-card {
    padding: 1rem;
  }
  
  .stat-icon,
  .action-icon {
    width: 50px;
    height: 50px;
    font-size: 1.5rem;
  }
  
  .dashboard-info {
    display: none;
  }
}
</style>