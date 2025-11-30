<script setup lang="ts">
import defaultPreset from '@/assets/defaultPreset.json'
import SvgIcon from '@/components/common/SvgIcon/index.vue'
import { useBasicLayout } from '@/hooks/useBasicLayout'
import { fetchHomePresetsAPI } from '@/api/models'
import { ref, onMounted, computed } from 'vue'

interface Props {
  isHideDefaultPreset: boolean
}
const { isMobile } = useBasicLayout()
defineProps<Props>()
const emit = defineEmits<{
  (e: 'click', box: { appId?: number; prompt: any; model?: string; modelName?: string }): void
}>()

const randomItems = ref<any[]>([])
const isVisible = ref(false)
const loadedItems = ref<Set<number>>(new Set())

// 响应式计算属性
const gridColsClass = computed(() => {
  if (isMobile.value) return 'grid-cols-1'
  return 'grid-cols-2 sm:grid-cols-2 lg:grid-cols-4'
})

const cardHeightClass = computed(() => {
  if (isMobile.value) return 'h-20'
  return 'h-24'
})

const containerPaddingClass = computed(() => {
  if (isMobile.value) return 'px-2'
  return 'px-4'
})

const gapClass = computed(() => {
  if (isMobile.value) return 'gap-2'
  return 'gap-4'
})

const getRandomGradient = () => {
  const gradients = [
    'from-blue-400 via-blue-500 to-blue-600',
    'from-purple-400 via-purple-500 to-purple-600',
    'from-green-400 via-green-500 to-green-600',
    'from-pink-400 via-pink-500 to-pink-600',
    'from-indigo-400 via-indigo-500 to-indigo-600',
    'from-red-400 via-red-500 to-red-600',
    'from-yellow-400 via-yellow-500 to-yellow-600',
    'from-teal-400 via-teal-500 to-teal-600',
  ]
  return gradients[Math.floor(Math.random() * gradients.length)]
}

const getIconColorClass = () => {
  const colors = [
    'text-blue-500',
    'text-purple-500',
    'text-green-500',
    'text-pink-500',
    'text-indigo-500',
    'text-red-500',
    'text-yellow-500',
    'text-teal-500',
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

const handleItemClick = (item: any, index: number) => {
  emit('click', item)
  // 标记该项为已加载
  loadedItems.value.add(index)
}

onMounted(() => {
  fetchHomePresets()
  // 触发入场动画
  setTimeout(() => {
    isVisible.value = true
  }, 100)
})
</script>

<template>
  <div v-if="!isHideDefaultPreset && !isMobile" :class="['w-full flex justify-center items-center', containerPaddingClass.value]">
    <div :class="['grid w-full max-w-5xl', gridColsClass.value, gapClass.value]">
      <div
        v-for="(item, index) in randomItems"
        :key="item.title"
        class="transform transition-all duration-500"
        :class="[
          isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4',
          loadedItems.has(index) ? 'scale-95' : 'hover:scale-105'
        ]"
        :style="{ transitionDelay: `${index * 100}ms` }"
      >
        <button
          @click="handleItemClick(item, index)"
          :class="['group relative w-full rounded-2xl overflow-hidden transition-all duration-300 hover:shadow-xl hover:shadow-primary-500/20 preset-hints', cardHeightClass.value]"
        >
          <!-- 背景渐变 -->
          <div class="absolute inset-0 bg-gradient-to-br opacity-90" :class="getRandomGradient()"></div>
          
          <!-- 玻璃态覆盖层 -->
          <div class="absolute inset-0 bg-white/10 backdrop-blur-sm"></div>
          
          <!-- 装饰光晕 -->
          <div :class="['absolute bg-white/20 rounded-full blur-2xl group-hover:scale-150 transition-transform duration-500 floating-element', isMobile ? 'top-0 right-0 w-16 h-16 -translate-y-8 translate-x-8' : 'top-0 right-0 w-20 h-20 -translate-y-10 translate-x-10']"></div>
          
          <!-- 动态光点 -->
          <div class="absolute top-1/4 left-1/4 w-2 h-2 bg-white/60 rounded-full glow-effect"></div>
          <div class="absolute bottom-1/3 right-1/3 w-1.5 h-1.5 bg-white/40 rounded-full glow-effect" style="animation-delay: 0.5s;"></div>
          
          <!-- 内容区域 -->
          <div :class="['relative h-full flex items-center justify-between', isMobile ? 'p-3' : 'p-4']">
            <!-- 图标区域 -->
            <div class="flex-shrink-0">
              <div :class="['relative rounded-xl bg-white/20 backdrop-blur-sm flex items-center justify-center group-hover:bg-white/30 transition-all duration-300 icon-container', isMobile ? 'w-10 h-10' : 'w-12 h-12']">
                <SvgIcon
                  :icon="item.icon || 'ri:robot-line'"
                  :class="['text-white', isMobile ? 'text-xl' : 'text-2xl', item.iconColor || getIconColorClass()]"
                />
                <!-- 图标光晕 -->
                <div class="absolute inset-0 rounded-xl bg-white/30 scale-0 group-hover:scale-100 transition-transform duration-300"></div>
              </div>
            </div>
            
            <!-- 文字区域 -->
            <div :class="['flex-grow min-w-0 text-left text-content', isMobile ? 'ml-2' : 'ml-3']">
              <h3 :class="['text-white font-semibold leading-tight truncate group-hover:text-white/95 transition-colors duration-200', isMobile ? 'text-xs' : 'text-sm']">
                {{ item.title }}
              </h3>
              <div class="mt-1 h-0.5 w-full bg-white/30 rounded-full overflow-hidden">
                <div class="h-full bg-white/60 rounded-full transform scale-x-0 group-hover:scale-x-100 transition-transform duration-300 origin-left"></div>
              </div>
            </div>
            
            <!-- 悬停指示器 -->
            <div class="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity duration-300 indicator">
              <div :class="['bg-white/30 backdrop-blur-sm rounded-full flex items-center justify-center', isMobile ? 'w-5 h-5' : 'w-6 h-6']">
                <svg :class="['text-white', isMobile ? 'w-2.5 h-2.5' : 'w-3 h-3']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"></path>
                </svg>
              </div>
            </div>
          </div>
          
          <!-- 边框光效 -->
          <div class="absolute inset-0 rounded-2xl border border-white/20 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
          
          <!-- 点击波纹效果 -->
          <div class="absolute inset-0 rounded-2xl bg-white/20 scale-0 group-active:scale-100 transition-transform duration-200"></div>
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 添加自定义动画 */
@keyframes float {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  25% { transform: translateY(-5px) rotate(1deg); }
  50% { transform: translateY(-10px) rotate(0deg); }
  75% { transform: translateY(-5px) rotate(-1deg); }
}

@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}

