import { useEffect, type ReactNode } from 'react'
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import { AuthProvider, useAuth } from './lib/auth'
import { startProgressSync } from './lib/progress'
import { isConfigured } from './lib/supabase'
import LibraryPage from './pages/LibraryPage'
import LoginPage from './pages/LoginPage'
import ReaderPage from './pages/ReaderPage'

function RequireAuth({ children }: { children: ReactNode }) {
  const { session, loading } = useAuth()
  if (loading) return null
  if (!session) return <Navigate to="/login" replace />
  return children
}

export default function App() {
  useEffect(() => (isConfigured ? startProgressSync() : undefined), [])

  if (!isConfigured) {
    return (
      <main style={{ padding: 24 }}>
        <h1>Chưa cấu hình Supabase</h1>
        <p>Tạo file <code>.env.local</code> theo mẫu <code>.env.example</code> rồi chạy lại <code>npm run dev</code>.</p>
      </main>
    )
  }

  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/" element={<RequireAuth><LibraryPage /></RequireAuth>} />
          <Route path="/read/:bookId" element={<RequireAuth><ReaderPage /></RequireAuth>} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  )
}
