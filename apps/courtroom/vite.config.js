import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    // Bind the IPv4 loopback by name, not by Vite's default of "localhost".
    // On macOS "localhost" resolves through the system resolver and commonly
    // comes back as ::1 alone, so the dev server ends up listening on IPv6 only
    // and http://127.0.0.1:5173 is refused even though the port is plainly in
    // use. The engine's server already pins 127.0.0.1; this matches it.
    host: '127.0.0.1',
    port: 5173,
    // Fail loudly if 5173 is taken rather than quietly moving to 5174, which
    // produces the same "refused on 5173" symptom from a different cause.
    strictPort: true,
    // The courtroom GLB is ~105 MB; raise the payload ceiling so dev serving is happy.
    fs: { strict: false },
  },
  assetsInclude: ['**/*.glb'],
  build: {
    chunkSizeWarningLimit: 2000,
  },
})
