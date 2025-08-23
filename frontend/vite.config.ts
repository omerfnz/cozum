import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://3.126.55.85:3000',
        changeOrigin: true,
      },
      '/auth': {
        target: 'http://3.126.55.85:3000',
        changeOrigin: true,
      },
    },
  },
})