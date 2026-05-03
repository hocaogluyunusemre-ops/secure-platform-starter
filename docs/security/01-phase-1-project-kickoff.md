# 01 — Faz 1: Proje Başında

> Yeni bir platform başlatırken **ilk hafta içinde** tamamlaman gerekenler. Sonradan geri dönüp eklemek 5x daha pahalı; başta düzgün kuralım.

Önerim: Bu dosyayı **canlı checklist** olarak tut. Her platformda kopyala, üzerinde işaretle.

---

## 0. Tek Seferlik Kurulum (5 dakika)

> **Önce bu — sonra her şey.** İlerleyen aşamalarda yeni kurulum yapmana gerek kalmasın diye **tek komut** ile her şey kurulur.

```bash
make setup
```

veya doğrudan:

```bash
bash scripts/security/setup.sh
```

Bu script idempotent — kurulu olanı atlar, eksiği ekler. İçeriği:

- [x] Global tool kontrol/kurulum (gitleaks, jq, semgrep, trivy, claude-code)
- [x] NPM dev dependency kurulum (eslint + security plugin, prettier, husky, lint-staged, cyclonedx-npm, license-checker, typescript)
- [x] Dotfile'lar (`.gitignore`, `.gitleaks.toml`, `.editorconfig`, `.prettierrc`, `.eslintrc.cjs`, `.nvmrc`, `SECURITY.md`)
- [x] Husky pre-commit hook (lint-staged + tsc + gitleaks)
- [x] `package.json`'a `sec:audit`, `sec:secrets`, `sec:licenses`, `sec:sbom`, `sec:all` script'leri
- [x] `docs/security/evidence/` klasörü
- [x] Hook script'lerin executable yapılması

**Sonuç:** İlerleyen turlarda paket / config kurmak için durmana gerek yok. Yeni özel paket gerekirse `npm add <paket>` yapacaksın, başka bir şey değil.

---

## 1. Repo & Versiyon Kontrolü Hijyeni

### 1.1 GitHub Repo Ayarları
- [ ] Repo private olarak oluşturuldu (kurumsal proje için)
- [ ] Branch protection ana branch'lerde aktif:
  - [ ] Direct push yasak (PR zorunlu)
  - [ ] Required status checks (CI yeşil olmalı)
  - [ ] Required reviewers (en az 1 — solo dev için kendine sor: "bu değişikliği başka biri review etse onaylar mıydı?")
  - [ ] Linear history (rebase/merge kuralı)
  - [ ] Force push yasak
  - [ ] Branch deletion yasak
- [ ] Default branch korunuyor (main)
- [ ] Signed commits zorunlu (`git config commit.gpgsign true`)
- [ ] Repo description ve README dolu
- [ ] License dosyası eklendi (özel sözleşme yoksa)

### 1.2 Gitignore Kontrolü
- [ ] `.env*` (production .env dahil!)
- [ ] `node_modules/`
- [ ] `.DS_Store`
- [ ] `*.log`
- [ ] `coverage/`
- [ ] `dist/`, `build/`, `.next/`
- [ ] IDE dosyaları (`.idea/`, `.vscode/settings.json` — extensions.json kalabilir)
- [ ] Cloud credential'ları (`.aws/`, `.gcp/`)

### 1.3 GitHub Security Features
- [ ] **Dependabot alerts** açık
- [ ] **Dependabot security updates** açık (otomatik PR)
- [ ] **Secret scanning** açık (GitHub Advanced Security veya gitleaks)
- [ ] **Push protection for secrets** açık
- [ ] **Code scanning** açık (GitHub CodeQL veya Semgrep)

---

## 2. Claude Code Setup

### 2.1 CLAUDE.md
- [ ] Repo root'unda `CLAUDE.md` var
- [ ] Proje bağlamı dolu (proje adı, müşteri tipi, hassasiyet, stack)
- [ ] Hassas dosyalar listesi projeye göre güncellendi
- [ ] Stop-and-ask listesi anlaşıldı
- [ ] Coding rules anlaşıldı

### 2.2 .claude Klasörü
- [ ] `.claude/settings.json` projeye uyarlandı
- [ ] Permissions allow/ask/deny listeleri kontrol edildi
- [ ] `.claude/agents/` altında 4 güvenlik agent'ı mevcut:
  - [ ] `security-guardian.md`
  - [ ] `pre-deploy-auditor.md`
  - [ ] `threat-modeler.md`
  - [ ] `dependency-watchdog.md`
- [ ] `.claude/settings.json` versiyon kontrolünde (`.claude/settings.local.json` ise lokal-only)

### 2.3 Pre-commit Hooks
- [ ] `husky` veya `lefthook` kurulu
- [ ] Pre-commit'te koşan kontroller:
  - [ ] Lint (ESLint + security plugin)
  - [ ] Type check (`tsc --noEmit`)
  - [ ] Secret scan (`gitleaks protect --staged`)
  - [ ] Format check (Prettier)

---

## 3. Tech Stack Güvenlik Default'ları

