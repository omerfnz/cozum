import { useCallback, useEffect, useMemo, useState } from 'react'
import { createTeam, deleteTeam, getTeams, updateTeam, type Team, getUsers, type User } from '../lib/api'
import toast from 'react-hot-toast'

export default function Teams() {
  const [loading, setLoading] = useState(true)
  const [teams, setTeams] = useState<Team[]>([])
  const [users, setUsers] = useState<User[]>([])
  const [query, setQuery] = useState('')

  // form state
  const [editing, setEditing] = useState<Team | null>(null)
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')
  const [teamType, setTeamType] = useState<Team['team_type']>('EKIP')
  const [memberIds, setMemberIds] = useState<number[]>([])
  const [isActive, setIsActive] = useState(true)

  const load = useCallback(async () => {
    try {
      setLoading(true)
      const [t, u] = await Promise.all([getTeams(), getUsers()])
      setTeams(t)
      setUsers(u)
    } catch (e) {
      const err = e as { response?: { data?: { detail?: string } } }
      toast.error(err?.response?.data?.detail || 'Ekipler yüklenemedi')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    load()
  }, [load])

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase()
    if (!q) return teams
    return teams.filter(t =>
      t.name.toLowerCase().includes(q) || (t.description || '').toLowerCase().includes(q)
    )
  }, [teams, query])

  const resetForm = () => {
    setEditing(null)
    setName('')
    setDescription('')
    setTeamType('EKIP')
    setMemberIds([])
    setIsActive(true)
  }

  const startEdit = (t: Team) => {
    setEditing(t)
    setName(t.name)
    setDescription(t.description || '')
    setTeamType(t.team_type)
    setMemberIds(t.members || [])
    setIsActive(t.is_active)
  }

  const submit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    if (!name.trim()) {
      return toast.error('Takım adı zorunludur')
    }
    try {
      if (editing) {
        const updated = await updateTeam(editing.id, {
          name,
          description,
          team_type: teamType,
          members: memberIds,
          is_active: isActive,
        })
        setTeams(prev => prev.map(x => (x.id === editing.id ? updated : x)))
        toast.success('Takım güncellendi')
      } else {
        const created = await createTeam({ name, description, team_type: teamType, members: memberIds, is_active: isActive })
        setTeams(prev => [created, ...prev])
        toast.success('Takım oluşturuldu')
      }
      resetForm()
    } catch (e) {
      const err = e as { response?: { status?: number } }
      if (err?.response?.status === 403) {
        toast.error('Bu işlem için yetkiniz yok')
      } else {
        toast.error('İşlem sırasında hata oluştu')
      }
    }
  }

  const remove = async (t: Team) => {
    if (!confirm(`${t.name} takımını pasif yapmak istiyor musunuz?`)) return
    try {
      await deleteTeam(t.id)
      setTeams(prev => prev.filter(x => x.id !== t.id))
      toast.success('Takım pasif yapıldı')
    } catch (e) {
      const err = e as { response?: { status?: number } }
      if (err?.response?.status === 403) {
        toast.error('Bu işlem için yetkiniz yok')
      } else {
        toast.error('İşlem sırasında hata oluştu')
      }
    }
  }

  return (
    <div className="space-y-8 p-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Ekipler</h1>
          <p className="text-sm text-gray-500 mt-1">Ekip oluşturun, üyeleri yönetin ve düzenleyin</p>
        </div>
        <div>
          <input
            className="w-72 rounded-md border border-gray-300 px-3 py-2 focus:ring-2 focus:ring-blue-500"
            placeholder="Ara: isim veya açıklama"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
          />
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-1">
          <div className="bg-white p-6 rounded-xl border border-gray-100 shadow-sm">
            <h2 className="text-base font-semibold mb-4">{editing ? 'Takım Düzenle' : 'Yeni Takım'}</h2>
            <form onSubmit={submit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Ad</label>
                <input
                  className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 focus:ring-2 focus:ring-blue-500"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="Takım adı"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Açıklama</label>
                <textarea
                  className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 focus:ring-2 focus:ring-blue-500"
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  placeholder="Opsiyonel açıklama"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Tür</label>
                <select
                  className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 focus:ring-2 focus:ring-blue-500"
                  value={teamType}
                  onChange={(e) => setTeamType(e.target.value as Team['team_type'])}
                >
                  <option value="EKIP">Saha Ekibi</option>
                  <option value="OPERATOR">Operatör Takımı</option>
                  <option value="ADMIN">Admin Takımı</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Üyeler</label>
                <div className="mt-1 grid grid-cols-1 gap-2 max-h-40 overflow-auto border rounded-lg p-2">
                  {users.map(u => (
                    <label key={u.id} className="flex items-center gap-2 text-sm">
                      <input
                        type="checkbox"
                        checked={memberIds.includes(u.id)}
                        onChange={(e) => {
                          const checked = e.target.checked
                          setMemberIds(prev => checked ? Array.from(new Set([...prev, u.id])) : prev.filter(id => id !== u.id))
                        }}
                      />
                      <span>{u.username} <span className="text-gray-500">({u.email})</span></span>
                    </label>
                  ))}
                </div>
              </div>
              <div className="flex items-center gap-2">
                <input id="isActive" type="checkbox" className="h-4 w-4" checked={isActive} onChange={e => setIsActive(e.target.checked)} />
                <label htmlFor="isActive" className="text-sm text-gray-700">Aktif</label>
              </div>
              <div className="flex items-center gap-2">
                <button type="submit" className="px-4 py-2 rounded-lg bg-blue-600 text-white hover:bg-blue-700">
                  {editing ? 'Güncelle' : 'Ekle'}
                </button>
                {editing && (
                  <button type="button" onClick={resetForm} className="px-4 py-2 rounded-lg border">
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
              <h2 className="text-base font-semibold">Ekipler</h2>
              <span className="text-xs text-gray-500">{filtered.length} sonuç</span>
            </div>
            <div className="p-6">
              {loading ? (
                <p className="text-gray-500">Yükleniyor...</p>
              ) : filtered.length === 0 ? (
                <p className="text-gray-500">Kayıt bulunamadı</p>
              ) : (
                <ul className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  {filtered.map(t => (
                    <li key={t.id} className="p-4 rounded-lg border border-gray-200 bg-white">
                      <div className="flex items-start justify-between">
                        <div>
                          <p className="font-medium text-gray-900">{t.name}</p>
                          {t.description && (
                            <p className="text-sm text-gray-500 mt-1 line-clamp-2">{t.description}</p>
                          )}
                          <p className="text-xs text-gray-500 mt-1">Tür: {t.team_type} • Üye: {t.members_count ?? (t.members?.length || 0)}</p>
                        </div>
                        <span className={`text-xs px-2 py-1 rounded-full ${t.is_active ? 'bg-emerald-50 text-emerald-700' : 'bg-gray-100 text-gray-600'}`}>
                          {t.is_active ? 'Aktif' : 'Pasif'}
                        </span>
                      </div>
                      <div className="flex items-center gap-2 mt-4">
                        <button onClick={() => startEdit(t)} className="px-3 py-1 text-sm rounded-md border">Düzenle</button>
                        <button onClick={() => remove(t)} className="px-3 py-1 text-sm rounded-md border border-amber-300 text-amber-700">Pasif Yap</button>
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