# Secure Platform Starter — Makefile
#
# Tek seferlik setup ve günlük güvenlik komutları için kısayollar.
# Detay: docs/security/04-master-checklist.md

.PHONY: help setup setup-force audit secrets licenses sbom security clean

# Varsayılan: help göster
.DEFAULT_GOAL := help

help:
	@echo ""
	@echo "Secure Platform Starter — komutlar:"
	@echo ""
	@echo "  make setup        Tek seferlik kurulum (idempotent)"
	@echo "  make setup-force  Mevcut config'leri yeniden yaz (--force)"
	@echo ""
	@echo "  make audit        npm audit (vulnerable dependencies)"
	@echo "  make secrets      gitleaks (secret scanning)"
	@echo "  make licenses     license-checker (compliance)"
	@echo "  make sbom         CycloneDX SBOM üret"
	@echo "  make security     Tümü tek seferde (audit + secrets + licenses + sbom)"
	@echo ""
	@echo "  make clean        Geçici dosyaları temizle"
	@echo ""
	@echo "Detay: docs/security/04-master-checklist.md"
	@echo ""

setup:
	@bash scripts/security/setup.sh

setup-force:
	@bash scripts/security/setup.sh --force

audit:
	@npm audit --audit-level=high

secrets:
	@gitleaks detect --no-banner --redact

licenses:
	@npx license-checker --summary

sbom:
	@mkdir -p docs/security/evidence
	@npx @cyclonedx/cyclonedx-npm --output-file docs/security/evidence/16-sbom-current.json
	@echo "✓ SBOM: docs/security/evidence/16-sbom-current.json"

security: audit secrets licenses sbom
	@echo ""
	@echo "✓ Tüm güvenlik tarama tamamlandı"

clean:
	@rm -f npm-audit.json zap-baseline-report.html
	@echo "✓ Geçici dosyalar temizlendi"
