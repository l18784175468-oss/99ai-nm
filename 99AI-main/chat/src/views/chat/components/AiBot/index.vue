<script setup lang="ts">
import SvgIcon from '@/components/common/SvgIcon/index.vue'
import { useBasicLayout } from '@/hooks/useBasicLayout'
// import { t } from '@/locales';
import defaultPreset from '@/assets/defaultPreset.json'
import { useAuthStore, useChatStore } from '@/store'
import { computed, inject, onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'

const onConversation = inject<any>('onConversation')
const authStore = useAuthStore()
const chatStore = useChatStore()
const groupSources = computed(() => chatStore.groupList)
const { isMobile } = useBasicLayout()
const randomItems = ref()
const route = useRoute()

const isHideDefaultPreset = computed(
  () => Number(authStore.globalConfig?.isHideDefaultPreset) === 1
)

// 从后端配置获取预设，如果没有则使用默认预设
const getHomePresets = () => {
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
}

const getRandomItems = () => {
  const presets = getHomePresets()
  randomItems.value = presets.sort(() => 0.5 - Math.random()).slice(0, 4)
}

onMounted(() => {
  getRandomItems()
})
const usingPlugin = computed(() => chatStore.currentPlugin)
const siteName = authStore.globalConfig?.siteName || 'AIWeb'
const isCanvasModel = computed(() => usingPlugin.value?.parameters.includes('canvas'))

const createNewChatGroup = inject('createNewChatGroup', () =>
  Promise.resolve()
) as () => Promise<void>

async function handleClick(box: { appId?: number; prompt: any }) {
  if (groupSources.value.length === 0) {
    // await nextTick();
    await createNewChatGroup()
    // await chatStore.queryMyGroup();
  }
  const { appId, prompt } = box
  if (appId && appId > 0) {
    try {
      await chatStore.addNewChatGroup(appId)
      await chatStore.queryMyGroup()
    } catch (error) {}
  } else {
    onConversation({
      msg: prompt,
    })
  }
}

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
  <div
    :class="[isMobile ? 'mb-16' : 'mt-8']"
    class="px-4 select-none w-full flex flex-col items-center justify-center h-full"
  >
    <h1 class="mb-8 rounded-lg px-6 py-3 text-center text-4xl font-bold bg-gradient-to-r from-primary-500 to-primary-600 bg-clip-text text-transparent animate-fade-in">
      {{ siteName }}
    </h1>
    <div v-if="!isHideDefaultPreset" class="w-full md:max-w-[45rem]">
      <div
        :class="[
          isCanvasModel ? 'grid-cols-2 mx-2' : 'grid-cols-2 sm:grid-cols-2 lg:grid-cols-4',
          'grid gap-4',
        ]"
      >
        <div 
          v-for="(item, index) in randomItems" 
          :key="item.title" 
          class="animate-fade-in-up"
          :style="{ animationDelay: `${index * 0.1}s` }"
        >
          <button
            @click="handleClick(item)"
            class="group relative w-full h-full min-h-[5.5rem] rounded-xl bg-white dark:bg-gray-800/80 backdrop-blur-sm border border-gray-200 dark:border-gray-700 shadow-md hover:shadow-xl transition-all duration-300 hover:scale-105 hover:-translate-y-1 hover:border-primary-300 dark:hover:border-primary-600 overflow-hidden"
          >
            <!-- 背景渐变效果 -->
            <div class="absolute inset-0 bg-gradient-to-br from-primary-50/0 to-primary-100/0 dark:from-primary-900/0 dark:to-primary-800/0 group-hover:from-primary-50/50 group-hover:to-primary-100/50 dark:group-hover:from-primary-900/20 dark:group-hover:to-primary-800/20 transition-all duration-300"></div>
            
            <!-- 内容 -->
            <div class="relative flex flex-col gap-2 px-3 pb-4 pt-3 h-full">
              <SvgIcon
                :icon="item.icon || 'ri:sparkling-line'"
                :class="['text-xl mb-2', item.iconColor || getRandomColorClass()]"
              />
              <div
                class="line-clamp-2 break-all overflow-hidden text-gray-700 dark:text-gray-300 flex-grow text-sm font-medium group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors duration-300"
              >
                {{ item.title }}
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

.animate-fade-in {
  animation: fade-in 0.6s ease-out;
}

.animate-fade-in-up {
  animation: fade-in-up 0.5s ease-out both;
}
</style>
