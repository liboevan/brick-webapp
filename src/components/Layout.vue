<template>
  <div class="layout">
    <!-- Header with User Avatar and Navigation Ball -->
    <Header v-if="showHeader">
      <!-- Page Title Slot -->
      <template #pageTitle>
        <slot name="pageTitle" />
      </template>
      
      <!-- Page Controls Slot -->
      <template #pageControls>
        <slot name="pageControls" />
      </template>
    </Header>
    
    <!-- Main Content -->
    <div class="layout-main">
      <slot />
    </div>
  </div>
</template>

<script>
import Header from './Header.vue'
import authMixin from '../mixins/auth.js'

export default {
  name: 'Layout',
  components: {
    Header
  },
  mixins: [authMixin],
  computed: {
    showHeader() {
      // Show header on all pages except login
      return this.$route.path !== '/login'
    }
  }
}
</script>

<style scoped>
.layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.layout-main {
  flex: 1;
  min-height: 0;
  background: #f5f5f5;
}
</style> 