<template>
  <div class="modal-overlay">
    <div class="modal-content">
      <div class="modal-header">
        <h2 class="modal-title">
          <span class="title-icon">👥</span>
          Connected Clients
        </h2>
        <button class="close-btn" @click="$emit('close')" title="Close">
          <span class="close-icon">×</span>
        </button>
      </div>

      <div class="modal-body">
        <div v-if="!serverModeEnabled" class="disabled-state">
          <div class="disabled-icon">🛑</div>
          <h3>Server Mode Disabled</h3>
          <p>Enable server mode to view connected clients</p>
          <div class="disabled-hint">
            Server mode allows this NTP server to accept client connections
          </div>
        </div>

        <div v-else>
          <!-- Header with refresh button -->
          <div class="section-header">
            <div class="header-info">
              <h3 class="section-title">
                <span class="section-icon">📊</span>
                Client Connections
                <span class="client-count">({{ clients.length }})</span>
              </h3>
              <p class="section-subtitle">
                {{ clients.length }} client{{ clients.length !== 1 ? 's' : '' }} connected
              </p>
            </div>
            <button 
              @click="fetchClients" 
              :disabled="loadingClients"
              class="refresh-btn"
              title="Refresh client list"
            >
              <span v-if="loadingClients" class="loading-spinner">⏳</span>
              <span v-else class="btn-icon">🔄</span>
              {{ loadingClients ? 'Refreshing...' : 'Refresh' }}
            </button>
          </div>

          <!-- Clients Table -->
          <div class="clients-container">
            <div v-if="clients.length === 0" class="empty-state">
              <div class="empty-icon">👥</div>
              <h3>No Clients Connected</h3>
              <p>No NTP clients are currently connected to this server</p>
              <div class="empty-hint">
                Clients will appear here when they connect to this NTP server
              </div>
            </div>
            
            <div v-else class="clients-table-container">
              <table class="clients-table">
                <thead>
                  <tr>
                    <th class="th-address">
                      <span class="th-icon">🌐</span>
                      Client Address
                    </th>
                    <th class="th-packets">
                      <span class="th-icon">📦</span>
                      NTP Packets
                    </th>
                    <th class="th-dropped">
                      <span class="th-icon">❌</span>
                      Dropped
                    </th>
                    <th class="th-offset">
                      <span class="th-icon">⏱️</span>
                      Offset
                    </th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="client in clients" :key="client.address" class="client-row">
                    <td class="client-address">
                      <div class="address-info">
                        <span class="address-text">{{ client.address }}</span>
                        <span class="connection-status">
                          <span class="status-dot active"></span>
                          Connected
                        </span>
                      </div>
                    </td>
                    <td class="client-packets">
                      <span class="packet-count">{{ client.ntp_packets || '0' }}</span>
                    </td>
                    <td class="client-dropped">
                      <span class="dropped-count" :class="{ 'has-dropped': client.ntp_dropped > 0 }">
                        {{ client.ntp_dropped || '0' }}
                      </span>
                    </td>
                    <td class="client-offset">
                      <span class="offset-value">{{ client.offset || 'N/A' }}</span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Connection Info -->
          <div class="connection-info">
            <div class="info-card">
              <div class="info-icon">📡</div>
              <div class="info-content">
                <h4>Server Mode Active</h4>
                <p>Accepting NTP client connections on port 123/UDP</p>
              </div>
            </div>
            <div class="info-card">
              <div class="info-icon">🔒</div>
              <div class="info-content">
                <h4>Security Note</h4>
                <p>Only trusted clients should connect to this NTP server</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
const props = defineProps({ serverModeEnabled: Boolean })
const clients = ref([])
const loadingClients = ref(false)

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

