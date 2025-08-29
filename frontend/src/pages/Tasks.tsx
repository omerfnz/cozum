import { useEffect, useMemo, useState } from 'react'
import { getTasks, updateTaskStatus, type Task } from '../lib/api'
import toast from 'react-hot-toast'

export default function Tasks() {
  const [loading, setLoading] = useState(true)
  const [tasks, setTasks] = useState<Task[]>([])
  const [query, setQuery] = useState('')

  const fetchTasks = async () => {
    try {
      setLoading(true)
      const data = await getTasks()
      setTasks(data)
    } catch (e) {
      const err = e as { response?: { data?: { detail?: string } } }
      toast.error(err?.response?.data?.detail || 'Görevler yüklenemedi')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchTasks()
  }, [])

  const filtered = useMemo(() => {
    const q = query.toLowerCase().trim()
    if (!q) return tasks
    return tasks.filter(t =>
      t.report_title.toLowerCase().includes(q) ||
      (t.assigned_team_name || '').toLowerCase().includes(q) ||
      t.status.toLowerCase().includes(q)
    )
  }, [tasks, query])

  const updateStatus = async (t: Task, status: Task['status']) => {
    try {
      const updated = await updateTaskStatus(t.id, status)
      setTasks(prev => prev.map(x => (x.id === t.id ? updated : x)))
      toast.success('Durum güncellendi')
    } catch (e) {
      const err = e as { response?: { data?: { detail?: string } } }
      toast.error(err?.response?.data?.detail || 'Durum güncellenemedi')
    }
  }

  return (
    <div className="p-6">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Görevler</h1>
          <p className="text-slate-500 text-sm">Rapor atamaları ve durum yönetimi</p>
        </div>
        <div className="w-72">
          <input
            value={query}
            onChange={e => setQuery(e.target.value)}
            placeholder="Ara: rapor, takım, durum..."
            className="w-full px-3 py-2 rounded-md border border-gray-200 focus:ring-2 focus:ring-blue-500 outline-none"
          />
        </div>
      </div>

      <div className="bg-white rounded-lg border border-gray-200 overflow-hidden shadow-sm">
        <table className="min-w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="text-left px-4 py-3 text-slate-600 text-sm">Rapor</th>
              <th className="text-left px-4 py-3 text-slate-600 text-sm">Takım</th>
              <th className="text-left px-4 py-3 text-slate-600 text-sm">Durum</th>
              <th className="text-right px-4 py-3 text-slate-600 text-sm">İşlemler</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <>
                {Array.from({ length: 8 }).map((_, i) => (
                  <tr key={i} className="border-t border-gray-100 animate-pulse">
                    <td className="px-4 py-3"><div className="h-4 w-64 bg-slate-200 rounded" /></td>
                    <td className="px-4 py-3"><div className="h-4 w-48 bg-slate-200 rounded" /></td>
                    <td className="px-4 py-3"><div className="h-8 w-28 bg-slate-200 rounded" /></td>
                    <td className="px-4 py-3 text-right"><div className="h-8 w-24 bg-slate-200 rounded ml-auto" /></td>
                  </tr>
                ))}
              </>
            ) : filtered.length === 0 ? (
              <tr>
                <td colSpan={4} className="px-4 py-8 text-center text-slate-500">Kayıt bulunamadı</td>
              </tr>
            ) : (
              filtered.map(t => (
                <tr key={t.id} className="border-t border-gray-100 hover:bg-gray-50">
                  <td className="px-4 py-3 text-sm text-slate-800">{t.report_title}</td>
                  <td className="px-4 py-3 text-sm text-slate-800">{t.assigned_team_name || '—'}</td>
                  <td className="px-4 py-3 text-sm">
                    <select
                      value={t.status}
                      onChange={e => updateStatus(t, e.target.value as Task['status'])}
                      className="px-2 py-1 border border-gray-200 rounded-md text-sm"
                    >
                      <option value="ATANDI">Atandı</option>
                      <option value="DEVAM_EDIYOR">Devam Ediyor</option>
                      <option value="TAMAMLANDI">Tamamlandı</option>
                      <option value="IPTAL">İptal</option>
                    </select>
                  </td>
                  <td className="px-4 py-3 text-sm text-right">
                    <button className="px-3 py-1.5 bg-blue-50 text-blue-600 rounded-md hover:bg-blue-100">Detay</button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  )
}