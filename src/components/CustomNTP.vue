<template>
  <Layout>
    <!-- Page Title in Header -->
    <template #pageTitle>
      <h1 class="page-title">NTP Time Synchronization</h1>
    </template>
    
    <!-- Page Controls in Header -->
    <template #pageControls>
      <div class="auto-refresh">
        <label class="refresh-toggle">
          <input type="checkbox" v-model="autoRefresh" @change="toggleAutoRefresh">
          <span class="toggle-slider"></span>
          Auto Refresh
        </label>
        <span class="last-update">Last updated: {{ lastUpdateTime }}</span>
      </div>
    </template>
    
    <!-- Main Content -->
    <div class="custom-ntp">
      <div class="ntp-content ntp-grid">
        <!-- 左上：Status Overview -->
        <div class="status-section compact">
          <h2 class="section-title">Status Overview</h2>
          <div class="status-cards">
            <div class="status-card primary" :class="getSyncStatusClass()">
              <div class="status-icon">⏰</div>
              <div class="status-info">
                <div class="status-label">Sync Status</div>
                <div class="status-value">{{ getSyncStatusText() }}</div>
              </div>
            </div>
            <div class="status-card">
              <div class="status-icon">📍</div>
              <div class="status-info">
                <div class="status-label">Stratum</div>
                <div class="status-value">{{ status.tracking?.Stratum || 'Unknown' }}</div>
              </div>
            </div>
            <div class="status-card">
              <div class="status-icon">📡</div>
              <div class="status-info">
                <div class="status-label">Active Sources</div>
                <div class="status-value">{{ getActiveSourcesCount() }}</div>
              </div>
            </div>
            <div class="status-card">
              <div class="status-icon">⚡</div>
              <div class="status-info">
                <div class="status-label">Frequency</div>
                <div class="status-value">{{ status.tracking?.Frequency || 'Unknown' }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- 右上：Tracking Details -->
        <div class="tracking-section compact">
          <h2 class="section-title">Tracking Details</h2>
          <div class="tracking-list">
            <div class="tracking-item" v-for="(val, key) in trackingDisplayList" :key="key">
              <span class="tracking-label">{{ key }}:</span>
              <span class="tracking-value">{{ val }}</span>
            </div>
          </div>
        </div>

        <!-- 左下：NTP Sources -->
        <div class="sources-section">
          <h2 class="section-title">NTP Sources</h2>
          <div class="sources-container">
            <div v-if="status.sources && status.sources.length > 0" class="sources-list">
              <div v-for="(source, index) in status.sources" :key="index" class="source-item" :class="getSourceStatusClass(source)">
                <div class="source-header">
                  <span class="source-name">{{ source.name }}</span>
                  <span class="source-status" :class="getSourceStatusClass(source)">{{ getSourceStatusText(source) }}</span>
                </div>
                <div class="source-details">
                  <div class="detail-row">
                    <span class="detail-label">Stratum:</span>
                    <span class="detail-value">{{ source.stratum || 'N/A' }}</span>
                  </div>
                  <div class="detail-row">
                    <span class="detail-label">Offset:</span>
                    <span class="detail-value">{{ source.offset || 'N/A' }}</span>
                  </div>
                </div>
              </div>
            </div>
            <div v-else class="no-sources">
              <p>No NTP sources configured</p>
            </div>
          </div>
        </div>

        <!-- 右下：Activity + Server Mode + Buttons -->
        <div class="right-bottom-section">
          <!-- Activity Statistics -->
          <div class="activity-section compact">
            <h2 class="section-title">Activity Statistics</h2>
            <div class="activity-cards">
              <div class="activity-card success">
                <div class="activity-icon">✅</div>
                <div class="activity-info">
                  <div class="activity-label">Success</div>
                  <div class="activity-value">{{ status.activity?.ok_count || '0' }}</div>
                </div>
              </div>
              <div class="activity-card error">
                <div class="activity-icon">❌</div>
                <div class="activity-info">
                  <div class="activity-label">Failed</div>
                  <div class="activity-value">{{ status.activity?.failed_count || '0' }}</div>
                </div>
              </div>
              <div class="activity-card warning">
                <div class="activity-icon">⚠️</div>
                <div class="activity-info">
                  <div class="activity-label">Bogus</div>
                  <div class="activity-value">{{ status.activity?.bogus_count || '0' }}</div>
                </div>
              </div>
              <div class="activity-card timeout">
                <div class="activity-icon">⏱️</div>
                <div class="activity-info">
                  <div class="activity-label">Timeouts</div>
                  <div class="activity-value">{{ status.activity?.timeout_count || '0' }}</div>
                </div>
              </div>
            </div>
          </div>

          <!-- Bottom Right Row: Server Mode + Buttons -->
          <div class="bottom-right-row">
            <!-- Server Mode -->
            <div class="server-mode-section compact">
              <h2 class="section-title">Server Mode</h2>
              <div class="server-mode-content tight">
                <div class="mode-status">
                  <div class="status-indicator" :class="{ active: serverModeEnabled }">
                    <span class="indicator-dot"></span>
                    <span class="status-text">{{ serverModeEnabled ? 'ON' : 'OFF' }}</span>
                  </div>
                  <div class="mode-description">
                    {{ serverModeEnabled ? 'Accepting client connections' : 'Not accepting connections' }}
                  </div>
                  <div class="port-info">
                    <span class="port-label">Port:</span>
                    <span class="port-value" :class="{ disabled: !serverModeEnabled }">123/UDP</span>
                  </div>
                </div>
                <div class="mode-controls">
                  <button 
                    v-if="hasPermission('clock/server_mode') || isSuperAdmin()"
                    @click="toggleServerMode" 
                    :disabled="loading.serverMode"
                    class="mode-btn"
                    :class="{ enabled: serverModeEnabled, disabled: !serverModeEnabled }"
                  >
                    <span v-if="loading.serverMode" class="loading-spinner">⏳</span>
                    <span v-else>{{ serverModeEnabled ? 'Disable' : 'Enable' }}</span>
                  </button>
                  <button v-else class="mode-btn" disabled title="Requires clock/server_mode permission">
                    <span class="action-icon">🔒</span>
                    <span class="action-text">Server Mode (Locked)</span>
                  </button>
                </div>
              </div>
            </div>

            <!-- Action Buttons -->
            <div class="actions-section">
              <button 
                v-if="hasPermission('clock/view') || isSuperAdmin()"
                @click="openClientsModal" 
                class="quick-action-btn"
              >
                <span class="action-icon">👥</span>
                <span class="action-text">View Clients</span>
              </button>
              <button 
                v-else 
                class="quick-action-btn" 
                disabled 
                title="Requires clock/view permission"
              >
                <span class="action-icon">🔒</span>
                <span class="action-text">View Clients (Locked)</span>
              </button>
              
              <button 
                v-if="hasPermission('clock/servers') || isSuperAdmin()"
                @click="openServersModal" 
                class="quick-action-btn"
              >
                <span class="action-icon">📡</span>
                <span class="action-text">Server Manager</span>
              </button>
              <button 
                v-else 
                class="quick-action-btn" 
                disabled 
                title="Requires clock/servers permission"
              >
                <span class="action-icon">🔒</span>
                <span class="action-text">Server Manager (Locked)</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modals -->
    <NTPServerClientsModal
      v-if="showClientsModal"
      :serverModeEnabled="serverModeEnabled"
      @close="showClientsModal = false"
    />
    <NTPServersManagerModal
      v-if="showServersModal"
      @close="showServersModal = false"
    />
  </Layout>
</template>

<script>
import { getApiConfig } from '../config/dashboard.js'
import NTPServerClientsModal from './NTPServerClientsModal.vue'
import NTPServersManagerModal from './NTPServersManagerModal.vue'
import authMixin from '../mixins/auth'
import Layout from './Layout.vue'

export default {
  name: 'CustomNTP',
  mixins: [authMixin],
  components: {
    NTPServerClientsModal,
    NTPServersManagerModal,
    Layout
  },
  data() {
    return {
      status: {
        tracking: {},
        sources: [],
        activity: {}
      },
      loading: {
        status: false,
        serverMode: false
      },
      error: '',
      success: '',
      apiConfig: null,
      autoRefresh: true,
      refreshInterval: null,
      lastUpdateTime: 'Never',
      showVersionTooltip: false,
      serverModeEnabled: false,
      versionInfo: {
        version: '0.1.0-dev',
        buildDate: new Date().toISOString(),
        environment: 'development'
      },
      showClientsModal: false,
      showServersModal: false
    }
  },
  computed: {
    trackingDisplayList() {
      // 只显示常用的几个字段，顺序可调整
      const t = this.status.tracking || {};
      return {
        'Last Offset': t['Last offset'] || 'Unknown',
        'RMS Offset': t['RMS offset'] || 'Unknown',
        'System Time': t['System time'] || 'Unknown',
        'Update Interval': t['Update interval'] || 'Unknown',
        'Root Delay': t['Root delay'] || 'Unknown',
        'Root Dispersion': t['Root dispersion'] || 'Unknown',
        'Skew': t['Skew'] || 'Unknown',
        'Leap Status': t['Leap status'] || 'Unknown',
      }
    }
  },
  mounted() {
    this.apiConfig = getApiConfig()
    this.loadStatus()
    this.loadVersionInfo()
    this.startAutoRefresh()
    
    // Add click outside listener for version tooltip
    document.addEventListener('click', this.handleClickOutside)
  },
  beforeUnmount() {
    this.stopAutoRefresh()
    document.removeEventListener('click', this.handleClickOutside)
  },
  methods: {
    showVersionInfo() {
      this.showVersionTooltip = !this.showVersionTooltip
    },

    formatBuildDate(dateString) {
      if (!dateString) return 'Unknown'
      const date = new Date(dateString)
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    },

    handleClickOutside(event) {
      const versionInfo = this.$el.querySelector('.version-info')
      if (versionInfo && !versionInfo.contains(event.target)) {
        this.showVersionTooltip = false
      }
    },

    async loadVersionInfo() {
      try {
        const config = window.BRICK_CONFIG.api.customNTP
        const response = await fetch(`${config.baseUrl}${config.endpoints.version}`, {
          headers: this.getAuthHeaders()
        })
        if (response.ok) {
          const data = await response.json()
          console.log('Version response:', data)
          // The API returns: { version: "string", build_datetime: "string" }
          this.versionInfo = {
            version: data.version || '0.1.0-dev',
            buildDate: data.build_datetime || new Date().toISOString(),
            environment: 'production'
          }
        }
      } catch (err) {
        console.log('Failed to load version info, using defaults:', err.message)
      }
    },

    async toggleServerMode() {
      this.loading.serverMode = true
      try {
        const config = window.BRICK_CONFIG.api.customNTP
        const response = await fetch(`${config.baseUrl}${config.endpoints.serverMode}`, {
          method: 'PUT',
          headers: this.getAuthHeaders(),
          body: JSON.stringify({ enabled: !this.serverModeEnabled })
        })
        
        if (response.ok) {
          const data = await response.json()
          this.serverModeEnabled = data.server_mode_enabled
          this.success = `Server mode ${this.serverModeEnabled ? 'enabled' : 'disabled'} successfully`
        } else {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`)
        }
      } catch (err) {
        this.error = `Failed to toggle server mode: ${err.message}`
      } finally {
        this.loading.serverMode = false
      }
    },

    getUptime() {
      // Cannot get uptime from the API, so return N/A
      return 'N/A'
    },

    refreshStatus() {
      this.loadStatus()
    },

    resetConfiguration() {
      if (confirm('Are you sure you want to reset the NTP configuration to defaults?')) {
        // Reset functionality removed - no server management UI
        this.success = 'Reset functionality not implemented'
      }
    },

    showLogs() {
      // This would open a logs modal or navigate to logs page
      alert('Logs feature coming soon!')
    },

    openAdvancedManagement() {
      // This method is no longer needed as modals handle advanced management
    },

    async loadStatus() {
      this.loading.status = true
      try {
        // Use flag 23 to exclude clients data (1+2+4+16 = 23)
        // 1=tracking, 2=sources, 4=activity, 16=server_mode (excludes 8=clients)
        const config = window.BRICK_CONFIG.api.customNTP
        const response = await fetch(`${config.baseUrl}${config.endpoints.status}?flags=23`, {
          headers: this.getAuthHeaders()
        })
        if (response.ok) {
          const data = await response.json()
          // Transform customNTP API response to expected format
          this.status = this.transformStatusResponse(data)
          // Set serverModeEnabled from status response
          this.serverModeEnabled = data.server_mode_enabled || false
          this.lastUpdateTime = new Date().toLocaleTimeString()
        } else {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`)
        }
      } catch (err) {
        this.error = `Failed to load status: ${err.message}`
      } finally {
        this.loading.status = false
      }
    },

    transformStatusResponse(data) {
      // Debug: Log the actual API response
      console.log('CustomNTP API response:', data)
      
      // Transform customNTP API response to expected format
      // The API returns: { tracking: {...}, sources: [...], activity: {...}, server_mode_enabled: bool }
      const transformed = {
        tracking: data.tracking || {},
        sources: data.sources || [],
        activity: data.activity || {}
      }
      
      console.log('Transformed status:', transformed)
      return transformed
    },

    getSyncStatusText() {
      if (!this.status.tracking) return 'Unknown'
      const leapStatus = this.status.tracking['Leap status'] || this.status.tracking.LeapStatus
      if (leapStatus === 'Normal') return 'Synchronized'
      if (leapStatus === 'Not synchronised') return 'Not Synced'
      return leapStatus || 'Unknown'
    },

    getSyncStatusClass() {
      if (!this.status.tracking) return 'unknown'
      const leapStatus = this.status.tracking['Leap status'] || this.status.tracking.LeapStatus
      if (leapStatus === 'Normal') return 'synced'
      return 'not-synced'
    },

    getLeapStatusClass() {
      if (!this.status.tracking) return 'unknown'
      const leapStatus = this.status.tracking['Leap status'] || this.status.tracking.LeapStatus
      if (!leapStatus) return 'unknown'
      if (leapStatus === 'Normal') return 'synced'
      if (leapStatus.includes('Leap')) return 'warning'
      return 'not-synced'
    },

    getActiveSourcesCount() {
      if (!this.status.sources) return '0'
      return this.status.sources.filter(s => s.state === '^' || s.state === '*').length.toString()
    },

    getUpdateRate() {
      if (!this.status.tracking || !this.status.tracking.UpdateRate) return 'Unknown'
      return this.status.tracking.UpdateRate
    },

    formatReferenceTime() {
      if (!this.status.tracking || !this.status.tracking['Ref time (UTC)']) return 'Unknown'
      const refTime = this.status.tracking['Ref time (UTC)']
      // Extract just the date part for display
      const match = refTime.match(/(\w{3} \w{3} \d{2} \d{2}:\d{2}:\d{2} \d{4})/)
      return match ? match[1] : refTime
    },

    getSourceStatusText(source) {
      const statusMap = {
        '^': 'Current',
        '*': 'Selected',
        '+': 'Candidate',
        '-': 'Rejected',
        '?': 'Unknown'
      }
      return statusMap[source.state] || 'Unknown'
    },

    getSourceStatusClass(source) {
      const classMap = {
        '^': 'current',
        '*': 'selected',
        '+': 'candidate',
        '-': 'rejected',
        '?': 'unknown'
      }
      return classMap[source.state] || 'unknown'
    },

    toggleAutoRefresh() {
      if (this.autoRefresh) {
        this.startAutoRefresh()
      } else {
        this.stopAutoRefresh()
      }
    },

    startAutoRefresh() {
      if (this.refreshInterval) {
        clearInterval(this.refreshInterval)
      }
      this.refreshInterval = setInterval(() => {
        this.loadStatus()
      }, 5000) // Refresh every 5 seconds
    },

    stopAutoRefresh() {
      if (this.refreshInterval) {
        clearInterval(this.refreshInterval)
        this.refreshInterval = null
      }
    },

    formatDate(dateString) {
      if (!dateString) return 'Unknown'
      const date = new Date(dateString)
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    },

    openServersModal() {
      this.showServersModal = true
    },

    openClientsModal() {
      this.showClientsModal = true
    }
  }
}
</script>

