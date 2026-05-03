#!/usr/bin/env bash
#
# scripts/security/check-secret-patterns.sh
# ─────────────────────────────────────────────────────────────────────────
# Claude Code PreToolUse hook (Edit|Write matcher).
# Yazılacak içerikte secret pattern'leri yakalar, exit 2 ile bloklar.
#
# Referans: .claude/settings.json → hooks.PreToolUse.Edit|Write
# ─────────────────────────────────────────────────────────────────────────

set -euo pipefail

INPUT="$(cat)"

# tool_input içinden file_path ve içerik çek
if command -v jq >/dev/null 2>&1; then
  FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')"
  # Edit'te new_string, Write'da content
  CONTENT="$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty')"
else
  FILE_PATH="$(echo "$INPUT" | grep -oE '"(file_path|path)"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"[^"]*"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')"
  CONTENT=""
fi

[[ -z "${FILE_PATH:-}" ]] && exit 0

block() {
  echo "BLOCKED: $1" >&2
  echo "Dosya: $FILE_PATH" >&2
  echo "Pattern: $2" >&2
  echo "Çözüm: secret'ı .env veya secrets manager'da tut, kodda referans ver" >&2
  exit 2
}

# ─── Dosya path bloku: .env doğrudan edit yasak ───
if echo "$FILE_PATH" | grep -qE '(^|/)\.env($|\.[a-z]+)'; then
  block ".env dosyası doğrudan edit yasak" ".env path"
fi

# ─── Content yoksa (jq yok veya extract edilmedi) skip ───
[[ -z "$CONTENT" ]] && exit 0

# ─── Secret pattern'leri ───
# Kaynak: TruffleHog + gitleaks default rules

# AWS Access Key ID
if echo "$CONTENT" | grep -qE '\bAKIA[0-9A-Z]{16}\b'; then
  block "AWS Access Key ID tespit edildi" "AKIA..."
fi

# AWS Secret Access Key (40 char base64'lı)
if echo "$CONTENT" | grep -qE 'aws_secret_access_key[[:space:]]*[=:][[:space:]]*[\"\x27]?[A-Za-z0-9/+=]{40}[\"\x27]?'; then
  block "AWS Secret Access Key tespit edildi" "aws_secret_access_key=..."
fi

# GitHub Personal Access Token (classic + fine-grained)
if echo "$CONTENT" | grep -qE '\bghp_[A-Za-z0-9]{36}\b|\bgithub_pat_[A-Za-z0-9_]{82}\b'; then
  block "GitHub Personal Access Token tespit edildi" "ghp_... veya github_pat_..."
fi

# GitHub OAuth tokens
if echo "$CONTENT" | grep -qE '\bgho_[A-Za-z0-9]{36}\b|\bghu_[A-Za-z0-9]{36}\b|\bghs_[A-Za-z0-9]{36}\b|\bghr_[A-Za-z0-9]{36}\b'; then
  block "GitHub OAuth/server token tespit edildi" "gho_/ghu_/ghs_/ghr_..."
fi

# Slack tokens
if echo "$CONTENT" | grep -qE '\bxox[pboa]-[0-9]+-[0-9]+(-[0-9]+)?-[a-zA-Z0-9]+\b'; then
  block "Slack token tespit edildi" "xox..."
fi

# Stripe live keys (sk_live, pk_live, rk_live)
if echo "$CONTENT" | grep -qE '\b(sk|rk)_live_[A-Za-z0-9]{24,}\b'; then
  block "Stripe live secret/restricted key tespit edildi" "sk_live_..."
fi

# Generic API key pattern (api_key="..." veya apiKey: "...")
if echo "$CONTENT" | grep -qiE '\b(api[_-]?key|apikey|secret[_-]?key|access[_-]?token|auth[_-]?token)["\x27]?[[:space:]]*[=:][[:space:]]*["\x27][A-Za-z0-9_\-]{32,}["\x27]'; then
  # Process.env kullanımı veya placeholder ise atla
  if ! echo "$CONTENT" | grep -qE 'process\.env|import\.meta\.env|REPLACE_ME|YOUR_KEY|<.*>|\$\{|XXX'; then
    block "Hardcoded API key/token tespit edildi (32+ char)" "api_key=\"...\""
  fi
fi

# Private keys (RSA, OpenSSH, EC)
if echo "$CONTENT" | grep -qE '-----BEGIN (RSA |OPENSSH |EC |DSA |PGP |ENCRYPTED )?PRIVATE KEY-----'; then
  block "Private key tespit edildi" "-----BEGIN ... PRIVATE KEY-----"
fi

# JWT (3 base64-like parts separated by dots, hardcoded)
if echo "$CONTENT" | grep -qE '\beyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{20,}\b'; then
  # Test/example JWT'leri için biraz tolerans — placeholder'lar geçer
  if ! echo "$CONTENT" | grep -qE 'example|test|sample|fake|mock'; then
    block "Hardcoded JWT tespit edildi" "eyJ...eyJ...."
  fi
fi

# Google API Key
if echo "$CONTENT" | grep -qE '\bAIza[0-9A-Za-z\-_]{35}\b'; then
  block "Google API key tespit edildi" "AIza..."
fi

# Generic high-entropy in obvious places
# (örn. password = "abc123" gibi sade string'leri yakalamıyoruz — false positive çok)
# Ama şüpheli pattern: "password" : "<32+ random chars>"
if echo "$CONTENT" | grep -qiE 'password["\x27]?[[:space:]]*[=:][[:space:]]*["\x27][A-Za-z0-9!@#$%^&*]{32,}["\x27]'; then
  if ! echo "$CONTENT" | grep -qE 'process\.env|REPLACE|YOUR_|<|\$\{|hash|crypt|bcrypt|argon'; then
    block "Hardcoded uzun password tespit edildi" "password=\"...\""
  fi
fi

exit 0
