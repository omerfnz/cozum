import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import toast from 'react-hot-toast'
import { getCategories, createReport, type Category } from '../lib/api'
import { isAxiosError } from 'axios'
// Harita için ek importlar
import { MapContainer, TileLayer, Marker, useMap, useMapEvents } from 'react-leaflet'
import type { LatLngExpression, LeafletMouseEvent } from 'leaflet'
import L from 'leaflet'
import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png'
import markerIcon from 'leaflet/dist/images/marker-icon.png'
import markerShadow from 'leaflet/dist/images/marker-shadow.png'

// Leaflet marker ikonlarını Vite ile düzgün göstermek için fix
L.Icon.Default.mergeOptions({
  iconRetinaUrl: markerIcon2x,
  iconUrl: markerIcon,
  shadowUrl: markerShadow,
})

const defaultIcon = new L.Icon({
  iconRetinaUrl: markerIcon2x,
  iconUrl: markerIcon,
  shadowUrl: markerShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  tooltipAnchor: [16, -28],
  shadowSize: [41, 41],
})

const round6 = (n: number) => Number(n.toFixed(6))

function RecenterOnChange({ center }: { center: LatLngExpression }) {
  const map = useMap()
  useEffect(() => {
    map.setView(center)
  }, [center, map])
  return null
}

function MapClickHandler({ onSelect }: { onSelect: (lat: number, lng: number) => void }) {
  useMapEvents({
    click(e: LeafletMouseEvent) {
      onSelect(e.latlng.lat, e.latlng.lng)
    },
  })
  return null
}

