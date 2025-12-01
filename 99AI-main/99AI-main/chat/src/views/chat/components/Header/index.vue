<script lang="ts" setup>
import { fetchQueryOneCatAPI } from '@/api/appStore'
import { fetchUpdateGroupAPI } from '@/api/group'
import { fetchQueryModelsListAPI } from '@/api/models'
import { DropdownMenu } from '@/components/common/DropdownMenu'
import ToolLinks from '@/views/chat/components/ToolLinks/index.vue'
import { useBasicLayout } from '@/hooks/useBasicLayout'
import { useAppStore, useChatStore, useGlobalStoreWithOut } from '@/store'
import {
  Brightness,
  CheckOne,
  Close,
  DarkMode,
  EditTwo,
  ExpandLeft,
  Right,
} from '@icon-park/vue-next'
import { computed, inject, onMounted, ref, Ref, watch } from 'vue'

interface ModelOption {
  label: string
  value: string
  modelDescription: string
  modelAvatar: string
}

interface Model {
  isFileUpload: any
  isImageUpload: any
  modelName: string
  model: string
  deductType: number
  keyType: number
  deduct: number
  modelAvatar: string
  modelDescription: string
  isNetworkSearch: any
  isMcpTool: any
  deepThinkingType: any
}

interface ExternalLink {
  icon?: string
  name?: string
  [key: string]: any
}

const useGlobalStore = useGlobalStoreWithOut()
const appStore = useAppStore()
const chatStore = useChatStore()
const modelOptions: Ref<ModelOption[]> = ref([])
const appDetail: any = ref(null)
const dataSources = computed(() => chatStore.groupList)
const collapsed = computed(() => appStore.siderCollapsed)
const chatGroupId = computed(() => chatStore.active)
const darkMode = computed(() => appStore.theme === 'dark')

const { isMobile } = useBasicLayout()
const isHovering = ref(false)
const isMenuOpen = ref(false)
const activeGroupInfo = computed(() => chatStore.getChatByGroupInfo())
const listSources = computed(() => chatStore.chatList)

// 计算预览器状态
const isPreviewerVisible = computed(
  () =>
    useGlobalStore.showHtmlPreviewer ||
    useGlobalStore.showTextEditor ||
    useGlobalStore.showImagePreviewer
)

// 计算应用广场状态
const isAppListVisible = computed(() => useGlobalStore.showAppListComponent)
const configObj = computed(() => {
  const configString = activeGroupInfo.value?.config
  if (!configString) {
    return {} // 提早返回一个空对象
  }

  try {
    return JSON.parse(configString)
  } catch (e) {
    return {} // 解析失败时返回一个空对象
  }
})

function checkMode() {
  const mode = darkMode.value ? 'light' : 'dark'
  appStore.setTheme(mode)
}

const activeModel = computed(() => String(configObj?.value?.modelInfo?.model ?? ''))
/* 当前对话组是否是应用 */
const activeAppId = computed(() => activeGroupInfo?.value?.appId || 0)

let modelMapsCache: any = ref({})
let modelTypeListCache: any = ref([])

watch(
  activeAppId,
  (val: number) => {
    if (val) queryAppDetail(val)
    else appDetail.value = null
  },
  { immediate: true }
)

/* 查询当前app详情提示用户使用 */
async function queryAppDetail(id: number) {
  const res: any = await fetchQueryOneCatAPI({ id })
  appDetail.value = res.data
}

const notSwitchModel = computed(() => {
  return (
    activeGroupInfo?.value?.appId &&
    (configObj.value.modelInfo?.isFixedModel === 1 ||
      configObj.value.modelInfo?.isGPTs === 1 ||
      configObj.value.modelInfo?.isFlowith === 1)
  )
})

const createNewChatGroup = inject('createNewChatGroup', () =>
  Promise.resolve()
) as () => Promise<void>

async function handleUpdateCollapsed() {
  appStore.setSiderCollapsed(!collapsed.value)
}

// 关闭应用广场
function closeAppList() {
  useGlobalStore.updateShowAppListComponent(false)
  // 在移动端不自动展开侧边栏
  if (!isMobile.value) {
    appStore.setSiderCollapsed(false)
  }
}

