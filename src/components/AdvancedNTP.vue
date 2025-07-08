<template>
  <div class="advanced-ntp-modal">
    <div class="modal-header">
      <h2>Advanced NTP Management</h2>
      <button class="close-btn" @click="$emit('close')">×</button>
    </div>
    <div class="tabs">
      <button :class="{active: tab==='servers'}" @click="tab='servers'">NTP Servers</button>
      <button :class="{active: tab==='clients'}" @click="tab='clients'" :disabled="!serverModeEnabled">Connected Clients</button>
    </div>
    <div class="tab-content">
      <div v-if="tab==='servers'">
        <h3>Manage NTP Servers</h3>
        <ul class="server-list">
          <li v-for="(server, idx) in servers" :key="server.name" class="server-item">
            <span>{{ server.name }}</span>
            <span class="server-status">{{ server.state }}</span>
            <button @click="removeServer(idx)" title="Remove">🗑️</button>
            <button @click="moveServer(idx, -1)" :disabled="idx===0" title="Move Up">⬆️</button>
            <button @click="moveServer(idx, 1)" :disabled="idx===servers.length-1" title="Move Down">⬇️</button>
          </li>
        </ul>
        <div class="add-server">
          <input v-model="newServer" placeholder="Add NTP server (hostname or IP)" />
          <button @click="addServer">Add</button>
        </div>
        <div class="server-actions">
          <button @click="resetToDefault">Reset to Default</button>
          <button @click="saveServers" :disabled="saving">Save</button>
        </div>
        <div v-if="serverMessage" class="message">{{ serverMessage }}</div>
      </div>
      <div v-else-if="tab==='clients'">
        <h3>Connected Clients</h3>
        <button @click="fetchClients" :disabled="loadingClients">Refresh</button>
        <table class="clients-table" v-if="clients.length">
          <thead>
            <tr>
              <th>Address</th>
              <th>NTP Packets</th>
              <th>Dropped</th>
              <th>Offset</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="client in clients" :key="client.address">
              <td>{{ client.address }}</td>
              <td>{{ client.ntp_packets || '-' }}</td>
              <td>{{ client.ntp_dropped || '-' }}</td>
              <td>{{ client.offset || '-' }}</td>
            </tr>
          </tbody>
        </table>
        <div v-else class="empty">No clients connected.</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'

// Props
const props = defineProps({
  serverModeEnabled: Boolean
})

// State
const tab = ref('servers')
const servers = ref([]) // [{name, state, ...}]
const newServer = ref('')
const saving = ref(false)
const serverMessage = ref('')
const clients = ref([])
const loadingClients = ref(false)

// Fetch servers from API
async function fetchServers() {
  // TODO: Replace with real API call
  try {
    const config = window.BRICK_CONFIG.api.customNTP
    const res = await fetch(`${config.baseUrl}${config.endpoints.status}?flags=2`)
    if (res.ok) {
      const data = await res.json()
      servers.value = (data.sources || []).map(s => ({...s}))
    } else {
      serverMessage.value = 'Failed to fetch servers.'
    }
  } catch (e) {
    serverMessage.value = 'Error fetching servers.'
  }
}

// Save servers to API
async function saveServers() {
  saving.value = true
  serverMessage.value = ''
  try {
    const config = window.BRICK_CONFIG.api.customNTP
    const res = await fetch(`${config.baseUrl}/servers`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ servers: servers.value.map(s => s.name) })
    })
    if (res.ok) {
      serverMessage.value = 'Servers updated.'
      await fetchServers()
    } else {
      serverMessage.value = 'Failed to update servers.'
    }
  } catch (e) {
    serverMessage.value = 'Error updating servers.'
  } finally {
    saving.value = false
  }
}

// Add server
function addServer() {
  if (!newServer.value.trim()) return
  servers.value.push({ name: newServer.value.trim(), state: '?' })
  newServer.value = ''
}

// Remove server
function removeServer(idx) {
  servers.value.splice(idx, 1)
}

// Move server up/down
function moveServer(idx, dir) {
  const newIdx = idx + dir
  if (newIdx < 0 || newIdx >= servers.value.length) return
  const temp = servers.value[idx]
  servers.value[idx] = servers.value[newIdx]
  servers.value[newIdx] = temp
}

// Reset to default servers
async function resetToDefault() {
  serverMessage.value = ''
  try {
    const config = window.BRICK_CONFIG.api.customNTP
    const res = await fetch(`${config.baseUrl}/servers/default`, { method: 'PUT' })
    if (res.ok) {
      serverMessage.value = 'Reset to default servers.'
      await fetchServers()
    } else {
      serverMessage.value = 'Failed to reset.'
    }
  } catch (e) {
    serverMessage.value = 'Error resetting servers.'
  }
}

// Fetch clients from API
async function fetchClients() {
  loadingClients.value = true
  try {
    const config = window.BRICK_CONFIG.api.customNTP
    const res = await fetch(`${config.baseUrl}${config.endpoints.status}/clients`)
    if (res.ok) {
      const data = await res.json()
      clients.value = data.clients || []
    } else {
      clients.value = []
    }
  } catch (e) {
    clients.value = []
  } finally {
    loadingClients.value = false
  }
}

// Watch for tab change to fetch clients
watch(tab, (val) => {
  if (val === 'clients' && props.serverModeEnabled) {
    fetchClients()
  }
})

// On mount, fetch servers
onMounted(() => {
  fetchServers()
})
</script>

<style scoped>
.advanced-ntp-modal {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 4px 24px rgba(0,0,0,0.18);
  max-width: 600px;
  margin: 2rem auto;
  padding: 1.5rem;
  position: relative;
}
.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}
.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
}
.tabs {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}
.tabs button {
  background: #f5f5f5;
  border: none;
  padding: 0.5rem 1.2rem;
  border-radius: 6px 6px 0 0;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}
.tabs button.active {
  background: #4CAF50;
  color: #fff;
}
.tab-content {
  background: #fafbfc;
  border-radius: 0 0 8px 8px;
  padding: 1rem;
}
.server-list {
  list-style: none;
  padding: 0;
  margin: 0 0 1rem 0;
}
.server-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0;
  border-bottom: 1px solid #eee;
}
.server-status {
  font-size: 0.8rem;
  color: #888;
  margin-left: 0.5rem;
}
.add-server {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
}
.add-server input {
  flex: 1;
  padding: 0.4rem 0.7rem;
  border-radius: 5px;
  border: 1px solid #ccc;
}
.server-actions {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}
.server-actions button {
  padding: 0.5rem 1rem;
  border-radius: 5px;
  border: none;
  background: #4CAF50;
  color: #fff;
  font-weight: 600;
  cursor: pointer;
}
.server-actions button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
.message {
  color: #2196F3;
  margin-top: 0.5rem;
}
.clients-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}
.clients-table th, .clients-table td {
  border: 1px solid #eee;
  padding: 0.5rem;
  text-align: left;
}
.empty {
  color: #888;
  margin-top: 1rem;
}
</style> 