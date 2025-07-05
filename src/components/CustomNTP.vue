<template>
  <div class="custom-ntp landscape">
    <div class="ntp-header compact">
      <h1 class="ntp-title">NTP Time Synchronization</h1>
      <div class="auto-refresh">
        <label class="refresh-toggle">
          <input type="checkbox" v-model="autoRefresh" @change="toggleAutoRefresh">
          <span class="toggle-slider"></span>
          Auto Refresh ({{ autoRefresh ? 'ON' : 'OFF' }})
        </label>
        <span class="last-update">Last updated: {{ lastUpdateTime }}</span>
      </div>
    </div>

    <div class="ntp-content">
      <!-- Left Column: Status and Tracking -->
      <div class="left-column">
        <!-- Status Overview -->
        <div class="ntp-section compact">
          <h2 class="section-title">Status Overview</h2>
          <div class="status-overview">
            <div class="status-item primary">
              <span class="status-icon">⏰</span>
              <div class="status-content">
                <span class="status-label">Sync Status</span>
                <span class="status-value" :class="getSyncStatusClass()">{{ getSyncStatusText() }}</span>
              </div>
            </div>
            <div class="status-item">
              <span class="status-icon">📍</span>
              <div class="status-content">
                <span class="status-label">Stratum</span>
                <span class="status-value">{{ status.tracking?.Stratum || 'Unknown' }}</span>
              </div>
            </div>
            <div class="status-item">
              <span class="status-icon">📡</span>
              <div class="status-content">
                <span class="status-label">Sources</span>
                <span class="status-value">{{ getActiveSourcesCount() }}</span>
              </div>
            </div>
            <div class="status-item">
              <span class="status-icon">⚡</span>
              <div class="status-content">
                <span class="status-label">Frequency</span>
                <span class="status-value">{{ status.tracking.Frequency || 'Unknown' }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Tracking Details -->
        <div class="ntp-section compact" v-if="status.tracking">
          <h2 class="section-title">Tracking Details</h2>
          <div class="tracking-grid compact">
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
              <span class="tracking-value">{{ status.tracking.Skew || 'Unknown' }}</span>
            </div>
            <div class="tracking-item">
              <span class="tracking-label">Leap Status:</span>
              <span class="tracking-value" :class="getLeapStatusClass()">{{ status.tracking['Leap status'] || 'Unknown' }}</span>
            </div>
          </div>
        </div>

        <!-- Activity Statistics -->
        <div class="ntp-section compact" v-if="status.activity">
          <h2 class="section-title">Activity Statistics</h2>
          <div class="activity-stats">
            <div class="stat-item">
              <span class="stat-icon">✅</span>
              <span class="stat-label">Success</span>
              <span class="stat-value">{{ status.activity.ok_count || '0' }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-icon">❌</span>
              <span class="stat-label">Failed</span>
              <span class="stat-value">{{ status.activity.failed_count || '0' }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-icon">⚠️</span>
              <span class="stat-label">Bogus</span>
              <span class="stat-value">{{ status.activity.bogus_count || '0' }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-icon">⏱️</span>
              <span class="stat-label">Timeouts</span>
              <span class="stat-value">{{ status.activity.timeout_count || '0' }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Right Column: Sources and Management -->
      <div class="right-column">
        <!-- NTP Sources -->
        <div class="ntp-section compact">
          <h2 class="section-title">NTP Sources</h2>
          <div class="sources-container compact">
            <div v-if="status.sources && status.sources.length > 0" class="sources-list">
              <div v-for="(source, index) in status.sources" :key="index" class="source-item" :class="getSourceStatusClass(source)">
                <div class="source-info">
                  <span class="source-name">{{ source.name }}</span>
                  <span class="source-status" :class="getSourceStatusClass(source)">{{ getSourceStatusText(source) }}</span>
                </div>
                <div class="source-details">
                  <span class="detail">Stratum: {{ source.stratum || 'N/A' }}</span>
                  <span class="detail">Poll: {{ source.poll || 'N/A' }}</span>
                  <span class="detail">Reach: {{ source.reach || 'N/A' }}</span>
                  <span class="detail">Offset: {{ source.offset || 'N/A' }}</span>
                </div>
              </div>
            </div>
            <div v-else class="no-sources">
              <p>No NTP sources configured</p>
            </div>
          </div>
        </div>

        <!-- Server Management -->
        <div class="ntp-section compact">
          <h2 class="section-title">Server Management</h2>
          
          <!-- Current Servers -->
          <div class="servers-section">
            <h3>Current NTP Servers</h3>
            <div v-if="servers.length > 0" class="servers-list compact">
              <div v-for="(server, index) in servers" :key="index" class="server-item">
                <span class="server-name">{{ server.name }}</span>
                <span class="server-status" :class="getServerStatusClass(server)">{{ getServerStatus(server) }}</span>
              </div>
            </div>
            <div v-else class="no-servers">
              <p>No NTP servers configured</p>
            </div>
          </div>

          <!-- Add New Servers -->
          <div class="servers-section">
            <h3>Configure NTP Servers</h3>
            <div class="add-servers-form compact">
              <div class="form-group">
                <textarea 
                  v-model="newServers"
                  placeholder="pool.ntp.org&#10;time.google.com&#10;time.windows.com"
                  rows="2"
                  class="form-textarea compact"
                ></textarea>
              </div>
              <div class="form-actions compact">
                <button 
                  @click="addServers" 
                  :disabled="loading.servers || !newServers.trim()"
                  class="action-btn primary compact"
                >
                  <span v-if="loading.servers" class="loading-spinner">⏳</span>
                  <span v-else>Add Servers</span>
                </button>
                <button 
                  @click="setDefaultServers" 
                  :disabled="loading.servers"
                  class="action-btn secondary compact"
                >
                  <span v-if="loading.servers" class="loading-spinner">⏳</span>
                  <span v-else>Set Default</span>
                </button>
                <button 
                  @click="clearServers" 
                  :disabled="loading.servers"
                  class="action-btn danger compact"
                >
                  <span v-if="loading.servers" class="loading-spinner">⏳</span>
                  <span v-else>Clear All</span>
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
  </div>
</template>

<script>
import { getApiConfig } from '../config/dashboard.js'

export default {
  name: 'CustomNTP',
  data() {
    return {
      status: {
        tracking: {},
        sources: [],
        activity: {},
        clients: []
      },
      servers: [],
      newServers: '',
      loading: {
        status: false,
        servers: false
      },
      error: '',
      success: '',
      apiConfig: null,
      autoRefresh: true,
      refreshInterval: null,
      lastUpdateTime: 'Never'
    }
  },
  mounted() {
    this.apiConfig = getApiConfig()
    this.loadStatus()
    this.loadServers()
    this.startAutoRefresh()
  },
  beforeUnmount() {
    this.stopAutoRefresh()
  },
  methods: {
    async loadStatus() {
      this.loading.status = true
      try {
        const response = await fetch(`${this.apiConfig.clockApi}/chrony/status`)
        if (response.ok) {
          this.status = await response.json()
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



    async loadServers() {
      try {
        const response = await fetch(`${this.apiConfig.clockApi}/chrony/servers`)
        if (response.ok) {
          const data = await response.json()
          this.servers = this.parseServers(data.servers || '')
        } else {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`)
        }
      } catch (err) {
        this.error = `Failed to load servers: ${err.message}`
      }
    },

    parseServers(serversOutput) {
      if (!serversOutput) return []
      
      const lines = serversOutput.split('\n')
      const servers = []
      
      for (const line of lines) {
        if (line.includes('^') || line.includes('*') || line.includes('+')) {
          const parts = line.trim().split(/\s+/)
          if (parts.length >= 2) {
            servers.push({
              name: parts[1],
              status: parts[0],
              raw: line
            })
          }
        }
      }
      
      return servers
    },

    getServerStatus(server) {
      const statusMap = {
        '^': 'Current',
        '*': 'Selected',
        '+': 'Candidate',
        '-': 'Rejected',
        '?': 'Unknown'
      }
      return statusMap[server.status] || 'Unknown'
    },

    getServerStatusClass(server) {
      const classMap = {
        '^': 'current',
        '*': 'selected',
        '+': 'candidate',
        '-': 'rejected',
        '?': 'unknown'
      }
      return classMap[server.status] || 'unknown'
    },

    getSyncStatusText() {
      if (!this.status.tracking) return 'Unknown'
      if (this.status.tracking.LeapStatus === 'Normal') return 'Synchronized'
      if (this.status.tracking.LeapStatus === 'Not synchronised') return 'Not Synced'
      return this.status.tracking.LeapStatus || 'Unknown'
    },

    getSyncStatusClass() {
      if (!this.status.tracking) return 'unknown'
      if (this.status.tracking.LeapStatus === 'Normal') return 'synced'
      return 'not-synced'
    },

    getLeapStatusClass() {
      if (!this.status.tracking || !this.status.tracking['Leap status']) return 'unknown'
      const leapStatus = this.status.tracking['Leap status']
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



    async addServers() {
      if (!this.newServers.trim()) return
      
      this.loading.servers = true
      try {
        const serverList = this.newServers
          .split(/[\n,]/)
          .map(s => s.trim())
          .filter(s => s.length > 0)
        
        const response = await fetch(`${this.apiConfig.clockApi}/chrony/servers`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ servers: serverList })
        })
        
        if (response.ok) {
          this.success = `Added ${serverList.length} server(s) successfully`
          this.newServers = ''
          await this.loadServers()
          await this.loadStatus() // Refresh status
        } else {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`)
        }
      } catch (err) {
        this.error = `Failed to add servers: ${err.message}`
      } finally {
        this.loading.servers = false
      }
    },

    async setDefaultServers() {
      this.loading.servers = true
      try {
        const response = await fetch(`${this.apiConfig.clockApi}/chrony/servers/default`, {
          method: 'PUT'
        })
        
        if (response.ok) {
          this.success = 'Default servers set successfully'
          await this.loadServers()
          await this.loadStatus() // Refresh status
        } else {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`)
        }
      } catch (err) {
        this.error = `Failed to set default servers: ${err.message}`
      } finally {
        this.loading.servers = false
      }
    },

    async clearServers() {
      this.loading.servers = true
      try {
        const response = await fetch(`${this.apiConfig.clockApi}/chrony/servers`, {
          method: 'DELETE'
        })
        
        if (response.ok) {
          this.success = 'All servers cleared successfully'
          this.servers = []
          await this.loadStatus() // Refresh status
        } else {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`)
        }
      } catch (err) {
        this.error = `Failed to clear servers: ${err.message}`
      } finally {
        this.loading.servers = false
      }
    }
  }
}
</script>

<style scoped>
.custom-ntp.landscape {
  max-width: 100%;
  margin: 0 auto;
  padding: 0.4rem;
  height: 100vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  background: linear-gradient(135deg, #2d4a2d 0%, #1e3a1e 100%);
}

.ntp-header.compact {
  text-align: center;
  margin-bottom: 0.4rem;
  padding: 0.6rem;
  background: rgba(139, 169, 139, 0.9);
  border-radius: var(--border-radius);
  backdrop-filter: blur(10px);
}

.ntp-title {
  font-size: 1.6rem;
  font-weight: 700;
  color: #2c3e2c;
  margin-bottom: 0.2rem;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
  letter-spacing: 0.3px;
}

.auto-refresh {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.6rem;
  margin-top: 0.2rem;
}

.refresh-toggle {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  color: #2c3e2c;
  font-size: 0.8rem;
  cursor: pointer;
  background: rgba(107, 142, 107, 0.2);
  padding: 0.3rem 0.6rem;
  border-radius: var(--border-radius);
  border: 1px solid rgba(107, 142, 107, 0.4);
  transition: all 0.3s ease;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.15);
}

.refresh-toggle:hover {
  background: rgba(107, 142, 107, 0.3);
  border-color: rgba(107, 142, 107, 0.6);
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
}

.refresh-toggle input[type="checkbox"] {
  display: none;
}

.toggle-slider {
  width: 32px;
  height: 16px;
  background: rgba(255, 255, 255, 0.4);
  border-radius: 8px;
  position: relative;
  transition: background 0.3s ease;
}

.toggle-slider:before {
  content: '';
  position: absolute;
  width: 10px;
  height: 10px;
  background: white;
  border-radius: 50%;
  top: 3px;
  left: 3px;
  transition: transform 0.3s ease;
}

.refresh-toggle input:checked + .toggle-slider {
  background: #6b8e6b;
}

.refresh-toggle input:checked + .toggle-slider:before {
  transform: translateX(16px);
}

.last-update {
  color: rgba(44, 62, 44, 0.8);
  font-size: 0.75rem;
  font-weight: 500;
}

.ntp-content {
  display: flex;
  gap: 0.8rem;
  flex: 1;
  overflow: hidden;
  max-height: calc(100vh - 110px);
}

.left-column {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.6rem;
  overflow-y: auto;
  max-height: 100%;
}

.right-column {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.6rem;
  overflow-y: auto;
  max-height: 100%;
}

.ntp-section {
  background: linear-gradient(135deg, rgba(139, 169, 139, 0.95) 0%, rgba(107, 142, 107, 0.95) 100%);
  border-radius: var(--border-radius);
  padding: 0.8rem;
  margin-bottom: 0.4rem;
  backdrop-filter: blur(10px);
  flex-shrink: 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.ntp-section.compact {
  padding: 0.6rem;
  margin-bottom: 0.4rem;
}

.section-title {
  color: #2c3e2c;
  font-size: 1.1rem;
  margin-bottom: 0.6rem;
  text-align: center;
  font-weight: 700;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
}

/* Status Overview */
.status-overview {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.6rem;
}

.status-item {
  background: rgba(107, 142, 107, 0.15);
  border-radius: var(--border-radius);
  padding: 0.6rem;
  display: flex;
  align-items: center;
  gap: 0.4rem;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s ease;
}

.status-item:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.status-item.primary {
  background: rgba(107, 142, 107, 0.25);
  box-shadow: 0 2px 6px rgba(107, 142, 107, 0.3);
}

.status-icon {
  font-size: 1.1rem;
  flex-shrink: 0;
}

.status-content {
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
}

.status-label {
  color: rgba(44, 62, 44, 0.8);
  font-size: 0.75rem;
  font-weight: 600;
}

.status-value {
  color: #2c3e2c;
  font-size: 0.9rem;
  font-weight: 700;
}

.status-value.synced {
  color: #6b8e6b;
  text-shadow: 0 0 4px rgba(107, 142, 107, 0.3);
  font-weight: 800;
}

.status-value.not-synced {
  color: #d32f2f;
  text-shadow: 0 0 4px rgba(211, 47, 47, 0.3);
  font-weight: 800;
}

.status-value.warning {
  color: #f57c00;
  text-shadow: 0 0 4px rgba(245, 124, 0, 0.3);
  font-weight: 800;
}

/* Tracking Grid */
.tracking-grid.compact {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.4rem;
}

.tracking-item {
  background: rgba(107, 142, 107, 0.1);
  border-radius: var(--border-radius);
  padding: 0.4rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
}

.tracking-label {
  color: rgba(44, 62, 44, 0.8);
  font-size: 0.7rem;
  font-weight: 600;
}

.tracking-value {
  color: #2c3e2c;
  font-size: 0.7rem;
  font-weight: 700;
}

/* Sources Container */
.sources-container.compact {
  margin-top: 0.2rem;
}

.sources-list {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.source-item {
  background: rgba(107, 142, 107, 0.1);
  border-radius: var(--border-radius);
  padding: 0.4rem;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  transition: transform 0.2s ease;
}

.source-item:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
}

.source-item.current {
  background: rgba(107, 142, 107, 0.25);
  box-shadow: 0 2px 6px rgba(107, 142, 107, 0.3);
}

.source-item.selected {
  background: rgba(33, 150, 243, 0.25);
  box-shadow: 0 2px 6px rgba(33, 150, 243, 0.3);
}

.source-item.candidate {
  background: rgba(255, 152, 0, 0.25);
  box-shadow: 0 2px 6px rgba(255, 152, 0, 0.3);
}

.source-item.rejected {
  background: rgba(244, 67, 54, 0.25);
  box-shadow: 0 2px 6px rgba(244, 67, 54, 0.3);
}

.source-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.2rem;
}

.source-name {
  color: #2c3e2c;
  font-weight: 700;
  font-size: 0.85rem;
}

.source-status {
  padding: 0.15rem 0.4rem;
  border-radius: 4px;
  font-size: 0.55rem;
  font-weight: 700;
  text-transform: uppercase;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.15);
}

.source-status.current {
  background: #6b8e6b;
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
  gap: 0.4rem;
  flex-wrap: wrap;
}

.detail {
  color: rgba(44, 62, 44, 0.7);
  font-size: 0.65rem;
  font-weight: 500;
}

/* Activity Stats */
.activity-stats {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.4rem;
}

.stat-item {
  background: rgba(107, 142, 107, 0.1);
  border-radius: var(--border-radius);
  padding: 0.4rem;
  text-align: center;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  transition: transform 0.2s ease;
}

.stat-item:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
}

.stat-icon {
  font-size: 1.1rem;
  display: block;
  margin-bottom: 0.2rem;
}

.stat-label {
  color: rgba(44, 62, 44, 0.8);
  font-size: 0.65rem;
  display: block;
  margin-bottom: 0.15rem;
  font-weight: 600;
}

.stat-value {
  color: #2c3e2c;
  font-size: 0.9rem;
  font-weight: 700;
}

/* Server Management */
.servers-section {
  margin-bottom: 0.6rem;
}

.servers-section h3 {
  color: #2c3e2c;
  font-size: 0.9rem;
  margin-bottom: 0.4rem;
  font-weight: 700;
}

.servers-list.compact {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.server-item {
  background: rgba(107, 142, 107, 0.1);
  border-radius: var(--border-radius);
  padding: 0.4rem 0.6rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  transition: transform 0.2s ease;
}

.server-item:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
}

.server-name {
  color: #2c3e2c;
  font-weight: 600;
  font-size: 0.8rem;
}

.server-status {
  padding: 0.15rem 0.4rem;
  border-radius: 4px;
  font-size: 0.55rem;
  font-weight: 700;
  text-transform: uppercase;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.15);
}

.server-status.current {
  background: #6b8e6b;
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
.add-servers-form.compact {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
}

.form-textarea.compact {
  width: 100%;
  padding: 0.4rem;
  border-radius: var(--border-radius);
  background: rgba(139, 169, 139, 0.8);
  color: #2c3e2c;
  font-family: monospace;
  font-size: 0.75rem;
  resize: vertical;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
}

.form-textarea.compact:focus {
  outline: none;
  background: rgba(139, 169, 139, 0.9);
  box-shadow: 0 2px 8px rgba(107, 142, 107, 0.3);
}

.form-textarea.compact::placeholder {
  color: rgba(44, 62, 44, 0.6);
}

.form-actions.compact {
  display: flex;
  gap: 0.4rem;
  flex-wrap: wrap;
}

.action-btn.compact {
  padding: 0.4rem 0.8rem;
  border: none;
  border-radius: var(--border-radius);
  cursor: pointer;
  font-weight: 700;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.2rem;
  font-size: 0.75rem;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
  text-transform: uppercase;
  letter-spacing: 0.3px;
}

.action-btn.compact:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none !important;
}

.action-btn.compact.primary {
  background: #6b8e6b;
  color: white;
}

.action-btn.compact.primary:hover:not(:disabled) {
  background: #5a7a5a;
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(107, 142, 107, 0.3);
}

.action-btn.compact.secondary {
  background: rgba(107, 142, 107, 0.2);
  color: #2c3e2c;
}

.action-btn.compact.secondary:hover:not(:disabled) {
  background: rgba(107, 142, 107, 0.3);
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(107, 142, 107, 0.2);
}

.action-btn.compact.danger {
  background: #d32f2f;
  color: white;
}

.action-btn.compact.danger:hover:not(:disabled) {
  background: #b71c1c;
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(211, 47, 47, 0.3);
}



/* Clients Container */
.clients-container.compact {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.client-item {
  background: rgba(107, 142, 107, 0.1);
  border-radius: var(--border-radius);
  padding: 0.4rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  transition: transform 0.2s ease;
}

.client-item:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
}

.client-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.2rem;
}

.client-address {
  color: #2c3e2c;
  font-weight: 700;
  font-size: 0.8rem;
}

.client-packets {
  color: rgba(44, 62, 44, 0.7);
  font-size: 0.65rem;
  font-weight: 500;
}

.client-details {
  display: flex;
  gap: 0.4rem;
  flex-wrap: wrap;
}

/* Messages */
.error-message,
.success-message {
  position: fixed;
  top: 20px;
  right: 20px;
  padding: 0.75rem 1.25rem;
  border-radius: var(--border-radius);
  max-width: 350px;
  z-index: 1000;
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
  font-size: 0.8rem;
  box-shadow: 0 3px 12px rgba(0, 0, 0, 0.25);
  border: 2px solid;
}

.error-message {
  background: rgba(244, 67, 54, 0.9);
  color: #ffffff;
  border-color: #d32f2f;
}

.success-message {
  background: rgba(76, 175, 80, 0.9);
  color: #ffffff;
  border-color: #4CAF50;
}

.error-message h3,
.success-message h3 {
  margin: 0 0 0.25rem 0;
  font-size: 1rem;
  font-weight: 700;
}

.error-message p,
.success-message p {
  margin: 0;
  font-size: 0.8rem;
  font-weight: 500;
}

.close-btn {
  background: none;
  border: none;
  color: inherit;
  font-size: 1.1rem;
  cursor: pointer;
  padding: 0;
  margin-left: auto;
  opacity: 0.7;
  font-weight: bold;
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
  color: rgba(44, 62, 44, 0.6);
  font-style: italic;
  padding: 0.6rem;
  font-size: 0.75rem;
  font-weight: 500;
}

/* Responsive Design - Mobile */
@media (max-width: 768px) {
  .custom-ntp.landscape {
    padding: 0.25rem;
  }
  
  .ntp-title {
    font-size: 1.5rem;
  }
  
  .auto-refresh {
    flex-direction: column;
    gap: 0.25rem;
  }
  
  .ntp-content {
    flex-direction: column;
    gap: 0.75rem;
  }
  
  .left-column,
  .right-column {
    overflow-y: visible;
  }
  
  .status-overview {
    grid-template-columns: 1fr;
  }
  
  .tracking-grid.compact {
    grid-template-columns: 1fr;
  }
  
  .activity-stats {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .control-card.compact {
    flex-direction: column;
    gap: 0.5rem;
    text-align: center;
  }
  
  .form-actions.compact {
    flex-direction: column;
  }
  
  .action-btn.compact {
    justify-content: center;
  }
}
</style> 