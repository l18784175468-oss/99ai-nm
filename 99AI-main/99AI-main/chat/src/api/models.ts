import { get, post } from '@/utils/request'

/* query models list  */
export function fetchQueryModelsListAPI<T>() {
  return get<T>({
    url: '/models/list',
  })
}

/* query base model config  */
export function fetchModelBaseConfigAPI<T>() {
  return get<T>({
    url: '/models/baseConfig',
  })
}

/* get home model presets  */
export function fetchHomePresetsAPI<T>() {
  return get<T>({
    url: '/models/homePresets',
  })
}

/* set home model presets  */
export function setHomePresetsAPI<T>(data: { presets: any[] }) {
  return post<T>({
    url: '/models/setHomePresets',
    data,
  })
}
