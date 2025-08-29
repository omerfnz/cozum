import { useEffect, useState, useMemo } from 'react'
import { me, getReports, getCategories, type Report, type Category } from '../lib/api'
import { useNavigate } from 'react-router-dom'

// Kullanıcı tipi tanımı (any yerine)
interface User {
  first_name?: string
  username?: string
  email: string
  role_display?: string
  role?: string
}

export default function Dashboard() {
  const navigate = useNavigate()
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const [reports, setReports] = useState<Report[]>([])
  const [categories, setCategories] = useState<Category[]>([])
  const [statsLoading, setStatsLoading] = useState(true)

  // Dashboard filtreleri
  const [scope, setScope] = useState<'all' | 'mine' | 'assigned'>('all')
  const [timeRange, setTimeRange] = useState<'7' | '30' | '90' | 'all'>('30')

  useEffect(() => {
    const loadAll = async () => {
      try {
        const userData = await me()
        setUser(userData)
        // User bilgisi geldikten sonra istatistikleri çek
        setStatsLoading(true)
        const [r, c] = await Promise.allSettled([
          getReports(scope === 'all' ? undefined : scope),
          getCategories(),
        ])
        if (r.status === 'fulfilled') setReports(r.value)
        if (c.status === 'fulfilled') setCategories(c.value)
      } catch {
        navigate('/login')
      } finally {
        setLoading(false)
        setStatsLoading(false)
      }
    }
    loadAll()
  }, [navigate, scope])

  // Zaman filtresi uygulanmış raporlar
  const filteredReports = useMemo(() => {
    if (timeRange === 'all') return reports
    const now = new Date()
    const days = Number(timeRange)
    const threshold = new Date(now)
    threshold.setDate(now.getDate() - days)
    return reports.filter((r) => new Date(r.created_at) >= threshold)
  }, [reports, timeRange])

  const totalReports = filteredReports.length
  const pending = filteredReports.filter(r => r.status === 'BEKLEMEDE' || r.status === 'INCELENIYOR').length
  const resolved = filteredReports.filter(r => r.status === 'COZULDU').length
  const categoriesCount = categories.length

  const statusCounts = {
    BEKLEMEDE: filteredReports.filter(r => r.status === 'BEKLEMEDE').length,
    INCELENIYOR: filteredReports.filter(r => r.status === 'INCELENIYOR').length,
    COZULDU: filteredReports.filter(r => r.status === 'COZULDU').length,
    REDDEDILDI: filteredReports.filter(r => r.status === 'REDDEDILDI').length,
  }
  const distTotal = Object.values(statusCounts).reduce((a, b) => a + b, 0) || 1

  // Top kategoriler (ilk 5)
  const topCategories = useMemo(() => {
    const map = new Map<string, number>()
    filteredReports.forEach((r) => {
      const name = r.category?.name || 'Diğer'
      map.set(name, (map.get(name) || 0) + 1)
    })
    const arr = Array.from(map.entries()).sort((a, b) => b[1] - a[1])
    return arr.slice(0, 5)
  }, [filteredReports])

  // Son bildirimler (en yeni 5)
  const recentReports = useMemo(() => {
    return [...filteredReports]
      .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
      .slice(0, 5)
  }, [filteredReports])

  // KPI hesaplamaları
  const kpis = useMemo(() => {
    const total = filteredReports.length || 0
    const now = new Date()
    const resolved = filteredReports.filter(r => r.status === 'COZULDU')
    const open = filteredReports.filter(r => r.status !== 'COZULDU')

    const resolutionRate = total ? (resolved.length / total) * 100 : 0

    const avgResolutionHours = resolved.length
      ? resolved.reduce((acc, r) => {
          const start = new Date(r.created_at).getTime()
          const end = new Date(r.updated_at || r.created_at).getTime()
          const hours = Math.max(0, (end - start) / (1000 * 60 * 60))
          return acc + hours
        }, 0) / resolved.length
      : 0

    const avgOpenAgeDays = open.length
      ? open.reduce((acc, r) => {
          const start = new Date(r.created_at).getTime()
          const days = Math.max(0, (now.getTime() - start) / (1000 * 60 * 60 * 24))
          return acc + days
        }, 0) / open.length
      : 0

    const assignmentRate = total
      ? (filteredReports.filter(r => !!r.assigned_team).length / total) * 100
      : 0

    return { resolutionRate, avgResolutionHours, avgOpenAgeDays, assignmentRate }
  }, [filteredReports])

  // Trend/Sparkline verisi (günlük oluşturulan raporlar)
  const trend = useMemo(() => {
    const toKey = (d: Date) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
    const days = timeRange === 'all' ? 30 : Number(timeRange)
    const labels: string[] = []
    const values: number[] = []

    const now = new Date()
    const start = new Date(now)
    start.setDate(now.getDate() - (days - 1))

    // bucketları hazırla
    const buckets = new Map<string, number>()
    for (let i = 0; i < days; i++) {
      const d = new Date(start)
      d.setDate(start.getDate() + i)
      buckets.set(toKey(d), 0)
    }

    filteredReports.forEach(r => {
      const key = toKey(new Date(r.created_at))
      if (buckets.has(key)) {
        buckets.set(key, (buckets.get(key) || 0) + 1)
      }
    })

    for (const [k, v] of buckets.entries()) {
      labels.push(k)
      values.push(v)
    }

    const max = values.reduce((a, b) => Math.max(a, b), 0)
    const W = 240
    const H = 40

    // Path hesapla
    const points = values.map((v, i) => {
      const x = (i / Math.max(1, values.length - 1)) * W
      const y = H - (max ? (v / max) * H : 0)
      return `${x},${y}`
    })
    const path = points.length ? `M ${points[0]} L ${points.slice(1).join(' ')}` : ''

    return { labels, values, max, W, H, path, total: values.reduce((a, b) => a + b, 0) }
  }, [filteredReports, timeRange])

  if (loading) {
    return (
      <div className="space-y-6 animate-pulse">
        <section className="h-28 rounded-2xl bg-slate-100 border border-slate-200" />
        <section className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="bg-white rounded-xl border border-gray-200 shadow-sm p-5">
              <div className="flex items-center gap-4">
                <div className="w-10 h-10 rounded-lg bg-slate-200" />
                <div className="flex-1 space-y-2">
                  <div className="h-3 w-24 bg-slate-200 rounded" />
                  <div className="h-4 w-16 bg-slate-200 rounded" />
                </div>
              </div>
            </div>
          ))}
        </section>
        <section className="bg-white rounded-xl border border-gray-200 shadow-sm p-5">
          <div className="h-3 w-full bg-slate-200 rounded" />
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mt-4">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="h-3 bg-slate-200 rounded" />
            ))}
          </div>
        </section>
        <section className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="bg-white rounded-xl border border-gray-200 shadow-sm p-5">
              <div className="flex items-center gap-4">
                <div className="w-10 h-10 rounded-lg bg-slate-200" />
                <div className="flex-1 space-y-2">
                  <div className="h-3 w-24 bg-slate-200 rounded" />
                  <div className="h-4 w-16 bg-slate-200 rounded" />
                </div>
              </div>
            </div>
          ))}
        </section>
        <section className="bg-white rounded-xl border border-gray-200 shadow-sm p-5">
          <div className="h-5 w-40 bg-slate-200 rounded mb-4" />
          <div className="w-full h-20 bg-slate-100 rounded" />
          <div className="flex items-center justify-between mt-3 text-xs">
            <div className="h-3 w-24 bg-slate-200 rounded" />
            <div className="h-3 w-16 bg-slate-200 rounded" />
          </div>
        </section>
        <section className="bg-white rounded-xl border border-gray-200 shadow-sm p-5">
          <div className="space-y-3">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="">
                <div className="flex items-center justify-between">
                  <div className="h-4 w-40 bg-slate-200 rounded" />
                  <div className="h-4 w-10 bg-slate-200 rounded" />
                </div>
                <div className="mt-2 h-2 bg-slate-100 rounded" />
              </div>
            ))}
          </div>
        </section>
        <section>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 rounded-lg bg-slate-200" />
                  <div className="flex-1 space-y-2">
                    <div className="h-4 w-24 bg-slate-200 rounded" />
                    <div className="h-3 w-32 bg-slate-200 rounded" />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </section>
        <section className="bg-white rounded-xl border border-gray-200 shadow-sm">
          <ul className="divide-y divide-gray-100">
            {Array.from({ length: 5 }).map((_, i) => (
              <li key={i} className="flex items-center justify-between px-6 py-4">
                <div className="flex items-center gap-3 min-w-0">
                  <div className="w-10 h-10 bg-slate-200 rounded" />
                  <div className="min-w-0 space-y-2">
                    <div className="h-4 w-40 bg-slate-200 rounded" />
                    <div className="h-3 w-24 bg-slate-200 rounded" />
                  </div>
                </div>
                <div className="h-8 w-20 bg-slate-200 rounded" />
              </li>
            ))}
          </ul>
        </section>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Üst Başlık - Açık Hero Bölümü */}
      <section className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-blue-50 to-indigo-50 border border-blue-100 p-6">
        <div className="relative z-10 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div>
            <p className="text-xs uppercase tracking-wider text-blue-600 font-medium">Hoş geldiniz</p>
            <h1 className="mt-1 text-2xl font-bold text-slate-900">
              {user?.first_name || user?.username || user?.email}
            </h1>
            <p className="mt-1 text-sm text-slate-600">Genel bakış ve hızlı aksiyonlar</p>
          </div>
          <div className="flex items-center gap-3">
            <button
              onClick={() => navigate('/categories')}
              className="inline-flex items-center rounded-xl bg-white/80 border border-blue-200 px-4 py-2 text-sm font-medium text-blue-700 hover:bg-white transition"
            >
              Kategorilere Git
            </button>
            <button
              onClick={() => navigate('/reports/new')}
              className="inline-flex items-center rounded-xl bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 transition"
            >
              Yeni Bildirim
            </button>
          </div>
        </div>
        <div className="pointer-events-none absolute -right-6 -top-6 h-24 w-24 rounded-full bg-blue-200/30 blur-xl"></div>
        <div className="pointer-events-none absolute -left-6 -bottom-6 h-24 w-24 rounded-full bg-indigo-200/30 blur-xl"></div>
      </section>

      {/* İstatistik kartları + Filtreler */}
      <section>
        <div className="mb-4 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
          <h2 className="text-lg font-semibold text-slate-900">Genel Bakış</h2>
          <div className="flex flex-wrap items-center gap-2">
            <select
              value={scope}
              onChange={(e) => setScope(e.target.value as 'all' | 'mine' | 'assigned')}
              className="rounded-lg border border-gray-300 px-3 py-2 text-sm bg-white"
            >
              <option value="all">Kapsam: Tümü</option>
              <option value="mine">Kapsam: Benim</option>
              <option value="assigned">Kapsam: Atananlar</option>
            </select>
            <select
              value={timeRange}
              onChange={(e) => setTimeRange(e.target.value as '7' | '30' | '90' | 'all')}
              className="rounded-lg border border-gray-300 px-3 py-2 text-sm bg-white"
            >
              <option value="7">Son 7 gün</option>
              <option value="30">Son 30 gün</option>
              <option value="90">Son 90 gün</option>
              <option value="all">Tümü</option>
            </select>
          </div>
        </div>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {[
            { title: 'Toplam Bildirim', value: statsLoading ? '...' : String(totalReports), color: 'bg-blue-600', textColor: 'text-blue-600' },
            { title: 'Bekleyen', value: statsLoading ? '...' : String(pending), color: 'bg-amber-500', textColor: 'text-amber-600' },
            { title: 'Çözülen', value: statsLoading ? '...' : String(resolved), color: 'bg-emerald-500', textColor: 'text-emerald-600' },
            { title: 'Kategoriler', value: statsLoading ? '...' : String(categoriesCount), color: 'bg-indigo-600', textColor: 'text-indigo-600' },
          ].map((c) => (
            <div key={c.title} className="bg-white rounded-xl border border-gray-200 shadow-sm p-5">
              <div className="flex items-center">
                <div className={`flex-shrink-0 w-10 h-10 rounded-lg ${c.color} text-white grid place-items-center font-semibold text-sm`}>
                  {c.value}
                </div>
                <div className="ml-4">
                  <div className="text-sm text-slate-500">{c.title}</div>
                  <div className={`text-xl font-semibold ${c.textColor}`}>{c.value}</div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Dağılım Çubuğu */}
      <section>
        <h2 className="text-lg font-semibold text-slate-900 mb-4">Durum Dağılımı</h2>
        <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-5">
          <div className="h-3 w-full rounded-full bg-slate-100 overflow-hidden">
            <div className="h-full bg-amber-400" style={{ width: `${(statusCounts.BEKLEMEDE / distTotal) * 100}%` }} />
            <div className="h-full bg-blue-400" style={{ width: `${(statusCounts.INCELENIYOR / distTotal) * 100}%` }} />
            <div className="h-full bg-emerald-500" style={{ width: `${(statusCounts.COZULDU / distTotal) * 100}%` }} />
            <div className="h-full bg-rose-400" style={{ width: `${(statusCounts.REDDEDILDI / distTotal) * 100}%` }} />
          </div>
          <div className="mt-3 grid grid-cols-2 sm:grid-cols-4 gap-2 text-xs text-slate-700">
            <div className="flex items-center gap-2"><span className="w-2 h-2 rounded-sm bg-amber-400" /> Beklemede: {statusCounts.BEKLEMEDE}</div>
            <div className="flex items-center gap-2"><span className="w-2 h-2 rounded-sm bg-blue-400" /> İnceleniyor: {statusCounts.INCELENIYOR}</div>
            <div className="flex items-center gap-2"><span className="w-2 h-2 rounded-sm bg-emerald-500" /> Çözüldü: {statusCounts.COZULDU}</div>
            <div className="flex items-center gap-2"><span className="w-2 h-2 rounded-sm bg-rose-400" /> Reddedildi: {statusCounts.REDDEDILDI}</div>
          </div>
        </div>
      </section>

      {/* KPI Kartları */}
      <section>
        <h2 className="text-lg font-semibold text-slate-900 mb-4">KPI Kartları</h2>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {[ 
            { title: 'Çözüm Oranı', value: `${kpis.resolutionRate.toFixed(0)}%`, color: 'bg-emerald-500', textColor: 'text-emerald-600' },
            { title: 'Ort. Çözüm Süresi', value: `${kpis.avgResolutionHours.toFixed(1)} sa`, color: 'bg-indigo-500', textColor: 'text-indigo-600' },
            { title: 'Bekleyenlerin Ort. Yaşı', value: `${kpis.avgOpenAgeDays.toFixed(1)} gün`, color: 'bg-amber-500', textColor: 'text-amber-600' },
            { title: 'Atanma Oranı', value: `${kpis.assignmentRate.toFixed(0)}%`, color: 'bg-blue-500', textColor: 'text-blue-600' },
          ].map((c) => (
            <div key={c.title} className="bg-white rounded-xl border border-gray-200 shadow-sm p-5">
              <div className="flex items-center">
                <div className={`flex-shrink-0 w-10 h-10 rounded-lg ${c.color} text-white grid place-items-center font-semibold text-sm`}>
                  {c.value}
                </div>
                <div className="ml-4">
                  <div className="text-sm text-slate-500">{c.title}</div>
                  <div className={`text-xl font-semibold ${c.textColor}`}>{c.value}</div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Trend (Sparkline) */}
      <section>
        <h2 className="text-lg font-semibold text-slate-900 mb-4">Trend: Günlük Bildirimler</h2>
        <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-5">
          <div className="flex items-center justify-between text-sm text-slate-600 mb-3">
            <span>Dilim: {timeRange === 'all' ? 'Son 30 gün' : `Son ${timeRange} gün`}</span>
            <span>Toplam: {trend.total}</span>
          </div>
          <svg viewBox={`0 0 ${trend.W} ${trend.H}`} className="w-full h-20">
            <path d={trend.path} fill="none" stroke="#6366f1" strokeWidth="2" />
            {/* alt alan dolgu */}
            {trend.path && (
              <path
                d={`${trend.path} L ${trend.W},${trend.H} L 0,${trend.H} Z`}
                fill="#6366f133"
                stroke="none"
              />
            )}
          </svg>
          <div className="mt-2 flex items-center justify-between text-xs text-slate-500">
            <span>{trend.labels[0]}</span>
            <span>{trend.labels[trend.labels.length - 1]}</span>
          </div>
        </div>
      </section>

      {/* Top Kategoriler */}
      <section>
        <h2 className="text-lg font-semibold text-slate-900 mb-4">Top Kategoriler</h2>
        <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-5">
          <div className="space-y-3">
            {topCategories.length === 0 ? (
              <div className="text-sm text-slate-500">Veri yok</div>
            ) : (
              topCategories.map(([name, count]) => {
                const max = topCategories[0][1] || 1
                const width = Math.max(4, Math.round((count / max) * 100))
                return (
                  <div key={name} className="">
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-slate-700">{name}</span>
                      <span className="text-slate-500">{count}</span>
                    </div>
                    <div className="mt-1 h-2 w-full rounded bg-slate-100 overflow-hidden">
                      <div className="h-full bg-indigo-500" style={{ width: `${width}%` }} />
                    </div>
                  </div>
                )
              })
            )}
          </div>
        </div>
      </section>

      {/* Hızlı İşlemler */}
      <section>
        <h2 className="text-lg font-semibold text-slate-900 mb-4">Hızlı İşlemler</h2>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {[
            { label: 'Kategoriler', desc: 'Kategori yönetimi', path: '/categories', icon: '📁', bgColor: 'bg-indigo-50', textColor: 'text-indigo-700' },
            { label: 'Vatandaş Bildirimleri', desc: 'Vatandaş bildirimleri', path: '/reports', icon: '📝', bgColor: 'bg-blue-50', textColor: 'text-blue-700' },
            { label: 'Ekipler', desc: 'Ekip yönetimi', path: '/teams', icon: '👥', bgColor: 'bg-emerald-50', textColor: 'text-emerald-700' },
            { label: 'Kullanıcılar', desc: 'Kullanıcı yönetimi', path: '/users', icon: '👤', bgColor: 'bg-amber-50', textColor: 'text-amber-700' },
            { label: 'Görevler', desc: 'Görev takibi', path: '/tasks', icon: '✅', bgColor: 'bg-rose-50', textColor: 'text-rose-700' },
            { label: 'Profil', desc: 'Profil ayarları', path: '/profile', icon: '⚙️', bgColor: 'bg-slate-50', textColor: 'text-slate-700' },
          ].map((a) => (
            <button
              key={a.label}
              onClick={() => navigate(a.path)}
              className="bg-white p-6 rounded-xl border border-gray-200 shadow-sm hover:shadow-md hover:border-gray-300 transition-all text-left"
            >
              <div className="flex items-center">
                <div className={`w-12 h-12 rounded-lg ${a.bgColor} grid place-items-center text-xl`}>
                  <span>{a.icon}</span>
                </div>
                <div className="ml-4">
                  <h3 className="text-base font-semibold text-slate-900">{a.label}</h3>
                  <p className="text-sm text-slate-500">{a.desc}</p>
                </div>
              </div>
            </button>
          ))}
        </div>
      </section>

      {/* Son Bildirimler */}
      <section>
        <h2 className="text-lg font-semibold text-slate-900 mb-4">Son Bildirimler</h2>
        <div className="bg-white rounded-xl border border-gray-200 shadow-sm">
          <ul className="divide-y divide-gray-100">
            {recentReports.length === 0 ? (
              <li className="px-6 py-4 text-sm text-slate-500">Veri yok</li>
            ) : (
              recentReports.map((r) => (
                <li key={r.id} className="flex items-center justify-between px-6 py-4">
                  <div className="flex items-center gap-3 min-w-0">
                    <div className="w-10 h-10 bg-slate-100 rounded overflow-hidden flex-shrink-0">
                      {r.first_media_url ? (
                        <img src={r.first_media_url} alt={r.title} className="w-full h-full object-cover" loading="lazy" />
                      ) : (
                        <div className="w-full h-full grid place-items-center text-slate-400 text-xs">—</div>
                      )}
                    </div>
                    <div className="min-w-0">
                      <p className="text-sm font-medium text-slate-900 truncate">{r.title}</p>
                      <p className="text-xs text-slate-500 mt-0.5">{new Date(r.created_at).toLocaleString()}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <span className="hidden sm:inline text-xs text-slate-500 truncate max-w-[140px]">{r.category?.name}</span>
                    <button
                      onClick={() => navigate(`/reports/${r.id}`)}
                      className="inline-flex items-center rounded-lg border border-gray-300 px-3 py-1.5 text-xs text-slate-700 hover:bg-gray-50"
                    >
                      Görüntüle
                    </button>
                  </div>
                </li>
              ))
            )}
          </ul>
        </div>
      </section>
    </div>
  )
}