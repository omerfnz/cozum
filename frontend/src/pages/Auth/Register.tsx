import React, { useState } from 'react';
import { register as registerApi } from '../../lib/api';
import { Link, useNavigate } from 'react-router-dom';
import { Toaster, toast } from 'react-hot-toast';
import AuthLayout from './AuthLayout';

export default function Register() {
  const navigate = useNavigate();
  const [form, setForm] = useState({
    email: '',
    username: '',
    password: '',
    password_confirm: '',
  });
  const [loading, setLoading] = useState(false);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setForm((f) => ({ ...f, [name]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await registerApi({ ...form });
      toast.success('Kayıt başarılı! Giriş sayfasına yönlendiriliyorsunuz.');
      navigate('/login');
    } catch (err: unknown) {
      const error = err as { response?: { data?: unknown } };
      const detail = (error?.response?.data as string) ?? undefined;
      toast.error(typeof detail === 'string' ? detail : 'Kayıt başarısız');
    } finally {
      setLoading(false);
    }
  };

  return (
    <AuthLayout title="Kayıt Ol" subtitle="Birkaç adımda hesabınızı oluşturun">
      <Toaster position="top-right" />
      <form onSubmit={handleSubmit} className="space-y-5">
        <div className="space-y-2">
          <label htmlFor="username" className="block text-sm font-medium text-slate-700">
            Kullanıcı Adı
          </label>
          <div className="relative">
            <input
              id="username"
              name="username"
              type="text"
              required
              value={form.username}
              onChange={handleChange}
              className="peer block w-full rounded-xl border border-slate-200 bg-white/60 px-3.5 py-2.5 text-slate-900 shadow-sm outline-none transition focus:border-blue-500 focus:ring-4 focus:ring-blue-100"
              placeholder="ornek.kullanici"
            />
            <div className="pointer-events-none absolute inset-y-0 right-3.5 flex items-center text-slate-400">
              <svg className="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6.75a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.5 19.5a7.5 7.5 0 1115 0v.75a.75.75 0 01-.75.75h-13.5a.75.75 0 01-.75-.75v-.75z" />
              </svg>
            </div>
          </div>
        </div>

        <div className="space-y-2">
          <label htmlFor="email" className="block text-sm font-medium text-slate-700">
            E-posta Adresi
          </label>
          <div className="relative">
            <input
              id="email"
              name="email"
              type="email"
              autoComplete="email"
              required
              value={form.email}
              onChange={handleChange}
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
          <label htmlFor="password" className="block text-sm font-medium text-slate-700">
            Şifre
          </label>
          <div className="relative">
            <input
              id="password"
              name="password"
              type="password"
              autoComplete="new-password"
              required
              value={form.password}
              onChange={handleChange}
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

        <div className="space-y-2">
          <label htmlFor="confirmPassword" className="block text-sm font-medium text-slate-700">
            Şifre (Tekrar)
          </label>
          <div className="relative">
            <input
              id="password_confirm"
              name="password_confirm"
              type="password"
              autoComplete="new-password"
              required
              value={form.password_confirm}
              onChange={handleChange}
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
          disabled={Boolean(loading || (form.password && form.password_confirm && form.password !== form.password_confirm))}
          className="inline-flex w-full items-center justify-center gap-2 rounded-xl bg-blue-600 px-4 py-2.5 text-sm font-medium text-white shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-4 focus:ring-blue-100 disabled:opacity-50"
        >
          {loading ? 'Kayıt yapılıyor...' : 'Kayıt Ol'}
        </button>

        <div className="flex items-center justify-between text-xs text-slate-500">
          <span>Zaten hesabınız var mı?</span>
          <Link
            to="/login"
            className="text-blue-700 hover:text-blue-800 font-medium"
          >
            Giriş yapın
          </Link>
        </div>
      </form>
    </AuthLayout>
  );
}