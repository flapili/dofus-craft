import { defineConfig, presetIcons, presetUno, transformerVariantGroup } from 'unocss'
import { presetScrollbar } from 'unocss-preset-scrollbar'

export default defineConfig({
  presets: [
    presetUno(),
    presetIcons(),
    presetScrollbar(),
  ],

  transformers: [
    transformerVariantGroup(),
  ],
})
