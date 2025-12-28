<script setup lang="ts">
import { ref, onMounted } from "vue";
import { api } from "./api";

const status = ref<string>("loading...");

onMounted(async () => {
  try {
    const response = await api.get("/health");
    status.value = response.data.status;
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
