<script lang="ts" setup>
import { fetchQueryOneCatAPI } from '@/api/appStore'
import { fetchUpdateGroupAPI } from '@/api/group'
import { fetchQueryModelsListAPI } from '@/api/models'
import { DropdownMenu } from '@/components/common/DropdownMenu'
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
  val => {
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
  <header class="sticky top-0 left-0 right-0 z-30 h-16 select-none group">
    <!-- 多层背景装饰 -->
    <div class="absolute inset-0 bg-gradient-to-r from-white/90 via-white/80 to-white/90 dark:from-gray-900/90 dark:via-gray-900/80 dark:to-gray-900/90 backdrop-blur-xl border-b border-gray-200/50 dark:border-gray-700/50 transition-all duration-300"></div>
    
    <!-- 动态光效 -->
    <div class="absolute inset-0 bg-gradient-to-r from-primary-500/5 via-transparent to-purple-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
    
    <div class="relative flex items-center justify-center min-w-0 h-full">
      <div class="flex w-full h-full items-center" :class="{ 'px-4': !isMobile, 'px-2': isMobile }">
        <!-- 侧边栏展开按钮 -->
        <div
          v-if="collapsed && !externalLinkActive && !isPreviewerVisible"
          class="relative group mx-1"
        >
          <button
            type="button"
            class="relative w-10 h-10 rounded-xl bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm border border-gray-200/50 dark:border-gray-600/50 flex items-center justify-center hover:bg-white dark:hover:bg-gray-700 transition-all duration-300 hover:scale-105 shadow-sm hover:shadow-lg group overflow-hidden"
            @click="handleUpdateCollapsed"
            aria-label="展开侧边栏"
          >
            <ExpandLeft size="20" class="text-gray-600 dark:text-gray-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-all duration-300 relative z-10" />
            <!-- 按钮光晕 -->
            <div class="absolute inset-0 rounded-xl bg-gradient-to-r from-primary-500/10 to-purple-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            <!-- 波纹效果 -->
            <div class="absolute inset-0 rounded-xl bg-primary-500/20 scale-0 group-active:scale-100 transition-transform duration-300"></div>
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
            <div class="py-2 flex items-center space-x-3 group">
              <div class="relative transform transition-transform duration-300 group-hover:scale-110">
                <img
                  v-if="currentExternalLink && currentExternalLink.icon"
                  :src="currentExternalLink.icon"
                  alt="网站图标"
                  class="w-8 h-8 rounded-xl object-cover shadow-md group-hover:shadow-xl transition-shadow duration-300"
                />
                <div v-else class="w-8 h-8 rounded-xl bg-gradient-to-br from-gray-200 to-gray-300 dark:from-gray-600 dark:to-gray-700 flex items-center justify-center shadow-md group-hover:shadow-xl transition-all duration-300">
                  <span class="text-sm font-medium text-gray-600 dark:text-gray-300 group-hover:text-gray-800 dark:group-hover:text-gray-100 transition-colors duration-300">{{ currentExternalLink?.name?.charAt(0) || '?' }}</span>
                </div>
                <!-- 装饰环 -->
                <div class="absolute -inset-1 rounded-xl border-2 border-primary-300/30 dark:border-primary-600/30 animate-pulse"></div>
                <!-- 悬停光晕 -->
                <div class="absolute -inset-2 rounded-xl bg-primary-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300 blur-md"></div>
              </div>
              <span
                class="text-base font-medium text-gray-800 dark:text-gray-200 truncate whitespace-nowrap overflow-hidden max-w-[30vw] transition-colors duration-300 group-hover:text-primary-600 dark:group-hover:text-primary-400"
              >
                {{ currentExternalLink?.name || '外部链接' }}
              </span>
            </div>
          </div>

          <!-- 不可切换模型状态 -->
          <div v-else-if="notSwitchModel" class="flex-1 flex items-center">
            <div class="relative group">
              <div class="menu menu-md relative">
                <button class="relative menu-trigger bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm border border-gray-200/50 dark:border-gray-600/50 rounded-xl px-4 py-2 flex items-center space-x-3 hover:bg-white dark:hover:bg-gray-700 transition-all duration-300 shadow-sm hover:shadow-md" aria-label="当前对话" disabled>
                  <div class="avatar avatar-md relative">
                    <div class="w-8 h-8 rounded-xl bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center shadow-sm group-hover:shadow-md transition-all duration-300">
                      <span class="text-white font-bold text-sm">{{ (activeGroupInfo?.title || '新对话').charAt(0) }}</span>
                    </div>
                    <!-- 头像光晕 -->
                    <div class="absolute inset-0 rounded-xl bg-primary-400/20 scale-0 group-hover:scale-100 transition-transform duration-300 blur-md"></div>
                  </div>
                  <span class="truncate whitespace-nowrap overflow-hidden max-w-[30vw] font-medium text-gray-700 dark:text-gray-300 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors duration-300">
                    {{ activeGroupInfo?.title || '新对话' }}
                  </span>
                  <div class="w-2 h-2 bg-green-500 rounded-full animate-pulse shadow-sm"></div>
                </button>
              </div>
              <!-- 背景光晕 -->
              <div class="absolute inset-0 rounded-xl bg-gradient-to-r from-primary-500/5 to-purple-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            </div>
          </div>

          <!-- 模型选择下拉菜单 -->
          <div v-else class="flex-1 flex items-center">
            <DropdownMenu v-model="isMenuOpen" position="bottom-left" max-height="50vh">
              <template #trigger>
                <button
                  class="relative group menu-trigger bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm border border-gray-200/50 dark:border-gray-600/50 rounded-xl px-4 py-2 flex items-center space-x-3 hover:bg-white dark:hover:bg-gray-700 transition-all duration-300 hover:scale-[1.02] hover:shadow-md overflow-hidden"
                  @mouseover="isHovering = true"
                  @mouseleave="isHovering = false"
                  aria-label="选择模型"
                >
                  <div class="avatar avatar-md relative">
                    <div class="w-8 h-8 rounded-xl bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center shadow-sm group-hover:shadow-md transition-all duration-300">
                      <span class="text-white font-bold text-sm">{{ (configObj?.modelInfo?.modelName || '新对话').charAt(0) }}</span>
                    </div>
                    <!-- 头像光晕 -->
                    <div class="absolute inset-0 rounded-xl bg-primary-400/20 scale-0 group-hover:scale-100 transition-transform duration-300 blur-md"></div>
                  </div>
                  <span class="truncate whitespace-nowrap overflow-hidden max-w-[40vw] font-medium text-gray-700 dark:text-gray-300 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors duration-300">
                    {{ configObj?.modelInfo?.modelName || '新对话' }}
                  </span>
                  <Right
                    v-if="isHovering || isMobile || isMenuOpen"
                    size="18"
                    class="text-gray-500 dark:text-gray-400 transition-all duration-300"
                    :class="{
                      'rotate-90': isMenuOpen,
                    }"
                    aria-hidden="true"
                  />
                  <!-- 背景光晕 -->
                  <div class="absolute inset-0 rounded-xl bg-gradient-to-r from-primary-500/10 to-purple-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                  <!-- 波纹效果 -->
                  <div class="absolute inset-0 rounded-xl bg-primary-500/20 scale-0 group-active:scale-100 transition-transform duration-300"></div>
                </button>
              </template>
              <template #menu="{ close }">
                <div class="p-2 bg-white/95 dark:bg-gray-800/95 backdrop-blur-xl rounded-2xl shadow-2xl border border-gray-200/50 dark:border-gray-700/50 overflow-hidden">
                  <!-- 菜单顶部装饰线 -->
                  <div class="h-0.5 w-full bg-gradient-to-r from-primary-500 via-purple-500 to-primary-500 mb-2 rounded-full"></div>
                  <div class="max-h-60 overflow-y-auto custom-scrollbar">
                    <div
                      v-for="(option, index) in modelOptions"
                      :key="index"
                      class="menu-item menu-item-md group relative overflow-hidden"
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
                      <div class="avatar avatar-md relative">
                        <img
                          v-if="option.modelAvatar"
                          :src="option.modelAvatar"
                          :alt="`${option.label}模型图标`"
                          class="w-full h-full object-cover rounded-xl"
                        />
                        <div v-else class="w-full h-full rounded-xl bg-gradient-to-br from-primary-400 to-purple-600 flex items-center justify-center">
                          <span class="text-white font-bold text-sm">{{ option.label.charAt(0) }}</span>
                        </div>
                        <!-- 选中状态指示器 -->
                        <div v-if="activeModel === option.value" class="absolute -top-1 -right-1 w-4 h-4 bg-primary-500 rounded-full flex items-center justify-center shadow-md animate-pulse">
                          <CheckOne
                            theme="filled"
                            size="12"
                            class="text-white"
                            aria-hidden="true"
                          />
                        </div>
                        <!-- 悬停光晕 -->
                        <div class="absolute inset-0 rounded-xl bg-primary-400/20 scale-0 group-hover:scale-100 transition-transform duration-300 blur-md"></div>
                      </div>
                      <div class="menu-item-content">
                        <div class="menu-item-title font-medium">
                          {{ option.label }}
                        </div>
                        <div v-if="option.modelDescription" class="menu-item-description text-sm">
                          {{ option.modelDescription }}
                        </div>
                      </div>
                      <!-- 悬停效果 -->
                      <div class="absolute inset-0 rounded-xl bg-gradient-to-r from-primary-500/5 to-purple-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                    </div>
                  </div>
                </div>
              </template>
            </DropdownMenu>
          </div>

          <!-- 右侧功能按钮区域 -->
          <div class="flex items-center space-x-1">
            <!-- 主题切换按钮 -->
            <div v-if="!externalLinkActive && !isPreviewerVisible" class="relative group">
              <button
                type="button"
                class="relative w-10 h-10 rounded-xl bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm border border-gray-200/50 dark:border-gray-600/50 flex items-center justify-center hover:bg-white dark:hover:bg-gray-700 transition-all duration-300 hover:scale-105 shadow-sm hover:shadow-lg group overflow-hidden"
                @click="checkMode()"
                aria-label="切换主题"
              >
                <Brightness v-if="!darkMode" size="18" class="text-gray-600 dark:text-gray-400 group-hover:text-yellow-500 dark:group-hover:text-yellow-400 transition-all duration-300 relative z-10" />
                <DarkMode v-else size="18" class="text-gray-600 dark:text-gray-400 group-hover:text-blue-500 transition-all duration-300 relative z-10" />
                <!-- 背景光晕 -->
                <div class="absolute inset-0 rounded-xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"
                     :class="darkMode ? 'bg-gradient-to-r from-blue-500/10 to-blue-600/10' : 'bg-gradient-to-r from-yellow-500/10 to-orange-500/10'"></div>
                <!-- 波纹效果 -->
                <div class="absolute inset-0 rounded-xl scale-0 group-active:scale-100 transition-transform duration-300"
                     :class="darkMode ? 'bg-blue-500/20' : 'bg-yellow-500/20'"></div>
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
                class="relative w-10 h-10 rounded-xl bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm border border-gray-200/50 dark:border-gray-600/50 flex items-center justify-center hover:bg-white dark:hover:bg-gray-700 transition-all duration-300 hover:scale-105 shadow-sm hover:shadow-lg group overflow-hidden"
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
                <Close size="18" class="text-gray-600 dark:text-gray-400 group-hover:text-red-500 transition-all duration-300 relative z-10" />
                <!-- 背景光晕 -->
                <div class="absolute inset-0 rounded-xl bg-gradient-to-r from-red-500/10 to-red-600/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                <!-- 波纹效果 -->
                <div class="absolute inset-0 rounded-xl bg-red-500/20 scale-0 group-active:scale-100 transition-transform duration-300"></div>
              </button>
              <div v-if="!isMobile" class="tooltip tooltip-bottom">关闭</div>
            </div>
            <div v-else-if="isAppListVisible" class="relative group">
              <button
                type="button"
                class="relative w-10 h-10 rounded-xl bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm border border-gray-200/50 dark:border-gray-600/50 flex items-center justify-center hover:bg-white dark:hover:bg-gray-700 transition-all duration-300 hover:scale-105 shadow-sm hover:shadow-lg group overflow-hidden"
                @click="closeAppList"
                aria-label="关闭应用广场"
              >
                <Close size="18" class="text-gray-600 dark:text-gray-400 group-hover:text-red-500 transition-all duration-300 relative z-10" />
                <!-- 背景光晕 -->
                <div class="absolute inset-0 rounded-xl bg-gradient-to-r from-red-500/10 to-red-600/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                <!-- 波纹效果 -->
                <div class="absolute inset-0 rounded-xl bg-red-500/20 scale-0 group-active:scale-100 transition-transform duration-300"></div>
              </button>
              <div v-if="!isMobile" class="tooltip tooltip-bottom">关闭</div>
            </div>
            <div v-else-if="!isPreviewerVisible" class="relative group">
              <button
                type="button"
                class="relative w-10 h-10 rounded-xl bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm border border-gray-200/50 dark:border-gray-600/50 flex items-center justify-center hover:bg-white dark:hover:bg-gray-700 transition-all duration-300 hover:scale-105 shadow-sm hover:shadow-lg group overflow-hidden"
                @click="createNewChatGroup()"
                :disabled="listSources.length === 0 && !activeAppId && dataSources.length !== 0"
                aria-label="新建对话"
              >
                <EditTwo size="18" class="text-gray-600 dark:text-gray-400 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-all duration-300 relative z-10" />
                <!-- 背景光晕 -->
                <div class="absolute inset-0 rounded-xl bg-gradient-to-r from-primary-500/10 to-purple-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                <!-- 波纹效果 -->
                <div class="absolute inset-0 rounded-xl bg-primary-500/20 scale-0 group-active:scale-100 transition-transform duration-300"></div>
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
  transition: all 0.3s ease;
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

/* 按钮交互增强 */
.group button {
  position: relative;
  overflow: hidden;
}

.group button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s;
}

.group:hover button::before {
  left: 100%;
}

/* 头像动画增强 */
.avatar {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.avatar:hover {
  transform: scale(1.05) rotate(2deg);
}

/* 菜单项动画 */
.menu-item {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  transform-origin: center;
}

.menu-item:hover {
  transform: translateY(-2px) scale(1.02);
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
