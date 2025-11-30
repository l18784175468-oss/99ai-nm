<script lang="ts" setup>
import { fetchQueryOneCatAPI } from '@/api/appStore'
import logo from '@/assets/logo.png'
import { useAuthStore, useChatStore } from '@/store'
import { computed, ref, watch } from 'vue'
import { useBasicLayout } from '@/hooks/useBasicLayout'

const { isMobile } = useBasicLayout()

const appDetail: any = ref({ name: '', des: '', coverImg: '' })
const authStore = useAuthStore()
const logoPath = computed(() => authStore.globalConfig.clientLogoPath || logo)
// 获取用户昵称
const nickname = computed(() => (authStore.userInfo as any)?.nickname || '')
// 根据时间获取问候语
const greeting = computed(() => {
  const hour = new Date().getHours()
  let greet = ''

  if (hour < 6) greet = '凌晨好'
  else if (hour < 9) greet = '早上好'
  else if (hour < 12) greet = '上午好'
  else if (hour < 14) greet = '中午好'
  else if (hour < 18) greet = '下午好'
  else greet = '晚上好'

  if (nickname.value) {
    return `${greet}，${nickname.value}，欢迎使用${authStore.globalConfig?.siteName}`
  } else {
    return `${greet}，欢迎使用${authStore.globalConfig?.siteName}`
  }
})

const homeWelcomeContent =
  authStore.globalConfig?.homeWelcomeContent ||
  '我可以帮你写代码、读文件、写作各种创意内容，请把你的任务交给我吧~'
const chatStore = useChatStore()
const activeGroupInfo = computed(() => chatStore.getChatByGroupInfo())
const activeAppId = computed(() => activeGroupInfo?.value?.appId || 0)

const queryAppInfo = async (appId: number) => {
  try {
    const res: any = await fetchQueryOneCatAPI({ id: appId })
    if (res.data) {
      appDetail.value = res.data
    } else {
      appDetail.value = { name: '', des: '', coverImg: '' }
    }
  } catch (error) {}
}

function bgRandomColor() {
  const hues = [
    'bg-blue-300',
    'bg-red-300',
    'bg-green-300',
    'bg-yellow-300',
    'bg-purple-300',
    'bg-pink-300',
  ]
  return hues[Math.floor(Math.random() * hues.length)]
}

function bgRandomGradient() {
  const gradients = [
    'from-blue-400 to-purple-600',
    'from-green-400 to-teal-600',
    'from-orange-400 to-red-600',
    'from-pink-400 to-rose-600',
    'from-indigo-400 to-purple-600',
    'from-yellow-400 to-orange-600',
  ]
  return gradients[Math.floor(Math.random() * gradients.length)]
}

// 响应式计算属性
const isVisible = ref(true)
const isLoaded = ref(true)

// 响应式样式计算
const containerClasses = computed(() => [
  'welcome-component',
  isMobile.value ? 'mobile-optimized' : 'desktop-optimized'
])

const logoSizeClasses = computed(() => [
  'relative w-24 h-24 md:w-32 md:h-32 rounded-2xl overflow-hidden shadow-2xl group-hover:shadow-3xl transition-all duration-500 transform group-hover:scale-105 group-hover:rotate-3',
  isMobile.value ? 'w-20 h-20' : 'w-24 h-24 md:w-32 md:h-32'
])

const titleSizeClasses = computed(() => [
  'text-4xl md:text-5xl font-bold bg-gradient-to-r from-primary-600 via-purple-600 to-pink-600 bg-clip-text text-transparent animate-gradient',
  isMobile.value ? 'text-3xl' : 'text-4xl md:text-5xl'
])

const contentSizeClasses = computed(() => [
  'text-center text-lg md:text-xl text-gray-700 dark:text-gray-300 leading-relaxed',
  isMobile.value ? 'text-base' : 'text-lg md:text-xl'
])

watch(
  () => activeAppId.value,
  newVal => {
    if (newVal) {
      queryAppInfo(newVal)
    }
  },
  { immediate: true }
)
</script>