/* 修改对话组模型配置 */
async function switchModel(option: any) {
  chatStore.setUsingDeepThinking(false)
  chatStore.setUsingNetwork(false)
  chatStore.setUsingPlugin(null)
  const { modelInfo, fileInfo } = chatStore.activeConfig

  const { isGPTs, isFixedModel, modelName, isFlowith } = modelInfo

  const config = {
    modelInfo: {
      keyType: option.keyType,
      modelName: (activeGroupInfo?.value?.appId ? modelName : option.label) || '', // 更明确的条件
      model: option.value,
      deductType: option.deductType,
      deduct: option.deduct,
      isFileUpload: option.isFileUpload,
      isImageUpload: option.isImageUpload,
      isNetworkSearch: option.isNetworkSearch,
      deepThinkingType: option.deepThinkingType,
      isMcpTool: option.isMcpTool,
      modelAvatar: option.modelAvatar || '',
      isGPTs, // 简化赋值
      isFlowith, // 简化赋值
      isFixedModel, // 简化赋值
    },
    fileInfo: fileInfo || {}, // 确保 fileInfo 为空时不出错
  }

  const params = {
    groupId: chatGroupId.value,
    config: JSON.stringify(config),
  }
  await fetchUpdateGroupAPI(params)
  await chatStore.queryMyGroup()
  // useGlobalStore.updateModelDialog(false);
}

async function queryModelsList() {
  try {
    const res: any = await fetchQueryModelsListAPI()
    if (!res.success) return
    const { modelMaps, modelTypeList } = res.data
    modelMapsCache.value = modelMaps
    modelTypeListCache.value = modelTypeList
    // 使用类型断言来告诉 TypeScript flatModelArray 是 Model[] 类型
    const flatModelArray = Object.values(modelMaps).flat() as Model[]
    const filteredModelArray = flatModelArray.filter(model => model.keyType === 1)
    modelOptions.value = filteredModelArray.map(model => ({
      label: model.modelName,
      value: model.model,
      deductType: model.deductType,
      keyType: model.keyType,
      deduct: model.deduct,
      isFileUpload: model.isFileUpload,
      isImageUpload: model.isImageUpload,
      isNetworkSearch: model.isNetworkSearch,
      deepThinkingType: model.deepThinkingType,
      isMcpTool: model.isMcpTool,
      modelAvatar: model.modelAvatar,
      modelDescription: model.modelDescription,
    }))
  } catch (error) {}
}

// 在mounted时查询模型列表
onMounted(() => {
  queryModelsList()
})

const externalLinkActive = computed(
  () => useGlobalStore.externalLinkDialog && useGlobalStore.currentExternalLink
)
const currentExternalLink = computed(() => {
  const link = useGlobalStore.currentExternalLink
  return (typeof link === 'object' ? link : {}) as ExternalLink
})

// 打开文本编辑器
const openTextEditor = () => {
  useGlobalStore.updateTextEditor(true)
}

// 添加一个新的方法来处理模型选择
function handleModelSelect(option: any) {
  switchModel(option)
}

function openSettings(tab?: number) {
  if (isMobile.value) {
    useGlobalStore.updateMobileSettingsDialog(true, tab)
    appStore.setSiderCollapsed(true)
  } else {
    useGlobalStore.updateSettingsDialog(true, tab)
  }
}
</script>

