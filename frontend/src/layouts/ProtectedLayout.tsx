import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { me } from '../lib/api'
import AppBar from '../components/AppBar'
import Sidebar from '../components/Sidebar'

interface User {
  first_name?: string
  username?: string
  email: string
  role_display?: string
  role?: string
}

interface ProtectedLayoutProps {
  children: React.ReactNode
}

export default function ProtectedLayout({ children }: ProtectedLayoutProps) {
  const navigate = useNavigate()
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const [sidebarOpen, setSidebarOpen] = useState(false)

  useEffect(() => {
    const checkAuth = async () => {
      try {
        const token = localStorage.getItem('token')
        if (!token) {
          navigate('/login')
          return
        }
        
        const userData = await me()
        setUser(userData)
      } catch (error) {
        console.error('Auth check failed:', error)
        localStorage.removeItem('token')
        navigate('/login')
      } finally {
        setLoading(false)
      }
    }

    checkAuth()
  }, [navigate])

  const handleMenuToggle = () => {
    setSidebarOpen(!sidebarOpen)
  }

  const handleSidebarClose = () => {
    setSidebarOpen(false)
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center w-full h-auto bg-gradient-to-br from-slate-50 to-slate-100">
        <div className="text-center">
          <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-700 font-medium">Yükleniyor...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="flex w-full h-auto bg-gradient-to-br from-slate-50 to-slate-100">
      {/* Sidebar */}
      <Sidebar isOpen={sidebarOpen} onClose={handleSidebarClose} />

      {/* Ana içerik alanı */}
      <div className="flex w-full flex-col">
        {/* AppBar */}
        <AppBar onMenuToggle={handleMenuToggle} user={user || undefined} />

        {/* Ana içerik - Scroll burada değil, content'te olacak */}
        <main className="w-full h-auto p-4 md:p-6 lg:p-8">
          {children}
        </main>
      </div>
    </div>
  )
}