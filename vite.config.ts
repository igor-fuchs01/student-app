import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "node:path";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@app": path.resolve(import.meta.dirname, "./src/app"),
      "@components": path.resolve(import.meta.dirname, "./src/components"),
      "@features": path.resolve(import.meta.dirname, "./src/features"),
      "@services": path.resolve(import.meta.dirname, "./src/services"),
      "@styles": path.resolve(import.meta.dirname, "./src/styles"),
      "@models": path.resolve(import.meta.dirname, "./src/types"),
      "@utils": path.resolve(import.meta.dirname, "./src/utils"),
    },
  },
  server: {
    port: 5173,
  },
});
