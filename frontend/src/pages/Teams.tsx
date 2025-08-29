import { useEffect, useMemo, useState } from 'react'
import { createTeam, deleteTeam, getTeams, updateTeam, type Team } from '../lib/api'
import toast from 'react-hot-toast'

export default function Teams() {
  const [loading, setLoading] = useState(true)
  const [teams, setTeams] = useState<Team[]>([])
  const [query, setQuery] = useState('')
  const [form, setForm] = useState<{ id?: number; name: string; description?: string | null }>({ name: '', description: '' })

  const fetchTeams = async () => {
    try {
      setLoading(true)
      const data = await getTeams()
      setTeams(data)
    } catch (e) {
      const err = e as { response?: { data?: { detail?: string } } }
      toast.error(err?.response?.data?.detail || 'Takımlar yüklenirken hata oluştu')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchTeams()
  }, [])

  const filtered = useMemo(() => {
    const q = query.toLowerCase().trim()
    if (!q) return teams
    return teams.filter(t =>
      t.name.toLowerCase().includes(q) || (t.description || '').toLowerCase().includes(q)
    )
  }, [teams, query])

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      if (form.id) {
        const updated = await updateTeam(form.id, { name: form.name, description: form.description })
        setTeams(prev => prev.map(t => (t.id === updated.id ? updated : t)))
        toast.success('Takım güncellendi')
      } else {
        const created = await createTeam({ name: form.name, description: form.description ?? undefined })
        setTeams(prev => [created, ...prev])
        toast.success('Takım oluşturuldu')
      }
      setForm({ name: '', description: '' })
    } catch (e) {
      const err = e as { response?: { data?: { detail?: string } } }
      toast.error(err?.response?.data?.detail || 'İşlem başarısız')
    }
  }

  const onEdit = (t: Team) => setForm({ id: t.id, name: t.name, description: t.description })

  const onDelete = async (t: Team) => {
    if (!confirm(`${t.name} takımını silmek istediğinize emin misiniz?`)) return
    try {
      await deleteTeam(t.id)
      setTeams(prev => prev.filter(x => x.id !== t.id))
      toast.success('Takım silindi')
    } catch (e) {
      const err = e as { response?: { data?: { detail?: string } } }
      toast.error(err?.response?.data?.detail || 'Silme başarısız')
    }
  }

  return (
    <div className="p-6">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Takımlar</h1>
          <p className="text-slate-500 text-sm">Takım oluşturma, düzenleme ve üyeleri yönetme</p>
        </div>
        <div className="w-72">
          <input
            value={query}
            onChange={e => setQuery(e.target.value)}
            placeholder="Ara: takım adı, açıklama..."
            className="w-full px-3 py-2 rounded-md border border-gray-200 focus:ring-2 focus:ring-blue-500 outline-none"
          />
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Sol Panel - Form */}
        <div className="lg:col-span-1">
          <div className="bg-white rounded-lg border border-gray-200 p-4 shadow-sm">
            <h2 className="font-semibold text-slate-800 mb-4">{form.id ? 'Takım Düzenle' : 'Yeni Takım'}</h2>
            {loading ? (
              <div className="animate-pulse space-y-4">
                <div className="h-10 bg-slate-200 rounded" />
                <div className="h-24 bg-slate-200 rounded" />
                <div className="flex gap-3">
                  <div className="h-10 w-28 bg-slate-200 rounded" />
                  <div className="h-10 w-24 bg-slate-200 rounded" />
                </div>
              </div>
            ) : (
              <form onSubmit={onSubmit} className="space-y-3">
                <div>
                  <label className="block text-sm text-slate-600 mb-1">Takım Adı</label>
                  <input
                    value={form.name}
                    onChange={e => setForm(prev => ({ ...prev, name: e.target.value }))}
                    required
                    className="w-full px-3 py-2 rounded-md border border-gray-200 focus:ring-2 focus:ring-blue-500 outline-none"
                  />
                </div>
                <div>
                  <label className="block text-sm text-slate-600 mb-1">Açıklama</label>
                  <textarea
                    value={form.description || ''}
                    onChange={e => setForm(prev => ({ ...prev, description: e.target.value }))}
                    className="w-full px-3 py-2 rounded-md border border-gray-200 focus:ring-2 focus:ring-blue-500 outline-none"
                    rows={4}
                  />
                </div>
                <div className="flex items-center gap-3">
                  <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
                    {form.id ? 'Güncelle' : 'Oluştur'}
                  </button>
                  {form.id && (
                    <button type="button" onClick={() => setForm({ name: '', description: '' })} className="px-4 py-2 bg-gray-100 text-slate-700 rounded-md hover:bg-gray-200">
                      İptal
                    </button>
                  )}
                </div>
              </form>
            )}
          </div>
        </div>

        {/* Sağ Panel - Kartlar */}
        <div className="lg:col-span-2">
          <div className="bg-white rounded-lg border border-gray-200 p-4 shadow-sm">
            <h2 className="font-semibold text-slate-800 mb-4">Takım Listesi</h2>
            {loading ? (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 animate-pulse">
                {Array.from({ length: 6 }).map((_, i) => (
                  <div key={i} className="border border-gray-100 rounded-lg p-4">
                    <div className="h-5 w-40 bg-slate-200 rounded mb-3" />
                    <div className="h-4 w-full bg-slate-200 rounded mb-2" />
                    <div className="h-4 w-2/3 bg-slate-200 rounded mb-4" />
                    <div className="flex gap-3 mt-2">
                      <div className="h-9 w-24 bg-slate-200 rounded" />
                      <div className="h-9 w-24 bg-slate-200 rounded" />
                    </div>
                  </div>
                ))}
              </div>
            ) : filtered.length === 0 ? (
              <p className="text-slate-500 text-sm">Kayıt bulunamadı</p>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {filtered.map(t => (
                  <div key={t.id} className="border border-gray-100 rounded-lg p-4 hover:bg-gray-50">
                    <div className="flex items-start justify-between">
                      <div>
                        <h3 className="font-semibold text-slate-800">{t.name}</h3>
                        {t.description && <p className="text-slate-600 text-sm mt-1">{t.description}</p>}
                      </div>
                      <div className="flex gap-2">
                        <button onClick={() => onEdit(t)} className="px-3 py-1.5 bg-amber-50 text-amber-700 rounded-md hover:bg-amber-100 text-sm">Düzenle</button>
                        <button onClick={() => onDelete(t)} className="px-3 py-1.5 bg-red-50 text-red-600 rounded-md hover:bg-red-100 text-sm">Sil</button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}