# Navegar al proyecto
Set-Location "horse-race-game"

# 1. Agregar "type": "module" al package.json del frontend para usar ESM
@'
{
  "name": "frontend",
  "version": "1.0.0",
  "type": "module",
  "license": "MIT",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.45",
    "@types/react-dom": "^18.2.18",
    "@vitejs/plugin-react": "^4.2.1",
    "typescript": "^5.3.3",
    "vite": "^5.0.8"
  }
}
'@ | Out-File -FilePath "frontend/package.json" -Encoding utf8

# 2. Renombrar vite.config.ts a vite.config.mts para forzar ESM
Rename-Item -Path "frontend/vite.config.ts" -NewName "vite.config.mts" -Force

# 3. Actualizar tsconfig.node.json para incluir .mts
@'
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.mts"]
}
'@ | Out-File -FilePath "frontend/tsconfig.node.json" -Encoding utf8

# 4. Crear un archivo postcss.config.cjs vacío para evitar el error
@'
module.exports = {
  plugins: []
};
'@ | Out-File -FilePath "frontend/postcss.config.cjs" -Encoding utf8

Write-Host "✅ Configuración corregida!" -ForegroundColor Green
Write-Host ""
Write-Host "Ahora ejecuta:" -ForegroundColor Yellow
Write-Host "yarn build" -ForegroundColor Cyan
