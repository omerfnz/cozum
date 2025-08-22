import { useEffect, useMemo, useState } from 'react'
import { getReports, getTeams, updateReport, type Report, type Team, me } from '../lib/api'

export default function Tasks() {
  const [reports, setReports] = useState<Report[]>([])
  const [teams, setTeams] = useState<Team[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [query, setQuery] = useState('')
  const [role, setRole] = useState<'VATANDAS' | 'OPERATOR' | 'EKIP' | 'ADMIN' | undefined>()

  useEffect(() => {
    const load = async () => {
      setLoading(true)
      setError(null)
      try {
        const user = await me()
        setRole(user?.role)
        const [r, t] = await Promise.all([getReports(), getTeams()])
        setReports(r)
        setTeams(t)
      } catch (e) {
        console.error(e)
        setError('Görevler yüklenemedi')
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [])

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase()
    if (!q) return reports
    return reports.filter(r =>
      r.title.toLowerCase().includes(q) ||
      (r.category?.name || '').toLowerCase().includes(q) ||
      (r.reporter?.username || r.reporter?.email || '').toLowerCase().includes(q)
    )
  }, [reports, query])

  const statusOptions: Report['status'][] = ['BEKLEMEDE', 'INCELENIYOR', 'COZULDU', 'REDDEDILDI']

  const handleStatusChange = async (id: number, status: Report['status']) => {
    try {
      const updated = await updateReport(id, { status })
      setReports(prev => prev.map(r => (r.id === id ? { ...r, status: updated.status } : r)))
    } catch {
      alert('Durum güncellenemedi')
    }
  }

  const handleAssignTeam = async (id: number, teamId: number | null) => {
    try {
      const updated = await updateReport(id, { assigned_team: teamId })
      setReports(prev => prev.map(r => (r.id === id ? { ...r, assigned_team: updated.assigned_team } : r)))
    } catch {
      alert('Ekip ataması yapılamadı')
    }
  }

  const handleMarkResolved = async (id: number) => {
    await handleStatusChange(id, 'COZULDU')
  }

  const canOperate = role === 'OPERATOR' || role === 'ADMIN'
  const isTeamMember = role === 'EKIP'

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-semibold text-slate-900">Görevler</h1>
          <p className="text-sm text-slate-600">Ekip atamaları ve durum güncellemeleri</p>
        </div>
      </div>

      <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-4">
        <div className="flex flex-col sm:flex-row sm:items-center gap-3">
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Ara: başlık, kategori, kullanıcı"
            className="w-full sm:max-w-xs rounded-lg border border-gray-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <div className="text-sm text-slate-600 sm:ml-auto">Toplam: {filtered.length}</div>
        </div>
      </div>

      {loading ? (
        <div className="min-h-[30vh] grid place-items-center">
          <div className="text-slate-600">Yükleniyor...</div>
        </div>
      ) : error ? (
        <div className="min-h-[20vh] grid place-items-center">
          <div className="text-rose-600">{error}</div>
        </div>
      ) : (
        <div className="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full text-sm">
              <thead className="bg-slate-50 border-b border-gray-200">
                <tr>
                  <th className="text-left font-medium text-slate-600 px-4 py-3">Başlık</th>
                  <th className="text-left font-medium text-slate-600 px-4 py-3">Kategori</th>
                  <th className="text-left font-medium text-slate-600 px-4 py-3">Durum</th>
                  <th className="text-left font-medium text-slate-600 px-4 py-3">Atanan Ekip</th>
                  {canOperate && <th className="text-left font-medium text-slate-600 px-4 py-3">İşlemler</th>}
                  {isTeamMember && <th className="text-left font-medium text-slate-600 px-4 py-3">Aksiyon</th>}
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {filtered.map((r) => (
                  <tr key={r.id} className="hover:bg-slate-50/60">
                    <td className="px-4 py-3">
                      <div className="font-medium text-slate-900">{r.title}</div>
                      <div className="text-xs text-slate-500">{r.reporter?.username || r.reporter?.email}</div>
                    </td>
                    <td className="px-4 py-3">
                      <span className="text-slate-700">{r.category?.name}</span>
                    </td>
                    <td className="px-4 py-3">
                      <select
                        className="border border-gray-300 rounded-lg px-2 py-1 text-sm"
                        value={r.status}
                        onChange={(e) => handleStatusChange(r.id, e.target.value as Report['status'])}
                        disabled={!canOperate}
                      >
                        {statusOptions.map(s => (
                          <option key={s} value={s}>{s}</option>
                        ))}
                      </select>
                    </td>
                    <td className="px-4 py-3">
                      <select
                        className="border border-gray-300 rounded-lg px-2 py-1 text-sm"
                        value={r.assigned_team?.id || ''}
                        onChange={(e) => handleAssignTeam(r.id, e.target.value ? Number(e.target.value) : null)}
                        disabled={!canOperate}
                      >
                        <option value="">Seçilmedi</option>
                        {teams.map(t => (
                          <option key={t.id} value={t.id}>{t.name}</option>
                        ))}
                      </select>
                    </td>
                    {canOperate && (
                      <td className="px-4 py-3">
                        <button
                          onClick={() => handleAssignTeam(r.id, null)}
                          className="text-xs px-3 py-1 rounded-md border border-gray-300 hover:bg-gray-50"
                        >
                          Atamayı Kaldır
                        </button>
                      </td>
                    )}
                    {isTeamMember && (
                      <td className="px-4 py-3">
                        <button
                          onClick={() => handleMarkResolved(r.id)}
                          className="text-xs px-3 py-1 rounded-md bg-emerald-600 text-white hover:bg-emerald-700 disabled:opacity-50"
                          disabled={r.status === 'COZULDU'}
                        >
                          Çözüldü İşaretle
                        </button>
                      </td>
                    )}
                  </tr>
                ))}
                {filtered.length === 0 && (
                  <tr>
                    <td colSpan={5} className="px-4 py-12 text-center text-slate-500">
                      Kayıt bulunamadı
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}