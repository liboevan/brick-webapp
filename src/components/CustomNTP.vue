<template>
  <div class="custom-ntp">
    <!-- Shared Header -->
    <SharedHeader title="NTP Time Synchronization">
      <template #controls>
        <div class="auto-refresh">
          <label class="refresh-toggle">
            <input type="checkbox" v-model="autoRefresh" @change="toggleAutoRefresh">
            <span class="toggle-slider"></span>
            Auto Refresh
          </label>
          <span class="last-update">Last updated: {{ lastUpdateTime }}</span>
        </div>
      </template>
    </SharedHeader>

    <!-- Main Content - 2x3 Grid Layout -->
    <div class="ntp-content">
      <!-- Grid Container -->
      <div class="grid-container">
        <!-- Area 1: Status Overview -->
        <div class="grid-area area-1">
          <div class="panel-section status-overview">
            <h2 class="section-title">Status Overview</h2>
            <div class="status-grid">
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
        </div>

        <!-- Area 2: Tracking Details -->
        <div class="grid-area area-2">
          <div class="panel-section tracking-details">
            <h2 class="section-title">Tracking Details</h2>
            <div class="tracking-grid">
              <div class="tracking-item">
                <span class="tracking-label">Last Offset:</span>
                <span class="tracking-value">{{ status.tracking['Last offset'] || 'Unknown' }}</span>
              </div>
              <div class="tracking-item">
                <span class="tracking-label">RMS Offset:</span>
                <span class="tracking-value">{{ status.tracking['RMS offset'] || 'Unknown' }}</span>
              </div>
              <div class="tracking-item">
                <span class="tracking-label">System Time:</span>
                <span class="tracking-value">{{ status.tracking['System time'] || 'Unknown' }}</span>
              </div>
              <div class="tracking-item">
                <span class="tracking-label">Update Interval:</span>
                <span class="tracking-value">{{ status.tracking['Update interval'] || 'Unknown' }}</span>
              </div>
              <div class="tracking-item">
                <span class="tracking-label">Root Delay:</span>
                <span class="tracking-value">{{ status.tracking['Root delay'] || 'Unknown' }}</span>
              </div>
              <div class="tracking-item">
                <span class="tracking-label">Root Dispersion:</span>
                <span class="tracking-value">{{ status.tracking['Root dispersion'] || 'Unknown' }}</span>
              </div>
              <div class="tracking-item">
                <span class="tracking-label">Skew:</span>
                <span class="tracking-value">{{ status.tracking?.Skew || 'Unknown' }}</span>
              </div>
              <div class="tracking-item">
                <span class="tracking-label">Leap Status:</span>
                <span class="tracking-value" :class="getLeapStatusClass()">{{ status.tracking['Leap status'] || 'Unknown' }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Area 3: NTP Sources -->
        <div class="grid-area area-3">
          <div class="panel-section sources-section">
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
        </div>

        <!-- Area 4: Activity Statistics -->
        <div class="grid-area area-4">
          <div class="panel-section activity-section">
            <h2 class="section-title">Activity Statistics</h2>
            <div class="activity-grid">
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
        </div>

        <!-- Area 5: Server Mode -->
        <div class="grid-area area-5">
          <div class="panel-section server-mode-section">
            <h2 class="section-title">Server Mode</h2>
            <div class="server-mode-content">
              <div class="mode-status">
                <div class="status-indicator" :class="{ active: serverModeEnabled }">
                  <span class="indicator-dot"></span>
                  <span class="status-text">{{ serverModeEnabled ? 'ON' : 'OFF' }}</span>
                </div>
                <div class="mode-description">
                  {{ serverModeEnabled ? 'Accepting client connections' : 'Not accepting connections' }}
                </div>
              </div>
              <div class="mode-controls">
                <button 
                  v-if="hasPermission('clock/server-mode')"
                  @click="toggleServerMode" 
                  :disabled="loading.serverMode"
                  class="mode-btn"
                  :class="{ enabled: serverModeEnabled, disabled: !serverModeEnabled }"
                >
                  <span v-if="loading.serverMode" class="loading-spinner">⏳</span>
                  <span v-else>{{ serverModeEnabled ? 'Disable' : 'Enable' }}</span>
                </button>
                <button v-else class="mode-btn" disabled title="Admin only">
                  <span class="action-icon">🔒</span>
                  <span class="action-text">Server Mode (Admin)</span>
                </button>
              </div>
              <div class="mode-info">
                <div class="info-item">
                  <span class="info-label">Port:</span>
                  <span class="info-value">123/UDP</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Stratum:</span>
                  <span class="info-value">{{ status.tracking?.Stratum || 'Unknown' }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Area 6: Quick Actions -->
        <div class="grid-area area-6">
          <div class="panel-section quick-actions-section">
            <h2 class="section-title">Quick Actions</h2>
            <div class="quick-actions-content">
              <!-- System Info -->
              <div class="system-info">
                <div class="info-card">
                  <div class="info-icon">ℹ️</div>
                  <div class="info-content">
                    <div class="info-title">System</div>
                    <div class="info-details">
                      <div class="detail-item">
                        <span class="detail-label">Ver:</span>
                        <span class="detail-value">v{{ versionInfo.version }}</span>
                      </div>
                      <div class="detail-item">
                        <span class="detail-label">Up:</span>
                        <span class="detail-value">{{ getUptime() }}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Quick Actions -->
              <div class="actions-grid">
                <button @click="refreshStatus" class="quick-action-btn" title="Refresh Status">
                  <span class="action-icon">🔄</span>
                  <span class="action-text">Refresh</span>
                </button>
                <button @click="resetConfiguration" class="quick-action-btn" title="Reset Configuration">
                  <span class="action-icon">⚡</span>
                  <span class="action-text">Reset</span>
                </button>
                <button @click="openClientsModal" class="quick-action-btn" title="View Connected Clients" :disabled="!serverModeEnabled">
                  <span class="action-icon">👥</span>
                  <span class="action-text">Clients</span>
                </button>
                <!-- Servers Manager (Admin only placeholder) -->
                <button v-if="hasPermission('clock/servers')"
                  @click="openServersModal" 
                  class="quick-action-btn" 
                  title="Manage NTP Servers">
                  <span class="action-icon">🗂️</span>
                  <span class="action-text">Servers</span>
                </button>
                <button v-else class="quick-action-btn" disabled title="Admin only">
                  <span class="action-icon">🔒</span>
                  <span class="action-text">Servers (Admin)</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Error Messages -->
    <div v-if="error" class="error-message">
      <h3>Error</h3>
      <p>{{ error }}</p>
      <button @click="error = ''" class="close-btn">×</button>
    </div>

    <!-- Success Messages -->
    <div v-if="success" class="success-message">
      <h3>Success</h3>
      <p>{{ success }}</p>
      <button @click="success = ''" class="close-btn">×</button>
    </div>

    <NTPServerClientsModal
      v-if="showClientsModal"
      :serverModeEnabled="serverModeEnabled"
      @close="showClientsModal = false"
    />
    <NTPServersManagerModal
      v-if="showServersModal"
      @close="showServersModal = false"
    />
  </div>
</template>

<script>
import { getApiConfig } from '../config/dashboard.js'
import NTPServerClientsModal from './NTPServerClientsModal.vue'
import NTPServersManagerModal from './NTPServersManagerModal.vue'
import authMixin from '../mixins/auth.js'
import AvatarDropdown from './AvatarDropdown.vue'
import SharedHeader from './SharedHeader.vue'

export default {
  name: 'CustomNTP',
  mixins: [authMixin],
  components: {
    NTPServerClientsModal,
    NTPServersManagerModal,
    AvatarDropdown,
    SharedHeader
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

    openClientsModal() {
      this.showClientsModal = true
    },
    openServersModal() {
      this.showServersModal = true
    },
  }
}
</script>

<style scoped>
.custom-ntp {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  /* overflow: visible; */
}

/* Auto Refresh Controls */

.auto-refresh {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.refresh-toggle {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #34495e;
  font-size: 0.85rem;
  cursor: pointer;
  padding: 0.5rem 1rem;
  border-radius: 25px;
  transition: all 0.3s ease;
  font-weight: 500;
}

.refresh-toggle:hover {
  background: #e9ecef;
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.refresh-toggle input[type="checkbox"] {
  display: none;
}

.toggle-slider {
  width: 36px;
  height: 18px;
  background: #dee2e6;
  border-radius: 9px;
  position: relative;
  transition: background 0.3s ease;
}

.toggle-slider:before {
  content: '';
  position: absolute;
  width: 12px;
  height: 12px;
  background: white;
  border-radius: 50%;
  top: 3px;
  left: 3px;
  transition: transform 0.3s ease;
}

.refresh-toggle input:checked + .toggle-slider {
  background: #4CAF50;
}

.refresh-toggle input:checked + .toggle-slider:before {
  transform: translateX(18px);
}

.last-update {
  color: #6c757d;
  font-size: 0.8rem;
  font-weight: 500;
}

.version-info {
  position: relative;
}

.version-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 8px;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.version-btn:hover {
  background: rgba(76, 175, 80, 0.1);
  transform: scale(1.05);
}

.version-icon {
  font-size: 1.2rem;
  color: #2c3e50;
  transition: color 0.3s ease;
}

.version-btn:hover .version-icon {
  color: #4CAF50;
}

.version-tooltip {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 0.5rem;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 12px;
  padding: 1rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  border: 1px solid rgba(255, 255, 255, 0.2);
  z-index: 1000;
  min-width: 250px;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.tooltip-content {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.tooltip-title {
  font-weight: 700;
  color: #2c3e50;
  font-size: 0.9rem;
  margin-bottom: 0.5rem;
  border-bottom: 1px solid #e9ecef;
  padding-bottom: 0.5rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.tooltip-icon {
  font-size: 1rem;
}

.tooltip-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
}

.tooltip-label {
  color: #6c757d;
  font-size: 0.8rem;
  font-weight: 600;
}

.tooltip-value {
  color: #2c3e50;
  font-size: 0.8rem;
  font-weight: 700;
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
}

.version-number {
  color: #4CAF50;
  background: rgba(76, 175, 80, 0.1);
  padding: 0.2rem 0.4rem;
  border-radius: 4px;
  font-size: 0.75rem;
}

.environment-tag {
  color: #FF9800;
  background: rgba(255, 152, 0, 0.1);
  padding: 0.2rem 0.4rem;
  border-radius: 4px;
  font-size: 0.7rem;
  text-transform: uppercase;
  font-weight: 600;
}

.brick-logo-btn {
  background: none;
  border: none;
  outline: none;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.brick-logo-btn:hover {
  background: rgba(76, 175, 80, 0.1);
  transform: scale(1.05);
  border: none;
  outline: none;
}

.brick-logo-btn:focus {
  border: none;
  outline: none;
  box-shadow: none;
}

.brick-logo {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.7rem 1.2rem;
  background: #4CAF50;
  border-radius: 4px;
  outline: none;
}

.brick-icon {
  font-size: 1.2rem;
}

.brick-icon-img {
  width: 1.2rem;
  height: 1.2rem;
  object-fit: contain;
}

.brick-text {
  color: white;
  font-weight: 700;
  font-size: 1rem;
  letter-spacing: 1px;
}

.brick-logo:hover,
.brick-logo:focus {
  border: none;
  outline: none;
}

/* Main Content - 2x3 Grid Layout */
.ntp-content {
  display: flex;
  flex: 1 1 0;
  padding: 0.4rem 0.75rem;
  min-height: 0;
  /* overflow: visible; */
}

.grid-container {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  grid-template-rows: repeat(2, minmax(0, 1fr));
  gap: 0.4rem;
  width: 100%;
  height: 100%;
}

.grid-area {
  display: flex;
  flex-direction: column;
  min-height: 0;
}

.area-1 {
  grid-area: 1 / 1 / 2 / 2;
}

.area-2 {
  grid-area: 1 / 2 / 2 / 3;
}

.area-3 {
  grid-area: 1 / 3 / 2 / 4;
}

.area-4 {
  grid-area: 2 / 1 / 3 / 2;
}

.area-5 {
  grid-area: 2 / 2 / 3 / 3;
}

.area-6 {
  grid-area: 2 / 3 / 3 / 4;
}

.panel-section {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 7px;
  padding: 0.25rem 0.5rem;
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.09);
  backdrop-filter: blur(5px);
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.section-title {
  color: #2c3e50;
  font-size: 0.95rem;
  margin-bottom: 0.4rem;
  text-align: center;
  font-weight: 600;
  border-bottom: 1px solid #e0f2e9;
  padding-bottom: 0.2rem;
}

.subsection-title {
  color: #495057;
  font-size: 1rem;
  margin-bottom: 0.75rem;
  font-weight: 600;
}

/* Status Overview */
.status-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.75rem;
  flex: 1;
}

.status-card {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-radius: 12px;
  padding: 0.75rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.status-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}

.status-card.primary {
  background: linear-gradient(135deg, #e8f5e8 0%, #c8e6c9 100%);
  border: 1px solid #8ee4af;
}

.status-card.primary.synced {
  background: linear-gradient(135deg, #e8f5e8 0%, #c8e6c9 100%);
  border-color: #4CAF50;
}

.status-card.primary.not-synced {
  background: linear-gradient(135deg, #ffebee 0%, #ffcdd2 100%);
  border-color: #f44336;
}

.status-icon {
  font-size: 1.5rem;
  flex-shrink: 0;
}

.status-info {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.status-label {
  color: #6c757d;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.status-value {
  color: #2c3e50;
  font-size: 1rem;
  font-weight: 700;
}

/* Tracking Details */
.tracking-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.5rem;
  flex: 1;
  overflow-y: auto;
}

.tracking-item {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 0.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  border: 1px solid #e9ecef;
}

.tracking-label {
  color: #6c757d;
  font-size: 0.75rem;
  font-weight: 600;
}

.tracking-value {
  color: #2c3e50;
  font-size: 0.75rem;
  font-weight: 700;
}

/* Future Features Section */
.future-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  text-align: center;
  padding: 1rem;
}

.future-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
  opacity: 0.7;
}

.future-text h3 {
  color: #2c3e50;
  font-size: 1.1rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.future-text p {
  color: #6c757d;
  font-size: 0.85rem;
  margin-bottom: 1rem;
  line-height: 1.4;
}

.future-features {
  list-style: none;
  padding: 0;
  margin: 0;
  text-align: left;
}

.future-features li {
  color: #495057;
  font-size: 0.75rem;
  margin-bottom: 0.3rem;
  padding-left: 1rem;
  position: relative;
}

.future-features li:before {
  content: '•';
  color: #4CAF50;
  font-weight: bold;
  position: absolute;
  left: 0;
}

/* Sources Section */
.sources-container {
  flex: 1;
  overflow: hidden;
}

.sources-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  height: 100%;
  overflow-y: auto;
  padding-right: 0.5rem;
  max-height: calc(100% - 2rem);
}

.sources-list::-webkit-scrollbar {
  width: 6px;
}

.sources-list::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.3);
  border-radius: 3px;
}

.sources-list::-webkit-scrollbar-thumb {
  background: rgba(0, 0, 0, 0.2);
  border-radius: 3px;
}

.sources-list::-webkit-scrollbar-thumb:hover {
  background: rgba(0, 0, 0, 0.3);
}

.source-item {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 0.75rem;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  border: 1px solid #e9ecef;
  min-height: 60px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.source-item:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
}

.source-item.current {
  background: linear-gradient(135deg, #e8f5e8 0%, #c8e6c9 100%);
  border-color: #4CAF50;
}

.source-item.selected {
  background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%);
  border-color: #2196F3;
}

.source-item.candidate {
  background: linear-gradient(135deg, #fff3e0 0%, #ffe0b2 100%);
  border-color: #FF9800;
}

.source-item.rejected {
  background: linear-gradient(135deg, #ffebee 0%, #ffcdd2 100%);
  border-color: #f44336;
}

.source-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.source-name {
  color: #2c3e50;
  font-weight: 700;
  font-size: 0.85rem;
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.source-status {
  padding: 0.15rem 0.4rem;
  border-radius: 12px;
  font-size: 0.5rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.3px;
  flex-shrink: 0;
}

.source-status.current {
  background: #4CAF50;
  color: white;
}

.source-status.selected {
  background: #2196F3;
  color: white;
}

.source-status.candidate {
  background: #FF9800;
  color: white;
}

.source-status.rejected {
  background: #f44336;
  color: white;
}

.source-status.unknown {
  background: #9E9E9E;
  color: white;
}

.source-details {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.detail-label {
  color: #6c757d;
  font-size: 0.7rem;
  font-weight: 600;
}

.detail-value {
  color: #2c3e50;
  font-size: 0.7rem;
  font-weight: 700;
}

/* Activity Statistics */
.activity-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.75rem;
  flex: 1;
}

.activity-card {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-radius: 12px;
  padding: 0.75rem;
  text-align: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.activity-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}

.activity-card.success {
  background: linear-gradient(135deg, #e8f5e8 0%, #c8e6c9 100%);
  border-color: #4CAF50;
}

.activity-card.error {
  background: linear-gradient(135deg, #ffebee 0%, #ffcdd2 100%);
  border-color: #f44336;
}

.activity-card.warning {
  background: linear-gradient(135deg, #fff3e0 0%, #ffe0b2 100%);
  border-color: #FF9800;
}

.activity-card.timeout {
  background: linear-gradient(135deg, #f3e5f5 0%, #e1bee7 100%);
  border-color: #9C27B0;
}

.activity-icon {
  font-size: 1.5rem;
  display: block;
  margin-bottom: 0.5rem;
}

.activity-info {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.activity-label {
  color: #6c757d;
  font-size: 0.7rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.activity-value {
  color: #2c3e50;
  font-size: 1.1rem;
  font-weight: 700;
}

/* Server Management */
.servers-section {
  margin-bottom: 1.5rem;
}

.servers-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.server-item {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 0.75rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  border: 1px solid #e9ecef;
  transition: all 0.3s ease;
}

.server-item:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
}

.server-name {
  color: #2c3e50;
  font-weight: 600;
  font-size: 0.8rem;
}

.server-status {
  padding: 0.2rem 0.6rem;
  border-radius: 15px;
  font-size: 0.55rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.server-status.current {
  background: #4CAF50;
  color: white;
}

.server-status.selected {
  background: #2196F3;
  color: white;
}

.server-status.candidate {
  background: #FF9800;
  color: white;
}

.server-status.rejected {
  background: #f44336;
  color: white;
}

.server-status.unknown {
  background: #9E9E9E;
  color: white;
}

/* Form Styles */
.add-servers-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.form-textarea {
  width: 100%;
  padding: 0.75rem;
  border-radius: 8px;
  background: #ffffff;
  color: #2c3e50;
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 0.8rem;
  resize: vertical;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
  border: 1px solid #e9ecef;
  transition: all 0.3s ease;
}

.form-textarea:focus {
  outline: none;
  background: #ffffff;
  box-shadow: 0 2px 8px rgba(76, 175, 80, 0.2);
  border-color: #4CAF50;
}

.form-textarea::placeholder {
  color: #adb5bd;
}

.form-actions {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.action-btn {
  padding: 0.6rem 1rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.75rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  flex: 1;
  justify-content: center;
}

.action-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none !important;
}

.action-btn.primary {
  background: linear-gradient(135deg, #4CAF50, #45a049);
  color: white;
}

.action-btn.primary:hover:not(:disabled) {
  background: linear-gradient(135deg, #45a049, #388E3C);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3);
}

.action-btn.secondary {
  background: linear-gradient(135deg, #6c757d, #5a6268);
  color: white;
}

.action-btn.secondary:hover:not(:disabled) {
  background: linear-gradient(135deg, #5a6268, #495057);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(108, 117, 125, 0.3);
}

.action-btn.danger {
  background: linear-gradient(135deg, #f44336, #d32f2f);
  color: white;
}

.action-btn.danger:hover:not(:disabled) {
  background: linear-gradient(135deg, #d32f2f, #c62828);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(244, 67, 54, 0.3);
}

/* Messages */
.error-message,
.success-message {
  position: fixed;
  top: 80px;
  right: 20px;
  padding: 1rem 1.5rem;
  border-radius: 12px;
  max-width: 400px;
  z-index: 1000;
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
  font-size: 0.85rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.25);
  border: 2px solid;
  backdrop-filter: blur(10px);
}

.error-message {
  background: rgba(244, 67, 54, 0.95);
  color: #ffffff;
  border-color: #d32f2f;
}

.success-message {
  background: rgba(76, 175, 80, 0.95);
  color: #ffffff;
  border-color: #4CAF50;
}

.error-message h3,
.success-message h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.1rem;
  font-weight: 700;
}

.error-message p,
.success-message p {
  margin: 0;
  font-size: 0.85rem;
  font-weight: 500;
}

.close-btn {
  background: none;
  border: none;
  color: inherit;
  font-size: 1.2rem;
  cursor: pointer;
  padding: 0;
  margin-left: auto;
  opacity: 0.7;
  font-weight: bold;
  transition: opacity 0.3s ease;
}

.close-btn:hover {
  opacity: 1;
}

.loading-spinner {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.no-servers,
.no-sources {
  text-align: center;
  color: #6c757d;
  font-style: italic;
  padding: 1rem;
  font-size: 0.8rem;
  font-weight: 500;
  background: #f8f9fa;
  border-radius: 8px;
  border: 1px dashed #dee2e6;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .grid-container {
    grid-template-columns: repeat(2, 1fr);
    grid-template-rows: repeat(3, 1fr);
  }
  
  .area-1 {
    grid-area: 1 / 1 / 2 / 2;
  }
  
  .area-2 {
    grid-area: 1 / 2 / 2 / 3;
  }
  
  .area-3 {
    grid-area: 2 / 1 / 3 / 2;
  }
  
  .area-4 {
    grid-area: 2 / 2 / 3 / 3;
  }
  
  .area-5 {
    grid-area: 3 / 1 / 4 / 2;
  }
  
  .area-6 {
    grid-area: 3 / 2 / 4 / 3;
  }
}

@media (max-width: 768px) {
  .ntp-header {
    flex-direction: column;
    gap: 1rem;
    padding: 1rem;
  }
  
  .header-left {
    flex-direction: column;
    gap: 1rem;
  }
  
  .header-right {
    flex-direction: column;
    gap: 1rem;
  }
  
  .ntp-title {
    font-size: 1.5rem;
  }
  
  .auto-refresh {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .ntp-content {
    padding: 1rem;
  }
  
  .grid-container {
    grid-template-columns: 1fr;
    grid-template-rows: repeat(6, auto);
  }
  
  .area-1,
  .area-2,
  .area-3,
  .area-4,
  .area-5,
  .area-6 {
    grid-area: auto;
  }
  
  .status-grid,
  .activity-grid,
  .tracking-grid {
    grid-template-columns: 1fr;
  }
  
  .form-actions {
    flex-direction: column;
  }
  
  .action-btn {
    justify-content: center;
  }
}

/* Area 5: Server Mode Styles */
.server-mode-section {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.server-mode-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 0.75rem;
}

.mode-status {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 8px;
  padding: 1rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  text-align: center;
}

.status-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.indicator-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: #f44336;
  transition: background 0.3s ease;
}

.status-indicator.active .indicator-dot {
  background: #4CAF50;
}

.status-text {
  font-size: 1.1rem;
  font-weight: 600;
  color: #333;
}

.mode-description {
  color: #666;
  font-size: 0.9rem;
  line-height: 1.4;
}

.mode-controls {
  display: flex;
  justify-content: center;
}

.mode-btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 6px;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
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

.mode-info {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 8px;
  padding: 1rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0;
  border-bottom: 1px solid #eee;
}

.info-item:last-child {
  border-bottom: none;
}

.info-label {
  font-weight: 500;
  color: #666;
}

.info-value {
  font-weight: 600;
  color: #333;
}

/* Area 6: Quick Actions Styles */
.quick-actions-section {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.quick-actions-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  padding: 0.75rem;
}

.system-info {
  margin-bottom: 1rem;
}

.info-card {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 8px;
  padding: 0.75rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.info-icon {
  font-size: 1.5rem;
}

.info-content {
  flex: 1;
}

.info-title {
  font-weight: 600;
  color: #333;
  margin-bottom: 0.5rem;
}

.info-details {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  font-size: 0.85rem;
}

.detail-label {
  color: #666;
}

.detail-value {
  font-weight: 500;
  color: #333;
}

.actions-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.quick-action-btn {
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid #ddd;
  border-radius: 6px;
  padding: 0.75rem;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  text-decoration: none;
  color: inherit;
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
</style> 