<style scoped>
.custom-ntp {
  height: calc(100vh - 60px);
  display: flex;
  flex-direction: column;
  background: #f5f5f5;
}

/* Page Title Styles */
.page-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--primary-green);
  margin: 0;
}

/* Auto Refresh Controls */
.auto-refresh {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 0.25rem;
  margin-left: auto;
  padding-right: 1rem;
  min-height: 1.5rem;
  justify-content: center;
}

.refresh-toggle {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #4CAF50;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  background: rgba(76, 175, 80, 0.1);
  padding: 0.2rem 0.5rem;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
}

.refresh-toggle:hover {
  background: rgba(76, 175, 80, 0.2);
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(76, 175, 80, 0.2);
}

.refresh-toggle input[type="checkbox"] {
  display: none;
}

.toggle-slider {
  width: 24px;
  height: 12px;
  background: #dee2e6;
  border-radius: 6px;
  position: relative;
  transition: background 0.3s ease;
}

.toggle-slider:before {
  content: '';
  position: absolute;
  width: 8px;
  height: 8px;
  background: white;
  border-radius: 50%;
  top: 2px;
  left: 2px;
  transition: transform 0.3s ease;
}

.refresh-toggle input:checked + .toggle-slider {
  background: #4CAF50;
}

.refresh-toggle input:checked + .toggle-slider:before {
  transform: translateX(12px);
}

