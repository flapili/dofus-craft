import type recipes from '@/assets//recipes.json'

export type ItemId = keyof typeof recipes

export default function useToCraft() {
  return useState<{ [key in ItemId]?: number }>(() => reactive({}))
}
