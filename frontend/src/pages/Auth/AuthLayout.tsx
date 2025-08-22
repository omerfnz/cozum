import React from 'react';

interface AuthLayoutProps {
  title: string;
  subtitle: string;
  children: React.ReactNode;
}

const AuthLayout: React.FC<AuthLayoutProps> = ({ title, subtitle, children }) => {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100">
      <div className="mx-auto max-w-7xl min-h-screen grid grid-cols-1 md:grid-cols-2">
        {/* Sol marka paneli */}
        <div className="hidden md:flex relative items-center justify-center p-10 bg-gradient-to-br from-blue-600 to-indigo-700 text-white overflow-hidden">
          {/* Dekoratif grid desen */}
          <svg className="absolute inset-0 h-full w-full opacity-10" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="none">
            <defs>
              <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
                <path d="M 40 0 L 0 0 0 40" fill="none" stroke="currentColor" strokeWidth="0.5" />
              </pattern>
            </defs>
            <rect width="100%" height="100%" fill="url(#grid)" />
          </svg>

          <div className="relative z-10 max-w-md">
            <div className="flex items-center gap-3">
              <div className="h-12 w-12 rounded-xl bg-white/15 backdrop-blur-sm grid place-items-center">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" className="h-7 w-7">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v12m6-6H6" />
                </svg>
              </div>
              <div>
                <p className="text-sm/5 text-blue-100">Kurumsal Platform</p>
                <h3 className="text-xl font-semibold tracking-tight">Çözüm Var</h3>
              </div>
            </div>
            <p className="mt-6 text-blue-50/90">
              Güvenli, hızlı ve modern arayüz ile günlük operasyonlarınızı kolaylaştırın. Tüm süreçler tek çatı altında.
            </p>
            <div className="mt-8 grid grid-cols-2 gap-4">
              {[
                { label: 'Kurumsal Güvenlik' },
                { label: 'Merkezi Yönetim' },
                { label: 'Raporlama' },
                { label: 'Erişilebilirlik' },
              ].map((i) => (
                <div key={i.label} className="flex items-center gap-2 text-blue-100/90">
                  <span className="inline-flex h-5 w-5 items-center justify-center rounded-full bg-white/15">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="h-3.5 w-3.5">
                      <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-7.5 7.5a1 1 0 01-1.414 0l-3-3a1 1 0 111.414-1.414L8.5 12.086l6.793-6.793a1 1 0 011.414 0z" clipRule="evenodd" />
                    </svg>
                  </span>
                  <span className="text-sm">{i.label}</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Sağ form paneli */}
        <div className="flex items-center justify-center p-6 md:p-10">
          <div className="w-full max-w-md">
            <div className="mb-8 text-center">
              <div className="mx-auto h-12 w-12 rounded-xl bg-blue-600/10 text-blue-600 grid place-items-center">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" className="h-7 w-7">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v12m6-6H6" />
                </svg>
              </div>
              <h1 className="mt-4 text-2xl font-semibold tracking-tight text-slate-900">{title}</h1>
              <p className="mt-1 text-sm text-slate-600">{subtitle}</p>
            </div>

            <div className="bg-white/80 backdrop-blur-sm border border-slate-200 rounded-2xl shadow-lg p-6 md:p-8">
              {children}
            </div>

            <p className="mt-6 text-center text-xs text-slate-500">
              Devam ederek Kullanım Koşulları ve Gizlilik Politikasını kabul etmiş olursunuz.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AuthLayout;