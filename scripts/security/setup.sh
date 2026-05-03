#!/usr/bin/env bash
#
# scripts/security/setup.sh
# ─────────────────────────────────────────────────────────────────────────
# Tek seferlik güvenlik kurulum scripti.
#
# Felsefe:
#   - Idempotent: kurulu olanı atlar, eksiği ekler
#   - Stack-agnostic ama Next.js + TypeScript için optimize
#   - macOS + Linux destekli (Windows için WSL kullan)
#   - Production secret veya AWS credential üretmez (manuel iş)
#
# Kullanım:
#   bash scripts/security/setup.sh         # standart kurulum
#   bash scripts/security/setup.sh --force # mevcut config'leri yeniden yaz
#   bash scripts/security/setup.sh --skip-globals  # sadece project-level
#
# Detay: docs/security/01-phase-1-project-kickoff.md
# ─────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ─── Renkler ───
if [[ -t 1 ]]; then
  RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'; BLU='\033[0;34m'; DIM='\033[2m'; RST='\033[0m'
else
  RED=''; GRN=''; YLW=''; BLU=''; DIM=''; RST=''
fi

ok()    { printf "${GRN}✓${RST} %s\n" "$*"; }
skip()  { printf "${DIM}↷ %s${RST}\n" "$*"; }
info()  { printf "${BLU}→${RST} %s\n" "$*"; }
warn()  { printf "${YLW}⚠${RST} %s\n" "$*"; }
fail()  { printf "${RED}✗${RST} %s\n" "$*" >&2; }
header(){ printf "\n${BLU}━━━ %s ━━━${RST}\n" "$*"; }

# ─── Argümanlar ───
FORCE=0
SKIP_GLOBALS=0
SKIP_NPM=0
for arg in "$@"; do
  case "$arg" in
    --force)         FORCE=1 ;;
    --skip-globals)  SKIP_GLOBALS=1 ;;
    --skip-npm)      SKIP_NPM=1 ;;
    --help|-h)
      sed -n '3,18p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
  esac
done

# ─── Repo root tespit ───
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"
info "Repo: $REPO_ROOT"

# ─── OS tespit ───
OS="$(uname -s)"
case "$OS" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
  *)      fail "Desteklenmeyen OS: $OS (macOS veya Linux gerekli)"; exit 1 ;;
esac
info "Platform: $PLATFORM"

# ─── Helpers ───
has_cmd() { command -v "$1" >/dev/null 2>&1; }

confirm() {
  # confirm "prompt" → varsayılan Y
  local prompt="${1:-Devam edilsin mi?}"
  read -r -p "$(printf "${YLW}?${RST} %s [Y/n]: " "$prompt")" reply
  [[ -z "$reply" || "$reply" =~ ^[Yy] ]]
}

write_if_missing() {
  # write_if_missing path "content"
  local path="$1"
  local content="$2"
  if [[ -f "$path" && $FORCE -eq 0 ]]; then
    skip "$path zaten var (--force ile yeniden yazılır)"
    return
  fi
  mkdir -p "$(dirname "$path")"
  printf "%s" "$content" > "$path"
  ok "$path yazıldı"
}

# ─── Pre-flight: zorunlu araçlar ───
header "Pre-flight kontrol"

if ! has_cmd git; then fail "git yok — önce git yükle"; exit 1; fi
ok "git: $(git --version | awk '{print $3}')"

if ! has_cmd node; then
  fail "node yok — Node.js LTS (20+) gerekli. https://nodejs.org veya nvm ile kur."
  exit 1
fi
NODE_MAJ="$(node -v | sed 's/v\([0-9]*\).*/\1/')"
if (( NODE_MAJ < 20 )); then
  warn "Node $NODE_MAJ tespit edildi — 20+ önerilir (LTS). Devam ediliyor."
fi
ok "node: $(node -v)"

# Package manager tespit
PM="npm"
if [[ -f "pnpm-lock.yaml" ]]; then PM="pnpm";
elif [[ -f "yarn.lock" ]]; then PM="yarn";
fi
ok "Package manager: $PM"