<template>
  <header class="sticky top-0 left-0 right-0 z-30 h-16 select-none group header-component">
    <!-- 多层背景装饰 -->
    <div class="absolute inset-0 bg-gradient-to-r from-white/95 via-white/90 to-white/95 dark:from-gray-900/95 dark:via-gray-900/90 dark:to-gray-900/95 backdrop-blur-xl border-b border-gray-200/60 dark:border-gray-700/60 transition-all duration-300"></div>
    
    <!-- 动态光效 -->
    <div class="absolute inset-0 bg-gradient-to-r from-primary-500/8 via-transparent to-purple-500/8 opacity-0 group-hover:opacity-100 transition-opacity duration-700"></div>
    
    <!-- 顶部装饰线 -->
    <div class="absolute top-0 left-0 right-0 h-0.5 bg-gradient-to-r from-transparent via-primary-500/30 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
    
    <!-- 动态粒子背景 -->
    <div class="absolute inset-0 overflow-hidden pointer-events-none">
      <div class="absolute w-96 h-96 -top-48 -left-48 bg-primary-400/5 rounded-full blur-3xl animate-pulse"></div>
      <div class="absolute w-96 h-96 -top-48 -right-48 bg-purple-400/5 rounded-full blur-3xl animate-pulse" style="animation-delay: 1s;"></div>
    </div>
    
    <div class="relative flex items-center justify-center min-w-0 h-full">
      <div class="flex w-full h-full items-center" :class="{ 'px-4': !isMobile, 'px-2': isMobile }">
        <!-- 侧边栏展开按钮 -->
        <div
          v-if="collapsed && !externalLinkActive && !isPreviewerVisible"
          class="relative group mx-2"
        >
          <button
            type="button"
            class="relative w-11 h-11 rounded-2xl bg-white/80 dark:bg-gray-800/80 backdrop-blur-md border border-gray-200/60 dark:border-gray-600/60 flex items-center justify-center hover:bg-white dark:hover:bg-gray-700 transition-all duration-500 hover:scale-110 shadow-md hover:shadow-xl group overflow-hidden"
            @click="handleUpdateCollapsed"
            aria-label="展开侧边栏"
          >
            <ExpandLeft size="22" class="text-gray-600 dark:text-gray-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-all duration-500 relative z-10" />
            <!-- 按钮光晕 -->
            <div class="absolute inset-0 rounded-2xl bg-gradient-to-r from-primary-500/15 to-purple-500/15 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
            <!-- 波纹效果 -->
            <div class="absolute inset-0 rounded-2xl bg-primary-500/25 scale-0 group-active:scale-100 transition-transform duration-500"></div>
            <!-- 装饰环 -->
            <div class="absolute -inset-1 rounded-2xl border-2 border-primary-300/40 dark:border-primary-600/40 opacity-0 group-hover:opacity-100 transition-all duration-500"></div>
          </button>
          <!-- 悬停提示 -->
          <div v-if="!isMobile" class="tooltip tooltip-right">展开侧栏</div>
        </div>

        <!-- 主要内容区域 -->
        <div class="flex justify-between items-center h-full w-full">
          <!-- 外部链接显示 -->
          <div
            v-if="externalLinkActive"
            class="relative flex-1 flex ele-drag items-center justify-between h-full"
          >
            <div class="py-3 flex items-center space-x-4 group">
              <div class="relative transform transition-all duration-500 group-hover:scale-115 group-hover:rotate-6">
                <img
                  v-if="currentExternalLink && currentExternalLink.icon"
                  :src="currentExternalLink.icon"
                  alt="网站图标"
                  class="w-10 h-10 rounded-2xl object-cover shadow-lg group-hover:shadow-2xl transition-all duration-500"
                />
                <div v-else class="w-10 h-10 rounded-2xl bg-gradient-to-br from-gray-200 to-gray-300 dark:from-gray-600 dark:to-gray-700 flex items-center justify-center shadow-lg group-hover:shadow-2xl transition-all duration-500">
                  <span class="text-base font-bold text-gray-600 dark:text-gray-300 group-hover:text-gray-800 dark:group-hover:text-gray-100 transition-colors duration-500">{{ currentExternalLink?.name?.charAt(0) || '?' }}</span>
                </div>
                <!-- 装饰环 -->
                <div class="absolute -inset-1 rounded-2xl border-2 border-primary-300/40 dark:border-primary-600/40 animate-pulse"></div>
                <!-- 悬停光晕 -->
                <div class="absolute -inset-2 rounded-2xl bg-primary-500/15 opacity-0 group-hover:opacity-100 transition-all duration-500 blur-lg"></div>
              </div>
              <span
                class="text-lg font-semibold text-gray-800 dark:text-gray-200 truncate whitespace-nowrap overflow-hidden max-w-[30vw] transition-all duration-500 group-hover:text-primary-600 dark:group-hover:text-primary-400"
              >
                {{ currentExternalLink?.name || '外部链接' }}
              </span>
            </div>
          </div>

          <!-- 不可切换模型状态 -->
          <div v-else-if="notSwitchModel" class="flex-1 flex items-center">
            <div class="relative group">
              <div class="menu menu-lg relative">
                <button class="relative menu-trigger bg-white/80 dark:bg-gray-800/80 backdrop-blur-md border border-gray-200/60 dark:border-gray-600/60 rounded-2xl px-5 py-3 flex items-center space-x-4 hover:bg-white dark:hover:bg-gray-700 transition-all duration-500 shadow-md hover:shadow-xl" aria-label="当前对话" disabled>
                  <div class="avatar avatar-lg relative">
                    <div class="w-10 h-10 rounded-2xl bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center shadow-md group-hover:shadow-xl transition-all duration-500">
                      <span class="text-white font-bold text-base">{{ (activeGroupInfo?.title || '新对话').charAt(0) }}</span>
                    </div>
                    <!-- 头像光晕 -->
                    <div class="absolute inset-0 rounded-2xl bg-primary-400/25 scale-0 group-hover:scale-110 transition-transform duration-500 blur-lg"></div>
                    <!-- 状态指示器 -->
                    <div class="absolute -bottom-1 -right-1 w-3 h-3 bg-green-500 rounded-full animate-pulse shadow-md"></div>
                  </div>
                  <span class="truncate whitespace-nowrap overflow-hidden max-w-[30vw] font-semibold text-gray-700 dark:text-gray-300 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors duration-500">
                    {{ activeGroupInfo?.title || '新对话' }}
                  </span>
                </button>
              </div>
              <!-- 背景光晕 -->
              <div class="absolute inset-0 rounded-2xl bg-gradient-to-r from-primary-500/8 to-purple-500/8 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
            </div>
          </div>

          <!-- 模型选择下拉菜单 -->
          <div v-else class="flex-1 flex items-center">
            <DropdownMenu v-model="isMenuOpen" position="bottom-left" max-height="60vh">
              <template #trigger>
                <button
                  class="relative group menu-trigger bg-white/80 dark:bg-gray-800/80 backdrop-blur-md border border-gray-200/60 dark:border-gray-600/60 rounded-2xl px-5 py-3 flex items-center space-x-4 hover:bg-white dark:hover:bg-gray-700 transition-all duration-500 hover:scale-[1.03] hover:shadow-xl overflow-hidden"
                  @mouseover="isHovering = true"
                  @mouseleave="isHovering = false"
                  aria-label="选择模型"
                >
                  <div class="avatar avatar-lg relative">
                    <div class="w-10 h-10 rounded-2xl bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center shadow-md group-hover:shadow-xl transition-all duration-500">
                      <span class="text-white font-bold text-base">{{ (configObj?.modelInfo?.modelName || '新对话').charAt(0) }}</span>
                    </div>
                    <!-- 头像光晕 -->
                    <div class="absolute inset-0 rounded-2xl bg-primary-400/25 scale-0 group-hover:scale-110 transition-transform duration-500 blur-lg"></div>
                  </div>
                  <span class="truncate whitespace-nowrap overflow-hidden max-w-[40vw] font-semibold text-gray-700 dark:text-gray-300 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors duration-500">
                    {{ configObj?.modelInfo?.modelName || '新对话' }}
                  </span>
                  <Right
                    v-if="isHovering || isMobile || isMenuOpen"
                    size="20"
                    class="text-gray-500 dark:text-gray-400 transition-all duration-500"
                    :class="{
                      'rotate-90': isMenuOpen,
                    }"
                    aria-hidden="true"
                  />
                  <!-- 背景光晕 -->
                  <div class="absolute inset-0 rounded-2xl bg-gradient-to-r from-primary-500/15 to-purple-500/15 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                  <!-- 波纹效果 -->
                  <div class="absolute inset-0 rounded-2xl bg-primary-500/25 scale-0 group-active:scale-100 transition-transform duration-500"></div>
                </button>
              </template>
              <template #menu="{ close }">
                <div class="p-3 bg-white/95 dark:bg-gray-800/95 backdrop-blur-xl rounded-3xl shadow-2xl border border-gray-200/60 dark:border-gray-700/60 overflow-hidden">
                  <!-- 菜单顶部装饰线 -->
                  <div class="h-1 w-full bg-gradient-to-r from-primary-500 via-purple-500 to-primary-500 mb-3 rounded-full"></div>
                  <div class="max-h-64 overflow-y-auto custom-scrollbar">
                    <div
                      v-for="(option, index) in modelOptions"
                      :key="index"
                      class="menu-item menu-item-lg group relative overflow-hidden"
                      :class="{ 'menu-item-active': activeModel === option.value }"
                      @click="
                        () => {
                          handleModelSelect(option)
                          close()
                        }
                      "
                      role="menuitem"
                      tabindex="0"
                      :aria-label="`选择${option.label}模型`"
                    >
                      <div class="avatar avatar-lg relative">
                        <img
                          v-if="option.modelAvatar"
                          :src="option.modelAvatar"
                          :alt="`${option.label}模型图标`"
                          class="w-full h-full object-cover rounded-2xl"
                        />
                        <div v-else class="w-full h-full rounded-2xl bg-gradient-to-br from-primary-400 to-purple-600 flex items-center justify-center">
                          <span class="text-white font-bold text-base">{{ option.label.charAt(0) }}</span>
                        </div>
                        <!-- 选中状态指示器 -->
                        <div v-if="activeModel === option.value" class="absolute -top-1 -right-1 w-5 h-5 bg-primary-500 rounded-full flex items-center justify-center shadow-lg animate-pulse">
                          <CheckOne
                            theme="filled"
                            size="14"
                            class="text-white"
                            aria-hidden="true"
                          />
                        </div>
                        <!-- 悬停光晕 -->
                        <div class="absolute inset-0 rounded-2xl bg-primary-400/25 scale-0 group-hover:scale-110 transition-transform duration-500 blur-lg"></div>
                      </div>
                      <div class="menu-item-content">
                        <div class="menu-item-title font-semibold">
                          {{ option.label }}
                        </div>
                        <div v-if="option.modelDescription" class="menu-item-description text-sm">
                          {{ option.modelDescription }}
                        </div>
                      </div>
                      <!-- 悬停效果 -->
                      <div class="absolute inset-0 rounded-2xl bg-gradient-to-r from-primary-500/8 to-purple-500/8 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                    </div>
                  </div>
                </div>
              </template>
            </DropdownMenu>
          </div>

          <!-- 右侧功能按钮区域 -->
          <div class="flex items-center space-x-2">
            <!-- 主题切换按钮 -->
            <div v-if="!externalLinkActive && !isPreviewerVisible" class="relative group">
              <button
                type="button"
                class="relative w-11 h-11 rounded-2xl bg-white/80 dark:bg-gray-800/80 backdrop-blur-md border border-gray-200/60 dark:border-gray-600/60 flex items-center justify-center hover:bg-white dark:hover:bg-gray-700 transition-all duration-500 hover:scale-110 shadow-md hover:shadow-xl group overflow-hidden"
                @click="checkMode()"
                aria-label="切换主题"
              >
                <Brightness v-if="!darkMode" size="20" class="text-gray-600 dark:text-gray-400 group-hover:text-yellow-500 dark:group-hover:text-yellow-400 transition-all duration-500 relative z-10" />
                <DarkMode v-else size="20" class="text-gray-600 dark:text-gray-400 group-hover:text-blue-500 transition-all duration-500 relative z-10" />
                <!-- 背景光晕 -->
                <div class="absolute inset-0 rounded-2xl opacity-0 group-hover:opacity-100 transition-all duration-500"
                     :class="darkMode ? 'bg-gradient-to-r from-blue-500/15 to-blue-600/15' : 'bg-gradient-to-r from-yellow-500/15 to-orange-500/15'"></div>
                <!-- 波纹效果 -->
                <div class="absolute inset-0 rounded-2xl scale-0 group-active:scale-100 transition-transform duration-500"
                     :class="darkMode ? 'bg-blue-500/25' : 'bg-yellow-500/25'"></div>
                <!-- 装饰环 -->
                <div class="absolute -inset-1 rounded-2xl border-2 border-gray-300/40 dark:border-gray-600/40 opacity-0 group-hover:opacity-100 transition-all duration-500"></div>
              </button>
              <!-- 悬停提示 -->
              <div v-if="!isMobile" class="tooltip tooltip-bottom">切换主题</div>
            </div>

            <!-- 工具链接组件 -->
            <ToolLinks v-if="!externalLinkActive && !isPreviewerVisible && !isAppListVisible" />

            <!-- 关闭/新建对话按钮 -->
            <div v-if="externalLinkActive" class="relative group">
              <button
                type="button"
                class="relative w-11 h-11 rounded-2xl bg-white/80 dark:bg-gray-800/80 backdrop-blur-md border border-gray-200/60 dark:border-gray-600/60 flex items-center justify-center hover:bg-white dark:hover:bg-gray-700 transition-all duration-500 hover:scale-110 shadow-md hover:shadow-xl group overflow-hidden"
                @click="
                  () => {
                    useGlobalStore.updateExternalLinkDialog(false)
                    if (!isMobile) {
                      appStore.setSiderCollapsed(false)
                    }
                  }
                "
                aria-label="关闭外部链接"
              >
                <Close size="20" class="text-gray-600 dark:text-gray-400 group-hover:text-red-500 transition-all duration-500 relative z-10" />
                <!-- 背景光晕 -->
                <div class="absolute inset-0 rounded-2xl bg-gradient-to-r from-red-500/15 to-red-600/15 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                <!-- 波纹效果 -->
                <div class="absolute inset-0 rounded-2xl bg-red-500/25 scale-0 group-active:scale-100 transition-transform duration-500"></div>
                <!-- 装饰环 -->
                <div class="absolute -inset-1 rounded-2xl border-2 border-red-300/40 dark:border-red-600/40 opacity-0 group-hover:opacity-100 transition-all duration-500"></div>
              </button>
              <div v-if="!isMobile" class="tooltip tooltip-bottom">关闭</div>
            </div>
            <div v-else-if="isAppListVisible" class="relative group">
              <button
                type="button"
                class="relative w-11 h-11 rounded-2xl bg-white/80 dark:bg-gray-800/80 backdrop-blur-md border border-gray-200/60 dark:border-gray-600/60 flex items-center justify-center hover:bg-white dark:hover:bg-gray-700 transition-all duration-500 hover:scale-110 shadow-md hover:shadow-xl group overflow-hidden"
                @click="closeAppList"
                aria-label="关闭应用广场"
              >
                <Close size="20" class="text-gray-600 dark:text-gray-400 group-hover:text-red-500 transition-all duration-500 relative z-10" />
                <!-- 背景光晕 -->
                <div class="absolute inset-0 rounded-2xl bg-gradient-to-r from-red-500/15 to-red-600/15 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                <!-- 波纹效果 -->
                <div class="absolute inset-0 rounded-2xl bg-red-500/25 scale-0 group-active:scale-100 transition-transform duration-500"></div>
                <!-- 装饰环 -->
                <div class="absolute -inset-1 rounded-2xl border-2 border-red-300/40 dark:border-red-600/40 opacity-0 group-hover:opacity-100 transition-all duration-500"></div>
              </button>
              <div v-if="!isMobile" class="tooltip tooltip-bottom">关闭</div>
            </div>
            <div v-else-if="!isPreviewerVisible" class="relative group">
              <button
                type="button"
                class="relative w-11 h-11 rounded-2xl bg-white/80 dark:bg-gray-800/80 backdrop-blur-md border border-gray-200/60 dark:border-gray-600/60 flex items-center justify-center hover:bg-white dark:hover:bg-gray-700 transition-all duration-500 hover:scale-110 shadow-md hover:shadow-xl group overflow-hidden"
                @click="createNewChatGroup()"
                :disabled="listSources.length === 0 && !activeAppId && dataSources.length !== 0"
                aria-label="新建对话"
              >
                <EditTwo size="20" class="text-gray-600 dark:text-gray-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-all duration-500 relative z-10" />
                <!-- 背景光晕 -->
                <div class="absolute inset-0 rounded-2xl bg-gradient-to-r from-primary-500/15 to-purple-500/15 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                <!-- 波纹效果 -->
                <div class="absolute inset-0 rounded-2xl bg-primary-500/25 scale-0 group-active:scale-100 transition-transform duration-500"></div>
                <!-- 装饰环 -->
                <div class="absolute -inset-1 rounded-2xl border-2 border-primary-300/40 dark:border-primary-600/40 opacity-0 group-hover:opacity-100 transition-all duration-500"></div>
              </button>
              <div v-if="!isMobile" class="tooltip tooltip-bottom">新建对话</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </header>
