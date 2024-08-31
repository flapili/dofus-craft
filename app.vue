<script setup lang="ts">
import type { WebviewWindow } from '@tauri-apps/api/webviewWindow'
import { getCurrentWebviewWindow } from '@tauri-apps/api/webviewWindow'

const toCraft = useToCraft()

const currentWebviewWindow = ref<WebviewWindow>()
onMounted(() => {
  if (!supportMultiWindows())
    return

  currentWebviewWindow.value = getCurrentWebviewWindow()
  currentWebviewWindow.value.listen<Record<number, number>>('toCraft', (event) => {
    toCraft.value = event.payload
  })
})
</script>

<template>
  <div class="size-screen flex">
    <NuxtPage />
  </div>
</template>