# ─── Step 1: Global araçlar ───
if [[ $SKIP_GLOBALS -eq 0 ]]; then
  header "Global güvenlik araçları"

  install_via_pkgmgr() {
    # install_via_pkgmgr <command-name> <macos-brew-name> <linux-apt-name>
    local cmd="$1" brew_pkg="$2" apt_pkg="$3"
    if has_cmd "$cmd"; then
      ok "$cmd zaten kurulu ($($cmd --version 2>&1 | head -1 | tr -d '\n'))"
      return
    fi
    info "$cmd kurulmamış — kurulum deneniyor..."
    if [[ "$PLATFORM" == "macos" ]]; then
      if has_cmd brew; then
        brew install "$brew_pkg" && ok "$cmd kuruldu (brew)"
      else
        warn "Homebrew yok. Manuel kur: brew install $brew_pkg veya $cmd resmi kurulumu"
      fi
    elif [[ "$PLATFORM" == "linux" ]]; then
      if has_cmd apt-get; then
        if confirm "sudo apt-get install -y $apt_pkg çalıştırılsın mı?"; then
          sudo apt-get update -qq && sudo apt-get install -y "$apt_pkg" && ok "$cmd kuruldu (apt)"
        else
          skip "$cmd kurulumu atlandı — manuel kur"
        fi
      else
        warn "apt-get yok. $cmd manuel kur."
      fi
    fi
  }

  # gitleaks — secret scanning
  install_via_pkgmgr "gitleaks" "gitleaks" "gitleaks"

  # jq — JSON parser (hooks ve scriptler için)
  install_via_pkgmgr "jq" "jq" "jq"

  # trivy — container/IaC scan (opsiyonel ama önerilir)
  if has_cmd trivy; then
    ok "trivy zaten kurulu"
  else
    info "trivy kurulmamış (opsiyonel — Dockerfile veya IaC scan için)"
    if [[ "$PLATFORM" == "macos" ]] && has_cmd brew; then
      if confirm "trivy kurulsun mu?"; then
        brew install aquasecurity/trivy/trivy && ok "trivy kuruldu"
      fi
    else
      skip "trivy manuel kur: https://aquasecurity.github.io/trivy/latest/getting-started/installation/"
    fi
  fi

  # semgrep — SAST (Python ile)
  if has_cmd semgrep; then
    ok "semgrep zaten kurulu"
  else
    info "semgrep kurulmamış (önerilir — SAST scanning)"
    if has_cmd pip3; then
      if confirm "pip3 install --user semgrep çalıştırılsın mı?"; then
        pip3 install --user semgrep && ok "semgrep kuruldu (pip3 --user)"
      fi
    elif has_cmd brew && [[ "$PLATFORM" == "macos" ]]; then
      if confirm "brew install semgrep çalıştırılsın mı?"; then
        brew install semgrep && ok "semgrep kuruldu"
      fi
    else
      skip "semgrep manuel kur: https://semgrep.dev/docs/getting-started/"
    fi
  fi

  # Claude Code (opsiyonel; npm i -g)
  if has_cmd claude; then
    ok "claude (Claude Code) zaten kurulu"
  else
    info "claude (Claude Code) kurulmamış"
    if confirm "$PM ile global Claude Code kurulsun mu (@anthropic-ai/claude-code)?"; then
      case "$PM" in
        npm)  npm install -g @anthropic-ai/claude-code ;;
        yarn) yarn global add @anthropic-ai/claude-code ;;
        pnpm) pnpm add -g @anthropic-ai/claude-code ;;
      esac
      ok "Claude Code kuruldu"
    else
      skip "Claude Code kurulumu atlandı"
    fi
  fi

  # Prowler (opsiyonel, AWS account scanning)
  if has_cmd prowler; then
    ok "prowler zaten kurulu"
  else
    skip "prowler kurulmamış (opsiyonel — AWS hesabı tarama için ileri seviye). pip3 install --user prowler"
  fi
else
  skip "Global araçlar atlandı (--skip-globals)"
fi

# ─── Step 2: package.json kontrol ───
header "Project package.json"

if [[ ! -f "package.json" ]]; then
  warn "package.json yok"
  if confirm "$PM init -y çalıştırılsın mı?"; then
    case "$PM" in
      npm)  npm init -y >/dev/null ;;
      yarn) yarn init -y >/dev/null ;;
      pnpm) pnpm init >/dev/null ;;
    esac
    ok "package.json oluşturuldu"
  else
    fail "package.json gerekli — script durdu"
    exit 1
  fi
fi

