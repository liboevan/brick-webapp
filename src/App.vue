<template>
  <div id="app">
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'App'
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
  min-height: 100vh;
  color: #333;
}

#app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* Green theme variables */
:root {
  --primary-green: #4CAF50;
  --dark-green: #45a049;
  --light-green: #81C784;
  --accent-green: #66BB6A;
  --white: #ffffff;
  --light-gray: #f5f5f5;
  --dark-gray: #333333;
  --shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  --border-radius: 12px;
}
</style> 