import { useState } from 'react'
import { useNavigate } from 'react-router-dom'

interface AppBarProps {
  onMenuToggle: () => void
  user?: {
    first_name?: string
    username?: string
    email: string
    role_display?: string
    role?: string
  }
}

// SVG Icon Components
const IconMenu = () => (
  <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
  </svg>
)

const IconSearch = () => (
  <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
  </svg>
)

const IconBell = () => (
  <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
  </svg>
)

const IconUser = () => (
  <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
  </svg>
)

const IconChevronDown = () => (
  <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
  </svg>
)

// removed unused IconLogOut component

export default function AppBar({ onMenuToggle, user }: AppBarProps) {
  const navigate = useNavigate()
  const [showUserMenu, setShowUserMenu] = useState(false)

  const handleLogout = () => {
    localStorage.removeItem('token')
    navigate('/login')
  }

  const userName = user?.first_name || user?.username || user?.email?.split('@')[0] || 'Kullanıcı'
  const userRole = user?.role_display || user?.role || 'Kullanıcı'

  return (
    <header className="h-16 bg-white/90 backdrop-blur supports-[backdrop-filter]:bg-white/70 text-slate-700 flex items-center justify-between px-4 lg:px-6 z-30 shadow-sm border-b border-gray-200">
      {/* Sol taraf - Menu butonu ve logo */}
      <div className="flex items-center space-x-4">
        <button
          onClick={onMenuToggle}
          className="p-2 rounded-lg hover:bg-gray-100 transition-colors lg:hidden"
          aria-label="Menüyü aç"
        >
          <IconMenu />
        </button>
        
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 bg-gradient-to-r from-indigo-500 to-blue-600 rounded-lg flex items-center justify-center">
            <span className="text-white font-bold text-sm">C</span>
          </div>
          <h1 className="text-xl font-bold hidden sm:block text-slate-900">Cozum</h1>
        </div>
      </div>

      {/* Orta - Arama kutusu (masaüstünde) */}
      <div className="hidden md:flex flex-1 mx-8">
        <div className="relative w-full">
          <div className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400">
            <IconSearch />
          </div>
          <input
            type="text"
            placeholder="Arama yapın..."
            className="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white text-sm placeholder-slate-400 text-slate-700"
          />
        </div>
      </div>

      {/* Sağ taraf - Bildirimler ve kullanıcı menüsü */}
      <div className="flex items-center space-x-3">
        {/* Bildirim butonu */}
        <button 
          className="p-2.5 rounded-lg hover:bg-gray-100 transition-colors relative"
          aria-label="Bildirimler"
        >
          <IconBell />
          <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center font-medium">
            3
          </span>
        </button>

        {/* Kullanıcı menüsü */}
        <div className="relative">
          <button
            onClick={() => setShowUserMenu(!showUserMenu)}
            className="flex items-center space-x-3 p-2 rounded-lg hover:bg-gray-100 transition-colors"
            aria-haspopup="menu"
            aria-expanded={showUserMenu}
          >
            <div className="w-8 h-8 bg-gradient-to-r from-indigo-500 to-blue-600 rounded-full flex items-center justify-center text-white">
              <IconUser />
            </div>
            <div className="hidden md:block text-left">
              <div className="text-sm font-medium text-slate-900">{userName}</div>
              <div className="text-xs text-slate-500">{userRole}</div>
            </div>
            <div className="text-slate-500">
              <IconChevronDown />
            </div>
          </button>

          {/* Dropdown menü */}
          {showUserMenu && (
            <>
              <div 
                className="fixed inset-0 z-40" 
                onClick={() => setShowUserMenu(false)}
              ></div>
              <div className="absolute right-0 mt-2 w-48 bg-white text-slate-900 rounded-lg shadow-xl border border-gray-200 py-1 z-50">
                <button
                  onClick={() => {
                    navigate('/profile')
                    setShowUserMenu(false)
                  }}
                  className="flex items-center w-full px-4 py-2 text-sm hover:bg-gray-100 transition-colors"
                >
                  <IconUser />
                  <span className="ml-3">Profil</span>
                </button>
                <hr className="my-1 border-gray-200" />
                <button
                  onClick={handleLogout}
                  className="flex items-center w-full px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors"
                >
                  <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                  </svg>
                  <span className="ml-3">Çıkış Yap</span>
                </button>
              </div>
            </>
          )}
        </div>
      </div>
    </header>
  )
}