# ─── Step 3: NPM dev dependencies ───
if [[ $SKIP_NPM -eq 0 ]]; then
  header "Dev dependencies (project-level)"

  # Hangileri zaten kurulu kontrol et
  declare -a TO_INSTALL=()

  check_dep() {
    local pkg="$1"
    if jq -e ".devDependencies[\"$pkg\"] // .dependencies[\"$pkg\"]" package.json >/dev/null 2>&1; then
      ok "$pkg zaten yüklü"
    else
      TO_INSTALL+=("$pkg")
    fi
  }

  # Core security/quality dev deps
  check_dep "husky"
  check_dep "lint-staged"
  check_dep "@cyclonedx/cyclonedx-npm"
  check_dep "license-checker"
  check_dep "prettier"
  check_dep "eslint"
  check_dep "eslint-plugin-security"

  # TypeScript
  if jq -e '.devDependencies["typescript"] // .dependencies["typescript"]' package.json >/dev/null 2>&1; then
    ok "typescript zaten yüklü"
    check_dep "@typescript-eslint/parser"
    check_dep "@typescript-eslint/eslint-plugin"
  else
    info "typescript kurulu değil — TS projesi mi? (önerilen)"
    if confirm "typescript ve TS dev deps kurulsun mu?"; then
      TO_INSTALL+=("typescript" "@types/node" "@typescript-eslint/parser" "@typescript-eslint/eslint-plugin")
    fi
  fi

  # Next.js detect
  if jq -e '.dependencies["next"]' package.json >/dev/null 2>&1; then
    ok "Next.js projesi tespit edildi"
    check_dep "eslint-config-next"
  fi

  if (( ${#TO_INSTALL[@]} > 0 )); then
    info "Kurulacaklar: ${TO_INSTALL[*]}"
    if confirm "Şimdi kurulsun mu?"; then
      case "$PM" in
        npm)  npm install --save-dev "${TO_INSTALL[@]}" ;;
        yarn) yarn add --dev "${TO_INSTALL[@]}" ;;
        pnpm) pnpm add -D "${TO_INSTALL[@]}" ;;
      esac
      ok "Dev dependencies kuruldu"
    else
      skip "Dev dependencies atlandı"
    fi
  else
    ok "Tüm dev dependencies hazır"
  fi
else
  skip "NPM dev deps atlandı (--skip-npm)"
fi

# ─── Step 4: Dotfiles (idempotent — sadece eksikse yaz) ───
header "Dotfiles & config"

# .gitignore
if [[ ! -f ".gitignore" ]] || [[ $FORCE -eq 1 ]]; then
  if [[ -f "templates/.gitignore.template" ]]; then
    cp templates/.gitignore.template .gitignore
    ok ".gitignore yazıldı (template'ten)"
  fi
