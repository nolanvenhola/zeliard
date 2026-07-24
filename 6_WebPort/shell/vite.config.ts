import { defineConfig } from 'vite';
import { resolve } from 'node:path';

export default defineConfig({
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
        rollupOptions: {
            input: {
                webport: resolve(__dirname, 'index.html'),
                masmReference: resolve(__dirname, 'hybrid.html'),
            },
        },
    },
});
