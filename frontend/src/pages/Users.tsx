import { useEffect, useMemo, useState } from 'react'
import { getUsers, getTeams, setUserRole, setUserTeam, deleteUser, type User, type Team } from '../lib/api'
import toast from 'react-hot-toast'

export default function Users() {
  const [loading, setLoading] = useState(true)
  const [users, setUsers] = useState<User[]>([])
  const [teams, setTeams] = useState<Team[]>([])
  const [query, setQuery] = useState('')

  const fetchAll = async () => {
    try {
      setLoading(true)
      const [u, t] = await Promise.all([getUsers(), getTeams()])
      setUsers(u)
      setTeams(t)
    } catch (e) {
      const err = e as { response?: { data?: { detail?: string } } }
      toast.error(err?.response?.data?.detail || 'Kullanıcılar yüklenirken hata oluştu')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchAll()
  }, [])

  const filtered = useMemo(() => {
    const q = query.toLowerCase().trim()
    if (!q) return users
    return users.filter(u =>
      u.email.toLowerCase().includes(q) ||
      u.username.toLowerCase().includes(q) ||
      (u.team_name || '').toLowerCase().includes(q) ||
      (u.first_name || '').toLowerCase().includes(q) ||
      (u.last_name || '').toLowerCase().includes(q)
    )
  }, [users, query])

  const handleChangeRole = async (u: User, role: User['role']) => {
    try {
      const updated = await setUserRole(u.id, role)
      setUsers(prev => prev.map(x => x.id === u.id ? updated : x))
      toast.success('Rol güncellendi')
    } catch (e) {
      const err = e as { response?: { data?: { detail?: string } } }
      toast.error(err?.response?.data?.detail || 'Rol güncellenemedi')
    }
  }

  const handleChangeTeam = async (u: User, team: number | null) => {
    try {
      const updated = await setUserTeam(u.id, team)
      setUsers(prev => prev.map(x => x.id === u.id ? updated : x))
      toast.success('Takım güncellendi')
    } catch (e) {
      const err = e as { response?: { data?: { detail?: string } } }
      toast.error(err?.response?.data?.detail || 'Takım güncellenemedi')
    }
  }

  const handleDelete = async (u: User) => {
    if (!confirm(`${u.email} kullanıcısını silmek istediğinize emin misiniz?`)) return
    try {
      await deleteUser(u.id)
      setUsers(prev => prev.filter(x => x.id !== u.id))
      toast.success('Kullanıcı silindi')
    } catch (e) {
      const err = e as { response?: { data?: { detail?: string } } }
      toast.error(err?.response?.data?.detail || 'Kullanıcı silinemedi')
    }
  }

  return (
    <div className="p-6">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Kullanıcılar</h1>
          <p className="text-slate-500 text-sm">Kullanıcıları görüntüle, rol ve takım atamalarını düzenle</p>
        </div>
        <div className="w-72">
          <input
            value={query}
            onChange={e => setQuery(e.target.value)}
            placeholder="Ara: email, kullanıcı adı, takım..."
            className="w-full px-3 py-2 rounded-md border border-gray-200 focus:ring-2 focus:ring-blue-500 outline-none"
          />
        </div>
      </div>

      <div className="bg-white rounded-lg border border-gray-200 overflow-hidden shadow-sm">
        <table className="min-w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="text-left px-4 py-3 text-slate-600 text-sm">Email</th>
              <th className="text-left px-4 py-3 text-slate-600 text-sm">Kullanıcı Adı</th>
              <th className="text-left px-4 py-3 text-slate-600 text-sm">Rol</th>
              <th className="text-left px-4 py-3 text-slate-600 text-sm">Takım</th>
              <th className="text-right px-4 py-3 text-slate-600 text-sm">İşlemler</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <>
                {Array.from({ length: 8 }).map((_, i) => (
                  <tr key={i} className="border-t border-gray-100 animate-pulse">
                    <td className="px-4 py-3"><div className="h-4 w-48 bg-slate-200 rounded" /></td>
                    <td className="px-4 py-3"><div className="h-4 w-32 bg-slate-200 rounded" /></td>
                    <td className="px-4 py-3"><div className="h-8 w-28 bg-slate-200 rounded" /></td>
                    <td className="px-4 py-3"><div className="h-8 w-40 bg-slate-200 rounded" /></td>
                    <td className="px-4 py-3 text-right"><div className="h-8 w-16 bg-slate-200 rounded ml-auto" /></td>
                  </tr>
                ))}
              </>
            ) : filtered.length === 0 ? (
              <tr>
                <td colSpan={5} className="px-4 py-8 text-center text-slate-500">Kayıt bulunamadı</td>
              </tr>
            ) : (
              filtered.map(u => (
                <tr key={u.id} className="border-t border-gray-100 hover:bg-gray-50">
                  <td className="px-4 py-3 text-sm text-slate-800">{u.email}</td>
                  <td className="px-4 py-3 text-sm text-slate-800">{u.username}</td>
                  <td className="px-4 py-3 text-sm">
                    <select
                      value={u.role}
                      onChange={e => handleChangeRole(u, e.target.value as User['role'])}
                      className="px-2 py-1 border border-gray-200 rounded-md text-sm"
                    >
                      <option value="VATANDAS">Vatandaş</option>
                      <option value="EKIP">Saha Ekibi</option>
                      <option value="OPERATOR">Operatör</option>
                      <option value="ADMIN">Admin</option>
                    </select>
                  </td>
                  <td className="px-4 py-3 text-sm">
                    <select
                      value={u.team ?? ''}
                      onChange={e => handleChangeTeam(u, e.target.value ? Number(e.target.value) : null)}
                      className="px-2 py-1 border border-gray-200 rounded-md text-sm"
                    >
                      <option value="">— Takım Yok —</option>
                      {teams.map(t => (
                        <option key={t.id} value={t.id}>{t.name}</option>
                      ))}
                    </select>
                  </td>
                  <td className="px-4 py-3 text-sm text-right">
                    <button
                      onClick={() => handleDelete(u)}
                      className="px-3 py-1.5 bg-red-50 text-red-600 rounded-md hover:bg-red-100"
                    >Sil</button>
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