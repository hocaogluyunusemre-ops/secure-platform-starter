#!/usr/bin/env bash
#
# scripts/security/validate-bash-command.sh
# ─────────────────────────────────────────────────────────────────────────
# Claude Code PreToolUse hook (Bash matcher).
# Tehlikeli pattern'leri yakalar, exit 2 ile bloklar.
#
# Referans: .claude/settings.json → hooks.PreToolUse.Bash
# Detay:    https://code.claude.com/docs/en/hooks
# ─────────────────────────────────────────────────────────────────────────

set -euo pipefail

# Claude Code, hook'a JSON'u stdin'den geçirir.
INPUT="$(cat)"

# Komut tool_input.command alanında
# jq yoksa basic regex'e düş
if command -v jq >/dev/null 2>&1; then
  CMD="$(echo "$INPUT" | jq -r '.tool_input.command // empty')"
else
  CMD="$(echo "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/')"
fi

# Boşsa geç
[[ -z "${CMD:-}" ]] && exit 0

block() {
  echo "BLOCKED: $1" >&2
  echo "Komut: $CMD" >&2
  echo "Bu kontrolü bypass etmek için: kullanıcı manuel olarak terminalde çalıştırmalı." >&2
  exit 2
}

# ─── Bloklanan pattern'ler ───

# 1. Recursive force delete root-near
if echo "$CMD" | grep -qE '\brm[[:space:]]+(-[A-Za-z]*[rRf]+[A-Za-z]*[[:space:]]+|-[rRf]+[[:space:]]+)*(/|/\*|\$HOME|~|/etc|/var|/usr|/opt|node_modules)'; then
  if echo "$CMD" | grep -qE '\brm[[:space:]]+-[A-Za-z]*[rRf]+[A-Za-z]*[[:space:]]+(/|/\*|~|\$HOME)([[:space:]]|$)'; then
    block "rm -rf root-near directories yasak"
  fi
fi

# 2. Force push to main/master/develop
if echo "$CMD" | grep -qE 'git[[:space:]]+push[[:space:]]+.*(--force|--force-with-lease|-f)\b' && \
   echo "$CMD" | grep -qE '\b(main|master|develop|production)\b'; then
  block "Korumalı branch'e force push yasak"
fi

# 3. AWS yıkıcı komutlar
if echo "$CMD" | grep -qE 'aws[[:space:]]+(s3[[:space:]]+rb|iam[[:space:]]+delete|ec2[[:space:]]+terminate-instances|rds[[:space:]]+delete-db|kms[[:space:]]+schedule-key-deletion)'; then
  block "Yıkıcı AWS komutu — kullanıcı kendisi çalıştırmalı"
fi

# 4. Terraform destroy
if echo "$CMD" | grep -qE 'terraform[[:space:]]+destroy'; then
  block "terraform destroy — kullanıcı kendisi çalıştırmalı"
fi

# 5. Pipe-to-shell (curl ... | sh)
if echo "$CMD" | grep -qE '(curl|wget)[[:space:]].*\|[[:space:]]*(sh|bash|zsh)\b'; then
  block "curl/wget | sh pattern — supply chain riski"
fi

# 6. eval / dynamic code
if echo "$CMD" | grep -qE '\beval[[:space:]]'; then
  block "eval kullanımı — A05:2025 Injection riski"
fi

# 7. .env dosyalarını cat / echo etme (secret sızıntısı)
if echo "$CMD" | grep -qE '\b(cat|less|more|head|tail)[[:space:]].*\.env(\.production|\.staging)?(\b|$)'; then
  block ".env dosyasını okuma yasak — secret sızıntı riski"
fi

# 8. Sudo (genelde dev workflow'da gerek yok)
if echo "$CMD" | grep -qE '^[[:space:]]*sudo[[:space:]]'; then
  block "sudo komutları kullanıcı tarafından manuel çalıştırılmalı"
fi

# 9. Network listening (nc -l, vs.)
if echo "$CMD" | grep -qE '\b(nc|netcat|ncat)[[:space:]]+(-l|-L)\b'; then
  block "Network listener başlatma — kullanıcı manuel çalıştırmalı"
fi

# Geçtiyse OK
exit 0