</template>

<style scoped>
/* 响应式布局优化 */
.header-component {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

/* 新增动画效果 */
@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}

@keyframes glow-pulse {
  0%, 100% { opacity: 0.3; transform: scale(1); }
  50% { opacity: 0.8; transform: scale(1.05); }
}

@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-3px); }
}

@keyframes ripple {
  0% {
    transform: scale(0);
    opacity: 1;
  }
  100% {
    transform: scale(4);
    opacity: 0;
  }
}

/* 按钮交互增强 */
.group button {
  position: relative;
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.group button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  transition: left 0.6s cubic-bezier(0.4, 0, 0.2, 1);
}

.group:hover button::before {
  left: 100%;
}

/* 按钮点击波纹效果 */
.group button::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.5);
  transform: translate(-50%, -50%);
  transition: width 0.6s, height 0.6s;
}

.group button:active::after {
  width: 300px;
  height: 300px;
}

/* 头像动画增强 */
.avatar {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  animation: float 3s ease-in-out infinite;
}

.avatar:hover {
  transform: scale(1.08) rotate(3deg);
  filter: brightness(1.1);
}

/* 菜单项动画 */
.menu-item {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  transform-origin: center;
  position: relative;
}

.menu-item::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  background: linear-gradient(45deg, transparent, rgba(255, 255, 255, 0.1), transparent);
  opacity: 0;
  transition: opacity 0.3s;
}

