import { isTauri } from '@tauri-apps/api/core'
import { type } from '@tauri-apps/plugin-os'

export default function supportMultiWindows() {
  return isTauri() && ['linux', 'macos', 'windows'].includes(type())
}