export default function ReportsCreate() {
  const navigate = useNavigate()
  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [category, setCategory] = useState<number | ''>('')
  const [image, setImage] = useState<File | null>(null)
  const [categories, setCategories] = useState<Category[]>([])
  const [loading, setLoading] = useState(false)
  const [initialLoading, setInitialLoading] = useState(true)
  // Konum alanları
  const [location, setLocation] = useState('')
  const [latitude, setLatitude] = useState<number | undefined>(undefined)
  const [longitude, setLongitude] = useState<number | undefined>(undefined)
  const [mapCenter, setMapCenter] = useState<LatLngExpression>([39.92077, 32.85411]) // Ankara varsayılan

  // Dosya doğrulama sabitleri ve yardımcılar
  const MAX_IMAGE_SIZE = 10 * 1024 * 1024 // 10 MB
  const ALLOWED_MIME = new Set([
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/heic',
    'image/heif',
  ])
  const ALLOWED_EXT = new Set(['jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'])
  const formatBytes = (bytes: number) => {
    const sizes = ['B', 'KB', 'MB', 'GB']
    if (bytes === 0) return '0 B'
    const i = Math.floor(Math.log(bytes) / Math.log(1024))
    return `${(bytes / Math.pow(1024, i)).toFixed(1)} ${sizes[i]}`
  }
  const validateImage = (file: File): string | null => {
    if (file.size > MAX_IMAGE_SIZE) {
      return `Dosya çok büyük: ${formatBytes(file.size)}. En fazla ${formatBytes(MAX_IMAGE_SIZE)} yükleyebilirsiniz.`
    }
    // MIME tipi veya uzantı ile kontrol
    if (file.type && ALLOWED_MIME.has(file.type)) return null
    const ext = file.name.split('.').pop()?.toLowerCase() || ''
    if (ALLOWED_EXT.has(ext)) return null
    return 'Desteklenmeyen dosya türü. İzin verilen türler: JPG, JPEG, PNG, WEBP, HEIC, HEIF.'
  }
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const f = e.target.files?.[0] || null
    if (!f) {
      setImage(null)
      return
    }
    const err = validateImage(f)
    if (err) {
      toast.error(err)
      setImage(null)
      // input temizle
      e.currentTarget.value = ''
      return
    }
    setImage(f)
  }

  useEffect(() => {
    const load = async () => {
      try {
        const cats = await getCategories()
        setCategories(cats)
      } catch {
        toast.error('Kategoriler yüklenemedi')
      } finally {
        setInitialLoading(false)
      }
    }
    load()
  }, [])

  const useMyLocation = () => {
    if (!navigator.geolocation) {
      toast.error('Tarayıcınız konum desteği sunmuyor')
      return
    }
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const lat = round6(pos.coords.latitude)
        const lng = round6(pos.coords.longitude)
        setLatitude(lat)
        setLongitude(lng)
        setMapCenter([lat, lng])
        toast.success('Konum alındı')
      },
      () => toast.error('Konum alınamadı')
    )
  }

  const handleMapSelect = (lat: number, lng: number) => {
    setLatitude(round6(lat))
    setLongitude(round6(lng))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!title.trim() || !description.trim() || !category) {
      toast.error('Lütfen başlık, açıklama ve kategori alanlarını doldurun.')
      return
    }
    if (!image) {
      toast.error('Lütfen bir fotoğraf seçin (MVP gereği).')
      return
    }
    // Ek güvenlik: seçili dosyayı tekrar doğrula
    const err = validateImage(image)
    if (err) {
      toast.error(err)
      return
    }
    if (latitude === undefined || longitude === undefined) {
      toast.error('Lütfen haritadan bir konum seçin veya "Konumumu Kullan" butonuna tıklayın.')
      return
    }

    setLoading(true)
    try {
      await createReport({
        title: title.trim(),
        description: description.trim(),
        category: Number(category),
        location: location.trim() || undefined,
        latitude,
        longitude,
        media_files: [image],
      })
      toast.success('Bildirim oluşturuldu')
      navigate('/dashboard')
    } catch (err: unknown) {
      console.error('Report creation error:', err)
      let detail = ''
      if (isAxiosError(err)) {
        const resp = err.response?.data
        detail = typeof resp === 'string' ? resp : resp ? JSON.stringify(resp) : ''
      }
      toast.error(`Bildirim oluşturulamadı${detail ? `: ${detail}` : ''}`)
    } finally {
      setLoading(false)
    }
  }

  if (initialLoading) {
    return (
      <div className="max-w-2xl mx-auto">
        <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-6">
          <div className="animate-pulse space-y-5">
            <div className="h-6 w-40 bg-slate-200 rounded" />
            <div className="space-y-3">
              <div className="h-4 w-24 bg-slate-200 rounded" />
              <div className="h-10 w-full bg-slate-200 rounded" />
            </div>
            <div className="space-y-3">
              <div className="h-4 w-28 bg-slate-200 rounded" />
              <div className="h-24 w-full bg-slate-200 rounded" />
            </div>
            <div className="space-y-3">
              <div className="h-4 w-24 bg-slate-200 rounded" />
              <div className="h-10 w-full bg-slate-200 rounded" />
            </div>
            <div className="space-y-3">
              <div className="h-4 w-32 bg-slate-200 rounded" />
              <div className="h-10 w-full bg-slate-200 rounded" />
            </div>
            <div className="space-y-3">
              <div className="h-4 w-20 bg-slate-200 rounded" />
              <div className="h-72 w-full bg-slate-200 rounded" />
            </div>
            <div className="space-y-3">
              <div className="h-4 w-24 bg-slate-200 rounded" />
              <div className="h-10 w-2/3 bg-slate-200 rounded" />
            </div>
            <div className="flex items-center gap-2 pt-2">
              <div className="h-10 w-28 bg-slate-200 rounded" />
              <div className="h-10 w-24 bg-slate-200 rounded" />
            </div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="max-w-2xl mx-auto">
      <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-6">
        <h1 className="text-xl font-semibold text-slate-900 mb-4">Yeni Bildirim</h1>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-700">Başlık</label>
            <input
              type="text"
              className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Örn. Bozuk kaldırım"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-700">Açıklama</label>
            <textarea
              className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              rows={4}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Sorunu kısaca açıklayın"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-700">Kategori</label>
            <select
              className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              value={category}
              onChange={(e) => setCategory(e.target.value ? Number(e.target.value) : '')}
            >
              <option value="">Kategori seçin</option>
              {categories.map((c) => (
                <option key={c.id} value={c.id}>{c.name}</option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-700">Adres (isteğe bağlı)</label>
            <input
              type="text"
              className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              value={location}
              onChange={(e) => setLocation(e.target.value)}
              placeholder="Örn. Atatürk Bulvarı No:1, Çankaya/Ankara"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-slate-700">Konum</label>
            <div className="flex items-center gap-2 mb-2 text-sm text-slate-600">
              <span>Lat: {latitude?.toFixed(6) ?? '-'}</span>
              <span>Lng: {longitude?.toFixed(6) ?? '-'}</span>
              <button type="button" onClick={useMyLocation} className="ml-auto inline-flex items-center rounded-md bg-blue-100 text-blue-700 px-2 py-1 hover:bg-blue-200">Konumumu Kullan</button>
            </div>
            <div className="w-full h-72 rounded-lg overflow-hidden border border-gray-300">
              <MapContainer center={mapCenter as LatLngExpression} zoom={15} style={{ height: '100%', width: '100%' }} scrollWheelZoom>
                <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" attribution="&copy; OpenStreetMap katkıda bulunanlar" />
                <RecenterOnChange center={mapCenter} />
                {latitude !== undefined && longitude !== undefined && (
                  <Marker position={[latitude, longitude] as LatLngExpression} icon={defaultIcon} />
                )}
                <MapClickHandler onSelect={handleMapSelect} />
              </MapContainer>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-700">Fotoğraf</label>
            <input
              type="file"
              accept="image/*"
              className="mt-1 block w-full text-sm text-slate-700 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
              onChange={handleFileChange}
            />
            <p className="mt-1 text-xs text-slate-500">İzin verilen türler: JPG, JPEG, PNG, WEBP, HEIC, HEIF. Maksimum boyut: {formatBytes(MAX_IMAGE_SIZE)}.</p>
          </div>

          <div className="pt-2">
            <button
              type="submit"
              disabled={loading}
              className="inline-flex items-center rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-60"
            >
              {loading ? 'Gönderiliyor...' : 'Gönder'}
            </button>
            <button
              type="button"
              onClick={() => navigate(-1)}
              className="ml-2 inline-flex items-center rounded-lg bg-white px-4 py-2 text-sm font-medium text-slate-700 border border-gray-300 hover:bg-gray-50"
            >
              İptal
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}