.menu-item:hover::before {
  opacity: 1;
}

.menu-item:hover {
  transform: translateY(-3px) scale(1.03);
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}

.menu-item-active {
  background: linear-gradient(135deg, rgba(79, 70, 229, 0.1), rgba(139, 92, 246, 0.1));
  border-color: rgba(79, 70, 229, 0.3);
}

/* 工具提示增强 */
.tooltip {
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
}

/* 移动端优化 */
@media (max-width: 640px) {
  .header-component {
    height: 3.5rem;
  }
  
  .header-component .tooltip {
    display: none;
  }
  
  .header-component .menu-trigger {
    padding: 0.5rem 0.75rem;
  }
  
  .header-component .avatar {
    width: 2rem;
    height: 2rem;
  }
  
  .header-component .max-w-40vw {
    max-width: 40vw;
  }
  
  .header-component .max-w-30vw {
    max-width: 30vw;
  }
}

/* 暗色模式适配 */
@media (prefers-color-scheme: dark) {
  .header-component .glass-effect {
    background-color: rgba(17, 24, 39, 0.7) !important;
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
  }
  
  .header-component .glass-card {
    background: rgba(31, 41, 55, 0.5) !important;
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    border: 1px solid rgba(75, 85, 99, 0.2);
  }
}

/* 触摸设备优化 */
@media (hover: none) and (pointer: coarse) {
  .header-component .hover-scale:hover {
    transform: none;
  }
  
  .header-component .hover-glow:hover {
    box-shadow: none;
  }
  
  .header-component button {
    min-height: 44px; /* 增大触摸目标 */
    min-width: 44px;
  }
  
  .header-component .tooltip {
    display: none;
  }
  
  .header-component .group:hover .group-hover\:opacity-100 {
    opacity: 0;
  }
  
  .header-component .group:hover .group-hover\:scale-105 {
    transform: none;
  }
  
  .header-component .group:hover .group-hover\:scale-102 {
    transform: none;
  }
}

