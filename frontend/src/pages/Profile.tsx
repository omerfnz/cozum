import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { me, type User, updateMe, changePassword, setAuthTokens } from '../lib/api'
import { Toaster, toast } from 'react-hot-toast'

interface ApiErrorData { detail?: string; [key: string]: unknown }
interface ApiError { response?: { data?: ApiErrorData } }

export default function Profile() {
  const navigate = useNavigate()
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [changingPwd, setChangingPwd] = useState(false)
  const [form, setForm] = useState<Partial<User>>({})
  const [pwd, setPwd] = useState({ old_password: '', new_password: '', new_password_confirm: '' })

  useEffect(() => {
    const fetchMe = async () => {
      try {
        const token = localStorage.getItem('token')
        if (!token) {
          navigate('/login')
          return
        }
        const data = await me()
        setUser(data)
        setForm({
          username: data.username,
          first_name: data.first_name || '',
          last_name: data.last_name || '',
          phone: data.phone || '',
          address: data.address || ''
        })
      } catch (e) {
        console.error(e)
        localStorage.removeItem('token')
        navigate('/login')
      } finally {
        setLoading(false)
      }
    }
    fetchMe()
  }, [navigate])

  const handleProfileSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!form) return
    setSaving(true)
    try {
      const payload = {
        username: form.username,
        first_name: (form.first_name || '').toString(),
        last_name: (form.last_name || '').toString(),
        phone: (form.phone ?? '') as string,
        address: (form.address ?? '') as string
      }
      const updated = await updateMe(payload)
      setUser(updated)
      toast.success('Profil güncellendi')
    } catch (err) {
      const error = err as ApiError
      const msg = error?.response?.data?.detail || 'Profil güncellenemedi'
      toast.error(msg)
    } finally {
      setSaving(false)
    }
  }

  const handlePasswordSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!pwd.old_password || !pwd.new_password || !pwd.new_password_confirm) {
      toast.error('Lütfen tüm şifre alanlarını doldurun')
      return
    }
    if (pwd.new_password !== pwd.new_password_confirm) {
      toast.error('Yeni şifreler eşleşmiyor')
      return
    }
    setChangingPwd(true)
    try {
      await changePassword(pwd)
      toast.success('Şifre başarıyla değiştirildi')
      setPwd({ old_password: '', new_password: '', new_password_confirm: '' })
    } catch (err) {
      const error = err as ApiError
      const msg = error?.response?.data?.detail || 'Şifre değiştirilemedi'
      toast.error(msg)
    } finally {
      setChangingPwd(false)
    }
  }

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto">
        <div className="mb-6">
          <div className="h-7 w-40 bg-slate-200 rounded animate-pulse" />
          <div className="h-4 w-64 bg-slate-200 rounded mt-2 animate-pulse" />
        </div>
        <div className="grid grid-cols-1 gap-6">
          <section className="bg-white border border-gray-200 rounded-xl shadow-sm p-6">
            <div className="h-6 w-40 bg-slate-200 rounded mb-4 animate-pulse" />
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 animate-pulse">
              {Array.from({ length: 6 }).map((_, i) => (
                <div key={i}>
                  <div className="h-4 w-24 bg-slate-200 rounded mb-2" />
                  <div className="h-10 w-full bg-slate-200 rounded" />
                </div>
              ))}
            </div>
          </section>
          <section className="bg-white border border-gray-200 rounded-xl shadow-sm p-6">
            <div className="h-6 w-40 bg-slate-200 rounded mb-4 animate-pulse" />
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 animate-pulse">
              <div>
                <div className="h-4 w-24 bg-slate-200 rounded mb-2" />
                <div className="h-10 w-full bg-slate-200 rounded" />
              </div>
              <div className="md:col-span-2">
                <div className="h-4 w-24 bg-slate-200 rounded mb-2" />
                <div className="h-24 w-full bg-slate-200 rounded" />
              </div>
            </div>
          </section>
          <div className="flex items-center justify-end">
            <div className="h-10 w-28 bg-slate-200 rounded animate-pulse" />
          </div>
        </div>
      </div>
    )
  }

  if (!user) return null

  return (
    <div className="max-w-4xl mx-auto">
      <Toaster position="top-right" />
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-slate-900">Profilim</h1>
        <p className="text-slate-600 mt-1">Hesap bilgilerinizi görüntüleyin ve güncelleyin.</p>
      </div>

      <form onSubmit={handleProfileSubmit} className="grid grid-cols-1 gap-6">
        <section className="bg-white border border-gray-200 rounded-xl shadow-sm p-6">
          <h2 className="text-lg font-semibold text-slate-900 mb-4">Kullanıcı Bilgileri</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm text-slate-600 mb-1">Ad</label>
              <input value={form.first_name as string || ''} onChange={(e)=>setForm((f)=>({ ...f, first_name: e.target.value }))} className="w-full px-3 py-2 border border-gray-300 rounded-lg" />
            </div>
            <div>
              <label className="block text-sm text-slate-600 mb-1">Soyad</label>
              <input value={form.last_name as string || ''} onChange={(e)=>setForm((f)=>({ ...f, last_name: e.target.value }))} className="w-full px-3 py-2 border border-gray-300 rounded-lg" />
            </div>
            <div>
              <label className="block text-sm text-slate-600 mb-1">E-posta</label>
              <input value={user.email} disabled className="w-full px-3 py-2 border border-gray-300 rounded-lg bg-gray-50" />
            </div>
            <div>
              <label className="block text-sm text-slate-600 mb-1">Kullanıcı Adı</label>
              <input value={form.username as string || ''} onChange={(e)=>setForm((f)=>({ ...f, username: e.target.value }))} className="w-full px-3 py-2 border border-gray-300 rounded-lg" />
            </div>
            <div>
              <label className="block text-sm text-slate-600 mb-1">Rol</label>
              <input value={user.role_display || user.role} disabled className="w-full px-3 py-2 border border-gray-300 rounded-lg bg-gray-50" />
            </div>
            <div>
              <label className="block text-sm text-slate-600 mb-1">Takım</label>
              <input value={user.team_name || '-'} disabled className="w-full px-3 py-2 border border-gray-300 rounded-lg bg-gray-50" />
            </div>
          </div>
        </section>

        <section className="bg-white border border-gray-200 rounded-xl shadow-sm p-6">
          <h2 className="text-lg font-semibold text-slate-900 mb-4">İletişim</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm text-slate-600 mb-1">Telefon</label>
              <input value={(form.phone as string) || ''} onChange={(e)=>setForm((f)=>({ ...f, phone: e.target.value }))} className="w-full px-3 py-2 border border-gray-300 rounded-lg" />
            </div>
            <div className="md:col-span-2">
              <label className="block text-sm text-slate-600 mb-1">Adres</label>
              <textarea value={(form.address as string) || ''} onChange={(e)=>setForm((f)=>({ ...f, address: e.target.value }))} className="w-full px-3 py-2 border border-gray-300 rounded-lg min-h-[90px]" />
            </div>
          </div>
        </section>

        <div className="flex items-center justify-end">
          <button
            type="submit"
            disabled={saving}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
          >
            {saving ? 'Kaydediliyor...' : 'Değişiklikleri Kaydet'}
          </button>
        </div>
      </form>

      <section className="bg-white border border-gray-200 rounded-xl shadow-sm p-6 mt-6">
        <h2 className="text-lg font-semibold text-slate-900 mb-4">Şifre Değiştirme</h2>
        <form onSubmit={handlePasswordSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm text-slate-600 mb-1">Mevcut Şifre</label>
            <input type="password" value={pwd.old_password} onChange={(e)=>setPwd((p)=>({ ...p, old_password: e.target.value }))} className="w-full px-3 py-2 border border-gray-300 rounded-lg" />
          </div>
          <div>
            <label className="block text-sm text-slate-600 mb-1">Yeni Şifre</label>
            <input type="password" value={pwd.new_password} onChange={(e)=>setPwd((p)=>({ ...p, new_password: e.target.value }))} className="w-full px-3 py-2 border border-gray-300 rounded-lg" />
          </div>
          <div className="md:col-span-2">
            <label className="block text-sm text-slate-600 mb-1">Yeni Şifre (Tekrar)</label>
            <input type="password" value={pwd.new_password_confirm} onChange={(e)=>setPwd((p)=>({ ...p, new_password_confirm: e.target.value }))} className="w-full px-3 py-2 border border-gray-300 rounded-lg" />
          </div>
          <div className="md:col-span-2 flex items-center justify-end">
            <button type="submit" disabled={changingPwd} className="px-4 py-2 bg-slate-800 text-white rounded-lg hover:bg-slate-900 disabled:opacity-50">
              {changingPwd ? 'Güncelleniyor...' : 'Şifreyi Güncelle'}
            </button>
          </div>
        </form>
      </section>

      <div className="flex items-center justify-end mt-6">
        <button
          onClick={() => { setAuthTokens(undefined, undefined); navigate('/login') }}
          className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
        >
          Çıkış Yap
        </button>
      </div>
    </div>
  )
}