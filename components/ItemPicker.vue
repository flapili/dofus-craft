<script setup lang="ts">
import { useFuse } from '@vueuse/integrations/useFuse'
import { WebviewWindow, getCurrentWebviewWindow } from '@tauri-apps/api/webviewWindow'
import { exit } from '@tauri-apps/plugin-process'

import recipes from '@/assets/recipes.json'

const toCraft = useToCraft()

const mainWindow = ref<WebviewWindow>()
const windowToCraft = ref<WebviewWindow>()
onMounted(() => {
  if (!supportMultiWindows())
    return

  mainWindow.value = getCurrentWebviewWindow()
  mainWindow.value.once('tauri://close-requested', async () => {
    await exit(0)
  })

  windowToCraft.value = new WebviewWindow('toCraft', {
    url: '/toCraft',
    decorations: false,
    transparent: true,
    alwaysOnTop: true,
  })
  windowToCraft.value.once('tauri://error', console.warn)
})

const search = ref('')
const inputElement = ref<HTMLInputElement>()
const { focused } = useFocus(inputElement)
const { results } = useFuse(search, Object.values(recipes), {
  fuseOptions: {
    keys: ['name'],
  },
})

onStartTyping(() => {
  if (!focused.value) {
    focused.value = true
  }
})

async function addItemToCraft(itemId: ItemId) {
  toCraft.value[itemId] = (toCraft.value[itemId] ?? 0) + 1
  // Aka no web or mobile, sync windows
  if (supportMultiWindows())
    await windowToCraft.value?.emit('toCraft', toCraft.value)
}

async function reset() {
  toCraft.value = {}
  // Aka no web or mobile, sync windows
  if (supportMultiWindows())
    await windowToCraft.value?.emit('toCraft', toCraft.value)
}
</script>

<template>
  <div class="size-full flex flex-col bg-stone-500">
    <div class="w-full flex p-2.5">
      <input ref="inputElement" v-model="search" class="w-full px-2 py-0.5" placeholder="Nom de l'item">
    </div>
    <ul class="m-2 mt-0 flex flex-grow flex-wrap flex-gap-x-2 flex-gap-y-1 overflow-auto overflow-auto py-4 scrollbar-thumb-color-stone-100 scrollbar-track-color-transparent scrollbar-radius-2 scrollbar-track-radius-4 scrollbar-w-8px scrollbar">
      <li v-for="result in results" :key="result.item.id" class="border border-gray-700 bg-stone-300 px-1.5 py-0.5">
        <button @click="addItemToCraft(result.item.id as unknown as ItemId)">
          {{ result.item.name }}
        </button>
      </li>
    </ul>
    <button class="bg-red-700 px-1.5 py-0.5 text-white" @click="reset">
      Reset
    </button>
  </div>
</template>
