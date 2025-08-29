import { useState } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'

interface SidebarProps {
  isOpen: boolean
  onClose: () => void
  userRole?: Role
}

// Roller
type Role = 'VATANDAS' | 'OPERATOR' | 'EKIP' | 'ADMIN'

// SVG Icon Components
const IconDashboard = () => (
  <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2-2z" />
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 5a2 2 0 012-2h4a2 2 0 012 2v2H8V5z" />
  </svg>
)

const IconCategories = () => (
  <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
  </svg>
)

const IconReports = () => (
  <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
  </svg>
)

const IconUsers = () => (
  <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
  </svg>
)

const IconTasks = () => (
  <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
  </svg>
)

const IconTeams = () => (
  <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
  </svg>
)


const IconChevronLeft = () => (
  <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
  </svg>
)

export default function Sidebar({ isOpen, onClose, userRole }: SidebarProps) {
  const navigate = useNavigate()
  const location = useLocation()
  const [isCollapsed, setIsCollapsed] = useState(false)

  const menuItems: Array<{ 
    icon: React.FC; 
    label: string; 
    path: string;
    description: string;
    allowedRoles?: Role[]
  }> = [
    { 
      icon: IconDashboard, 
      label: 'Dashboard', 
      path: '/dashboard',
      description: 'Ana sayfa',
      allowedRoles: ['VATANDAS','OPERATOR','EKIP','ADMIN']
    },
    { 
      icon: IconCategories, 
      label: 'Kategoriler', 
      path: '/categories',
      description: 'Kategori yönetimi',
      allowedRoles: ['OPERATOR','ADMIN']
    },
    { 
      icon: IconReports, 
      label: 'Vatandaş Bildirimleri', 
      path: '/reports',
      description: 'Vatandaş bildirimleri',
      allowedRoles: ['VATANDAS','OPERATOR','EKIP','ADMIN']
    },
    { 
      icon: IconUsers, 
      label: 'Kullanıcılar', 
      path: '/users',
      description: 'Kullanıcı yönetimi',
      allowedRoles: ['ADMIN']
    },
    { 
      icon: IconTasks, 
      label: 'Görevler', 
      path: '/tasks',
      description: 'Görev takibi',
      allowedRoles: ['OPERATOR','EKIP','ADMIN']
    },
    { 
      icon: IconTeams, 
      label: 'Ekipler', 
      path: '/teams',
      description: 'Ekip yönetimi',
      allowedRoles: ['OPERATOR','ADMIN']
    }
  ]

  const visibleItems = menuItems.filter(item => !item.allowedRoles || item.allowedRoles.includes(userRole ?? 'VATANDAS'))

  const handleNavigation = (path: string) => {
    navigate(path)
    if (window.innerWidth < 1024) {
      onClose()
    }
  }

  return (
    <>
      {/* Mobile overlay */}
      {isOpen && (
        <div 
          className="fixed inset-0 bg-white/40 backdrop-blur-sm z-40 lg:hidden"
          onClick={onClose}
        />
      )}

      {/* Sidebar */}
      <aside className={`
        fixed top-0 left-0 z-50 h-full bg-white text-slate-700 transition-all duration-300 ease-in-out
        ${isOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
        ${isCollapsed ? 'w-16' : 'w-64'}
        lg:sticky lg:top-0 border-r border-gray-200 shadow-sm lg:shadow-none
      `}>
        {/* Sidebar Header */}
        <div className="flex items-center justify-between p-4 border-b border-gray-200">
          {!isCollapsed && (
            <div className="flex items-center space-x-3">
              <div className="w-8 h-8 bg-gradient-to-r from-indigo-500 to-blue-600 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-xs">CV</span>
              </div>
              <h2 className="text-xl font-bold text-slate-900">Cozum Var</h2>
            </div>
          )}
          
          <div className="flex items-center space-x-2">
            {/* Collapse button - desktop only */}
            <button
              onClick={() => setIsCollapsed(!isCollapsed)}
              className="hidden lg:flex p-1.5 rounded-lg hover:bg-gray-100 transition-colors"
              aria-label={isCollapsed ? "Genişlet" : "Daralt"}
            >
              <div className={`transform transition-transform ${isCollapsed ? 'rotate-180' : ''}`}>
                <IconChevronLeft />
              </div>
            </button>
            
            {/* Close button - mobile only */}
            <button
              onClick={onClose}
              className="lg:hidden p-1.5 rounded-lg hover:bg-gray-100 transition-colors"
              aria-label="Kapat"
            >
              <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 p-3 space-y-1 overflow-y-auto">
          {visibleItems.map((item) => {
            const Icon = item.icon
            const isActive = location.pathname === item.path || location.pathname.startsWith(item.path + '/')
            
            return (
              <button
                key={item.path}
                onClick={() => handleNavigation(item.path)}
                className={`
                  w-full flex items-center space-x-3 px-3 py-2.5 rounded-md text-left transition-all duration-200
                  ${isActive 
                    ? 'bg-blue-50 text-blue-700 border-l-4 border-blue-500' 
                    : 'text-slate-600 hover:bg-gray-100 hover:text-slate-900'
                  }
                  ${isCollapsed ? 'justify-center' : 'justify-start'}
                `}
                title={isCollapsed ? item.label : undefined}
              >
                <Icon />
                {!isCollapsed && (
                  <div className="flex-1 min-w-0">
                    <div className="font-medium text-sm">{item.label}</div>
                    <div className="text-xs text-slate-500 truncate">{item.description}</div>
                  </div>
                )}
              </button>
            )
          })}
        </nav>

        {/* Sidebar Footer */}
        {!isCollapsed && (
          <div className="p-4 border-t border-gray-200">
            <div className="text-center">
              <div className="text-xs text-slate-500">Cozum Var v1.0</div>
              <div className="text-xs text-slate-400 mt-1">© 2024 Tüm hakları saklıdır</div>
            </div>
          </div>
        )}
      </aside>
    </>
  )
}