<route lang="yaml">
meta:
  title: 首页模型预设
</route>

<script lang="ts" setup>
import api from '@/api/modules/models';
import { ElMessage, ElMessageBox } from 'element-plus';
import { onMounted, reactive, ref } from 'vue';

// 模型预设数据
const presets = ref<any[]>([]);
const loading = ref(false);
const models = ref<any[]>([]);

// 表单数据
const form = reactive({
  title: '',
  description: '',
  icon: 'ri:robot-line',
  iconColor: 'text-blue-500',
  model: '',
  modelName: '',
  prompt: '',
});

// 表单对话框状态
const dialogVisible = ref(false);
const isEdit = ref(false);
const editIndex = ref(-1);

// 颜色选项
const colorOptions = [
  { label: '蓝色', value: 'text-blue-500' },
  { label: '红色', value: 'text-red-500' },
  { label: '绿色', value: 'text-green-500' },
  { label: '黄色', value: 'text-yellow-500' },
  { label: '紫色', value: 'text-purple-500' },
  { label: '粉色', value: 'text-pink-500' },
  { label: '靛蓝', value: 'text-indigo-500' },
];

// 获取模型列表
const getModels = async () => {
  try {
    const res = await api.queryModels({ page: 1, size: 100 });
    if (res.data && res.data.rows) {
      models.value = res.data.rows;
    }
  } catch (error) {
    console.error('获取模型列表失败:', error);
  }
};

// 获取预设列表
const getPresets = async () => {
  loading.value = true;
  try {
    const res = await api.getHomePresets();
    if (res.data) {
      presets.value = res.data;
    }
  } catch (error) {
    console.error('获取模型预设失败:', error);
    ElMessage.error('获取模型预设失败');
  } finally {
    loading.value = false;
  }
};

// 保存预设
const savePresets = async () => {
  loading.value = true;
  try {
    await api.setHomePresets({ presets: presets.value });
    ElMessage.success('保存成功');
  } catch (error) {
    console.error('保存模型预设失败:', error);
    ElMessage.error('保存模型预设失败');
  } finally {
    loading.value = false;
  }
};

// 添加预设
const addPreset = () => {
  resetForm();
  isEdit.value = false;
  dialogVisible.value = true;
};

// 编辑预设
const editPreset = (index: number) => {
  const preset = presets.value[index];
  Object.assign(form, preset);
  isEdit.value = true;
  editIndex.value = index;
  dialogVisible.value = true;
};

// 删除预设
const deletePreset = (index: number) => {
  ElMessageBox.confirm('确定要删除这个预设吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      presets.value.splice(index, 1);
      savePresets();
    })
    .catch(() => {});
};

// 保存表单
const saveForm = () => {
  if (!form.title || !form.prompt) {
    ElMessage.error('请填写标题和提示词');
    return;
  }

  const presetData = { ...form };
  
  if (isEdit.value) {
    presets.value[editIndex.value] = presetData;
  } else {
    presets.value.push(presetData);
  }
  
  dialogVisible.value = false;
  savePresets();
};

// 重置表单
const resetForm = () => {
  Object.assign(form, {
    title: '',
    description: '',
    icon: 'ri:robot-line',
    iconColor: 'text-blue-500',
    model: '',
    modelName: '',
    prompt: '',
  });
};

// 上移预设
const moveUp = (index: number) => {
  if (index > 0) {
    const temp = presets.value[index - 1];
    presets.value[index - 1] = presets.value[index];
    presets.value[index] = temp;
    savePresets();
  }
};

// 下移预设
const moveDown = (index: number) => {
  if (index < presets.value.length - 1) {
    const temp = presets.value[index + 1];
    presets.value[index + 1] = presets.value[index];
    presets.value[index] = temp;
    savePresets();
  }
};

// 从模型创建预设
const createPresetFromModel = (model: any) => {
  resetForm();
  form.title = model.modelName;
  form.description = model.modelDescription || `${model.modelName} - 智能对话模型`;
  form.model = model.model;
  form.modelName = model.modelName;
  form.prompt = `你好，我是${model.modelName}，很高兴为您服务！`;
  isEdit.value = false;
  dialogVisible.value = true;
};

onMounted(() => {
  getPresets();
  getModels();
});
</script>

