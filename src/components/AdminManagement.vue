<template>
  <Layout>
    <!-- Page Title in Header -->
    <template #pageTitle>
      <h1 class="page-title">Admin Management</h1>
    </template>
    
    <!-- Page Controls in Header -->
    <template #pageControls>
      <div class="admin-info">
        <span class="admin-role">Super Administrator</span>
        <span class="last-update">Last updated: {{ lastUpdateTime }}</span>
      </div>
    </template>
    
    <!-- Main Content -->
    <div class="admin-management">
      <!-- Main Content -->
      <div class="admin-main">
        <!-- Navigation Tabs -->
        <div class="admin-tabs">
          <button 
            v-for="tab in tabs" 
            :key="tab.id"
            :class="['tab-btn', { active: activeTab === tab.id }]"
            @click="activeTab = tab.id"
          >
            <span class="tab-icon">{{ tab.icon }}</span>
            <span class="tab-label">{{ tab.label }}</span>
          </button>
        </div>

        <!-- Tab Content -->
        <div class="tab-content">
          <!-- Users Tab -->
          <div v-if="activeTab === 'users'" class="tab-panel">
            <div class="panel-header">
              <h2>User Management</h2>
              <button @click="showUserModal = true" class="add-btn">
                <span class="btn-icon">➕</span>
                Add User
              </button>
            </div>
            
            <div class="data-table">
              <table>
                <thead>
                  <tr>
                    <th>Username</th>
                    <th>First Name</th>
                    <th>Last Name</th>
                    <th>Email</th>
                    <th>Role</th>
                    <th>Status</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="user in users" :key="user.id">
                    <td>{{ user.username }}</td>
                    <td>{{ user.first_name || 'N/A' }}</td>
                    <td>{{ user.last_name || 'N/A' }}</td>
                    <td>{{ user.email || 'N/A' }}</td>
                    <td>
                      <span class="role-tag" :class="user.role">{{ user.role }}</span>
                    </td>
                    <td>
                      <span class="status-badge" :class="{ active: user.is_active }">
                        {{ user.is_active ? 'Active' : 'Inactive' }}
                      </span>
                    </td>
                    <td>
                      <div class="action-buttons">
                        <button @click="editUser(user)" class="action-btn edit">Edit</button>
                        <button @click="deleteUser(user)" class="action-btn delete">Delete</button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Roles Tab -->
          <div v-if="activeTab === 'roles'" class="tab-panel">
            <div class="panel-header">
              <h2>Role Management</h2>
              <button @click="showRoleModal = true" class="add-btn">
                <span class="btn-icon">➕</span>
                Add Role
              </button>
            </div>
            
            <div class="data-table">
              <table>
                <thead>
                  <tr>
                    <th>Role Name</th>
                    <th>Description</th>
                    <th>Permissions</th>
                    <th>Type</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="role in roles" :key="role.id">
                    <td>{{ role.name }}</td>
                    <td>{{ role.description || 'No description' }}</td>
                    <td>
                      <div class="permissions-list">
                        <span v-for="perm in role.permissions.slice(0, 3)" :key="perm.id" class="permission-tag">
                          {{ perm.name }}
                        </span>
                        <span v-if="role.permissions.length > 3" class="more-permissions">
                          +{{ role.permissions.length - 3 }} more
                        </span>
                      </div>
                    </td>
                    <td>
                      <span class="role-type" :class="{ system: isDefaultRole(role.name) }">
                        {{ isDefaultRole(role.name) ? 'System' : 'Custom' }}
                      </span>
                    </td>
                    <td>
                      <div class="action-buttons">
                        <button @click="editRole(role)" class="action-btn edit">Edit</button>
                        <button 
                          v-if="!isDefaultRole(role.name)"
                          @click="deleteRole(role)" 
                          class="action-btn delete"
                        >
                          Delete
                        </button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Permissions Tab -->
          <div v-if="activeTab === 'permissions'" class="tab-panel">
            <div class="panel-header">
              <h2>Permission Management</h2>
              <button @click="showPermissionModal = true" class="add-btn">
                <span class="btn-icon">➕</span>
                Add Permission
              </button>
            </div>
            
            <div class="data-table">
              <table>
                <thead>
                  <tr>
                    <th>Permission Name</th>
                    <th>Description</th>
                    <th>Resource</th>
                    <th>Action</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="permission in permissions" :key="permission.id">
                    <td>{{ permission.name }}</td>
                    <td>{{ permission.description || 'No description' }}</td>
                    <td>{{ permission.resource }}</td>
                    <td>{{ permission.action }}</td>
                    <td>
                      <div class="action-buttons">
                        <button @click="editPermission(permission)" class="action-btn edit">Edit</button>
                        <button @click="deletePermission(permission)" class="action-btn delete">Delete</button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- User Modal -->
    <div v-if="showUserModal" class="modal-overlay" @click="showUserModal = false">
      <div class="modal" @click.stop>
        <div class="modal-header">
          <h3>{{ editingUser ? 'Edit User' : 'Add User' }}</h3>
          <button @click="showUserModal = false" class="close-btn">×</button>
        </div>
        <form @submit.prevent="saveUser" class="modal-body">
          <div class="form-group">
            <label>Username</label>
            <input v-model="userForm.username" type="text" required :disabled="editingUser">
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>First Name</label>
              <input v-model="userForm.first_name" type="text">
            </div>
            <div class="form-group">
              <label>Last Name</label>
              <input v-model="userForm.last_name" type="text">
            </div>
          </div>
          <div class="form-group">
            <label>Password</label>
            <input v-model="userForm.password" type="password" :required="!editingUser">
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Email</label>
              <input v-model="userForm.email" type="email">
            </div>
            <div class="form-group">
              <label>Role</label>
              <select v-model="userForm.role_id" required>
                <option value="">Select Role</option>
                <option v-for="role in roles" :key="role.id" :value="role.id">
                  {{ role.name }}
                </option>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="checkbox-label">
              <input v-model="userForm.is_active" type="checkbox">
              Active
            </label>
          </div>
          <div class="modal-actions">
            <button type="button" class="btn-secondary" @click="showUserModal = false">Cancel</button>
            <button type="submit" class="btn-primary">Save</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Role Modal -->
    <div v-if="showRoleModal" class="modal-overlay" @click="showRoleModal = false">
      <div class="modal" @click.stop>
        <div class="modal-header">
          <h3>{{ editingRole ? 'Edit Role' : 'Add Role' }}</h3>
          <button @click="showRoleModal = false" class="close-btn">×</button>
        </div>
        <form @submit.prevent="saveRole" class="modal-body">
          <div class="form-group">
            <label>Role Name</label>
            <input v-model="roleForm.name" type="text" required>
          </div>
          <div class="form-group">
            <label>Description</label>
            <textarea v-model="roleForm.description" rows="3"></textarea>
          </div>
          <div class="form-group">
            <label>Permissions</label>
            <div class="permissions-selector">
              <label v-for="permission in permissions" :key="permission.id" class="checkbox-label">
                <input 
                  type="checkbox" 
                  :value="permission.id" 
                  v-model="roleForm.permissions"
                >
                {{ permission.name }} - {{ permission.description }}
              </label>
            </div>
          </div>
          <div class="modal-actions">
            <button type="button" class="btn-secondary" @click="showRoleModal = false">Cancel</button>
            <button type="submit" class="btn-primary">Save</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Permission Modal -->
    <div v-if="showPermissionModal" class="modal-overlay" @click="showPermissionModal = false">
      <div class="modal" @click.stop>
        <div class="modal-header">
          <h3>{{ editingPermission ? 'Edit Permission' : 'Add Permission' }}</h3>
          <button @click="showPermissionModal = false" class="close-btn">×</button>
        </div>
        <form @submit.prevent="savePermission" class="modal-body">
          <div class="form-group">
            <label>Permission Name</label>
            <input v-model="permissionForm.name" type="text" required>
          </div>
          <div class="form-group">
            <label>Description</label>
            <textarea v-model="permissionForm.description" rows="3"></textarea>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Resource</label>
              <input v-model="permissionForm.resource" type="text" required>
            </div>
            <div class="form-group">
              <label>Action</label>
              <input v-model="permissionForm.action" type="text" required>
            </div>
          </div>
          <div class="modal-actions">
            <button type="button" class="btn-secondary" @click="showPermissionModal = false">Cancel</button>
            <button type="submit" class="btn-primary">Save</button>
          </div>
        </form>
      </div>
    </div>
  </Layout>