.last-update {
  color: #6c757d;
  font-size: 0.75rem;
  font-weight: 500;
  white-space: nowrap;
}

/* Main Content Styles */
.ntp-content {
  flex: 1;
  padding: 0.75rem;
  overflow: hidden;
}

.ntp-content.ntp-grid {
  flex: 1;
  display: grid;
  grid-template-columns: 1fr 1fr;
  grid-template-rows: 2fr 3fr;
  gap: 0.5rem;
  height: 100%;
}

.status-section.compact,
.tracking-section.compact {
  min-height: 50px;
  padding: 0.4rem 0.4rem 0.2rem 0.4rem;
}

.status-cards {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  grid-template-rows: repeat(2, 1fr);
  gap: 0.3rem;
  height: 100%;
  padding: 0.2rem;
}

.status-card {
  background: rgba(255, 255, 255, 0.8);
  border-radius: 6px;
  padding: 0.4rem;
  display: flex;
  align-items: center;
  gap: 0.4rem;
  border: 1px solid #e9ecef;
  transition: all 0.3s ease;
  min-height: 0;
}

.status-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.status-card.primary {
  background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
  color: white;
}

.status-icon {
  font-size: 1.2rem;
  flex-shrink: 0;
}

.status-info {
  flex: 1;
}

.status-label {
  font-size: 0.7rem;
  font-weight: 500;
  opacity: 0.8;
  margin-bottom: 0.1rem;
}