<template>
  <!-- 应用详情页面 -->
  <div v-if="activeAppId" :class="containerClasses">
    <div
      class="relative group"
      :class="[
        'transition-all duration-700 transform',
        isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
      ]"
    >
      <!-- 背景光晕效果 -->
      <div class="absolute inset-0 bg-gradient-to-r opacity-20 blur-xl group-hover:opacity-30 transition-opacity duration-500"
           :class="bgRandomGradient()"></div>
      
      <div class="relative flex items-center mb-4">
        <!-- 应用图标 -->
        <div class="relative mr-4">
          <div v-if="appDetail?.coverImg"
               :class="['relative rounded-2xl overflow-hidden shadow-lg group-hover:shadow-xl transition-all duration-300 transform group-hover:scale-105', isMobile ? 'w-12 h-12' : 'w-16 h-16']">
            <img :src="appDetail?.coverImg" alt="Logo"
                 class="w-full h-full object-cover" />
            <!-- 光泽效果 -->
            <div class="absolute inset-0 bg-gradient-to-br from-white/20 to-transparent"></div>
          </div>
          <div v-else
               :class="['relative rounded-2xl overflow-hidden shadow-lg group-hover:shadow-xl transition-all duration-300 transform group-hover:scale-105', isMobile ? 'w-12 h-12' : 'w-16 h-16']">
            <div class="absolute inset-0 bg-gradient-to-br" :class="bgRandomGradient()"></div>
            <div class="absolute inset-0 flex items-center justify-center">
              <span :class="['text-white font-bold', isMobile ? 'text-lg' : 'text-2xl']">{{ appDetail.name.slice(0, 1) }}</span>
            </div>
            <!-- 光泽效果 -->
            <div class="absolute inset-0 bg-gradient-to-br from-white/20 to-transparent"></div>
          </div>
          <!-- 装饰光环 -->
          <div class="absolute -inset-1 bg-gradient-to-r opacity-0 group-hover:opacity-30 blur-md transition-opacity duration-500 rounded-2xl"
               :class="bgRandomGradient()"></div>
        </div>
        
        <!-- 应用名称 -->
        <h1 :class="['font-bold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent', isMobile ? 'text-2xl' : 'text-4xl']">
          {{ appDetail?.name }}
        </h1>
      </div>
      
      <!-- 应用描述 -->
      <div class="relative max-w-2xl mx-auto px-6">
        <div class="bg-white/60 dark:bg-gray-800/60 backdrop-blur-sm rounded-2xl px-6 py-4 shadow-lg border border-white/20 dark:border-gray-700/20">
          <h2 :class="['text-center leading-relaxed', isMobile ? 'text-base' : 'text-lg', 'text-gray-700 dark:text-gray-300']">
            {{ appDetail?.des }}
          </h2>
        </div>
      </div>
    </div>
  </div>

  <!-- 默认欢迎页面 -->
  <div v-else :class="['flex flex-col items-center justify-center select-none', isMobile ? 'px-2' : 'px-4']">
    <div
      class="relative w-full max-w-4xl"
      :class="[
        'transition-all duration-700 transform',
        isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
      ]"
    >
      <!-- 多层背景装饰 -->
      <div class="absolute inset-0 overflow-hidden pointer-events-none">
        <!-- 背景渐变层 -->
        <div class="absolute inset-0 bg-gradient-to-br from-primary-500/5 via-transparent to-purple-500/5"></div>
        <!-- 浮动装饰元素 -->
        <div :class="['absolute bg-gradient-to-br rounded-full blur-xl animate-pulse', isMobile ? 'top-5 left-5 w-10 h-10' : 'top-10 left-10 w-20 h-20', 'from-blue-400/20 to-purple-400/20']"></div>
        <div :class="['absolute bg-gradient-to-br rounded-full blur-xl animate-pulse', isMobile ? 'top-10 right-10 w-16 h-16' : 'top-20 right-20 w-32 h-32', 'from-pink-400/20 to-yellow-400/20']" style="animation-delay: 1s"></div>
        <div :class="['absolute bg-gradient-to-br rounded-full blur-xl animate-pulse', isMobile ? 'bottom-5 left-1/4 w-12 h-12' : 'bottom-10 left-1/4 w-24 h-24', 'from-green-400/20 to-blue-400/20']" style="animation-delay: 2s"></div>
        <!-- 动态光效 -->
        <div class="absolute inset-0 bg-gradient-to-r from-primary-500/3 via-transparent to-purple-500/3 opacity-0 animate-pulse"></div>
      </div>
      
      <!-- 主内容区 -->
      <div class="relative flex flex-col items-center">
        <!-- Logo区域 -->
        <div :class="['relative group', isMobile ? 'mb-4' : 'mb-8']">
          <!-- 背景光晕 -->
          <div class="absolute inset-0 bg-gradient-to-r from-primary-400/30 to-purple-400/30 rounded-full blur-2xl scale-150 group-hover:scale-175 transition-transform duration-700"></div>
          <!-- 动态光环 -->
          <div class="absolute inset-0 rounded-full bg-primary-500/10 scale-0 group-hover:scale-100 transition-transform duration-500 opacity-0 group-hover:opacity-100"></div>
          
          <!-- Logo容器 -->
          <div :class="logoSizeClasses">
            <div class="absolute inset-0 bg-gradient-to-br from-primary-500 via-purple-500 to-pink-500 transition-all duration-500 group-hover:from-primary-400 group-hover:via-purple-400 group-hover:to-pink-400"></div>
            <div class="absolute inset-0 flex items-center justify-center">
              <img :src="logoPath" alt="Logo" :class="['object-contain filter drop-shadow-lg transition-transform duration-500 group-hover:scale-110', isMobile ? 'w-12 h-12' : 'w-16 h-16 md:w-20 md:h-20']" />
            </div>
            <!-- 光泽效果 -->
            <div class="absolute inset-0 bg-gradient-to-br from-white/30 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
            <!-- 悬停光环 -->
            <div class="absolute -inset-2 rounded-full border-2 border-primary-300/20 opacity-0 group-hover:opacity-100 transition-all duration-500 group-hover:border-primary-400/40"></div>
          </div>
          
          <!-- 装饰环 -->
          <div :class="['absolute border-2 rounded-2xl animate-pulse', isMobile ? '-inset-1' : '-inset-2', 'border-primary-300/30']"></div>
          <div :class="['absolute border rounded-2xl animate-pulse', isMobile ? '-inset-2' : '-inset-4', 'border-primary-200/20']" style="animation-delay: 0.5s"></div>
        </div>
        
        <!-- 问候语 -->
        <div :class="['relative text-center', isMobile ? 'mb-4' : 'mb-8']">
          <h1
            :class="titleSizeClasses"
            :style="{
              backgroundSize: '200% 100%',
              animation: 'gradient 3s ease infinite'
            }"
          >
            {{ greeting }}
          </h1>
          <!-- 文字下方装饰线 -->
          <div :class="['mt-4 mx-auto bg-gradient-to-r from-primary-400 via-purple-400 to-pink-400 rounded-full animate-pulse', isMobile ? 'h-0.5 w-20' : 'h-1 w-32']"></div>
        </div>
        
        <!-- 欢迎内容 -->
        <div
          class="relative w-full max-w-2xl"
          :class="[
            'transition-all duration-700 delay-300 transform',
            isLoaded ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
          ]"
        >
          <div :class="['backdrop-blur-lg rounded-3xl shadow-xl border transition-all duration-500 hover:shadow-2xl hover:border-primary-300/30', isMobile ? 'px-4 py-3' : 'px-8 py-6', 'bg-white/70 dark:bg-gray-800/70 border-white/30 dark:border-gray-700/30']">
            <h2 :class="contentSizeClasses">
              {{ homeWelcomeContent }}
            </h2>
            <!-- 内容悬停效果 -->
            <div class="absolute inset-0 rounded-3xl bg-gradient-to-br from-primary-500/5 to-purple-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
          </div>
          
          <!-- 装饰元素 -->
          <div :class="['absolute bg-primary-400 rounded-full animate-bounce', isMobile ? '-top-1 -left-1 w-2 h-2' : '-top-2 -left-2 w-4 h-4']"></div>
          <div :class="['absolute bg-purple-400 rounded-full animate-bounce', isMobile ? '-top-0.5 -right-2 w-2 h-2' : '-top-1 -right-3 w-3 h-3']" style="animation-delay: 0.3s"></div>
          <div :class="['absolute bg-pink-400 rounded-full animate-bounce', isMobile ? '-bottom-1 -right-1 w-2.5 h-2.5' : '-bottom-2 -right-2 w-5 h-5']" style="animation-delay: 0.6s"></div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
