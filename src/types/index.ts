// User and Authentication Types
export interface User {
  id: number
  username: string
  email?: string
  first_name?: string
  last_name?: string
  role: string
  is_active: boolean
  permissions: string[]
}

export interface LoginRequest {
  username: string
  password: string
}

export interface LoginResponse {
  token: string
  expires_at: string
  user: User
  permissions: string[]
}


export interface ServerModeRequest {
  enabled: boolean
}

export interface ServerModeResponse {
  success: boolean
  server_mode_enabled: boolean
}

// API Configuration Types
export interface APIConfig {
  baseUrl: string
  customNTP: {
    baseUrl: string
    endpoints: {
      status: string
      servers: string
      serverMode: string
      version: string
      defaultServers: string
    }
  },
  sentinel: {
    baseUrl: string
    endpoints: {
      health: string
      metrics: string
      alerts: string
      configure: string
    }
  }
}



export interface AppConfig {
  title: string
  version: string
  environment: string
}

export interface FeatureConfig {
  enabled: boolean
  title: string
  description: string
  icon: string
  url: string
  color: string
}

export interface SystemConfig {
  name: string
  version: string
  status: string
}

export interface DebugConfig {
  enabled: boolean
  logLevel: string
}

export interface BrickConfig {
  api: APIConfig
  app: AppConfig
  features: Record<string, FeatureConfig>
  system: SystemConfig
  debug: DebugConfig
}

// Build Info Types
export interface BuildInfo {
  version: string
  buildDateTime: string
  buildTimestamp: number
  environment: string
  service: string
  description: string
}

// Component Props and Events
export interface ModalProps {
  serverModeEnabled?: boolean
}

export interface ModalEvents {
  close: () => void
}

// Router Types
export interface RouteMeta {
  requiresAuth?: boolean
  requiresSuperAdmin?: boolean
  title?: string
  [key: string]: unknown
  [key: symbol]: unknown
}

// Global Window Object
declare global {
  interface Window {
    BRICK_CONFIG: BrickConfig
    BUILD_INFO?: BuildInfo
  }
}