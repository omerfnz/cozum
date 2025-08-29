import axios, { type AxiosRequestConfig } from 'axios'

const baseURL = import.meta.env.VITE_API_BASE_URL || '/api'

export const api = axios.create({ 
  baseURL
})

export async function register(payload: {
  email: string
  username: string
  password: string
  password_confirm: string
  role?: 'VATANDAS' | 'OPERATOR' | 'EKIP' | 'ADMIN'
}) {
  const res = await api.post('/auth/register/', payload)
  return res.data
}

export async function login(payload: { email: string; password: string }) {
  const res = await api.post('/auth/login/', payload)
  return res.data as { access: string; refresh: string }
}

export async function me() {
  const res = await api.get('/auth/me/')
  return res.data
}

export const setAuthToken = (token?: string) => {
  if (token) {
    api.defaults.headers.common['Authorization'] = `Bearer ${token}`
    axios.defaults.headers.common['Authorization'] = `Bearer ${token}`
    localStorage.setItem('token', token)
  } else {
    delete api.defaults.headers.common['Authorization']
    delete axios.defaults.headers.common['Authorization']
    localStorage.removeItem('token')
  }
}

// Refresh token saklama yardımcıları (opsiyonel)
export const setRefreshToken = (token?: string) => {
  if (token) {
    localStorage.setItem('refresh_token', token)
  } else {
    localStorage.removeItem('refresh_token')
  }
}

export const setAuthTokens = (access?: string, refresh?: string) => {
  setAuthToken(access)
  setRefreshToken(refresh)
}

const saved = localStorage.getItem('token')
if (saved) {
  setAuthToken(saved)
}

// 401 için otomatik access token yenileme (opsiyonel)
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest: (AxiosRequestConfig & { _retry?: boolean }) = error.config ?? {}
    const status = error?.response?.status
    const isAuthEndpoint = typeof originalRequest?.url === 'string' && (
      (originalRequest.url as string).includes('/auth/login/') ||
      (originalRequest.url as string).includes('/auth/refresh/')
    )

    if (status === 401 && !isAuthEndpoint && !originalRequest._retry) {
      const refresh = localStorage.getItem('refresh_token')
      if (!refresh) {
        return Promise.reject(error)
      }
      originalRequest._retry = true
      try {
        const res = await api.post('/auth/refresh/', { refresh })
        const newAccess = res.data?.access as string | undefined
        if (newAccess) {
          setAuthToken(newAccess)
          const headers = (originalRequest.headers ?? {}) as unknown as Record<string, string>
          headers['Authorization'] = `Bearer ${newAccess}`
          originalRequest.headers = headers as unknown as AxiosRequestConfig['headers']
          return api.request(originalRequest)
        }
      } catch (e) {
        // Refresh başarısız: oturumu temizle
        setAuthTokens(undefined, undefined)
        return Promise.reject(e)
      }
    }
    return Promise.reject(error)
  }
)

// Profil güncelleme (backend: /auth/me/update/)
export async function updateMe(payload: Partial<{
  username: string;
  first_name: string;
  last_name: string;
  phone: string | null;
  address: string | null;
}>){
  const res = await api.patch('/auth/me/update/', payload)
  return res.data
}

// Şifre değiştirme (backend: /auth/password/change/)
export async function changePassword(payload: {
  old_password: string
  new_password: string
  new_password_confirm: string
}) {
  const res = await api.put('/auth/password/change/', payload)
  return res.data as { detail: string }
}

// Category API functions
export interface Category {
  id: number
  name: string
  description: string
  is_active: boolean
}

export async function getCategories(): Promise<Category[]> {
  const res = await api.get('/categories/')
  return res.data
}

export async function createCategory(payload: { name: string; description?: string; is_active?: boolean }): Promise<Category> {
  const res = await api.post('/categories/', payload)
  return res.data
}

export async function updateCategory(
  id: number,
  payload: Partial<Pick<Category, 'name' | 'description' | 'is_active'>>
): Promise<Category> {
  const res = await api.patch(`/categories/${id}/`, payload)
  return res.data
}

export async function deleteCategory(id: number): Promise<void> {
  await api.delete(`/categories/${id}/`)
}
// Users API
export interface User {
  id: number
  email: string
  username: string
  first_name?: string
  last_name?: string
  role: 'VATANDAS' | 'OPERATOR' | 'EKIP' | 'ADMIN'
  role_display?: string
  team?: number | null
  team_name?: string | null
  phone?: string | null
  address?: string | null
  date_joined?: string
  last_login?: string | null
}

// Teams API
export interface Team {
  id: number
  name: string
  description?: string | null
  team_type: 'EKIP' | 'OPERATOR' | 'ADMIN'
  created_by: number
  created_by_name?: string
  members?: number[]
  members_count?: number
  created_at: string
  is_active: boolean
}

// Reports API (liste - dashboard istatistikleri için)
export interface Report {
  id: number
  title: string
  status: 'BEKLEMEDE' | 'INCELENIYOR' | 'COZULDU' | 'REDDEDILDI'
  priority: 'DUSUK' | 'ORTA' | 'YUKSEK' | 'ACIL'
  reporter: User
  category: Category
  assigned_team: Team | null
  location?: string
  created_at: string
  updated_at: string
  media_count: number
  comment_count: number
  first_media_url?: string
}

export async function getReports(scope?: 'all' | 'mine' | 'assigned', tasksOnly?: boolean): Promise<Report[]> {
  const params: Record<string, string> = {}
  if (scope) params.scope = scope
  if (tasksOnly) params.tasks_only = 'true'
  
  const res = await api.get('/reports/', { params: Object.keys(params).length > 0 ? params : undefined })
  return res.data
}

