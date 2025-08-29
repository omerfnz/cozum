import { useEffect, useMemo, useState } from 'react'
import { createCategory, deleteCategory, getCategories, updateCategory, type Category } from '../lib/api'
import toast from 'react-hot-toast'

export default function Categories() {
  const [loading, setLoading] = useState(true)
  const [categories, setCategories] = useState<Category[]>([])
  const [query, setQuery] = useState('')
  const [form, setForm] = useState<{ id?: number; name: string; description?: string }>({ name: '', description: '' })

  const fetchCategories = async () => {
    try {
      setLoading(true)
      const data = await getCategories()
      setCategories(data)
    } catch (e) {
      const err = e as { response?: { data?: { detail?: string } } }
      toast.error(err?.response?.data?.detail || 'Kategoriler yüklenemedi')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchCategories()
  }, [])

  const filtered = useMemo(() => {
    const q = query.toLowerCase().trim()
    if (!q) return categories
    return categories.filter(c =>
      c.name.toLowerCase().includes(q) || (c.description || '').toLowerCase().includes(q)
    )
  }, [categories, query])

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      if (form.id) {
        const updated = await updateCategory(form.id, { name: form.name, description: form.description })
        setCategories(prev => prev.map(c => (c.id === updated.id ? updated : c)))
        toast.success('Kategori güncellendi')
      } else {
        const created = await createCategory({ name: form.name, description: form.description })
        setCategories(prev => [created, ...prev])
        toast.success('Kategori oluşturuldu')
      }
      setForm({ name: '', description: '' })
    } catch (e) {
      const err = e as { response?: { data?: { detail?: string } } }
      toast.error(err?.response?.data?.detail || 'İşlem başarısız')
    }
  }

  const onEdit = (c: Category) => setForm({ id: c.id, name: c.name, description: c.description })

  const onDelete = async (c: Category) => {
    if (!confirm(`${c.name} kategorisini silmek istediğinize emin misiniz?`)) return
    try {
      await deleteCategory(c.id)
      setCategories(prev => prev.filter(x => x.id !== c.id))
      toast.success('Kategori silindi')
    } catch (e) {
      const err = e as { response?: { data?: { detail?: string } } }
      toast.error(err?.response?.data?.detail || 'Silme başarısız')
    }
  }

  return (
    <div className="p-6">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Kategoriler</h1>
          <p className="text-slate-500 text-sm">Kategori oluştur, düzenle ve yönet</p>
        </div>
        <div className="w-72">
          <input
            value={query}
            onChange={e => setQuery(e.target.value)}
            placeholder="Ara: ad, açıklama..."
            className="w-full px-3 py-2 rounded-md border border-gray-200 focus:ring-2 focus:ring-blue-500 outline-none"
          />
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-1">
          <div className="bg-white rounded-lg border border-gray-200 p-4 shadow-sm">
            <h2 className="font-semibold text-slate-800 mb-4">{form.id ? 'Kategori Düzenle' : 'Yeni Kategori'}</h2>
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
                  <label className="block text-sm text-slate-600 mb-1">Ad</label>
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

        <div className="lg:col-span-2">
          <div className="bg-white rounded-lg border border-gray-200 p-4 shadow-sm">
            <h2 className="font-semibold text-slate-800 mb-4">Kategori Listesi</h2>
            {loading ? (
              <div className="divide-y divide-gray-100 animate-pulse">
                {Array.from({ length: 8 }).map((_, i) => (
                  <div key={i} className="flex items-center justify-between py-3">
                    <div>
                      <div className="h-4 w-48 bg-slate-200 rounded mb-2" />
                      <div className="h-3 w-72 bg-slate-200 rounded" />
                    </div>
                    <div className="flex gap-2">
                      <div className="h-9 w-20 bg-slate-200 rounded" />
                      <div className="h-9 w-20 bg-slate-200 rounded" />
                    </div>
                  </div>
                ))}
              </div>
            ) : filtered.length === 0 ? (
              <p className="text-slate-500 text-sm">Kayıt bulunamadı</p>
            ) : (
              <ul className="divide-y divide-gray-100">
                {filtered.map(c => (
                  <li key={c.id} className="flex items-center justify-between py-3 hover:bg-gray-50 px-2 -mx-2 rounded">
                    <div>
                      <p className="font-medium text-slate-800">{c.name}</p>
                      {c.description && <p className="text-slate-600 text-sm mt-0.5">{c.description}</p>}
                    </div>
                    <div className="flex gap-2">
                      <button onClick={() => onEdit(c)} className="px-3 py-1.5 bg-amber-50 text-amber-700 rounded-md hover:bg-amber-100 text-sm">Düzenle</button>
                      <button onClick={() => onDelete(c)} className="px-3 py-1.5 bg-red-50 text-red-600 rounded-md hover:bg-red-100 text-sm">Sil</button>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}