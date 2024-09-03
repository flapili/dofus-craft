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
    height: 600,
    width: 300,
  })
  windowToCraft.value.once('tauri://error', console.warn)
})

const search = ref('')

const inputElement = ref<HTMLButtonElement>()
const { focused } = useFocus(inputElement)
const { results } = useFuse(search, Object.values(recipes).filter(item => item.recipe), {
  fuseOptions: {
    keys: ['name'],
    threshold: 0.4,
  },
})

const limitResults = useArrayFilter(results, (_, index) => index < 10)

const activeElement = useActiveElement()
const itemContainerElement = ref<HTMLDivElement>()

onKeyStroke(['ArrowDown', 'ArrowUp'], (e) => {
  e.preventDefault()

  let targetElement: HTMLButtonElement | undefined
  if (activeElement.value && activeElement.value.parentElement === itemContainerElement.value) {
    if (e.key === 'ArrowDown') {
      targetElement = activeElement.value.nextElementSibling as HTMLButtonElement
    }
    else if (e.key === 'ArrowUp') {
      targetElement = activeElement.value.previousElementSibling as HTMLButtonElement
    }
  }
  else {
    if (e.key === 'ArrowDown') {
      targetElement = itemContainerElement.value?.firstElementChild as HTMLButtonElement
    }
    else if (e.key === 'ArrowUp') {
      targetElement = itemContainerElement.value?.lastElementChild as HTMLButtonElement
    }
  }

  if (targetElement) {
    targetElement.focus()
  }
})

onKeyStroke('Backspace', () => {
  if (!focused.value) {
    focused.value = true
  }
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

const { Ctrl_Escape } = useMagicKeys()
watch(Ctrl_Escape, reset)
</script>

<template>
  <div class="size-full flex flex-col bg-stone-500">
    <div class="w-full flex p-2.5">
      <input ref="inputElement" v-model="search" autocomplete="off" spellcheck="false" class="w-full rounded-sm bg-stone-100 px-2 py-0.5 outline-none focus:bg-blue-50" placeholder="Nom de l'item">
    </div>
    <div ref="itemContainerElement" class="m-2 mt-0 flex flex-grow flex-col flex-gap-x-2 flex-gap-y-1 overflow-auto overflow-auto pb-4 scrollbar-thumb-color-stone-100 scrollbar-track-color-transparent scrollbar-radius-2 scrollbar-track-radius-4 scrollbar-w-8px scrollbar">
      <button v-for="result in limitResults" :key="result.item.id" class="w-full border border-gray-700 rounded-sm bg-stone-300 px-1.5 py-0.5 outline-none active:bg-blue-400 focus:bg-blue-300 hover:bg-blue-200" @click="addItemToCraft(result.item.id as unknown as ItemId)">
        {{ result.item.name }}
      </button>
    </div>
    <button class="flex items-center justify-center bg-red-700 px-1.5 py-0.5 text-white outline-none focus:bg-red-600 hover:bg-red-600" @click="reset">
      <i class="i-material-symbols:delete-forever m-1.5 block text-2xl" />
    </button>
  </div>
</template>
