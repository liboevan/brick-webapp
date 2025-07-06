// Dashboard Configuration
// Uses runtime configuration from /config.js

// Get runtime configuration
const getRuntimeConfig = () => {
  if (!window.BRICK_CONFIG) {
    console.error('❌ BRICK_CONFIG not found! Please ensure /config.js is loaded.')
    throw new Error('Configuration file not loaded. Please check /config.js exists and is loaded before the app.')
  }
  return window.BRICK_CONFIG
}

// Convert runtime config to dashboard format
export const getConfig = () => {
  const config = getRuntimeConfig()
  
  return {
    title: config.app.title,
    subtitle: "Your modular system management",
    
    // Features from runtime config
    features: [
      {
        id: 'customNTP',
        title: config.features.customNTP.title,
        description: config.features.customNTP.description,
        icon: config.features.customNTP.icon,
        url: config.features.customNTP.url,
        color: config.features.customNTP.color,
        enabled: config.features.customNTP.enabled
      },
      {
        id: 'security',
        title: config.features.sentinel.title,
        description: config.features.sentinel.description,
        icon: config.features.sentinel.icon,
        url: config.features.sentinel.url,
        color: config.features.sentinel.color,
        enabled: config.features.sentinel.enabled
      },
      {
        id: 'gateway',
        title: config.features.gateway.title,
        description: config.features.gateway.description,
        icon: config.features.gateway.icon,
        url: config.features.gateway.url,
        color: config.features.gateway.color,
        enabled: config.features.gateway.enabled
      },
      {
        id: 'login',
        title: config.features.login.title,
        description: config.features.login.description,
        icon: config.features.login.icon,
        url: config.features.login.url,
        color: config.features.login.color,
        enabled: config.features.login.enabled
      }
    ],

    // System information from runtime config
    system: {
      name: config.system.name,
      version: config.system.version,
      status: config.system.status
    },

    // Theme configuration
    theme: {
      primaryColor: '#4CAF50',
      secondaryColor: '#45a049',
      accentColor: '#66BB6A'
    }
  }
}

// API configuration getter
export const getApiConfig = () => {
  const config = getRuntimeConfig()
  return {
    gatewayUrl: config.api.baseUrl,
    customNTPApi: config.api.customNTP.baseUrl, // Use the customNTP baseUrl directly
    sentinelApi: config.api.sentinel.baseUrl
  }
}

// Environment getter
export const getEnvironment = () => {
  const config = getRuntimeConfig()
  return config.app.environment
} 