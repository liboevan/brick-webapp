<template>
  <div class="modal-overlay">
    <div class="modal-content">
      <div class="modal-header">
        <h2 class="modal-title">
          <span class="title-icon">🗂️</span>
          Manage NTP Servers
        </h2>
        <button class="close-btn" @click="$emit('close')" title="Close">
          <span class="close-icon">×</span>
        </button>
      </div>

      <div class="modal-body">
        <!-- Server List Section -->
        <div class="section">
          <h3 class="section-title">
            <span class="section-icon">📡</span>
            Configured Servers
            <span class="server-count">({{ servers.length }})</span>
          </h3>
          <div class="server-list-container">
            <div v-if="servers.length === 0" class="empty-state">
              <div class="empty-icon">📡</div>
              <p>No servers configured</p>
              <p class="empty-hint">Add servers to get started</p>
            </div>
            <div v-else class="server-list">
              <div v-for="(server, idx) in servers" :key="server.name" class="server-item">
                <div class="server-info">
                  <div class="server-name">{{ server.name }}</div>
                  <div class="server-status">
                    <span class="status-dot" :class="getStatusClass(server.state)"></span>
                    {{ getStatusText(server.state) }}
                  </div>
                </div>
                <div class="server-actions">
                  <button 
                    @click="moveServer(idx, -1)" 
                    :disabled="idx === 0" 
                    class="action-btn move-btn" 
                    title="Move Up"
                  >
                    <span class="btn-icon">⬆️</span>
                  </button>
                  <button 
                    @click="moveServer(idx, 1)" 
                    :disabled="idx === servers.length - 1" 
                    class="action-btn move-btn" 
                    title="Move Down"
                  >
                    <span class="btn-icon">⬇️</span>
                  </button>
                  <button 
                    @click="removeServer(idx)" 
                    class="action-btn remove-btn" 
                    title="Remove Server"
                  >
                    <span class="btn-icon">🗑️</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Add Server Section -->
        <div class="section">
          <h3 class="section-title">
            <span class="section-icon">➕</span>
            Add New Server
          </h3>
          <div class="add-server-container">
            <div class="input-group">
              <input 
                v-model="newServer" 
                @keyup.enter="addServer"
                placeholder="Enter NTP server (e.g., pool.ntp.org)" 
                class="server-input"
              />
              <button 
                @click="addServer" 
                :disabled="!newServer.trim()"
                class="add-btn"
              >
                <span class="btn-icon">➕</span>
                Add
              </button>
            </div>
            <div class="input-hint">
              Enter a hostname or IP address of an NTP server
            </div>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="action-buttons">
          <button 
            @click="resetToDefault" 
            class="action-btn secondary-btn"
            :disabled="saving"
          >
            <span class="btn-icon">🔄</span>
            Reset to Default
          </button>
          <button 
            @click="saveServers" 
            :disabled="saving || servers.length === 0"
            class="action-btn primary-btn"
          >
            <span v-if="saving" class="loading-spinner">⏳</span>
            <span v-else class="btn-icon">💾</span>
            {{ saving ? 'Saving...' : 'Save Changes' }}
          </button>
        </div>

        <!-- Message Display -->
        <div v-if="serverMessage" class="message" :class="getMessageClass()">
          <span class="message-icon">{{ getMessageIcon() }}</span>
          {{ serverMessage }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
const servers = ref([])
const newServer = ref('')
const saving = ref(false)
const serverMessage = ref('')

// Helper function to get auth headers
function getAuthHeaders() {
  const token = localStorage.getItem('jwt_token')
  if (token) {
    return {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  }
  return {
    'Content-Type': 'application/json'
  }
}

async function fetchServers() {
  try {
    const config = window.BRICK_CONFIG.api.customNTP
    const res = await fetch(`${config.baseUrl}${config.endpoints.servers}`, {
      headers: getAuthHeaders()
    })
    if (res.ok) {
      const data = await res.json()
      console.log('fetchServers response:', data)
      // Transform server names to the expected format with state
      servers.value = (data.servers || []).map(serverName => ({
        name: serverName,
        state: '?' // Default state for configured servers
      }))
    } else {
      serverMessage.value = 'Failed to fetch servers.'
      console.error('Failed to fetch servers:', res.status, await res.text())
    }
  } catch (e) {
    serverMessage.value = 'Error fetching servers.'
    console.error('Error fetching servers:', e)
  }
}

async function saveServers() {
  if (servers.value.length === 0) {
    serverMessage.value = 'You must have at least one server.'
    return
  }
  saving.value = true
  serverMessage.value = ''
  try {
    const config = window.BRICK_CONFIG.api.customNTP
    const payload = { servers: servers.value.map(s => s.name) }
    console.log('saveServers payload:', payload)
    const res = await fetch(`${config.baseUrl}${config.endpoints.servers}`, {
      method: 'PUT',
      headers: getAuthHeaders(),
      body: JSON.stringify(payload)
    })
    const resText = await res.text()
    console.log('saveServers response:', res.status, resText)
    if (res.ok) {
      serverMessage.value = 'Servers updated successfully!'
      await fetchServers()
    } else {
      serverMessage.value = 'Failed to update servers: ' + resText
    }
  } catch (e) {
    serverMessage.value = 'Error updating servers.'
    console.error('Error updating servers:', e)
  } finally {
    saving.value = false
  }
}

function addServer() {
  if (!newServer.value.trim()) return
  servers.value.push({ name: newServer.value.trim(), state: '?' })
  newServer.value = ''
}

function removeServer(idx) {
  servers.value.splice(idx, 1)
}

function moveServer(idx, dir) {
  const newIdx = idx + dir
  if (newIdx < 0 || newIdx >= servers.value.length) return
  const temp = servers.value[idx]
  servers.value[idx] = servers.value[newIdx]
  servers.value[newIdx] = temp
}

async function resetToDefault() {
  serverMessage.value = ''
  try {
    const config = window.BRICK_CONFIG.api.customNTP
    const res = await fetch(`${config.baseUrl}${config.endpoints.defaultServers}`, { 
      method: 'PUT',
      headers: getAuthHeaders()
    })
    if (res.ok) {
      serverMessage.value = 'Reset to default servers successfully!'
      await fetchServers()
    } else {
      const errText = await res.text()
      serverMessage.value = 'Failed to reset: ' + errText
    }
  } catch (e) {
    serverMessage.value = 'Error resetting servers.'
  }
}

// Helper functions for UI
function getStatusText(state) {
  const statusMap = {
    '^': 'Current',
    '*': 'Selected', 
    '+': 'Candidate',
    '-': 'Rejected',
    '?': 'Unknown'
  }
  return statusMap[state] || 'Unknown'
}

function getStatusClass(state) {
  const classMap = {
    '^': 'current',
    '*': 'selected',
    '+': 'candidate', 
    '-': 'rejected',
    '?': 'unknown'
  }
  return classMap[state] || 'unknown'
}

function getMessageClass() {
  if (serverMessage.value.includes('successfully')) return 'success'
  if (serverMessage.value.includes('Failed') || serverMessage.value.includes('Error')) return 'error'
  return 'info'
}

function getMessageIcon() {
  if (serverMessage.value.includes('successfully')) return '✅'
  if (serverMessage.value.includes('Failed') || serverMessage.value.includes('Error')) return '❌'
  return 'ℹ️'
}

onMounted(() => {
  fetchServers()
})
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.6);
  backdrop-filter: blur(4px);
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.modal-content {
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  border-radius: 20px;
  width: 600px;
  height: 600px;
  max-width: 90vw;
  max-height: 90vh;
  box-shadow: 0 20px 60px rgba(0,0,0,0.3);
  position: relative;
  overflow: hidden;
  border: 1px solid rgba(255,255,255,0.2);
  display: flex;
  flex-direction: column;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 2rem;
  background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
  color: white;
  border-bottom: 1px solid rgba(255,255,255,0.1);
  flex-shrink: 0;
}

.modal-title {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
}

.title-icon {
  font-size: 1.25rem;
}

.close-btn {
  background: rgba(255,255,255,0.2);
  border: none;
  border-radius: 50%;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s ease;
  color: white;
}

.close-btn:hover {
  background: rgba(255,255,255,0.3);
  transform: scale(1.1);
}

.close-icon {
  font-size: 1.25rem;
  font-weight: bold;
}

.modal-body {
  padding: 2rem;
  overflow-y: auto;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.section {
  margin-bottom: 1.5rem;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin: 0 0 1rem 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: #2c3e50;
}

.section-icon {
  font-size: 1rem;
}

.server-count {
  font-size: 0.9rem;
  color: #6c757d;
  font-weight: normal;
  margin-left: 0.5rem;
}

.server-list-container {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 1rem;
  border: 1px solid #e9ecef;
  max-height: 200px;
  overflow-y: auto;
}

.empty-state {
  text-align: center;
  padding: 2rem;
  color: #6c757d;
}

.empty-icon {
  font-size: 2.5rem;
  margin-bottom: 1rem;
  opacity: 0.5;
}

.empty-hint {
  font-size: 0.85rem;
  margin-top: 0.5rem;
  opacity: 0.7;
}

.server-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.server-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem;
  background: white;
  border-radius: 6px;
  border: 1px solid #e9ecef;
  transition: all 0.2s ease;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}

.server-item:hover {
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  transform: translateY(-1px);
}

.server-info {
  flex: 1;
  min-width: 0;
}

.server-name {
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 0.25rem;
  font-size: 0.9rem;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.server-status {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.75rem;
  color: #6c757d;
}

.status-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #6c757d;
  flex-shrink: 0;
}

.status-dot.current { background: #28a745; }
.status-dot.selected { background: #007bff; }
.status-dot.candidate { background: #ffc107; }
.status-dot.rejected { background: #dc3545; }
.status-dot.unknown { background: #6c757d; }

.server-actions {
  display: flex;
  gap: 0.25rem;
  flex-shrink: 0;
}

.action-btn {
  padding: 0.4rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 28px;
  height: 28px;
}

.move-btn {
  background: #e9ecef;
  color: #495057;
}

.move-btn:hover:not(:disabled) {
  background: #dee2e6;
  transform: scale(1.05);
}

.move-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.remove-btn {
  background: #f8d7da;
  color: #721c24;
}

.remove-btn:hover {
  background: #f5c6cb;
  transform: scale(1.05);
}

.btn-icon {
  font-size: 0.75rem;
}

.add-server-container {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 1rem;
  border: 1px solid #e9ecef;
}

.input-group {
  display: flex;
  gap: 0.75rem;
  margin-bottom: 0.5rem;
}

.server-input {
  flex: 1;
  padding: 0.6rem 0.8rem;
  border: 2px solid #e9ecef;
  border-radius: 6px;
  font-size: 0.9rem;
  transition: all 0.2s ease;
  background: white;
}

.server-input:focus {
  outline: none;
  border-color: #4CAF50;
  box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.1);
}

.add-btn {
  padding: 0.6rem 1rem;
  background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
  color: white;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  gap: 0.4rem;
  white-space: nowrap;
  font-size: 0.85rem;
}

.add-btn:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3);
}

.add-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.input-hint {
  font-size: 0.8rem;
  color: #6c757d;
  font-style: italic;
}

.action-buttons {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: auto;
  padding-top: 1rem;
  border-top: 1px solid #e9ecef;
  flex-shrink: 0;
}

.primary-btn {
  background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
  color: white;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
}

.primary-btn:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3);
}

.secondary-btn {
  background: #6c757d;
  color: white;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
}

.secondary-btn:hover:not(:disabled) {
  background: #5a6268;
  transform: translateY(-1px);
}

.action-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.loading-spinner {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.message {
  margin-top: 1rem;
  padding: 0.75rem;
  border-radius: 6px;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 500;
  font-size: 0.9rem;
}

.message.success {
  background: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}

.message.error {
  background: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
}

.message.info {
  background: #d1ecf1;
  color: #0c5460;
  border: 1px solid #bee5eb;
}

.message-icon {
  font-size: 1rem;
}

/* Responsive design */
@media (max-width: 768px) {
  .modal-content {
    width: 95vw;
    height: 90vh;
    margin: 1rem;
  }
  
  .modal-header {
    padding: 1rem 1.5rem;
  }
  
  .modal-body {
    padding: 1.5rem;
  }
  
  .input-group {
    flex-direction: column;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .server-list-container {
    max-height: 150px;
  }
}
</style> 