watch(() => props.serverModeEnabled, (enabled) => {
  if (enabled) fetchClients()
})
onMounted(() => {
  if (props.serverModeEnabled) fetchClients()
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
  width: 700px;
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
  background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
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

.disabled-state {
  text-align: center;
  padding: 2rem;
  color: #6c757d;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.disabled-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
  opacity: 0.5;
}

.disabled-state h3 {
  margin: 0 0 1rem 0;
  font-size: 1.3rem;
  color: #495057;
}

.disabled-state p {
  margin: 0 0 1rem 0;
  font-size: 1rem;
}

.disabled-hint {
  font-size: 0.9rem;
  opacity: 0.7;
  max-width: 400px;
  margin: 0 auto;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e9ecef;
  flex-shrink: 0;
}

.header-info {
  flex: 1;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin: 0 0 0.5rem 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: #2c3e50;
}

.section-icon {
  font-size: 1rem;
}

.client-count {
  font-size: 0.9rem;
  color: #6c757d;
  font-weight: normal;
  margin-left: 0.5rem;
}

.section-subtitle {
  margin: 0;
  color: #6c757d;
  font-size: 0.9rem;
}

.refresh-btn {
  padding: 0.6rem 1rem;
  background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
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

.refresh-btn:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(33, 150, 243, 0.3);
}

.refresh-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.btn-icon {
  font-size: 0.8rem;
}

.loading-spinner {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.clients-container {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 1rem;
  border: 1px solid #e9ecef;
  margin-bottom: 1rem;
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.empty-state {
  text-align: center;
  padding: 2rem;
  color: #6c757d;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.empty-icon {
  font-size: 2.5rem;
  margin-bottom: 1rem;
  opacity: 0.5;
}

.empty-state h3 {
  margin: 0 0 1rem 0;
  font-size: 1.2rem;
  color: #495057;
}

.empty-state p {
  margin: 0 0 1rem 0;
  font-size: 0.9rem;
}

.empty-hint {
  font-size: 0.8rem;
  opacity: 0.7;
  max-width: 350px;
  margin: 0 auto;
}

.clients-table-container {
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.clients-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.85rem;
  flex: 1;
}

.clients-table thead {
  position: sticky;
  top: 0;
  z-index: 10;
}

.clients-table th {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  padding: 0.75rem;
  text-align: left;
  font-weight: 600;
  color: #495057;
  border-bottom: 2px solid #dee2e6;
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.8rem;
}

.th-icon {
  font-size: 0.75rem;
}

.clients-table td {
  padding: 0.75rem;
  border-bottom: 1px solid #f1f3f4;
  vertical-align: middle;
}

.client-row {
  transition: background-color 0.2s ease;
}

.client-row:hover {
  background-color: #f8f9fa;
}

.client-address {
  width: 35%;
}

.address-info {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
}

.address-text {
  font-weight: 600;
  color: #2c3e50;
  font-family: 'Courier New', monospace;
  font-size: 0.8rem;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.connection-status {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.7rem;
  color: #6c757d;
}

.status-dot {
  width: 5px;
  height: 5px;
  border-radius: 50%;
}

.status-dot.active {
  background: #28a745;
}

.client-packets, .client-dropped, .client-offset {
  text-align: center;
}

.packet-count {
  font-weight: 600;
  color: #28a745;
  font-size: 0.8rem;
}

.dropped-count {
  font-weight: 600;
  color: #6c757d;
  font-size: 0.8rem;
}

.dropped-count.has-dropped {
  color: #dc3545;
}

.offset-value {
  font-family: 'Courier New', monospace;
  font-size: 0.75rem;
  color: #495057;
}

.connection-info {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  flex-shrink: 0;
}

.info-card {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
  padding: 0.75rem;
  background: #f8f9fa;
  border-radius: 6px;
  border: 1px solid #e9ecef;
}

.info-icon {
  font-size: 1.2rem;
  opacity: 0.7;
  flex-shrink: 0;
}

.info-content h4 {
  margin: 0 0 0.4rem 0;
  font-size: 0.9rem;
  font-weight: 600;
  color: #2c3e50;
}

.info-content p {
  margin: 0;
  font-size: 0.8rem;
  color: #6c757d;
  line-height: 1.3;
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
  
  .section-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }
  
  .refresh-btn {
    align-self: flex-end;
  }
  
  .connection-info {
    grid-template-columns: 1fr;
  }
  
  .clients-table {
    font-size: 0.75rem;
  }
  
  .clients-table th,
  .clients-table td {
    padding: 0.5rem 0.4rem;
  }
}
</style> 