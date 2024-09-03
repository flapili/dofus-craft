<script setup lang="ts">
import { WebviewWindow } from '@tauri-apps/api/webviewWindow'

import recipes from '@/assets/recipes.json'

const activeTab = ref<'components' | 'actionPlan'>('components')

const toCraft = useToCraft()

const components = computed(() => {
  const result: { [K in ItemId]?: number } = {}
  for (const [itemId, quantity] of Object.entries(toCraft.value)) {
    const recipe = recipes[itemId as ItemId].recipe
    if (recipe === null) {
      result[itemId as ItemId] = quantity
      continue
    }
    for (const [componentId, componentQuantity] of Object.entries(recipe)) {
      result[componentId as ItemId] = (result[componentId as ItemId] ?? 0) + componentQuantity * quantity
    }
  }
  return result
})

const actionPlan = computed(() => {
  const result: { [key: string]: {
    level: number
    items: { [K in ItemId]?: number }
  } } = {}

  for (const [itemId, quantity] of Object.entries(toCraft.value)) {
    const item = recipes[itemId as ItemId]
    const level = item.profession?.level
    const professionName = item.profession?.name

    if (level === undefined || professionName === undefined) {
      continue
    }

    if (result[professionName] === undefined) {
      result[professionName] = {
        level,
        items: {},
      }
    }
    if (result[professionName].level < level) {
      result[professionName].level = level
    }
    result[professionName].items[itemId as ItemId] = quantity
  }

  return result
})

async function removeItem(itemId: ItemId) {
  toCraft.value[itemId] = (toCraft.value[itemId] ?? 0) - 1
  if (toCraft.value[itemId] <= 0) {
    delete toCraft.value[itemId]
  }

  if (supportMultiWindows()) {
    const windowMain = await WebviewWindow.getByLabel('main')
    windowMain?.emit('toCraft', toCraft.value)
  }
}

async function decomposeRecipe(itemId: ItemId, quantity: number) {
  toCraft.value[itemId] = (toCraft.value[itemId] ?? 0) + quantity

  if (supportMultiWindows()) {
    const windowMain = await WebviewWindow.getByLabel('main')
    windowMain?.emit('toCraft', toCraft.value)
  }
}

onKeyStroke(['ArrowLeft', 'ArrowRight'], (e) => {
  e.preventDefault()
  if (e.key === 'ArrowLeft') {
    activeTab.value = 'components'
  }
  else if (e.key === 'ArrowRight') {
    activeTab.value = 'actionPlan'
  }
})
</script>

<template>
  <div
    data-tauri-drag-region
    :class="{ 'select-none bg-opacity-40': supportMultiWindows() }"
    class="size-full flex flex-col bg-stone-500"
  >
    <div class="w-full flex text-lg children:(w-full p-2)">
      <button
        data-tauri-drag-region
        :class="{
          'bg-stone-500 text-stone-100': activeTab === 'components',
          'bg-stone-400': activeTab !== 'components',
        }"
        @click="activeTab = 'components'"
      >
        Composants
      </button>
      <button
        data-tauri-drag-region
        :class="{
          'bg-stone-500 text-stone-100': activeTab === 'actionPlan',
          'bg-stone-400': activeTab !== 'actionPlan',
        }"
        @click="activeTab = 'actionPlan'"
      >
        Plan d'action
      </button>
    </div>

    <div class="ml-2 overflow-auto py-4 text-stone-100 scrollbar-thumb-color-stone-100 scrollbar-track-color-transparent scrollbar-radius-2 scrollbar-track-radius-4 scrollbar-w-8px scrollbar">
      <ul v-if="activeTab === 'components'" class="flex flex-col flex-gap-1">
        <template v-for="[componentId, quantity] in Object.entries(components)" :key="componentId">
          <li v-if="quantity - (toCraft[componentId as ItemId] ?? 0) > 0" data-tauri-drag-region>
            {{ recipes[componentId as ItemId].name }} x {{ quantity - (toCraft[componentId as ItemId] ?? 0) }}
            <button v-if="recipes[componentId as ItemId].recipe" @click="decomposeRecipe(componentId as ItemId, quantity)">
              <i class="i-game-icons:stone-crafting block" />
            </button>
          </li>
        </template>
      </ul>

      <ul v-if="activeTab === 'actionPlan'">
        <li v-for="[profession, { items, level }] in Object.entries(actionPlan)" :key="profession">
          <h2>{{ profession }} ({{ level }})</h2>
          <ul class="ml-2">
            <li v-for="[itemId, quantity] in Object.entries(items)" :key="itemId" data-tauri-drag-region>
              {{ recipes[itemId as ItemId].name }} x {{ quantity }}
              <button @click="removeItem(itemId as ItemId)">
                <i class="i-material-symbols:delete-forever block" />
              </button>
            </li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</template>
