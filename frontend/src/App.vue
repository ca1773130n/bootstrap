<script setup lang="ts">
import { ref, onMounted } from "vue";
import { apiClient } from "./api/client";

const status = ref<string>("loading...");

onMounted(async () => {
  try {
    const response = await apiClient.health();
    status.value = response.status || "ok";
  } catch {
    status.value = "error";
  }
});
</script>

<template>
  <main>
    <h1>App</h1>
    <p>API Status: {{ status }}</p>
  </main>
</template>
