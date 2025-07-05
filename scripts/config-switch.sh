#!/bin/bash

# Configuration Switch Script
# Switch between development and production configurations

set -e

ACTION=${1:-help}

case $ACTION in
    "dev")
        echo "🔄 Switching to development configuration..."
        cp public/config.dev.js public/config.js
        echo "✅ Development configuration activated!"
        echo "📍 Gateway URL: localhost:17000"
        echo "📍 API paths: /clock/api, /sentinel/api"
        echo "🔧 Debug mode: enabled"
        ;;
    
    "prod")
        echo "🔄 Switching to production configuration..."
        cp public/config.prod.js public/config.js
        echo "✅ Production configuration activated!"
        echo "📍 Gateway URL: localhost:17000"
        echo "📍 API paths: /clock/api, /sentinel/api"
        echo "🔧 Debug mode: disabled"
        ;;
    
    "backup")
        echo "💾 Creating configuration backup..."
        cp public/config.js public/config.backup.$(date +%Y%m%d_%H%M%S).js
        echo "✅ Backup created!"
        ;;
    
    "restore")
        echo "🔄 Restoring from backup..."
        if [ -f public/config.js.backup ]; then
            cp public/config.js.backup public/config.js
            echo "✅ Configuration restored!"
        else
            echo "❌ No backup found!"
        fi
        ;;
    
    "show")
        echo "📋 Current configuration:"
        echo ""
        if [ -f public/config.js ]; then
            grep -E "(baseUrl|clockUrl|sentinelUrl|environment|debug)" public/config.js | head -10
        else
            echo "❌ No config.js found!"
        fi
        ;;
    
    "help"|*)
        echo "Configuration Switch Script"
        echo ""
        echo "Usage: ./scripts/config-switch.sh [action]"
        echo ""
        echo "Actions:"
        echo "  dev      - Switch to development config"
        echo "  prod     - Switch to production config"
        echo "  backup   - Create configuration backup"
        echo "  restore  - Restore from backup"
        echo "  show     - Show current configuration"
        echo "  help     - Show this help"
        echo ""
        echo "Examples:"
        echo "  ./scripts/config-switch.sh dev"
        echo "  ./scripts/config-switch.sh prod"
        echo ""
        echo "Note: Changes take effect after page refresh"
        ;;
esac 