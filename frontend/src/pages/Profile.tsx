import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { me, type User } from '../lib/api'

export default function Profile() {
  const navigate = useNavigate()
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

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

  if (loading) {
    return (
      <div className="flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto" />
          <p className="mt-3 text-gray-700 font-medium">Yükleniyor...</p>
        </div>
      </div>
    )
  }

  if (!user) return null

  return (
    <div className="max-w-4xl mx-auto">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-slate-900">Profilim</h1>
        <p className="text-slate-600 mt-1">Hesap bilgilerinizi görüntüleyin.</p>
      </div>

      <div className="grid grid-cols-1 gap-6">
        <section className="bg-white border border-gray-200 rounded-xl shadow-sm p-6">
          <h2 className="text-lg font-semibold text-slate-900 mb-4">Kullanıcı Bilgileri</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm text-slate-600 mb-1">Ad</label>
              <input value={user.first_name || ''} disabled className="w-full px-3 py-2 border border-gray-300 rounded-lg bg-gray-50" />
            </div>
            <div>
              <label className="block text-sm text-slate-600 mb-1">Soyad</label>
              <input value={user.last_name || ''} disabled className="w-full px-3 py-2 border border-gray-300 rounded-lg bg-gray-50" />
            </div>
            <div>
              <label className="block text-sm text-slate-600 mb-1">E-posta</label>
              <input value={user.email} disabled className="w-full px-3 py-2 border border-gray-300 rounded-lg bg-gray-50" />
            </div>
            <div>
              <label className="block text-sm text-slate-600 mb-1">Kullanıcı Adı</label>
              <input value={user.username} disabled className="w-full px-3 py-2 border border-gray-300 rounded-lg bg-gray-50" />
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
              <input value={user.phone || ''} disabled className="w-full px-3 py-2 border border-gray-300 rounded-lg bg-gray-50" />
            </div>
            <div className="md:col-span-2">
              <label className="block text-sm text-slate-600 mb-1">Adres</label>
              <textarea value={user.address || ''} disabled className="w-full px-3 py-2 border border-gray-300 rounded-lg bg-gray-50 min-h-[90px]" />
            </div>
          </div>
        </section>

        <div className="flex items-center justify-end">
          <button
            onClick={() => { localStorage.removeItem('token'); navigate('/login') }}
            className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
          >
            Çıkış Yap
          </button>
        </div>
      </div>
    </div>
  )
}