@keyframes gradient {
  0%, 100% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
}

@keyframes float {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  25% { transform: translateY(-10px) rotate(1deg); }
  50% { transform: translateY(-5px) rotate(0deg); }
  75% { transform: translateY(-10px) rotate(-1deg); }
}

@keyframes glow-pulse {
  0%, 100% { opacity: 0.3; transform: scale(1); }
  50% { opacity: 0.8; transform: scale(1.05); }
}

@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}

@keyframes ripple {
  0% { transform: scale(0); opacity: 1; }
  100% { transform: scale(4); opacity: 0; }
}

.animate-gradient {
  animation: gradient 3s ease infinite;
}

/* 欢迎组件特殊动画 */
.welcome-component {
  position: relative;
}

.welcome-component .floating-element {
  animation: float 6s ease-in-out infinite;
}

.welcome-component .glow-effect {
  animation: glow-pulse 2s ease-in-out infinite;
}

/* Logo悬停效果 */
.welcome-component .group:hover .logo-container {
  transform: scale(1.05) rotate(2deg);
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

/* 问候语动画 */
.welcome-component .greeting-text {
  position: relative;
  overflow: hidden;
}

.welcome-component .greeting-text::after {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.1), transparent);
  transition: left 0.8s;
}

.welcome-component .group:hover .greeting-text::after {
  left: 100%;
}