</template>

<script>
import authMixin from '../mixins/auth.js'
import Layout from './Layout.vue'

export default {
  name: 'AdminManagement',
  data() {
    return {
      activeTab: 'users',
      lastUpdateTime: new Date().toLocaleTimeString(),
      tabs: [
        { id: 'users', label: 'Users', icon: '👥' },
        { id: 'roles', label: 'Roles', icon: '🔐' },
        { id: 'permissions', label: 'Permissions', icon: '🔑' }
      ],
      
      // Data
      users: [],
      roles: [],
      permissions: [],
      
      // Modals
      showUserModal: false,
      showRoleModal: false,
      showPermissionModal: false,
      
      // Forms
      userForm: {
        username: '',
        password: '',
        email: '',
        first_name: '',
        last_name: '',
        role_id: null,
        is_active: true
      },
      roleForm: {
        name: '',
        description: '',
        permissions: []
      },
      permissionForm: {
        name: '',
        description: '',
        resource: '',
        action: ''
      },
      
      // Editing states
      editingUser: null,
      editingRole: null,
      editingPermission: null
    }
  },
  
  mixins: [authMixin],
  
  components: {
    Layout
  },
  
  async mounted() {
    if (!this.requireAuth()) return
    if (!this.isSuperAdmin()) {
      this.$router.push('/')
      return
    }
    
    await this.loadData()
  },
  
  methods: {
    isSuperAdmin() {
      return this.user && this.user.role === 'super-admin'
    },
    
    isDefaultRole(roleName) {
      return ['super-admin', 'admin', 'user'].includes(roleName)
    },
    
    async loadData() {
      await Promise.all([
        this.loadUsers(),
        this.loadRoles(),
        this.loadPermissions()
      ])
    },
    
    async loadUsers() {
      try {
        const response = await fetch('/api/auth/admin/users', {
          headers: this.getAuthHeaders()
        })
        if (response.ok) {
          const data = await response.json()
          this.users = data.users || []
        }
      } catch (error) {
        console.error('Failed to load users:', error)
      }
    },
    
    async loadRoles() {
      try {
        const response = await fetch('/api/auth/admin/roles', {
          headers: this.getAuthHeaders()
        })
        if (response.ok) {
          const data = await response.json()
          this.roles = data.roles || []
        }
      } catch (error) {
        console.error('Failed to load roles:', error)
      }
    },
    
    async loadPermissions() {
      try {
        const response = await fetch('/api/auth/admin/permissions', {
          headers: this.getAuthHeaders()
        })
        if (response.ok) {
          const data = await response.json()
          this.permissions = data.permissions || []
        }
      } catch (error) {
        console.error('Failed to load permissions:', error)
      }
    },
    
    // User methods
    editUser(user) {
      this.editingUser = user
      this.userForm = {
        username: user.username,
        password: '',
        email: user.email || '',
        first_name: user.first_name || '',
        last_name: user.last_name || '',
        role_id: user.role_id,
        is_active: user.is_active
      }
      this.showUserModal = true
    },
    
    async saveUser() {
      try {
        const url = this.editingUser 
          ? `/api/auth/admin/users/${this.editingUser.id}`
          : '/api/auth/admin/users'
        
        const method = this.editingUser ? 'PUT' : 'POST'
        const body = { ...this.userForm }
        
        if (this.editingUser) {
          delete body.password
          delete body.username
        }
        
        const response = await fetch(url, {
          method,
          headers: this.getAuthHeaders(),
          body: JSON.stringify(body)
        })
        
        if (response.ok) {
          await this.loadUsers()
          this.showUserModal = false
          this.resetUserForm()
        } else {
          const error = await response.json()
          alert(`Error: ${error.error}`)
        }
      } catch (error) {
        console.error('Failed to save user:', error)
        alert('Failed to save user')
      }
    },
    
    async deleteUser(user) {
      if (!confirm(`Are you sure you want to delete user "${user.username}"?`)) return
      
      try {
        const response = await fetch(`/api/auth/admin/users/${user.id}`, {
          method: 'DELETE',
          headers: this.getAuthHeaders()
        })
        
        if (response.ok) {
          await this.loadUsers()
        } else {
          const error = await response.json()
          alert(`Error: ${error.error}`)
        }
      } catch (error) {
        console.error('Failed to delete user:', error)
        alert('Failed to delete user')
      }
    },
    
    // Role methods
    editRole(role) {
      this.editingRole = role
      this.roleForm = {
        name: role.name,
        description: role.description || '',
        permissions: role.permissions.map(p => p.id)
      }
      this.showRoleModal = true
    },
    
    async saveRole() {
      try {
        const url = this.editingRole 
          ? `/api/auth/admin/roles/${this.editingRole.id}`
          : '/api/auth/admin/roles'
        
        const method = this.editingRole ? 'PUT' : 'POST'
        
        const response = await fetch(url, {
          method,
          headers: this.getAuthHeaders(),
          body: JSON.stringify(this.roleForm)
        })
        
        if (response.ok) {
          await this.loadRoles()
          this.showRoleModal = false
          this.resetRoleForm()
        } else {
          const error = await response.json()
          alert(`Error: ${error.error}`)
        }
      } catch (error) {
        console.error('Failed to save role:', error)
        alert('Failed to save role')
      }
    },
    
    async deleteRole(role) {
      if (!confirm(`Are you sure you want to delete role "${role.name}"?`)) return
      
      try {
        const response = await fetch(`/api/auth/admin/roles/${role.id}`, {
          method: 'DELETE',
          headers: this.getAuthHeaders()
        })
        
        if (response.ok) {
          await this.loadRoles()
        } else {
          const error = await response.json()
          alert(`Error: ${error.error}`)
        }
      } catch (error) {
        console.error('Failed to delete role:', error)
        alert('Failed to delete role')
      }
    },
    
    // Permission methods
    editPermission(permission) {
      this.editingPermission = permission
      this.permissionForm = {
        name: permission.name,
        description: permission.description || '',
        resource: permission.resource,
        action: permission.action
      }
      this.showPermissionModal = true
    },
    
    async savePermission() {
      try {
        const url = this.editingPermission 
          ? `/api/auth/admin/permissions/${this.editingPermission.id}`
          : '/api/auth/admin/permissions'
        
        const method = this.editingPermission ? 'PUT' : 'POST'
        
        const response = await fetch(url, {
          method,
          headers: this.getAuthHeaders(),
          body: JSON.stringify(this.permissionForm)
        })
        
        if (response.ok) {
          await this.loadPermissions()
          this.showPermissionModal = false
          this.resetPermissionForm()
        } else {
          const error = await response.json()
          alert(`Error: ${error.error}`)
        }
      } catch (error) {
        console.error('Failed to save permission:', error)
        alert('Failed to save permission')
      }
    },
    
    async deletePermission(permission) {
      if (!confirm(`Are you sure you want to delete permission "${permission.name}"?`)) return
      
      try {
        const response = await fetch(`/api/auth/admin/permissions/${permission.id}`, {
          method: 'DELETE',
          headers: this.getAuthHeaders()
        })
        
        if (response.ok) {
          await this.loadPermissions()
        } else {
          const error = await response.json()
          alert(`Error: ${error.error}`)
        }
      } catch (error) {
        console.error('Failed to delete permission:', error)
        alert('Failed to delete permission')
      }
    },
    
    // Form reset methods
    resetUserForm() {
      this.userForm = {
        username: '',
        password: '',
        email: '',
        first_name: '',
        last_name: '',
        role_id: null,
        is_active: true
      }
      this.editingUser = null
    },
    
    resetRoleForm() {
      this.roleForm = {
        name: '',
        description: '',
        permissions: []
      }
      this.editingRole = null
    },
    
    resetPermissionForm() {
      this.permissionForm = {
        name: '',
        description: '',
        resource: '',
        action: ''
      }
      this.editingPermission = null
    }
  }
}
</script>