.status-value {
  font-size: 0.9rem;
  font-weight: 600;
}

/* Tracking Details Styles */
.tracking-list {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.4rem;
  flex: 1;
}

.tracking-item {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: 0.4rem;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 6px;
  border: 1px solid #e9ecef;
  text-align: center;
}

.tracking-label {
  font-weight: 500;
  color: #6c757d;
  font-size: 0.8rem;
  margin-bottom: 0.25rem;
}

.tracking-value {
  font-weight: 600;
  color: #2c3e50;
  font-size: 0.9rem;
}

/* Sources Section Styles */
.sources-container {
  flex: 1;
  overflow: hidden;
  max-height: none;
}

.sources-list {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
}

.source-item {
  background: rgba(255, 255, 255, 0.8);
  border-radius: 4px;
  padding: 0.3rem;
  border: 1px solid #e9ecef;
  transition: all 0.3s ease;
  margin-bottom: 0.08rem;
}

.source-item:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.source-item.synced {
  border-color: #4CAF50;
  background: rgba(76, 175, 80, 0.1);
}

.source-item.unsynced {
  border-color: #f44336;
  background: rgba(244, 67, 54, 0.1);
}

.source-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.source-name {
  font-weight: 600;
  color: #2c3e50;
  font-size: 0.9rem;
}