### 3.1 Next.js (örnek; diğer framework'lerde benzer)
- [ ] `next.config.js`'de security headers tanımlı:
  - [ ] CSP (Content Security Policy)
  - [ ] HSTS (Strict-Transport-Security)
  - [ ] X-Frame-Options: DENY (veya CSP frame-ancestors)
  - [ ] X-Content-Type-Options: nosniff
  - [ ] Referrer-Policy: strict-origin-when-cross-origin
  - [ ] Permissions-Policy
- [ ] `poweredByHeader: false` (X-Powered-By gizle)
- [ ] `productionBrowserSourceMaps: false` (varsayılan zaten kapalı)

### 3.2 TypeScript
- [ ] `strict: true`
- [ ] `noImplicitAny: true`
- [ ] `strictNullChecks: true`
- [ ] `noUncheckedIndexedAccess: true` (önerilen)

### 3.3 ESLint
- [ ] `eslint-plugin-security` kurulu ve aktif
- [ ] `eslint-plugin-no-secrets` kurulu (opsiyonel ama yararlı)
- [ ] `eslint-plugin-react-hooks` (React varsa)

### 3.4 Validation (Zod / Valibot)
- [ ] Zod kurulu
- [ ] `lib/validators/` klasörü oluşturuldu
- [ ] Her API endpoint için schema standardı belirlendi

---

## 4. Authentication & Authorization Iskeleti

### 4.1 Auth Tool Seçimi
- [ ] Auth library seçildi (Auth.js / Clerk / Cognito)
- [ ] **Sebep yazılı** — neden bu seçildi (`docs/architecture/auth-decision.md`)
- [ ] Session strategy belirlendi (JWT / DB session)
- [ ] MFA stratejisi planlandı (TOTP / WebAuthn / SMS)

### 4.2 RBAC Iskeleti
- [ ] Roller tanımlı (örn: `admin`, `operator`, `customer`)
- [ ] Role-permission matrix yazılı (`docs/architecture/rbac-matrix.md`)
- [ ] `requireSession()`, `requireRole()` helper fonksiyonları yazılı
- [ ] `middleware.ts` route protection'a temel hazır

### 4.3 Şifre Politikası
- [ ] Min 12 karakter
- [ ] bcrypt / argon2 ile hash (cost factor uygun)
- [ ] HaveIBeenPwned API entegrasyonu planlandı (opsiyonel ama önerilir)

---

## 5. Veri Tabanı Hijyeni

### 5.1 Bağlantı Güvenliği
- [ ] Database publicly erişilemez (private subnet veya whitelist IP)
- [ ] TLS/SSL connection zorunlu
- [ ] Connection string Secrets Manager'da, kodda değil

### 5.2 User Hijyeni
- [ ] Application user'ı root değil
- [ ] Application user'ın izni minimum (DDL yok, sadece CRUD ihtiyacı kadar)
- [ ] Migration'ları farklı (daha yetkili) bir user koşturuyor

### 5.3 Şifreleme & Backup
- [ ] Encryption at rest aktif (AWS RDS checkbox)
- [ ] Otomatik backup aktif
- [ ] Backup encryption aktif
- [ ] PITR (point-in-time recovery) aktif
- [ ] Backup retention period belirlendi

### 5.4 Audit Tablosu
- [ ] `audit_logs` tablosu schema'da tasarlandı
- [ ] Append-only (DELETE/UPDATE yasak — DB grant ile zorla)
- [ ] Min alanlar: `id, actor_id, action, resource_type, resource_id, metadata, ip_address, user_agent, created_at`

---

## 6. Secrets Management

- [ ] Secrets Manager seçildi (AWS Secrets Manager / Vault / Doppler)
- [ ] Local development için `.env.local` template'i (`.env.example`)
- [ ] `.env*` gitignore'da (TEKRAR vurgu — en sık unutulan)
- [ ] Secret rotation planı yazılı (DB password 90 gün, API key yıllık)
- [ ] Acil secret rotation runbook'u var (compromise durumunda)

---

## 7. Logging & Monitoring Iskeleti

### 7.1 Application Logging
- [ ] Logger library seçildi (Pino, Winston)
- [ ] Log seviye standardı (info/warn/error/fatal)
- [ ] Log format: JSON, structured
- [ ] PII redaction kurallı (email, TC kimlik gibi alanlar otomatik mask)
- [ ] Log shipping (CloudWatch / Datadog / ELK) planlandı

### 7.2 Error Tracking
- [ ] Sentry hesabı açıldı
- [ ] Backend Sentry SDK kurulu
- [ ] Frontend Sentry SDK kurulu
- [ ] Source map upload pipeline tasarlandı (production stack trace okunabilir olsun)
- [ ] PII filter Sentry'de aktif (`beforeSend`)

### 7.3 Audit Log API
- [ ] `auditLog()` helper'ı yazıldı
- [ ] Hangi event'lerin logleneceği listelendi:
  - [ ] User login / logout / failed login
  - [ ] Password change / reset
  - [ ] Permission / role değişikliği
  - [ ] Sensitive data access (örn. başkasının verisini görme)
  - [ ] Data export
  - [ ] Admin action