// Bildirim oluşturma payloadı
export interface CreateReportPayload {
  title: string
  description: string
  category: number
  location?: string
  latitude?: number
  longitude?: number
  media_files?: File[]
}

export async function createReport(payload: CreateReportPayload): Promise<Report> {
  const formData = new FormData()
  formData.append('title', payload.title)
  formData.append('description', payload.description)
  formData.append('category', String(payload.category))
  
  if (payload.location) {
    formData.append('location', payload.location)
  }
  
  if (payload.latitude !== undefined) {
    formData.append('latitude', String(payload.latitude))
  }
  
  if (payload.longitude !== undefined) {
    formData.append('longitude', String(payload.longitude))
  }

  // Tek fotoğraf yükleme (MVP gereksinimi)
  if (payload.media_files && payload.media_files.length > 0) {
    // Backend media_files anahtarını bekliyor
    payload.media_files.forEach((file) => formData.append('media_files', file))
  }

  // Content-Type başlığını tarayıcının sınır (boundary) eklemesi için MANUEL AYARLAMAYIN
  // Axios + tarayıcı FormData gönderirken gerekli Content-Type ve boundary değerini kendisi belirler
  const res = await api.post('/reports/', formData)
  return res.data
}

export async function getUsers(): Promise<User[]> {
  const res = await api.get('/users/')
  return res.data
}

export async function getUser(id: number): Promise<User> {
  const res = await api.get(`/users/${id}/`)
  return res.data
}

export async function updateUser(id: number, payload: Partial<User>): Promise<User> {
  const res = await api.patch(`/users/${id}/`, payload)
  return res.data
}

export async function deleteUser(id: number): Promise<void> {
  await api.delete(`/users/${id}/`)
}

export async function setUserRole(id: number, role: User['role']): Promise<User> {
  const res = await api.post(`/users/${id}/set_role/`, { role })
  return res.data
}

export async function setUserTeam(id: number, team: number | null): Promise<User> {
  const res = await api.post(`/users/${id}/set_team/`, { team })
  return res.data
}

export interface MediaItem { id: number; file: string; file_path?: string; media_type?: string; uploaded_at?: string }
export interface CommentItem { id: number; user: User; content: string; created_at: string }
export interface ReportDetail extends Report {
  description: string
  latitude?: number
  longitude?: number
  media_files: MediaItem[]
  comments: CommentItem[]
}

export async function getReport(id: number): Promise<ReportDetail> {
  const res = await api.get(`/reports/${id}/`)
  return res.data
}

export async function getComments(reportId: number): Promise<CommentItem[]> {
  const res = await api.get(`/reports/${reportId}/comments/`)
  return res.data
}

export async function addComment(reportId: number, content: string): Promise<CommentItem> {
  const res = await api.post(`/reports/${reportId}/comments/`, { content })
  return res.data
}

export async function getTeams(): Promise<Team[]> {
  const res = await api.get('/teams/')
  return res.data
}

export async function createTeam(payload: { name: string; description?: string; team_type?: 'EKIP' | 'OPERATOR' | 'ADMIN'; members?: number[]; is_active?: boolean }): Promise<Team> {
  const res = await api.post('/teams/', payload)
  return res.data
}

export async function updateTeam(id: number, payload: Partial<Pick<Team, 'name' | 'description' | 'team_type' | 'members' | 'is_active'>>): Promise<Team> {
  const res = await api.patch(`/teams/${id}/`, payload)
  return res.data
}

export async function deleteTeam(id: number): Promise<void> {
  await api.delete(`/teams/${id}/`)
}
export async function updateReport(
  id: number,
  payload: Partial<{ status: Report['status']; assigned_team: number | null }>
): Promise<Report> {
  const res = await api.patch(`/reports/${id}/`, payload)
  return res.data
}

// Task helpers mapped from Report
export type TaskStatus = 'ATANDI' | 'DEVAM_EDIYOR' | 'TAMAMLANDI' | 'IPTAL'

export interface Task {
  id: number
  report_title: string
  assigned_team_name?: string | null
  status: TaskStatus
}

function reportStatusToTaskStatus(status: Report['status']): TaskStatus {
  switch (status) {
    case 'BEKLEMEDE':
      return 'ATANDI'
    case 'INCELENIYOR':
      return 'DEVAM_EDIYOR'
    case 'COZULDU':
      return 'TAMAMLANDI'
    case 'REDDEDILDI':
      return 'IPTAL'
    default:
      return 'ATANDI'
  }
}

function taskStatusToReportStatus(status: TaskStatus): Report['status'] {
  switch (status) {
    case 'ATANDI':
      return 'BEKLEMEDE'
    case 'DEVAM_EDIYOR':
      return 'INCELENIYOR'
    case 'TAMAMLANDI':
      return 'COZULDU'
    case 'IPTAL':
      return 'REDDEDILDI'
  }
}

function mapReportToTask(r: Report): Task {
  return {
    id: r.id,
    report_title: r.title,
    assigned_team_name: r.assigned_team?.name ?? null,
    status: reportStatusToTaskStatus(r.status),
  }
}

export async function getTasks(): Promise<Task[]> {
  const reports = await getReports(undefined, true)
  return reports.map(mapReportToTask)
}

export async function updateTaskStatus(id: number, status: TaskStatus): Promise<Task> {
  const updated = await updateReport(id, { status: taskStatusToReportStatus(status) })
  return mapReportToTask(updated)
}