else
  # Mevcut .gitignore'da kritik girdiler var mı kontrol
  REQUIRED_IGNORES=(".env" ".env.local" ".env.production" "node_modules" ".DS_Store" "*.log")
  MISSING=()
  for entry in "${REQUIRED_IGNORES[@]}"; do
    grep -qF "$entry" .gitignore || MISSING+=("$entry")
  done
  if (( ${#MISSING[@]} > 0 )); then
    warn ".gitignore'a eksik girdiler eklenecek: ${MISSING[*]}"
    {
      echo ""
      echo "# Added by secure-platform-starter setup"
      printf "%s\n" "${MISSING[@]}"
    } >> .gitignore
    ok ".gitignore güncellendi"
  else
    ok ".gitignore tamam"
  fi
fi

# .gitleaks.toml
if [[ ! -f ".gitleaks.toml" ]] || [[ $FORCE -eq 1 ]]; then
  [[ -f "templates/.gitleaks.toml.template" ]] && cp templates/.gitleaks.toml.template .gitleaks.toml && ok ".gitleaks.toml yazıldı"
else
  ok ".gitleaks.toml tamam"
fi

# .editorconfig
if [[ ! -f ".editorconfig" ]] || [[ $FORCE -eq 1 ]]; then
  [[ -f "templates/.editorconfig.template" ]] && cp templates/.editorconfig.template .editorconfig && ok ".editorconfig yazıldı"
else
  ok ".editorconfig tamam"
fi

# .nvmrc
if [[ ! -f ".nvmrc" ]] || [[ $FORCE -eq 1 ]]; then
  echo "20" > .nvmrc
  ok ".nvmrc yazıldı (Node 20)"
else
  ok ".nvmrc tamam"
fi

# .prettierrc
if [[ ! -f ".prettierrc" ]] && [[ ! -f ".prettierrc.json" ]] && [[ ! -f ".prettierrc.js" ]]; then
  [[ -f "templates/.prettierrc.template" ]] && cp templates/.prettierrc.template .prettierrc && ok ".prettierrc yazıldı"
else
  ok ".prettierrc tamam"
fi

# .eslintrc.cjs (sadece config yoksa — Next.js zaten eslint config oluşturuyor)
if [[ ! -f ".eslintrc.cjs" ]] && [[ ! -f ".eslintrc.json" ]] && [[ ! -f ".eslintrc.js" ]] && [[ ! -f "eslint.config.js" ]] && [[ ! -f "eslint.config.mjs" ]]; then
  [[ -f "templates/.eslintrc.cjs.template" ]] && cp templates/.eslintrc.cjs.template .eslintrc.cjs && ok ".eslintrc.cjs yazıldı"
else
  ok "ESLint config zaten var"
fi

# SECURITY.md
if [[ ! -f "SECURITY.md" ]] || [[ $FORCE -eq 1 ]]; then
  [[ -f "templates/SECURITY.md.template" ]] && cp templates/SECURITY.md.template SECURITY.md && ok "SECURITY.md yazıldı"
else
  ok "SECURITY.md tamam"
fi

# ─── Step 5: Husky pre-commit ───
header "Pre-commit hooks (Husky)"

if [[ -d ".husky" ]] && [[ -f ".husky/pre-commit" ]]; then
  ok ".husky/pre-commit zaten kurulu"
else
  if jq -e '.devDependencies["husky"]' package.json >/dev/null 2>&1; then
    npx husky init >/dev/null 2>&1 || true
    cat > .husky/pre-commit <<'HUSKY_EOF'
#!/usr/bin/env sh
# Pre-commit security checks
# Detay: docs/security/02-phase-2-coding-rules.md

set -e

# 1. Lint-staged (Prettier + ESLint sadece staged dosyalarda)
if [ -f "node_modules/.bin/lint-staged" ]; then
  npx lint-staged
fi

# 2. Type check (hızlı, incremental)
if [ -f "node_modules/.bin/tsc" ]; then
  npx tsc --noEmit --incremental || {
    echo "✗ TypeScript hataları var — commit iptal"
    exit 1
  }
fi

# 3. Secret scan (gitleaks varsa)
if command -v gitleaks >/dev/null 2>&1; then
  gitleaks protect --staged --no-banner || {
    echo "✗ Secret tespit edildi — commit iptal"
    echo "  False positive ise .gitleaks.toml içine allow ekle"
    exit 1
  }
fi

echo "✓ Pre-commit checks passed"
HUSKY_EOF
    chmod +x .husky/pre-commit
    ok "Husky pre-commit hook kuruldu"
  else
    warn "Husky yüklü değil — atlandı"
  fi
fi

# lint-staged config (package.json içinde)
if ! jq -e '.["lint-staged"]' package.json >/dev/null 2>&1; then
  if jq -e '.devDependencies["lint-staged"]' package.json >/dev/null 2>&1; then
    info "lint-staged config eklenecek"
    # jq ile package.json'a ekle
    tmp="$(mktemp)"
    jq '. + {
      "lint-staged": {
        "*.{js,jsx,ts,tsx}": ["eslint --fix", "prettier --write"],
        "*.{json,md,yml,yaml}": ["prettier --write"]
      }
    }' package.json > "$tmp" && mv "$tmp" package.json
    ok "lint-staged config eklendi"
  fi
else
  ok "lint-staged config zaten var"
fi

# ─── Step 6: NPM scripts (yardımcılar) ───
header "NPM scripts"

add_script_if_missing() {
  local name="$1" cmd="$2"
  if jq -e ".scripts[\"$name\"]" package.json >/dev/null 2>&1; then
    ok "script '$name' zaten var"
  else
    tmp="$(mktemp)"
    jq ".scripts[\"$name\"] = \"$cmd\"" package.json > "$tmp" && mv "$tmp" package.json
    ok "script '$name' eklendi"
  fi
}

add_script_if_missing "sec:audit"    "npm audit --audit-level=high"
add_script_if_missing "sec:secrets"  "gitleaks detect --no-banner"
add_script_if_missing "sec:licenses" "license-checker --summary"
add_script_if_missing "sec:sbom"     "cyclonedx-npm --output-file docs/security/evidence/16-sbom-current.json"
add_script_if_missing "sec:all"      "npm run sec:audit && npm run sec:secrets && npm run sec:licenses"

# ─── Step 7: Hook scriptleri executable yap ───
header "Hook scripts"

for hook in scripts/security/validate-bash-command.sh scripts/security/check-secret-patterns.sh; do
  if [[ -f "$hook" ]]; then
    chmod +x "$hook"
    ok "$hook executable"
  else
    skip "$hook yok (.claude/settings.json hook'tan referans veriyor — repo'dan eksiksiz kopyala)"
  fi
done

# ─── Step 8: Evidence klasörü ───
header "Evidence directory"
mkdir -p docs/security/evidence
[[ ! -f "docs/security/evidence/.gitkeep" ]] && touch docs/security/evidence/.gitkeep
ok "docs/security/evidence/ hazır"

# ─── Final özet ───
header "Kurulum özeti"

cat <<EOF

${GRN}✓ Setup tamamlandı.${RST}

Sonraki adımlar:

  1. ${BLU}CLAUDE.md${RST} içindeki <<TUTUCU>> alanlarını projeye göre doldur
  2. ${BLU}docs/security/01-phase-1-project-kickoff.md${RST} checklist'ini takip et
  3. ${BLU}npm run sec:all${RST} ile mevcut durumu görüntüle
  4. ${BLU}.github/workflows/security.yml${RST}'i projene uyarla, push et
  5. GitHub repo settings → ${BLU}Branch protection${RST} aktifleştir

İlerleyen turlarda yeni kurulum gerekli olmayacak.
Yeni paket eklemen gerekirse: ${BLU}$PM add <paket>${RST}.

Detay: ${DIM}docs/security/04-master-checklist.md${RST}

EOF