.source-status {
  font-size: 0.75rem;
  font-weight: 500;
  padding: 0.2rem 0.5rem;
  border-radius: 12px;
}

.source-status.synced {
  background: rgba(76, 175, 80, 0.2);
  color: #4CAF50;
}

.source-status.unsynced {
  background: rgba(244, 67, 54, 0.2);
  color: #f44336;
}

.source-details {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  font-size: 0.8rem;
}

.detail-label {
  color: #6c757d;
}

.detail-value {
  font-weight: 500;
  color: #2c3e50;
}

.no-sources {
  text-align: center;
  color: #6c757d;
  padding: 2rem;
}

/* Activity Statistics Styles */
.activity-cards {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  grid-template-rows: repeat(2, 1fr);
  gap: 0.3rem;
  height: 100%;
  padding: 0.2rem;
}

.activity-card {
  background: rgba(255, 255, 255, 0.8);
  border-radius: 6px;
  padding: 0.4rem;
  display: flex;
  align-items: center;
  gap: 0.4rem;
  border: 1px solid #e9ecef;
  transition: all 0.3s ease;
  min-height: 0;
}

.activity-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.activity-card.success {
  border-color: #4CAF50;
  background: rgba(76, 175, 80, 0.1);
}

.activity-card.error {
  border-color: #f44336;
  background: rgba(244, 67, 54, 0.1);
}