/* 内容卡片悬停效果 */
.welcome-component .content-card {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.welcome-component .content-card:hover {
  transform: translateY(-5px) scale(1.02);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
}

/* 装饰元素增强 */
.welcome-component .decoration-element {
  transition: all 0.3s ease;
}

.welcome-component .group:hover .decoration-element {
  transform: scale(1.2) rotate(5deg);
}

/* 响应式优化 */
.mobile-optimized {
  padding: 1rem;
}

.desktop-optimized {
  padding: 1.5rem;
}

/* 触摸设备优化 */
@media (hover: none) and (pointer: coarse) {
  .group:hover .group-hover\:scale-105 {
    transform: none;
  }
  
  .group:hover .group-hover\:shadow-xl {
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  }
  
  .group:hover .group-hover\:shadow-3xl {
    box-shadow: 0 35px 60px -12px rgba(0, 0, 0, 0.25);
  }
  
  .group:hover .group-hover\:rotate-3 {
    transform: none;
  }
  
  .group:hover .group-hover\:opacity-30 {
    opacity: 0.2;
  }
  
  .group:hover .group-hover\:scale-175 {
    transform: scale(1.5);
  }
}

/* 减少动画偏好支持 */
@media (prefers-reduced-motion: reduce) {
  .animate-pulse,
  .animate-bounce,
  .animate-gradient {
    animation: none;
  }
  
  .transition-all {
    transition: none;
  }
  
  .group:hover .group-hover\:scale-105,
  .group:hover .group-hover\:rotate-3 {
    transform: none;
  }
}

/* 高对比度模式支持 */
@media (prefers-contrast: high) {
  .bg-white\/70 {
    background-color: rgba(255, 255, 255, 0.9) !important;
  }
  
  .dark .bg-gray-800\/70 {
    background-color: rgba(31, 41, 55, 0.9) !important;
  }
  
  .border-white\/30 {
    border-color: rgba(255, 255, 255, 0.5) !important;
  }
  
  .dark .border-gray-700\/30 {
    border-color: rgba(75, 85, 99, 0.5) !important;
  }
}

/* 小屏幕优化 */
@media (max-width: 640px) {
  .mobile-optimized .absolute.w-20.h-20 {
    width: 2.5rem;
    height: 2.5rem;
  }
  
  .mobile-optimized .absolute.w-32.h-32 {
    width: 4rem;
    height: 4rem;
  }
  
  .mobile-optimized .absolute.w-24.h-24 {
    width: 3rem;
    height: 3rem;
  }
}
</style>
