import React, { useEffect, useState, useCallback, useMemo } from 'react'
import { createCategory, deleteCategory, getCategories, updateCategory } from '../lib/api'
import type { Category } from '../lib/api'
import toast from 'react-hot-toast'
import { useNavigate } from 'react-router-dom'

export default function Categories() {
  const [categories, setCategories] = useState<Category[]>([])
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')
  const [isActive, setIsActive] = useState(true)
  const [editing, setEditing] = useState<Category | null>(null)
  const [loading, setLoading] = useState(true)
  const [query, setQuery] = useState('')
  const navigate = useNavigate()

  const load = useCallback(async () => {
    try {
      const data = await getCategories()
      setCategories(data)
    } catch (e: unknown) {
      const err = e as { response?: { status?: number } };
      if (err?.response?.status === 401) {
        navigate('/login')
      } else {
        toast.error('Kategoriler yüklenemedi')
      }
    } finally {
      setLoading(false)
    }
  }, [navigate])

  useEffect(() => {
    load()
  }, [load])

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase()
    if (!q) return categories
    return categories.filter(c =>
      c.name.toLowerCase().includes(q) || (c.description || '').toLowerCase().includes(q)
    )
  }, [categories, query])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!name.trim()) {
      return toast.error('Kategori adı zorunludur')
    }
 
    try {
      if (editing) {
        const updated = await updateCategory(editing.id, { name, description, is_active: isActive })
        setCategories((prev) => prev.map((c) => (c.id === editing.id ? updated : c)))
        toast.success('Kategori güncellendi')
        setEditing(null)
      } else {
        const created = await createCategory({ name, description, is_active: isActive })
        setCategories((prev) => [created, ...prev])
        toast.success('Kategori eklendi')
      }
      setName('')
      setDescription('')
      setIsActive(true)
    } catch (e: unknown) {
      const err = e as { response?: { status?: number } };
      if (err?.response?.status === 403) {
        toast.error('Bu işlem için yetkiniz yok')
      } else {
        toast.error('İşlem sırasında bir hata oluştu')
      }
    }
  }
 
  const startEdit = (cat: Category) => {
    setEditing(cat)
    setName(cat.name)
    setDescription(cat.description || '')
    setIsActive(cat.is_active)
  }
 
  const cancelEdit = () => {
    setEditing(null)
    setName('')
    setDescription('')
    setIsActive(true)
  }
 
  const remove = async (id: number) => {
    if (!confirm('Bu kategoriyi pasif yapmak istediğinize emin misiniz?')) return
    try {
      await deleteCategory(id)
      setCategories((prev) => prev.filter((c) => c.id !== id))
      toast.success('Kategori pasif yapıldı')
    } catch (e: unknown) {
      const err = e as { response?: { status?: number } };
      if (err?.response?.status === 403) {
        toast.error('Bu işlem için yetkiniz yok')
      } else {
        toast.error('İşlem sırasında bir hata oluştu')
      }
    }
  }

  if (loading) {
    return (
      <div className="min-h-[60vh] flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Yükleniyor...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Kategoriler</h1>
          <p className="text-sm text-gray-500 mt-1">Kategori oluşturun, düzenleyin ve yönetin</p>
        </div>
        <div className="relative">
          <input
            type="text"
            className="w-64 rounded-xl border border-gray-300 px-3 py-2 focus:border-transparent focus:ring-2 focus:ring-blue-500 bg-white"
            placeholder="Ara: ad veya açıklama"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
          />
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-1">
          <div className="bg-white p-6 rounded-xl border border-gray-100 shadow-sm">
            <h2 className="text-base font-semibold mb-4">
              {editing ? 'Kategori Düzenle' : 'Yeni Kategori'}
            </h2>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Ad</label>
                <input
                  type="text"
                  className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 focus:border-transparent focus:ring-2 focus:ring-blue-500 bg-white"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="Kategori adı"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Açıklama</label>
                <textarea
                  className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 focus:border-transparent focus:ring-2 focus:ring-blue-500 bg-white"
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  placeholder="Opsiyonel açıklama"
                />
              </div>
              <div className="flex items-center gap-2">
                <input id="isActive" type="checkbox" className="h-4 w-4" checked={isActive} onChange={(e) => setIsActive(e.target.checked)} />
                <label htmlFor="isActive" className="text-sm text-gray-700">Aktif</label>
              </div>
              <div className="flex items-center space-x-2">
                <button
                  type="submit"
                  className="inline-flex items-center px-4 py-2 text-sm font-medium rounded-lg text-white bg-blue-600 hover:bg-blue-700"
                >
                  {editing ? 'Güncelle' : 'Ekle'}
                </button>
                {editing && (
                  <button
                    type="button"
                    onClick={cancelEdit}
                    className="inline-flex items-center px-4 py-2 text-sm font-medium rounded-lg border border-gray-300 text-gray-700 bg-white hover:bg-gray-50"
                  >
                    İptal
                  </button>
                )}
              </div>
            </form>
          </div>
        </div>

        <div className="lg:col-span-2">
          <div className="bg-white rounded-xl border border-gray-100 shadow-sm">
            <div className="px-6 py-4 border-b flex items-center justify-between">
              <h2 className="text-base font-semibold">Kategoriler</h2>
              <span className="text-xs text-gray-500">{filtered.length} sonuç</span>
            </div>
            <div className="p-6">
              {filtered.length === 0 ? (
                <p className="text-gray-500">Sonuç bulunamadı.</p>
              ) : (
                <ul className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  {filtered.map((cat) => (
                    <li key={cat.id} className="p-4 rounded-lg border border-gray-200 hover:border-gray-300 transition bg-white shadow-sm">
                      <div className="flex items-start justify-between">
                        <div>
                          <p className="font-medium text-gray-900">{cat.name}</p>
                          {cat.description && (
                            <p className="text-sm text-gray-500 mt-1 line-clamp-2">{cat.description}</p>
                          )}
                        </div>
                        <span className={`text-xs px-2 py-1 rounded-full ${cat.is_active ? 'bg-emerald-50 text-emerald-700' : 'bg-gray-100 text-gray-600'}`}>
                          {cat.is_active ? 'Aktif' : 'Pasif'}
                        </span>
                      </div>
                      <div className="flex items-center gap-2 mt-4">
                        <button
                          onClick={() => startEdit(cat)}
                          className="px-3 py-1 text-sm rounded-md border text-gray-700 hover:bg-gray-50"
                        >
                          Düzenle
                        </button>
                        <button
                          onClick={() => remove(cat.id)}
                          className="px-3 py-1 text-sm rounded-md border border-amber-300 text-amber-700 hover:bg-amber-50"
                        >
                          Pasif Yap
                        </button>
                      </div>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}