.activity-card.warning {
  border-color: #ff9800;
  background: rgba(255, 152, 0, 0.1);
}

.activity-card.timeout {
  border-color: #9c27b0;
  background: rgba(156, 39, 176, 0.1);
}

.activity-icon {
  font-size: 1.2rem;
  flex-shrink: 0;
}

.activity-info {
  flex: 1;
}

.activity-label {
  font-size: 0.7rem;
  font-weight: 500;
  opacity: 0.8;
  margin-bottom: 0.1rem;
}

.activity-value {
  font-size: 0.9rem;
  font-weight: 600;
}

/* Server Mode Styles */
.server-mode-content {
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
  height: 100%;
}

.mode-status {
  text-align: center;
  padding: 0.15rem;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.status-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.2rem;
  margin-bottom: 0.2rem;
}

.indicator-dot {
  width: 5px;
  height: 5px;
  border-radius: 50%;
  background: #f44336;
  transition: background 0.3s ease;
}

.status-indicator.active .indicator-dot {
  background: #4CAF50;
}

.status-text {
  font-size: 0.75rem;
  font-weight: 600;
  color: #333;
}

.mode-description {
  color: #666;
  font-size: 0.65rem;
  line-height: 1.1;
  margin-bottom: 0.2rem;
}

.port-info {
  margin-top: 0.2rem;
  font-size: 0.65rem;
  color: #666;
  display: flex;
  justify-content: center;
  gap: 0.3rem;
}

.port-label {
  font-weight: 500;
}

.port-value {
  font-weight: 600;
  color: #333;
}

.mode-controls {
  display: flex;
  justify-content: center;
  margin-bottom: 0.2rem;
  flex: 0 0 auto;
}

