import React, { useState } from 'react';
import { login, setAuthTokens, me } from '../../lib/api';
import { Link, useNavigate } from 'react-router-dom';
import { Toaster, toast } from 'react-hot-toast';
import AuthLayout from './AuthLayout';

export default function Login() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const { access, refresh } = await login({ email, password });
      setAuthTokens(access, refresh);
      const profile = await me();
      toast.success(`Hoş geldin, ${profile?.username || profile?.email}`);
      navigate('/dashboard');
    } catch (err: unknown) {
      const error = err as { response?: { data?: { detail?: string } } };
      toast.error(error?.response?.data?.detail || 'Giriş başarısız');
    } finally {
      setLoading(false);
    }
  };

  return (
    <AuthLayout title="Giriş Yap" subtitle="Hesabınıza erişim sağlayın">
      <Toaster position="top-right" />
      <form onSubmit={handleSubmit} className="space-y-5">
        <div className="space-y-2">
          <label
            htmlFor="email"
            className="block text-sm font-medium text-slate-700"
          >
            E-posta Adresi
          </label>
          <div className="relative">
            <input
              id="email"
              name="email"
              type="email"
              autoComplete="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="peer block w-full rounded-xl border border-slate-200 bg-white/60 px-3.5 py-2.5 text-slate-900 shadow-sm outline-none transition focus:border-blue-500 focus:ring-4 focus:ring-blue-100"
              placeholder="ornek@firma.com"
            />
            <div className="pointer-events-none absolute inset-y-0 right-3.5 flex items-center text-slate-400">
              <svg className="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                <path strokeLinecap="round" strokeLinejoin="round" d="M21.75 7.5l-9-4.5-9 4.5M3 8.25l9 4.5 9-4.5M3 8.25V16.5l9 4.5 9-4.5V8.25" />
              </svg>
            </div>
          </div>
        </div>

        <div className="space-y-2">
          <label
            htmlFor="password"
            className="block text-sm font-medium text-slate-700"
          >
            Şifre
          </label>
          <div className="relative">
            <input
              id="password"
              name="password"
              type="password"
              autoComplete="current-password"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="peer block w-full rounded-xl border border-slate-200 bg-white/60 px-3.5 py-2.5 text-slate-900 shadow-sm outline-none transition focus:border-blue-500 focus:ring-4 focus:ring-blue-100"
              placeholder="••••••••"
            />
            <div className="pointer-events-none absolute inset-y-0 right-3.5 flex items-center text-slate-400">
              <svg className="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                <path strokeLinecap="round" strokeLinejoin="round" d="M16.5 10.5V7.5a4.5 4.5 0 10-9 0v3m-.75 0h10.5c.621 0 1.125.504 1.125 1.125v7.5c0 .621-.504 1.125-1.125 1.125H6.75A1.125 1.125 0 015.625 19.125v-7.5C5.625 11.004 6.129 10.5 6.75 10.5z" />
              </svg>
            </div>
          </div>
        </div>

        <button
          type="submit"
          disabled={loading}
          className="inline-flex w-full items-center justify-center gap-2 rounded-xl bg-blue-600 px-4 py-2.5 text-sm font-medium text-white shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-4 focus:ring-blue-100 disabled:opacity-50"
        >
          {loading ? 'Giriş yapılıyor...' : 'Giriş Yap'}
        </button>

        <div className="flex items-center justify-between text-xs text-slate-500">
          <span>Hesabınız yok mu?</span>
          <Link
            to="/register"
            className="text-blue-700 hover:text-blue-800 font-medium"
          >
            Yeni hesap oluşturun
          </Link>
        </div>
      </form>
    </AuthLayout>
  );
}