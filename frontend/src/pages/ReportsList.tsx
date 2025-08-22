import { useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { getReports, type Report } from '../lib/api'

export default function ReportsList() {
  const navigate = useNavigate()
  const [reports, setReports] = useState<Report[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [query, setQuery] = useState('')

  // Filtre durumları
  const [statusFilter, setStatusFilter] = useState<Report['status'] | ''>('')
  const [priorityFilter, setPriorityFilter] = useState<Report['priority'] | ''>('')
  const [categoryFilter, setCategoryFilter] = useState<string>('')
  const [dateFrom, setDateFrom] = useState<string>('')
  const [dateTo, setDateTo] = useState<string>('')

  // Görsel fallback (inline SVG data-uri)
  const PLACEHOLDER_DATA_URI =
    "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='800' height='600'><rect width='100%' height='100%' fill='%23e5e7eb'/><text x='50%' y='50%' dominant-baseline='middle' text-anchor='middle' fill='%239ca3af' font-size='18'>G%C3%B6rsel%20y%C3%BCklenemedi</text></svg>"

  useEffect(() => {
    const load = async () => {
      setLoading(true)
      setError(null)
      try {
        const data = await getReports()
        setReports(data)
      } catch {
        setError('Bildirimler yüklenemedi')
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [])

  // Filtre seçenekleri
  const statusOptions = useMemo<Report['status'][]>(() => ['BEKLEMEDE', 'INCELENIYOR', 'COZULDU', 'REDDEDILDI'], [])
  const priorityOptions = useMemo<Report['priority'][]>(() => ['ACIL', 'YUKSEK', 'ORTA', 'DUSUK'], [])
  const categoryOptions = useMemo<string[]>(() => {
    const set = new Set<string>()
    reports.forEach((r) => {
      if (r.category?.name) set.add(r.category.name)
    })
    return Array.from(set)
  }, [reports])

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase()
    let list = reports

    if (q) {
      list = list.filter(
        (r) =>
          r.title.toLowerCase().includes(q) ||
          (r.category?.name || '').toLowerCase().includes(q) ||
          (r.reporter?.username || r.reporter?.email || '').toLowerCase().includes(q)
      )
    }

    if (statusFilter) list = list.filter((r) => r.status === statusFilter)
    if (priorityFilter) list = list.filter((r) => r.priority === priorityFilter)
    if (categoryFilter) list = list.filter((r) => (r.category?.name || '') === categoryFilter)

    if (dateFrom) {
      const from = new Date(dateFrom)
      list = list.filter((r) => new Date(r.created_at) >= from)
    }
    if (dateTo) {
      const to = new Date(dateTo)
      to.setHours(23, 59, 59, 999)
      list = list.filter((r) => new Date(r.created_at) <= to)
    }

    return list
  }, [reports, query, statusFilter, priorityFilter, categoryFilter, dateFrom, dateTo])

  const badgeForStatus = (status: Report['status']) => {
    switch (status) {
      case 'BEKLEMEDE':
        return 'bg-amber-50 text-amber-700 border-amber-200'
      case 'INCELENIYOR':
        return 'bg-blue-50 text-blue-700 border-blue-200'
      case 'COZULDU':
        return 'bg-emerald-50 text-emerald-700 border-emerald-200'
      case 'REDDEDILDI':
        return 'bg-rose-50 text-rose-700 border-rose-200'
      default:
        return 'bg-slate-50 text-slate-700 border-slate-200'
    }
  }

  const badgeForPriority = (priority: Report['priority']) => {
    switch (priority) {
      case 'ACIL':
        return 'bg-rose-50 text-rose-700 border-rose-200'
      case 'YUKSEK':
        return 'bg-amber-50 text-amber-700 border-amber-200'
      case 'ORTA':
        return 'bg-blue-50 text-blue-700 border-blue-200'
      case 'DUSUK':
        return 'bg-slate-50 text-slate-700 border-slate-200'
      default:
        return 'bg-slate-50 text-slate-700 border-slate-200'
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-semibold text-slate-900">Vatandaş Bildirimleri</h1>
          <p className="text-sm text-slate-600">Gelen bildirimleri görüntüleyin ve yönetin</p>
        </div>
        <button
          onClick={() => navigate('/reports/new')}
          className="inline-flex items-center rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700"
        >
          + Yeni Bildirim
        </button>
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

        {/* Filtreler */}
        <div className="mt-4 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3">
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value as Report['status'] | '')}
            className="rounded-lg border border-gray-300 px-3 py-2 text-sm"
          >
            <option value="">Durum (Tümü)</option>
            {statusOptions.map((o) => (
              <option key={o} value={o}>
                {o}
              </option>
            ))}
          </select>

          <select
            value={priorityFilter}
            onChange={(e) => setPriorityFilter(e.target.value as Report['priority'] | '')}
            className="rounded-lg border border-gray-300 px-3 py-2 text-sm"
          >
            <option value="">Öncelik (Tümü)</option>
            {priorityOptions.map((o) => (
              <option key={o} value={o}>
                {o}
              </option>
            ))}
          </select>

          <select
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
            className="rounded-lg border border-gray-300 px-3 py-2 text-sm"
          >
            <option value="">Kategori (Tümü)</option>
            {categoryOptions.map((o) => (
              <option key={o} value={o}>
                {o}
              </option>
            ))}
          </select>

          <input
            type="date"
            value={dateFrom}
            onChange={(e) => setDateFrom(e.target.value)}
            className="rounded-lg border border-gray-300 px-3 py-2 text-sm"
            placeholder="Başlangıç"
          />
          <input
            type="date"
            value={dateTo}
            onChange={(e) => setDateTo(e.target.value)}
            className="rounded-lg border border-gray-300 px-3 py-2 text-sm"
            placeholder="Bitiş"
          />
        </div>

        {(statusFilter || priorityFilter || categoryFilter || dateFrom || dateTo) && (
          <div className="mt-3 flex flex-wrap items-center gap-2">
            <button
              onClick={() => {
                setStatusFilter('')
                setPriorityFilter('')
                setCategoryFilter('')
                setDateFrom('')
                setDateTo('')
              }}
              className="inline-flex items-center rounded-lg border border-gray-300 px-3 py-1.5 text-sm text-slate-700 hover:bg-gray-50"
            >
              Filtreleri Temizle
            </button>
          </div>
        )}
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
        <div className="bg-transparent">
          {filtered.length === 0 ? (
            <div className="min-h-[20vh] grid place-items-center">
              <div className="text-slate-500">Kayıt bulunamadı</div>
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
              {filtered.map((r) => (
                <div
                  key={r.id}
                  onClick={() => navigate(`/reports/${r.id}`)}
                  className="group cursor-pointer bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden hover:shadow-md transition"
                >
                  <div className="relative aspect-[4/3] bg-slate-100">
                    {r.first_media_url ? (
                      <img
                        src={r.first_media_url}
                        alt={r.title}
                        className="w-full h-full object-cover"
                        loading="lazy"
                        decoding="async"
                        sizes="(min-width:1280px) 25vw, (min-width:1024px) 33vw, (min-width:640px) 50vw, 100vw"
                        onError={(e) => {
                          // fallback görsel
                          e.currentTarget.src = PLACEHOLDER_DATA_URI
                        }}
                      />
                    ) : (
                      <div className="w-full h-full grid place-items-center text-slate-400">
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-10 w-10" viewBox="0 0 24 24" fill="currentColor">
                          <path d="M4 5a2 2 0 012-2h12a2 2 0 012 2v13a1 1 0 11-2 0V5H6v14a1 1 0 11-2 0V5z" />
                          <path d="M8 21a1 1 0 001.447.894l3.724-1.862a2 2 0 01.894-.212H18a2 2 0 002-2v-4.586a2 2 0 00-.586-1.414l-4.414-4.414A2 2 0 0013.586 5H10a2 2 0 00-2 2v12z" />
                        </svg>
                      </div>
                    )}
                    <div className="absolute top-2 right-2">
                      <span className={`inline-flex items-center px-2.5 py-1 rounded-full border text-xs font-medium ${badgeForStatus(r.status)}`}>
                        {r.status}
                      </span>
                    </div>
                  </div>
                  <div className="p-3">
                    <div className="flex items-start justify-between gap-2">
                      <h3 className="font-semibold text-slate-900">{r.title}</h3>
                    </div>
                    <div className="mt-1 text-xs text-slate-600">
                      <span>{r.category?.name}</span>
                    </div>
                    <div className="mt-2 flex items-center justify-between">
                      <span className={`inline-flex items-center px-2 py-0.5 rounded-full border text-[11px] font-medium ${badgeForPriority(r.priority)}`}>
                        {r.priority}
                      </span>
                      <span className="text-xs text-slate-500">{new Date(r.created_at).toLocaleDateString()}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  )
}