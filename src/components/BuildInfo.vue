<template>
  <div class="build-info" v-if="buildInfo">
    <div class="build-info-content">
      <span class="version">v{{ buildInfo.version }}</span>
      <span class="build-date">{{ formatDate(buildInfo.buildDate) }}</span>
      <span class="environment">{{ buildInfo.environment }}</span>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BuildInfo',
  data() {
    return {
      buildInfo: null
    }
  },
  mounted() {
    this.buildInfo = window.BUILD_INFO || {
      version: '0.1.0-dev',
      buildDate: new Date().toISOString(),
      environment: 'development'
    }
  },
  methods: {
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
    }
  }
}
</script>

<style scoped>
.build-info {
  position: fixed;
  bottom: 10px;
  right: 10px;
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 8px 12px;
  border-radius: 6px;
  font-size: 0.75rem;
  font-family: monospace;
  z-index: 1000;
  backdrop-filter: blur(10px);
}

.build-info-content {
  display: flex;
  gap: 12px;
  align-items: center;
}

.version {
  color: #4CAF50;
  font-weight: bold;
}

.build-date {
  color: #ccc;
}

.environment {
  color: #FF9800;
  text-transform: uppercase;
  font-size: 0.7rem;
}

/* Hide in production unless debug is enabled */
@media (min-width: 768px) {
  .build-info {
    opacity: 0.7;
    transition: opacity 0.3s ease;
  }
  
  .build-info:hover {
    opacity: 1;
  }
}
</style> 