.mode-btn {
  padding: 0.2rem 0.5rem;
  border: none;
  border-radius: 3px;
  font-size: 0.65rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.2rem;
  min-height: 20px;
}

.mode-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.mode-btn.enabled {
  background: #f44336;
  color: white;
}

.mode-btn.enabled:hover:not(:disabled) {
  background: #d32f2f;
}

.mode-btn.disabled {
  background: #4CAF50;
  color: white;
}

.mode-btn.disabled:hover:not(:disabled) {
  background: #388E3C;
}

.actions-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  align-items: stretch;
  justify-content: center;
}

.quick-action-btn {
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 1.2rem;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  text-decoration: none;
  color: inherit;
  min-height: 80px;
  justify-content: center;
  flex: 1;
}

.quick-action-btn:hover {
  background: rgba(255, 255, 255, 1);
  border-color: #2196F3;
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.action-icon {
  font-size: 1.2rem;
}

.action-text {
  font-size: 0.8rem;
  font-weight: 500;
  color: #333;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .top-row, .bottom-row {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .top-row, .bottom-row {
    grid-template-columns: 1fr;
  }
  
  .status-cards {
    grid-template-columns: 1fr;
  }
  
  .tracking-list {
    grid-template-columns: 1fr;
  }
  
  .activity-cards {
    grid-template-columns: 1fr;
  }
  
  .actions-buttons {
    grid-template-columns: 1fr;
  }
}

.sources-section {
  display: flex;
  flex-direction: column;
  min-height: 0;
}

.right-bottom-section {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  min-height: 0;
}

.activity-section.compact {
  min-height: 0;
  padding: 0.4rem 0.4rem 0.2rem 0.4rem;
  flex: 0.4;
}

.bottom-right-row {
  display: flex;
  gap: 0.4rem;
  flex: 0.6;
  min-height: 0;
}

.server-mode-section.compact {
  flex: 1;
  min-height: 0;
  padding: 0.4rem 0.4rem 0.2rem 0.4rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.server-mode-content.tight {
  padding: 0.8rem 0 0 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  height: 100%;
  justify-content: flex-start;
  align-items: center;
}

.mode-status {
  text-align: center;
  padding: 0.2rem;
  flex: 0 0 auto;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.status-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.4rem;
  margin-bottom: 0.4rem;
}

.indicator-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #f44336;
  transition: background 0.3s ease;
}

.status-indicator.active .indicator-dot {
  background: #4CAF50;
}

.status-text {
  font-size: 1rem;
  font-weight: 600;
  color: #333;
}

.mode-description {
  color: #666;
  font-size: 0.8rem;
  line-height: 1.2;
  margin-bottom: 0.4rem;
}

.port-info {
  margin-top: 0.4rem;
  font-size: 0.8rem;
  color: #666;
  display: flex;
  justify-content: center;
  gap: 0.5rem;
}

.port-label {
  font-weight: 500;
}

.port-value {
  font-weight: 600;
  color: #333;
}

.port-value.disabled {
  text-decoration: line-through;
  opacity: 0.6;
}

.mode-controls {
  display: flex;
  justify-content: center;
  margin-top: 0.8rem;
  flex: 0 0 auto;
}

.mode-btn {
  padding: 0.3rem 0.8rem;
  border: none;
  border-radius: 4px;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.3rem;
  min-height: 28px;
}

.mode-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.mode-btn.enabled {
  background: #f44336;
  color: white;
}

.mode-btn.enabled:hover:not(:disabled) {
  background: #d32f2f;
}

.mode-btn.disabled {
  background: #4CAF50;
  color: white;
}

.mode-btn.disabled:hover:not(:disabled) {
  background: #388E3C;
}

.status-section, .tracking-section, .sources-section, .activity-section, .server-mode-section {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  padding: 0.75rem;
  display: flex;
  flex-direction: column;
  min-height: 180px;
}

.section-title {
  font-size: 0.9rem;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 0.5rem;
  border-bottom: 2px solid #e9ecef;
  padding-bottom: 0.3rem;
}
</style> 