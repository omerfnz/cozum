import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import toast from 'react-hot-toast'
import {
  addComment,
  getComments,
  getReport,
  me,
  getTeams,
  updateReport,
  type CommentItem,
  type ReportDetail,
  type Team,
  type User,
} from '../lib/api'
import { isAxiosError } from 'axios'

export default function ReportsDetail() {
  const { id } = useParams()
  const navigate = useNavigate()
  const reportId = Number(id)

  const [report, setReport] = useState<ReportDetail | null>(null)
  const [comments, setComments] = useState<CommentItem[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [commentText, setCommentText] = useState('')
  const [sending, setSending] = useState(false)
  const [currentUser, setCurrentUser] = useState<User | null>(null)
  const [teams, setTeams] = useState<Team[]>([])
  const [statusDraft, setStatusDraft] = useState<ReportDetail['status'] | undefined>(undefined)
  const [assignedTeamDraft, setAssignedTeamDraft] = useState<number | null | undefined>(undefined)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (!reportId) return
    const load = async () => {
      setLoading(true)
      setError(null)
      try {
        const [rep, coms] = await Promise.all([
          getReport(reportId),
          getComments(reportId),
        ])
        setReport(rep)
        setComments(coms)
      } catch (e) {
        console.error(e)
        setError('Bildirimi yüklerken bir hata oluştu')
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [reportId])

  // Kullanıcı ve takımlar
  useEffect(() => {
    const loadUserAndTeams = async () => {
      try {
        const u = await me()
        setCurrentUser(u)
        if (u.role === 'OPERATOR' || u.role === 'ADMIN') {
          const ts = await getTeams()
          setTeams(ts)
        }
      } catch {
        // ignore
      }
    }
    loadUserAndTeams()
  }, [])

  // Rapor geldiğinde taslak alanları doldur
  useEffect(() => {
    if (report) {
      setStatusDraft(report.status)
      setAssignedTeamDraft(report.assigned_team ? report.assigned_team.id : null)
    }
  }, [report])

  // Yetkiler
  const canChangeAssign = currentUser?.role === 'OPERATOR' || currentUser?.role === 'ADMIN'
  const canChangeStatus = canChangeAssign || currentUser?.role === 'EKIP'
  const canComment = canChangeStatus // EKIP + OPERATOR + ADMIN yorum yapabilir

  const handleAddComment = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!commentText.trim()) return
    setSending(true)
    try {
      const created = await addComment(reportId, commentText.trim())
      setComments((prev) => [created, ...prev])
      setCommentText('')
    } catch (err: unknown) {
      if (isAxiosError(err) && err.response?.status === 403) {
        toast.error('Yorum yapma yetkiniz yok')
      } else {
        toast.error('Yorum eklenemedi')
      }
    } finally {
      setSending(false)
    }
  }

  const handleSave = async () => {
    if (!report) return
    setSaving(true)
    try {
      // Sadece yetkin olunan ve gerçekten değişen alanları gönder
      const currentAssignedId = report.assigned_team?.id ?? null
      const changedStatus = canChangeStatus && (statusDraft !== undefined) && statusDraft !== report.status
      const changedAssign = canChangeAssign && (assignedTeamDraft ?? currentAssignedId) !== currentAssignedId

      const payload: { status?: ReportDetail['status']; assigned_team?: number | null } = {}
      if (changedStatus) payload.status = statusDraft as ReportDetail['status']
      if (changedAssign) payload.assigned_team = assignedTeamDraft === undefined ? null : assignedTeamDraft

      if (!changedStatus && !changedAssign) {
        toast('Kaydedilecek değişiklik yok')
        return
      }

      const updated = await updateReport(report.id, payload)
      // Lokal state'i güncelle
      setReport({ ...report, status: updated.status, assigned_team: updated.assigned_team })

      if (changedStatus && changedAssign) {
        toast.success('Durum ve ekip ataması güncellendi')
      } else if (changedStatus) {
        toast.success('Durum güncellendi')
      } else if (changedAssign) {
        toast.success('Ekip ataması güncellendi')
      }
    } catch (err: unknown) {
      if (isAxiosError(err)) {
        const detail = (err.response?.data as { detail?: string } | undefined)?.detail
        toast.error(detail || 'Güncelleme başarısız')
      } else {
        toast.error('Güncelleme başarısız')
      }
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <div className="space-y-6 animate-pulse">
        <div className="flex items-start justify-between">
          <div>
            <div className="h-6 w-48 bg-slate-200 rounded" />
            <div className="mt-2 h-3 w-64 bg-slate-200 rounded" />
          </div>
          <div className="h-9 w-20 bg-slate-200 rounded" />
        </div>
        <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="h-48 w-full rounded-lg bg-slate-200 border border-gray-200" />
          ))}
        </div>
        <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-4">
          <div className="h-5 w-32 bg-slate-200 rounded mb-3" />
          <div className="space-y-2">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="h-3 w-full bg-slate-200 rounded" />
            ))}
          </div>
        </div>
        <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-4">
          <div className="h-5 w-24 bg-slate-200 rounded mb-3" />
          <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
            <div className="h-10 bg-slate-200 rounded" />
            <div className="h-10 bg-slate-200 rounded" />
            <div className="h-10 bg-slate-200 rounded" />
          </div>
        </div>
        <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-4">
          <div className="h-5 w-24 bg-slate-200 rounded mb-3" />
          <div className="space-y-3">
            {Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="border border-gray-200 rounded-lg p-3">
                <div className="h-3 w-40 bg-slate-200 rounded" />
                <div className="h-4 w-72 bg-slate-200 rounded mt-2" />
              </div>
            ))}
          </div>
        </div>
      </div>
    )
  }

  if (error || !report) {
    return (
      <div className="min-h-[40vh] grid place-items-center">
        <div className="text-rose-600">{error || 'Kayıt bulunamadı'}</div>
        <button
          onClick={() => navigate(-1)}
          className="mt-4 inline-flex items-center rounded-lg bg-white px-4 py-2 text-sm font-medium text-slate-700 border border-gray-300 hover:bg-gray-50"
        >
          Geri Dön
        </button>
      </div>
    )
  }

  // Değişiklik kontrolü (Kaydet butonunu devre dışı bırakmak için)
  const currentAssignedId = report.assigned_team?.id ?? null
  const changedStatus = canChangeStatus && (statusDraft !== undefined) && statusDraft !== report.status
  const changedAssign = canChangeAssign && (assignedTeamDraft ?? currentAssignedId) !== currentAssignedId
  const hasChanges = changedStatus || changedAssign

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-slate-900">{report.title}</h1>
          <div className="text-sm text-slate-600 mt-1">
            {report.category?.name} • {new Date(report.created_at).toLocaleString()}
          </div>
        </div>
        <button
          onClick={() => navigate(-1)}
          className="inline-flex items-center rounded-lg bg-white px-4 py-2 text-sm font-medium text-slate-700 border border-gray-300 hover:bg-gray-50"
        >
          Geri
        </button>
      </div>

      {/* Medya galerisi */}
      {report.media_files?.length > 0 && (
        <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
          {report.media_files.map((m) => (
            <div key={m.id} className="relative w-full overflow-hidden rounded-lg border border-gray-200 bg-white">
              <img src={m.file} alt="media" className="w-full h-48 object-cover" />
            </div>
          ))}
        </div>
      )}

      <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-4">
        <h2 className="text-lg font-semibold text-slate-900 mb-2">Açıklama</h2>
        <p className="text-slate-700 whitespace-pre-line">{report.description}</p>
      </div>

      {(canChangeStatus || canChangeAssign) && (
        <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-4">
          <h2 className="text-lg font-semibold text-slate-900 mb-3">Yönetim</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-3 items-end">
            {canChangeStatus && (
              <div>
                <label className="block text-sm text-slate-600 mb-1">Durum</label>
                <select
                  value={statusDraft}
                  onChange={(e) => setStatusDraft(e.target.value as ReportDetail['status'])}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2"
                >
                  <option value="BEKLEMEDE">Beklemede</option>
                  <option value="INCELENIYOR">İnceleniyor</option>
                  <option value="COZULDU">Çözüldü</option>
                  <option value="REDDEDILDI">Reddedildi</option>
                </select>
              </div>
            )}
            {canChangeAssign && (
              <div>
                <label className="block text-sm text-slate-600 mb-1">Ekip Ataması</label>
                <select
                  value={assignedTeamDraft ?? ''}
                  onChange={(e) => setAssignedTeamDraft(e.target.value ? Number(e.target.value) : null)}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2"
                >
                  <option value="">— Atamasız —</option>
                  {teams.map((t) => (
                    <option key={t.id} value={t.id}>{t.name}</option>
                  ))}
                </select>
              </div>
            )}
            <div>
              <button
                onClick={handleSave}
                disabled={saving || !hasChanges}
                className="inline-flex items-center rounded-lg bg-emerald-600 px-4 py-2 text-sm font-medium text-white hover:bg-emerald-700 disabled:opacity-60"
              >
                {saving ? 'Kaydediliyor...' : 'Kaydet'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Konum bilgisi */}
      {(report.location || (report.latitude && report.longitude)) && (
        <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-4">
          <h2 className="text-lg font-semibold text-slate-900 mb-2">Konum</h2>
          <div className="text-slate-700">
            {report.location && <div>Adres: {report.location}</div>}
            {(report.latitude && report.longitude) && (
              <div>Koordinatlar: {report.latitude}, {report.longitude}</div>
            )}
          </div>
        </div>
      )}

      {/* Yorumlar */}
      <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-4">
        <h2 className="text-lg font-semibold text-slate-900 mb-3">Yorumlar</h2>
        {canComment ? (
          <form onSubmit={handleAddComment} className="flex gap-2 mb-4">
            <input
              type="text"
              value={commentText}
              onChange={(e) => setCommentText(e.target.value)}
              placeholder="Yorum yazın"
              disabled={sending}
              className="flex-1 rounded-lg border border-gray-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-50"
            />
            <button
              type="submit"
              disabled={sending || !commentText.trim()}
              className="inline-flex items-center rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-60"
            >
              {sending ? 'Gönderiliyor...' : 'Gönder'}
            </button>
          </form>
        ) : (
          <div className="mb-4 text-sm text-slate-600 bg-gray-50 border border-gray-200 rounded-lg px-3 py-2">
            Yorum eklemek yalnızca yetkili roller içindir.
          </div>
        )}
        <div className="space-y-3">
          {comments.map((c) => (
            <div key={c.id} className="border border-gray-200 rounded-lg p-3">
              <div className="text-sm text-slate-600">
                {c.user?.username || c.user?.email} • {new Date(c.created_at).toLocaleString()}
              </div>
              <div className="text-slate-800 mt-1">{c.content}</div>
            </div>
          ))}
          {comments.length === 0 && (
            <div className="text-slate-500">Henüz yorum yok</div>
          )}
        </div>
      </div>
    </div>
  )
}