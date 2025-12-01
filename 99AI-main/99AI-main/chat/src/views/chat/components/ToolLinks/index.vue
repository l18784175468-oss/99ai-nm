<script lang="ts" setup>
import { useGlobalStoreWithOut } from '@/store'
import { computed } from 'vue'

const useGlobalStore = useGlobalStoreWithOut()

// 工具链接配置
const toolLinks = [
  {
    name: '文本编辑器',
    icon: '📝',
    action: () => {
      useGlobalStore.updateTextEditor(true)
    }
  },
  {
    name: '应用广场',
    icon: '🎯',
    action: () => {
      useGlobalStore.updateShowAppListComponent(true)
    }
  }
]
</script>

<template>
  <div class="flex items-center space-x-2">
    <div
      v-for="(link, index) in toolLinks"
      :key="index"
      class="relative group"
    >
      <button
        type="button"
        class="relative w-11 h-11 rounded-2xl bg-white/80 dark:bg-gray-800/80 backdrop-blur-md border border-gray-200/60 dark:border-gray-600/60 flex items-center justify-center hover:bg-white dark:hover:bg-gray-700 transition-all duration-500 hover:scale-110 shadow-md hover:shadow-xl overflow-hidden"
        @click="link.action"
        :aria-label="link.name"
      >
        <span class="text-lg group-hover:scale-110 transition-transform duration-500">{{ link.icon }}</span>
        <!-- 背景光晕 -->
        <div class="absolute inset-0 rounded-2xl bg-gradient-to-r from-primary-500/15 to-purple-500/15 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
        <!-- 波纹效果 -->
        <div class="absolute inset-0 rounded-2xl bg-primary-500/25 scale-0 group-active:scale-100 transition-transform duration-500"></div>
        <!-- 装饰环 -->
        <div class="absolute -inset-1 rounded-2xl border-2 border-primary-300/40 dark:border-primary-600/40 opacity-0 group-hover:opacity-100 transition-all duration-500"></div>
      </button>
      <!-- 悬停提示 -->
      <div class="tooltip tooltip-bottom">{{ link.name }}</div>
    </div>
  </div>
</template>

<style scoped>
/* 工具提示增强 */
.tooltip {
  @apply absolute bottom-full left-1/2 transform -translate-x-1/2 mb-2 px-2 py-1 text-xs text-white bg-gray-800 dark:bg-gray-600 rounded-md whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none z-50;
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
}

.tooltip.tooltip-bottom::after {
  content: '';
  @apply absolute top-full left-1/2 transform -translate-x-1/2 -mt-1;
  border-width: 4px;
  border-style: solid;
  border-color: rgb(31 41 55) transparent transparent transparent;
}

.dark .tooltip.tooltip-bottom::after {
  border-color: rgb(75 85 99) transparent transparent transparent;
}
</style>