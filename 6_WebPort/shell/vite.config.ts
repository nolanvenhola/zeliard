import { defineConfig } from 'vite';

export default defineConfig({
    base: process.env.VITE_BASE_PATH ?? '/',
    server: {
        port: 5173,
        strictPort: true,
        headers: {
            'Cache-Control': 'no-store, max-age=0',
        },
        fs: {
            // Allow serving the engine build output that lives outside shell/.
            allow: ['..'],
        },
    },
    optimizeDeps: {
        // The Emscripten-generated module imports itself dynamically; keep
        // Vite from trying to pre-bundle it.
        exclude: ['../engine/build/zeliard.js'],
    },
    build: {
        target: 'es2022',
        outDir: 'dist',
    },
});
