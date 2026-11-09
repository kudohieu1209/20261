// PLACEHOLDER UI — agy thiết kế lại phần trình bày, giữ nguyên logic (signIn, chuyển trang).
import { useState, type FormEvent } from 'react'
import { Navigate } from 'react-router-dom'
import { signIn, useAuth } from '../lib/auth'

export default function LoginPage() {
  const { session } = useAuth()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  if (session) return <Navigate to="/" replace />

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault()
    setBusy(true)
    setError(null)
    try {
      await signIn(email, password)
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setBusy(false)
    }
  }

  return (
    <main>
      <h1>Đọc sách</h1>
      <form onSubmit={onSubmit}>
        <input type="email" autoComplete="email" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} required />
        <input type="password" autoComplete="current-password" placeholder="Mật khẩu" value={password} onChange={(e) => setPassword(e.target.value)} required />
        <button type="submit" disabled={busy}>{busy ? 'Đang đăng nhập…' : 'Đăng nhập'}</button>
        {error && <p role="alert">{error}</p>}
      </form>
    </main>
  )
}