<template>
  <div>
    <PageHeader>
      <template #title>
        <div class="flex items-center gap-4">首页模型预设</div>
      </template>
      <template #content>
        <div class="text-sm/6">
          <div>设置首页显示的模型预设，用户可以快速选择不同的模型开始对话。</div>
          <div>最多显示8个预设，可以通过拖拽或上下箭头调整顺序。</div>
        </div>
      </template>
      <div class="flex gap-2">
        <HButton @click="addPreset">
          <SvgIcon name="i-ri:add-line" />
          添加预设
        </HButton>
        <HButton @click="savePresets" :loading="loading">
          <SvgIcon name="i-ri:save-line" />
          保存设置
        </HButton>
      </div>
    </PageHeader>

    <!-- 模型列表 -->
    <el-card style="margin: 20px">
      <template #header>
        <div class="flex items-center justify-between">
          <span>从模型创建预设</span>
        </div>
      </template>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        <div v-for="(model, index) in models" :key="index" class="border rounded p-3 hover:shadow-md transition-shadow">
          <div class="flex items-center gap-2 mb-2">
            <img v-if="model.modelAvatar" :src="model.modelAvatar" class="w-6 h-6 rounded" />
            <div v-else class="w-6 h-6 rounded bg-gray-200 flex items-center justify-center text-xs">
              {{ model.modelName.slice(0, 1) }}
            </div>
            <span class="font-medium">{{ model.modelName }}</span>
          </div>
          <div class="text-sm text-gray-600 mb-2">{{ model.model }}</div>
          <el-button size="small" type="primary" @click="createPresetFromModel(model)">
            创建预设
          </el-button>
        </div>
      </div>
    </el-card>

    <!-- 预设列表 -->
    <el-card style="margin: 20px">
      <template #header>
        <div class="flex items-center justify-between">
          <span>当前预设列表</span>
          <span class="text-sm text-gray-500">{{ presets.length }}/8</span>
        </div>
      </template>
      
      <div v-if="presets.length === 0" class="text-center py-8 text-gray-500">
        暂无预设，请添加预设或从模型创建预设
      </div>
      
      <div v-else class="space-y-4">
        <div v-for="(preset, index) in presets" :key="index" class="border rounded p-4">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-3">
              <SvgIcon :icon="preset.icon || 'ri:robot-line'" :class="preset.iconColor || 'text-blue-500'" />
              <div>
                <div class="font-medium">{{ preset.title }}</div>
                <div class="text-sm text-gray-600">{{ preset.description }}</div>
                <div v-if="preset.modelName" class="text-xs text-blue-600">模型: {{ preset.modelName }}</div>
              </div>
            </div>
            <div class="flex items-center gap-2">
              <el-button size="small" type="primary" @click="moveUp(index)" :disabled="index === 0">
                上移
              </el-button>
              <el-button size="small" type="primary" @click="moveDown(index)" :disabled="index === presets.length - 1">
                下移
              </el-button>
              <el-button size="small" type="warning" @click="editPreset(index)">
                编辑
              </el-button>
              <el-button size="small" type="danger" @click="deletePreset(index)">
                删除
              </el-button>
            </div>
          </div>
        </div>
      </div>
    </el-card>

    <!-- 添加/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑预设' : '添加预设'" width="600px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="标题" required>
          <el-input v-model="form.title" placeholder="请输入预设标题" />
        </el-form-item>
        
        <el-form-item label="描述">
          <el-input v-model="form.description" placeholder="请输入预设描述" />
        </el-form-item>
        
        <el-form-item label="图标">
          <el-input v-model="form.icon" placeholder="请输入图标名称，如: ri:robot-line" />
        </el-form-item>
        
        <el-form-item label="图标颜色">
          <el-select v-model="form.iconColor" placeholder="请选择图标颜色">
            <el-option
              v-for="color in colorOptions"
              :key="color.value"
              :label="color.label"
              :value="color.value"
            >
              <span :class="color.value">{{ color.label }}</span>
            </el-option>
          </el-select>
        </el-form-item>
        
        <el-form-item label="模型">
          <el-select v-model="form.model" placeholder="请选择模型" clearable>
            <el-option
              v-for="model in models"
              :key="model.model"
              :label="`${model.modelName} (${model.model})`"
              :value="model.model"
            />
          </el-select>
        </el-form-item>
        
        <el-form-item label="提示词" required>
          <el-input
            v-model="form.prompt"
            type="textarea"
            :rows="4"
            placeholder="请输入预设提示词"
          />
        </el-form-item>
      </el-form>
      
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveForm">{{ isEdit ? '更新' : '添加' }}</el-button>
      </template>
    </el-dialog>
  </div>
</template>