<style scoped>
.admin-management {
  height: 100vh;
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

/* Admin Info Styles */
.admin-info {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 0.25rem;
  margin-left: auto;
  padding-right: 1rem;
  min-height: 1.5rem;
  justify-content: center;
}

.admin-role {
  color: #4CAF50;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  background: rgba(76, 175, 80, 0.1);
  padding: 0.2rem 0.5rem;
  border-radius: 12px;
}

.last-update {
  color: #6c757d;
  font-size: 0.75rem;
  font-weight: 500;
  white-space: nowrap;
}

/* Main Content */
.admin-main {
  flex: 1;
  padding: 1rem;
  overflow-y: auto;
  background: #f5f5f5;
}

/* Tabs */
.admin-tabs {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
  background: rgba(255, 255, 255, 0.9);
  border-radius: 12px;
  padding: 0.5rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.tab-btn {
  background: rgba(255, 255, 255, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.3);
  color: #2c3e50;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
  font-weight: 500;
}

.tab-btn:hover {
  background: rgba(255, 255, 255, 0.8);
  transform: translateY(-1px);
}

.tab-btn.active {
  background: #4CAF50;
  color: white;
  box-shadow: 0 2px 8px rgba(76, 175, 80, 0.3);
}

.tab-icon {
  font-size: 1.1rem;
}

/* Tab Content */
.tab-content {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.tab-panel {
  padding: 1.5rem;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e9ecef;
}

.panel-header h2 {
  color: #2c3e50;
  font-size: 1.25rem;
  margin: 0;
  font-weight: 600;
}

.add-btn {
  background: #4CAF50;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
  font-weight: 500;
}

.add-btn:hover {
  background: #45a049;
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(76, 175, 80, 0.3);
}

.btn-icon {
  font-size: 1rem;
}

/* Data Table */
.data-table {
  overflow-x: auto;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

table {
  width: 100%;
  border-collapse: collapse;
  background: white;
}

th, td {
  padding: 0.75rem;
  text-align: left;
  border-bottom: 1px solid #e9ecef;
}

th {
  background: #f8f9fa;
  font-weight: 600;
  color: #2c3e50;
  font-size: 0.85rem;
}

td {
  font-size: 0.9rem;
  color: #2c3e50;
}

/* Role Tags */
.role-tag {
  padding: 0.2rem 0.5rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: capitalize;
}

.role-tag.super-admin {
  background: rgba(156, 39, 176, 0.2);
  color: #9c27b0;
}

.role-tag.admin {
  background: rgba(33, 150, 243, 0.2);
  color: #2196f3;
}

.role-tag.user {
  background: rgba(76, 175, 80, 0.2);
  color: #4caf50;
}

/* Status Badges */
.status-badge {
  padding: 0.2rem 0.5rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  background: rgba(108, 117, 125, 0.2);
  color: #6c757d;
}

.status-badge.active {
  background: rgba(76, 175, 80, 0.2);
  color: #4caf50;
}

/* Action Buttons */
.action-buttons {
  display: flex;
  gap: 0.5rem;
}

.action-btn {
  padding: 0.3rem 0.6rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.75rem;
  font-weight: 500;
  transition: all 0.2s ease;
}

.action-btn.edit {
  background: #2196f3;
  color: white;
}

.action-btn.edit:hover {
  background: #1976d2;
}

.action-btn.delete {
  background: #f44336;
  color: white;
}

.action-btn.delete:hover {
  background: #d32f2f;
}

/* Permissions List */
.permissions-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.25rem;
}

.permission-tag {
  background: #e3f2fd;
  color: #1976d2;
  padding: 0.2rem 0.4rem;
  border-radius: 8px;
  font-size: 0.65rem;
  font-weight: 500;
}

.more-permissions {
  color: #6c757d;
  font-size: 0.65rem;
  font-style: italic;
}

/* Role Type */
.role-type {
  padding: 0.2rem 0.5rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  background: rgba(76, 175, 80, 0.2);
  color: #4caf50;
}

.role-type.system {
  background: rgba(156, 39, 176, 0.2);
  color: #9c27b0;
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
}

.modal {
  background: white;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  max-width: 500px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #e0e0e0;
}

.modal-header h3 {
  margin: 0;
  color: var(--dark-gray);
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #666;
}

.close-btn:hover {
  color: #333;
}

.modal-body {
  padding: 1.5rem;
}

/* Form Styles */
.form-group {
  margin-bottom: 1rem;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  color: #2c3e50;
  font-weight: 500;
  font-size: 0.9rem;
}

input, select, textarea {
  width: 100%;
  padding: 0.6rem;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 0.9rem;
  transition: border-color 0.3s ease;
}

input:focus, select:focus, textarea:focus {
  outline: none;
  border-color: #4CAF50;
  box-shadow: 0 0 0 2px rgba(76, 175, 80, 0.2);
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
}

.checkbox-label input[type="checkbox"] {
  width: auto;
}

.permissions-selector {
  max-height: 200px;
  overflow-y: auto;
  border: 1px solid #ddd;
  border-radius: var(--border-radius);
  padding: 1rem;
}

.permissions-selector .checkbox-label {
  margin-bottom: 0.5rem;
}

.modal-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
}

.btn-primary {
  background: #4CAF50;
  color: white;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 500;
}

.btn-primary:hover {
  background: #45a049;
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(76, 175, 80, 0.3);
}

.btn-secondary {
  background: #f8f9fa;
  color: #2c3e50;
  border: 1px solid #dee2e6;
  padding: 0.6rem 1.2rem;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 500;
}

.btn-secondary:hover {
  background: #e9ecef;
  transform: translateY(-1px);
}

/* Responsive Design */
@media (max-width: 768px) {
  .admin-title {
    font-size: 1rem;
  }
  
  .admin-tabs {
    flex-direction: column;
  }
  
  .panel-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }
  
  .form-row {
    grid-template-columns: 1fr;
  }
  
  .modal {
    width: 95%;
    margin: 1rem;
  }
  
  .header-left {
    gap: 1rem;
  }
  
  .header-right {
    gap: 1rem;
  }
  
  .admin-info {
    display: none;
  }
}
</style> 