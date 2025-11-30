<script setup lang="ts">
import defaultPreset from '@/assets/defaultPreset.json'
import SvgIcon from '@/components/common/SvgIcon/index.vue'
import { fetchHomePresetsAPI } from '@/api/models'
import { useAuthStore, useChatStore } from '@/store'
import { useBasicLayout } from '@/hooks/useBasicLayout'
import { computed, onMounted, ref } from 'vue'

interface Props {
  isHideDefaultPreset: boolean
}
const { isMobile } = useBasicLayout()
defineProps<Props>()
const emit = defineEmits<{
  (e: 'click', box: { appId?: number; prompt: any }): void
}>()

const authStore = useAuthStore()
const chatStore = useChatStore()

// 模型预设数据
const modelPresets = ref([])

// 从后端配置获取预设，如果没有则使用默认预设
const homePresets = computed(() => {
  try {
    const configPresets = authStore.globalConfig?.homePresets
    if (configPresets) {
      const parsed = JSON.parse(configPresets)
      if (Array.isArray(parsed) && parsed.length > 0) {
        return parsed
      }
    }
  } catch (error) {
    console.error('解析首页预设配置失败:', error)
  }
  // 如果没有配置或解析失败，使用默认预设
  return defaultPreset
})

// 合并模型预设和普通预设，优先显示模型预设
const allPresets = computed(() => {
  const combined = [...modelPresets.value, ...homePresets.value]
  return combined.slice(0, 8) // 最多显示8个
})

// 随机选择预设项，最多显示8个
const randomItems = computed(() => {
  const items = [...allPresets.value]
  return items.sort(() => 0.5 - Math.random()).slice(0, 8)
})

// 获取模型预设
const fetchModelPresets = async () => {
  try {
    const res: any = await fetchHomePresetsAPI()
    if (res.data && Array.isArray(res.data)) {
      modelPresets.value = res.data
    }
  } catch (error) {
    console.error('获取模型预设失败:', error)
  }
}

// 组件挂载时获取模型预设
onMounted(() => {
  fetchModelPresets()
})

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
</script>

<template>
  <div v-if="!isHideDefaultPreset && !isMobile && randomItems.length > 0" class="w-full flex justify-center items-center px-4">
    <div class="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-4 gap-4 max-w-5xl w-full">
      <div 
        v-for="(item, index) in randomItems" 
        :key="item.title" 
        class="animate-fade-in-up"
        :style="{ animationDelay: `${index * 0.1}s` }"
      >
        <button 
          @click="emit('click', item)" 
          class="group relative w-full h-full min-h-[5rem] rounded-2xl p-4 bg-white dark:bg-gray-800/80 backdrop-blur-sm border border-gray-200 dark:border-gray-700 shadow-sm hover:shadow-xl transition-all duration-300 hover:scale-105 hover:-translate-y-1 hover:border-primary-300 dark:hover:border-primary-600 overflow-hidden"
        >
          <!-- 背景渐变效果 -->
          <div class="absolute inset-0 bg-gradient-to-br from-primary-50/0 to-primary-100/0 dark:from-primary-900/0 dark:to-primary-800/0 group-hover:from-primary-50/50 group-hover:to-primary-100/50 dark:group-hover:from-primary-900/20 dark:group-hover:to-primary-800/20 transition-all duration-300"></div>
          
          <!-- 内容 -->
          <div class="relative flex flex-col items-start gap-3 h-full">
            <div class="flex items-center gap-3 w-full">
              <div class="flex-shrink-0 p-2 rounded-lg bg-primary-50 dark:bg-primary-900/30 group-hover:bg-primary-100 dark:group-hover:bg-primary-900/50 transition-colors duration-300">
                <SvgIcon
                  :icon="item.icon || 'ri:sparkling-line'"
                  :class="['text-xl', item.iconColor || getRandomColorClass()]"
                />
              </div>
              <div class="flex-grow text-gray-700 dark:text-gray-300 text-sm font-medium line-clamp-2 text-left group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors duration-300">
                {{ item.title }}
              </div>
            </div>
          </div>
          
          <!-- Hover 时的光效 -->
          <div class="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
            <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent transform -skew-x-12 -translate-x-full group-hover:translate-x-full transition-transform duration-700"></div>
          </div>
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
@keyframes fade-in-up {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade-in-up {
  animation: fade-in-up 0.5s ease-out both;
}
</style>