### 7.4 Alarmlar (Henüz aktif değil — Faz 3'te aktif olacak, ama planı şimdi yapılır)
- [ ] Alarm kategorileri belirlendi:
  - [ ] 5xx hata oranı
  - [ ] Failed login spike
  - [ ] DB connection failure
  - [ ] Unusual data access
  - [ ] Disk usage
  - [ ] Certificate expiry

---

## 8. CI/CD Iskeleti

### 8.1 Workflow Dosyası
- [ ] `.github/workflows/security.yml` oluşturuldu
- [ ] CI'da koşan adımlar:
  - [ ] Lint
  - [ ] Type check
  - [ ] Test
  - [ ] `npm audit`
  - [ ] Semgrep / Sonar
  - [ ] gitleaks
  - [ ] Build

### 8.2 Deploy Pipeline
- [ ] Staging ortam tanımlı
- [ ] Production ortam tanımlı
- [ ] Manual approval staging → production geçişinde
- [ ] Rollback prosedürü yazılı

### 8.3 IaC
- [ ] Cloud altyapısı kod ile tanımlanıyor (Terraform / CDK / Pulumi)
- [ ] **Hand-made resource ZERO TOLERANCE** — manuel oluşturulan AWS kaynağı yok
- [ ] State dosyası encrypted, backend'de (S3 + DynamoDB locking)
- [ ] IaC scan tool'u CI'da (Checkov / tfsec)

---

## 9. KVKK & Hukuki Iskelet

- [ ] **PII envanter** taslağı oluşturuldu (`docs/security/pii-inventory.md`)
- [ ] **Aydınlatma metni** taslağı yazıldı (avukatla onaylanacak)
- [ ] **Cookie politikası** tasarlandı
- [ ] **VERBİS** kayıt durumu kontrol edildi (gerekiyorsa kayıt başlatıldı)
- [ ] **Veri İşleme Sözleşmesi** taslağı (kurumsal müşteriler için)
- [ ] Müşteri ile **Data Processing Agreement** (DPA) kim sorumlu: Controller mı Processor mu — netleştirildi
- [ ] **Alt-yüklenici listesi** (AWS, Sentry, Stripe, vs.) yazılı

---

## 10. Threat Modeling (Mimari Tehdit Analizi)

- [ ] İlk threat model oturumu yapıldı (`threat-modeler` agent ile)
- [ ] STRIDE analizi `docs/security/threat-models/v1.md` altında
- [ ] Mimari diyagram (data flow + trust boundaries) hazır
- [ ] Top 10 tehdit ve mitigation'ları listede

---

## 11. Dokümantasyon Iskeleti

- [ ] `docs/` klasörü yapısı belirli:
  - [ ] `docs/architecture/` (mimari kararlar, ADR)
  - [ ] `docs/security/` (bu klasör)
  - [ ] `docs/runbooks/` (operasyonel talimatlar)
  - [ ] `docs/api/` (API dokümantasyonu)
- [ ] `SECURITY.md` repo root'unda — security@... email + raporlama yöntemi
- [ ] İlk **ADR** (Architectural Decision Record) yazıldı (mimari kararlar)

---

## 12. İletişim & Hesaplar

- [ ] **`security@<domain>`** email kuruldu (raporlar için)
- [ ] AWS hesabında MFA zorunlu (root + IAM users)
- [ ] AWS billing alert kuruldu (anormal harcamayı yakalar — kompromit göstergesi olabilir)
- [ ] GitHub hesabında MFA zorunlu
- [ ] Tüm 3. parti SaaS hesaplarında MFA aktif

---

## 13. İlk Customer Evidence Pack Iskeleti

`docs/security/09-customer-evidence-pack.md`'yi gör. Faz 1 sonunda en az şu dosyalar oluşturuldu (boş template olarak):

- [ ] `evidence/security-policy.md` (taslak)
- [ ] `evidence/incident-response-plan.md` (taslak — `07-incident-response.md`'den kopya)
- [ ] `evidence/architecture-diagram.md` (mermaid)
- [ ] `evidence/access-control-matrix.md` (RBAC tablosu)
- [ ] `evidence/sub-processors-list.md` (alt-yüklenici listesi)

---

## 14. Faz 1 Bitirme Kriterleri

Faz 1'in bittiğini söyleyebilmen için:

- [ ] CI/CD yeşil çalışıyor (en az boş bir endpoint deploy oluyor)
- [ ] Auth + RBAC iskeleti çalışır durumda (en az login + role-protected sayfa)
- [ ] Audit log tablosu var, ilk insert testi geçti
- [ ] Sentry production'a hata gönderiyor
- [ ] PII envanteri taslağı dolu
- [ ] Threat model v1 yazıldı
- [ ] Tüm "Yapıldı" işaretlerinin kanıtı `docs/security/evidence/` altında

**Faz 1 tamamlandığında 2. faza geç:** `02-phase-2-coding-rules.md`
