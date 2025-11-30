<script lang="ts" setup>
import { fetchQueryOneCatAPI } from '@/api/appStore'
import logo from '@/assets/logo.png'
import { useAuthStore, useChatStore } from '@/store'
import { computed, ref, watch } from 'vue'

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
  <div v-if="activeAppId" class="flex flex-col justify-center items-center select-none animate-fade-in">
    <div class="flex items-center mb-4 animate-slide-down">
      <div class="relative">
        <img 
          v-if="appDetail?.coverImg" 
          :src="appDetail?.coverImg" 
          alt="Logo" 
          class="h-12 w-12 mr-3 rounded-xl shadow-lg ring-2 ring-primary-200 dark:ring-primary-800 transition-transform duration-300 hover:scale-110" 
        />
        <div
          v-else
          :class="[
            'flex-shrink-0 rounded-xl w-12 h-12 flex items-center justify-center mr-3 shadow-lg ring-2 ring-primary-200 dark:ring-primary-800 transition-transform duration-300 hover:scale-110',
            bgRandomColor(),
          ]"
        >
          <span class="text-white text-xl font-bold">{{ appDetail.name.slice(0, 1) }}</span>
        </div>
      </div>
      <h1 class="text-4xl font-bold bg-gradient-to-r from-primary-500 to-primary-600 bg-clip-text text-transparent">
        {{ appDetail?.name }}
      </h1>
    </div>
    <h2 class="mb-2 rounded-lg px-6 py-3 text-center text-base text-gray-600 dark:text-gray-400 bg-gray-50 dark:bg-gray-800/50 backdrop-blur-sm max-w-2xl animate-slide-up">
      {{ appDetail?.des }}
    </h2>
  </div>

  <!-- 当 appDetail 不存在时显示的内容 -->
  <div v-else class="flex flex-col items-center justify-center select-none animate-fade-in">
    <div class="flex items-center mb-4 animate-slide-down">
      <div class="relative">
        <img 
          :src="logoPath" 
          alt="Logo" 
          class="h-12 w-12 mr-3 rounded-xl shadow-lg ring-2 ring-primary-200 dark:ring-primary-800 transition-transform duration-300 hover:scale-110 animate-pulse-slow" 
        />
      </div>
      <h1 class="text-4xl font-bold bg-gradient-to-r from-primary-500 to-primary-600 bg-clip-text text-transparent">
        {{ greeting }}
      </h1>
    </div>
    <h2 class="rounded-lg my-3 px-6 py-3 text-center text-base text-gray-600 dark:text-gray-400 bg-gray-50 dark:bg-gray-800/50 backdrop-blur-sm max-w-2xl animate-slide-up">
      {{ homeWelcomeContent }}
    </h2>
  </div>
</template>

<style scoped>
@keyframes fade-in {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

@keyframes slide-down {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes slide-up {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes pulse-slow {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.8;
  }
}

.animate-fade-in {
  animation: fade-in 0.6s ease-out;
}

.animate-slide-down {
  animation: slide-down 0.6s ease-out;
}

.animate-slide-up {
  animation: slide-up 0.6s ease-out 0.2s both;
}

.animate-pulse-slow {
  animation: pulse-slow 3s ease-in-out infinite;
}
</style>