/* 高对比度模式支持 */
@media (prefers-contrast: high) {
  .header-component .glass-effect {
    background-color: rgba(0, 0, 0, 0.8) !important;
    border: 1px solid rgba(255, 255, 255, 0.3);
  }
  
  .header-component .glass-card {
    background: rgba(0, 0, 0, 0.8) !important;
    border: 1px solid rgba(255, 255, 255, 0.3);
  }
}

/* 减少动画偏好支持 */
@media (prefers-reduced-motion: reduce) {
  .header-component .transition-all {
    transition: none;
  }
  
  .header-component .animate-pulse {
    animation: none;
  }
  
  .header-component .group:hover .group-hover\:scale-105 {
    transform: none;
  }
  
  .header-component .group:hover .group-hover\:scale-102 {
    transform: none;
  }
}

/* 键盘导航支持 */
.header-component button:focus-visible {
  outline: 2px solid #4f46e5;
  outline-offset: 2px;
}

.dark .header-component button:focus-visible {
  outline-color: #818cf8;
}

/* 自定义滚动条样式 */
.header-component .custom-scrollbar::-webkit-scrollbar {
  width: 6px;
}

.header-component .custom-scrollbar::-webkit-scrollbar-track {
  background: rgba(0, 0, 0, 0.1);
  border-radius: 3px;
}

.header-component .custom-scrollbar::-webkit-scrollbar-thumb {
  background: rgba(0, 0, 0, 0.3);
  border-radius: 3px;
}

.header-component .custom-scrollbar::-webkit-scrollbar-thumb:hover {
  background: rgba(0, 0, 0, 0.5);
}

.dark .header-component .custom-scrollbar::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.1);
}

.dark .header-component .custom-scrollbar::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.3);
}

.dark .header-component .custom-scrollbar::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.5);
}
</style>
