<script setup lang="ts">
import defaultPreset from '@/assets/defaultPreset.json'
import SvgIcon from '@/components/common/SvgIcon/index.vue'
import { useBasicLayout } from '@/hooks/useBasicLayout'
import { fetchHomePresetsAPI } from '@/api/models'
import { ref, onMounted } from 'vue'

interface Props {
  isHideDefaultPreset: boolean
}
const { isMobile } = useBasicLayout()
defineProps<Props>()
const emit = defineEmits<{
  (e: 'click', box: { appId?: number; prompt: any; model?: string; modelName?: string }): void
}>()

const randomItems = ref<any[]>([])

const getRandomColorClass = () => {
  const colors = [
    'text-red-500',
    'text-blue-500',
    'text-green-500',
    'text-yellow-500',
    'text-purple-500',
    'text-pink-500',
    'text-indigo-500',
  ]
  return colors[Math.floor(Math.random() * colors.length)]
}

// 获取模型预设
const fetchHomePresets = async () => {
  try {
    const { data } = await fetchHomePresetsAPI<any>()
    if (data && Array.isArray(data) && data.length > 0) {
      randomItems.value = data.slice(0, 8)
    } else {
      // 如果没有预设数据，使用默认预设
      randomItems.value = defaultPreset.sort(() => 0.5 - Math.random()).slice(0, 8)
    }
  } catch (error) {
    console.error('获取模型预设失败:', error)
    // 出错时使用默认预设
    randomItems.value = defaultPreset.sort(() => 0.5 - Math.random()).slice(0, 8)
  }
}

onMounted(() => {
  fetchHomePresets()
})
</script>

<template>
  <div v-if="!isHideDefaultPreset && !isMobile" class="w-full flex justify-center items-center">
    <div class="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <div v-for="item in randomItems" :key="item.title" class="mx-2">
        <button @click="emit('click', item)" class="btn-pill rounded-2xl p-3 h-full w-[8rem]">
          <div class="flex items-center gap-2 w-full">
            <SvgIcon
              :icon="item.icon || 'ri:robot-line'"
              :class="['mb-0 inline-block text-base', item.iconColor || getRandomColorClass()]"
            />
            <div class="flex-grow text-gray-600 dark:text-gray-500 text-sm truncate">
              {{ item.title }}
            </div>
          </div>
        </button>
      </div>
    </div>
  </div>
</template>