@keyframes glow-pulse {
  0%, 100% { opacity: 0.3; transform: scale(1); }
  50% { opacity: 0.8; transform: scale(1.05); }
}

@keyframes ripple {
  0% { transform: scale(0); opacity: 1; }
  100% { transform: scale(4); opacity: 0; }
}

/* 预设提示卡片特殊样式 */
.preset-hints {
  position: relative;
}

.preset-hints .hint-card {
  position: relative;
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.preset-hints .hint-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s;
}

.preset-hints .hint-card:hover::before {
  left: 100%;
}

.preset-hints .floating-element {
  animation: float 6s ease-in-out infinite;
}

.preset-hints .glow-effect {
  animation: glow-pulse 2s ease-in-out infinite;
}

/* 图标悬停效果 */
.preset-hints .icon-container {
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.preset-hints .hint-card:hover .icon-container {
  transform: scale(1.1) rotate(5deg);
}

/* 文字悬停效果 */
.preset-hints .text-content {
  position: relative;
  overflow: hidden;
}

.preset-hints .text-content::after {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.1), transparent);
  transition: left 0.5s;
}

.preset-hints .hint-card:hover .text-content::after {
  left: 100%;
}

/* 指示器动画 */
.preset-hints .indicator {
  transition: all 0.3s ease;
}

.preset-hints .hint-card:hover .indicator {
  transform: scale(1.2) rotate(15deg);
}

.group:hover .group-hover\:scale-150 {
  animation: float 6s ease-in-out infinite;
}

/* 响应式优化 */
@media (max-width: 640px) {
  .grid-cols-2 {
    grid-template-columns: repeat(1, minmax(0, 1fr));
  }
}

/* 触摸设备优化 */
@media (hover: none) and (pointer: coarse) {
  .preset-hints .hint-card {
    transition: none;
  }
  
  .preset-hints .hint-card:hover {
    transform: none;
  }
  
  .preset-hints .hint-card:hover .icon-container {
    transform: none;
  }
  
  .preset-hints .hint-card:hover .indicator {
    transform: none;
  }
  
  .preset-hints .floating-element {
    animation: none;
  }
  
  .preset-hints .glow-effect {
    animation: none;
  }
  
  .group:hover .group-hover\:scale-105 {
    transform: none;
  }
  
  .group:hover .group-hover\:scale-150 {
    transform: none;
    animation: none;
  }
  
  .group:hover .group-hover\:bg-white\/30 {
    background-color: rgba(255, 255, 255, 0.2);
  }
  
  .group:hover .group-hover\:text-white\/95 {
    color: rgba(255, 255, 255, 0.9);
  }
  
  .group:hover .group-hover\:scale-x-100 {
    transform: scaleX(0);
  }
  
  .group:hover .group-hover\:opacity-100 {
    opacity: 0;
  }
  
  .group-active .group-active\:scale-100 {
    transform: scale(0.95);
  }
}

/* 减少动画偏好支持 */
@media (prefers-reduced-motion: reduce) {
  .preset-hints .floating-element,
  .preset-hints .glow-effect {
    animation: none;
  }
  
  .preset-hints .hint-card::before,
  .preset-hints .text-content::after {
    transition: none;
  }
  
  .group:hover .group-hover\:scale-150 {
    animation: none;
  }
  
  .transform {
    transition: none;
  }
  
  .transition-all {
    transition: none;
  }
  
  .transition-opacity {
    transition: none;
  }
  
  .transition-transform {
    transition: none;
  }
  
  .transition-colors {
    transition: none;
  }
}

/* 高对比度模式支持 */
@media (prefers-contrast: high) {
  .preset-hints .bg-white\/10 {
    background-color: rgba(255, 255, 255, 0.2) !important;
  }
  
  .preset-hints .bg-white\/20 {
    background-color: rgba(255, 255, 255, 0.3) !important;
  }
  
  .preset-hints .bg-white\/30 {
    background-color: rgba(255, 255, 255, 0.4) !important;
  }
  
  .preset-hints .border-white\/20 {
    border-color: rgba(255, 255, 255, 0.4) !important;
  }
  
  .preset-hints .text-white\/95 {
    color: rgba(255, 255, 255, 0.98) !important;
  }
  
  .preset-hints .text-white\/90 {
    color: rgba(255, 255, 255, 0.95) !important;
  }
}

/* 暗色模式优化 */
@media (prefers-color-scheme: dark) {
  .preset-hints .bg-white\/10 {
    background-color: rgba(0, 0, 0, 0.1);
  }
  
  .preset-hints .bg-white\/20 {
    background-color: rgba(0, 0, 0, 0.2);
  }
  
  .preset-hints .bg-white\/30 {
    background-color: rgba(0, 0, 0, 0.3);
  }
}
</style>
