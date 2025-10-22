# Crear .gitignore en la raíz del proyecto
Set-Location "horse-race-game"

@'
# Dependencies
node_modules/
.pnp
.pnp.js

# Testing
coverage/
*.lcov

# Production builds
dist/
build/
*.tsbuildinfo

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
pnpm-debug.log*

# OS files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
Desktop.ini

# IDE/Editor files
.vscode/
.idea/
*.swp
*.swo
*.swn
*.bak
*.tmp
.project
.classpath
.c9/
*.launch
.settings/
*.sublime-workspace
*.sublime-project

# Yarn
.yarn/*
!.yarn/patches
!.yarn/plugins
!.yarn/releases
!.yarn/sdks
!.yarn/versions
.pnp.*

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Optional stylelint cache
.stylelintcache

# Microbundle cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Serverless directories
.serverless/

# Vite
.vite/

# Turbo
.turbo

# Vercel
.vercel

# TypeScript cache
*.tsbuildinfo

# Next.js
.next/
out/

# Nuxt.js
.nuxt
dist

# Gatsby files
.cache/
public

# Storybook build outputs
.out
.storybook-out
storybook-static

# Temporary folders
tmp/
temp/
'@ | Out-File -FilePath ".gitignore" -Encoding utf8

Write-Host "✅ .gitignore creado exitosamente!" -ForegroundColor Green
Write-Host ""
Write-Host "El archivo incluye:" -ForegroundColor Yellow
Write-Host "- node_modules y dependencias" -ForegroundColor Cyan
Write-Host "- Archivos de compilación (dist, build)" -ForegroundColor Cyan
Write-Host "- Variables de entorno (.env)" -ForegroundColor Cyan
Write-Host "- Logs y archivos temporales" -ForegroundColor Cyan
Write-Host "- Configuraciones de IDEs" -ForegroundColor Cyan
Write-Host "- Archivos del sistema operativo" -ForegroundColor Cyan
Write-Host "- Caché de Yarn, Vite y TypeScript" -ForegroundColor Cyan
