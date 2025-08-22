import { Routes, Route, Navigate, Outlet } from 'react-router-dom'
import Login from './pages/Auth/Login'
import Register from './pages/Auth/Register'
import Dashboard from './pages/Dashboard'
import Categories from './pages/Categories'
import Users from './pages/Users'
import Teams from './pages/Teams'
import ProtectedLayout from './layouts/ProtectedLayout'
import ReportsCreate from './pages/ReportsCreate'
import ReportsList from './pages/ReportsList'
import ReportsDetail from './pages/ReportsDetail'
import Tasks from './pages/Tasks'
import Profile from './pages/Profile'

function ProtectedRoutes() {
  return (
    <ProtectedLayout>
      <Outlet />
    </ProtectedLayout>
  )
}

export default function App() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100">
      <Routes>
        <Route path="/" element={<Navigate to="/login" replace />} />
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />

        {/* Protected Routes */}
        <Route path="/" element={<ProtectedRoutes />}>
          <Route path="dashboard" element={<Dashboard />} />
          <Route path="categories" element={<Categories />} />
          <Route path="users" element={<Users />} />
          <Route path="teams" element={<Teams />} />
          <Route path="reports" element={<ReportsList />} />
          <Route path="reports/new" element={<ReportsCreate />} />
          <Route path="reports/:id" element={<ReportsDetail />} />
          <Route path="tasks" element={<Tasks />} />
          <Route path="profile" element={<Profile />} />
        </Route>

        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </div>
  )
}