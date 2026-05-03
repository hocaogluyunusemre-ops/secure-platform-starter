# 03 — Faz 3: Canlıya Çıkmadan Önce

> Production'a çıkmadan önce **bütün kontrolleri** geçmen gereken kapsamlı checklist. `pre-deploy-auditor` agent'ı bu dosyayı kullanır. Hiçbir maddeyi "şimdilik geçiyorum" deme — kanıt üret veya kabul edilmiş risk olarak yazılı kayda al.

---

## Bölüm A: Kod Kalite & Güvenlik

### A.1 CI Pipeline Yeşil
- [ ] Son commit'te tüm CI adımları yeşil
- [ ] Lint (ESLint + security plugin)
- [ ] Type check (`tsc --noEmit`)
- [ ] Unit testler (coverage >70%)
- [ ] Integration testler
- [ ] E2E testler (kritik akışlar: login, ana use case, ödeme/başvuru)
- [ ] Build başarılı

### A.2 SAST (Static Analysis)
- [ ] Semgrep / SonarCloud / CodeQL koştu
- [ ] Hiç **High** veya **Critical** finding yok
- [ ] Medium/Low finding'ler triage edildi (kabul / fix / risk acceptance)
- **Kanıt:** son CI run linki

### A.3 Dependency Security
- [ ] `npm audit --audit-level=high` → 0 high/critical
- [ ] `dependency-watchdog` agent raporu temiz
- [ ] Tüm direct dep'ler 12 ay içinde güncellenmiş veya stable LTS
- [ ] License kontrolü temiz (GPL veya AGPL yok, ürün kapalı kaynak ise)
- [ ] SBOM (`sbom.json`) üretildi ve `evidence/` altında
- **Kanıt:** SBOM dosyası

### A.4 Secret Scanning
- [ ] `gitleaks detect` temiz
- [ ] Repo geçmişi tarandı (sadece HEAD değil)
- [ ] GitHub push protection aktif
- [ ] `.env*` dosyalar gitignore'da, history'de yok (`git log --all --full-history -- .env`)

---

## Bölüm B: Authentication & Authorization

### B.1 Authentication
- [ ] Default credential YOK (hiç bir hesap admin/admin değil)
- [ ] Test/staging credential'ları production'da kullanılmıyor
- [ ] Şifre politikası enforce: min 12 char
- [ ] HaveIBeenPwned breach kontrolü aktif
- [ ] bcrypt cost factor >= 12 (veya argon2)
- [ ] MFA admin role'lerde **zorunlu**
- [ ] Session timeout: idle 15-30 dk, absolute 8-12 saat
- [ ] Logout server-side session invalidate ediyor
- [ ] OAuth/SSO state parameter + PKCE

### B.2 Authorization (RBAC)
- [ ] Role-permission matrix yazılı (`evidence/rbac-matrix.md`)
- [ ] Her sensitive endpoint'te `requireRole()` kontrol var
- [ ] IDOR test edildi: User A, User B'nin verisini göremiyor
- [ ] Privilege escalation testi: regular user, admin endpoint'lerine 403 alıyor

### B.3 Session
- [ ] HttpOnly cookie
- [ ] Secure flag (HTTPS)
- [ ] SameSite=Lax veya Strict
- [ ] Session ID strong random (`crypto.randomBytes`)

---

## Bölüm C: Veri Güvenliği

### C.1 Encryption At Rest
- [ ] DB encryption aktif (AWS RDS / Postgres / MySQL)
- [ ] Backup encryption aktif
- [ ] S3 / object storage encryption aktif (SSE-KMS önerilir)
- [ ] EBS volumes encrypted
- [ ] Snapshots encrypted

### C.2 Encryption In Transit
- [ ] HTTPS zorunlu, HTTP redirect 301
- [ ] HSTS aktif: `max-age=31536000; includeSubDomains`
- [ ] HSTS preload eklendi (opsiyonel)
- [ ] TLS 1.2+ (1.3 ideal); TLS 1.0/1.1 disabled
- [ ] Certificate auto-renewal (ACM / Let's Encrypt)
- [ ] Internal service-to-service TLS

### C.3 Sensitive Data Handling
- [ ] PII envanteri güncel (`evidence/pii-inventory.md`)
- [ ] Hassas kolon listesi DB schema'da işaretli
- [ ] Logger PII redaction aktif (test edildi)
- [ ] Sentry `beforeSend` PII filter aktif
- [ ] Analytics platformu PII almıyor (PostHog / Plausible / GA — config kontrol)

### C.4 Backup & DR
- [ ] Otomatik backup aktif, sıklığı belirli
- [ ] Cross-region snapshot (DR için)
- [ ] PITR (Point-in-time recovery) aktif
- [ ] **Restore drill** son 90 günde yapıldı, başarılı
- [ ] RPO (Recovery Point Objective) yazılı
- [ ] RTO (Recovery Time Objective) yazılı
- **Kanıt:** restore drill rapor (`evidence/dr-drill-YYYY-MM-DD.md`)

---

## Bölüm D: Network & Infrastructure

### D.1 Network Topology
- [ ] DB private subnet'te, public erişimi YOK
- [ ] Application servers ALB/CloudFront arkasında
- [ ] Security group'lar least-privilege (sadece gerekli portlar)
- [ ] NACL'lar gözden geçirildi
- [ ] VPC flow log aktif (forensic için)

### D.2 WAF & DDoS
- [ ] WAF aktif (AWS WAF / Cloudflare / Sucuri)
- [ ] OWASP managed rule set aktif
- [ ] Rate limiting WAF seviyesinde
- [ ] DDoS koruması (AWS Shield Standard / Cloudflare)
- [ ] Bot management aktif (opsiyonel ama önerilir)

### D.3 IAM
- [ ] AWS root account MFA, kullanılmıyor
- [ ] IAM users'ta MFA zorunlu
- [ ] IAM Access Analyzer findings temiz
- [ ] Servis hesapları least-privilege
- [ ] Cross-account access varsa `ExternalId` kullanılıyor
- [ ] `AdministratorAccess` policy KIMSE'de yok (root hariç, MFA korumalı)
- [ ] Programmatic access key'ler 90 günde rotation planı

### D.4 Secrets Management
- [ ] AWS Secrets Manager / Vault aktif
- [ ] Production secret'ları sadece orada
- [ ] Secret rotation aktif (DB password 90 gün)
- [ ] Acil rotation runbook test edildi
- [ ] EC2/ECS task'ları IAM role kullanıyor (secret embed yok)

---

## Bölüm E: Security Headers (curl ile production URL test)

```bash
curl -sI https://app.example.com | grep -iE 'strict|content-security|x-frame|x-content|referrer|permissions'
```

- [ ] `Strict-Transport-Security: max-age=31536000; includeSubDomains; preload`
- [ ] `Content-Security-Policy: default-src 'self'; ...` (no `unsafe-eval`, minimal `unsafe-inline`)
- [ ] `X-Frame-Options: DENY` veya CSP `frame-ancestors 'none'`
- [ ] `X-Content-Type-Options: nosniff`
- [ ] `Referrer-Policy: strict-origin-when-cross-origin`
- [ ] `Permissions-Policy: camera=(), microphone=(), ...`
- [ ] `X-Powered-By` YOK (gizlendi)
- [ ] `Server` header YOK veya generic

**Test araçları:**
- <https://securityheaders.com/>
- <https://observatory.mozilla.org/>
- Hedef skor: A veya A+

---

## Bölüm F: Logging & Monitoring

### F.1 Logging
- [ ] Application logs centralized (CloudWatch / Datadog / ELK)
- [ ] Structured JSON log
- [ ] PII redaction çalışıyor (test edildi)
- [ ] Log retention policy uygulanıyor
- [ ] Audit log tablosu yazıyor (sample row görüldü)
- [ ] Audit log immutable (DELETE/UPDATE policy ile bloklanmış)

### F.2 Error Tracking
- [ ] Sentry production'a hata gönderiyor (test exception fırlattım, geldi)
- [ ] Source map upload aktif (production stack trace okunabilir)
- [ ] Release tracking aktif
- [ ] PII filter aktif
- [ ] Alert kuralları (Slack / email) aktif

### F.3 Alarms
- [ ] 5xx hata oranı alarm: >1% / 5dk
- [ ] 4xx hata oranı alarm (suspicious): >5% / 5 dk
- [ ] Login failure spike: >50/dk
- [ ] DB connection failure
- [ ] DB CPU >80%
- [ ] DB disk >80%
- [ ] Application latency p99 > X ms
- [ ] Cert expiry <30 gün
- [ ] AWS billing anomaly

### F.4 Synthetic Monitoring
- [ ] CloudWatch Synthetics canary kritik akışlarda (login, ana use case)
- [ ] Her 5 dakikada bir koşuyor
- [ ] Failure'da alarm çalıyor

### F.5 Status Page
- [ ] BetterStack / Statuspage / Atlassian Statuspage kuruldu
- [ ] Component listesi: API, Web App, Database, External Integrations
- [ ] Public URL: status.example.com

### F.6 Bildirim Kanalları
- [ ] Slack / email / SMS test edildi
- [ ] Critical alarm SMS / phone call'a gidiyor (gece 3'te uyandıracak)
- [ ] On-call rotation tanımlı (sen tek kişi olsan bile yedek planı)

---

## Bölüm G: KVKK & Hukuki Uyumluluk

### G.1 KVKK Temelleri
- [ ] **Aydınlatma metni** sitede, link'i her form altında
- [ ] **Açık rıza** akışları çalışıyor (gerekiyorsa)
- [ ] **Cookie banner** KVKK uyumlu (analytics opt-in)
- [ ] **VERBİS kaydı** yapılmış (gerekiyorsa)
- [ ] **Veri Sorumlusu** mu **Veri İşleyen** mi netleştirildi (kurumsal müşteri ile)

### G.2 Veri İşleme
- [ ] **PII envanteri** güncel ve `evidence/pii-inventory.md`'de
- [ ] **Veri saklama süreleri** belirlendi (her veri tipi için)
- [ ] **Veri silme akışı** test edildi (kullanıcı silme talebi → ne kadar sürede ne silinir)
- [ ] **Veri taşıma akışı** çalışıyor (kullanıcı verisi export)
- [ ] **Veri ihlali bildirim süreci** yazılı (72 saat)

### G.3 Alt-Yükleniciler
- [ ] **Sub-processors listesi** güncel (`evidence/sub-processors.md`)
- [ ] AWS, Sentry, Stripe vs için **Data Processing Agreement** (DPA) imzalı
- [ ] Müşteriye sunulacak DPA taslağı hazır

### G.4 Veri Lokasyonu
- [ ] Production data Türkiye veya AB'de (KVKK uyumu için)
- [ ] Yedekler aynı veya kıyaslanabilir korumada region'da
- [ ] Yurtdışı transfer varsa hukuki dayanağı yazılı

---

## Bölüm H: Threat Modeling & Risk

### H.1 Threat Model
- [ ] Sistem mimarisi için threat model güncel (`evidence/threat-model.md`)
- [ ] STRIDE analizi yapıldı
- [ ] Tüm Critical & High mitigasyonlar implement edildi
- [ ] Medium tehditler için risk acceptance veya plan

### H.2 Penetration Test (Kurumsal Müşteri için)
- [ ] **Bağımsız 3. parti pen test** yapıldı
- [ ] Critical/High bulgular düzeltildi (re-test ile doğrulandı)
- [ ] Pen test özet raporu `evidence/pentest-summary-YYYY-MM-DD.md`
- [ ] Tam rapor müşteriye NDA ile paylaşılabilir hazırlıkta

> Pen test pahalı olabilir. İlk launch için minimum: bir günlük scope-limited pentest (3-5k EUR). Veya OWASP ZAP automated baseline scan + manuel spot check.

### H.3 Bug Bounty / Disclosure
- [ ] `SECURITY.md` repo root'unda (raporlama yöntemi)
- [ ] `security@<domain>` email aktif, response 24 saat
- [ ] (Opsiyonel) Public bug bounty programı (HackerOne, Intigriti)

---

## Bölüm I: Incident Response

- [ ] **`07-incident-response.md`** runbook güncel
- [ ] Iletişim listesi güncel
- [ ] Incident sınıflandırması yapıldı (P0/P1/P2)
- [ ] Tabletop exercise yapıldı son 6 ayda (bir varsayımsal incident'i mental olarak çal)
- [ ] Forensic data toplama prosedürü (logs, snapshot)
- [ ] Müşteri bildirim taslağı (KVKK 72 saat için)

---

## Bölüm J: Operasyonel Hazırlık

### J.1 Deploy
- [ ] Deploy adımları yazılı (`docs/runbooks/deploy.md`)
- [ ] Rollback prosedürü yazılı ve test edildi
- [ ] Blue/green veya canary deployment (opsiyonel ama önerilir)
- [ ] Database migration plan (zero-downtime için: önce kolon ekle, kod güncelle, eskisini sonra sil)

### J.2 Smoke Test
- [ ] Deploy sonrası smoke test checklist:
  - [ ] Anasayfa yüklenir
  - [ ] Login çalışır
  - [ ] Ana use case (örn. başvuru oluşturma) çalışır
  - [ ] DB connectivity
  - [ ] External API entegrasyonları
  - [ ] Audit log yazıyor

### J.3 Documentation
- [ ] `README.md` güncel (yerel kurulum, deploy)
- [ ] `docs/runbooks/` altında operasyonel runbook'lar
- [ ] API dokümantasyonu güncel
- [ ] Mimari diyagram güncel

---

## Bölüm K: Customer Evidence Pack

Kurumsal müşterinin sorabileceği her güvenlik sorusunun cevabı **`docs/security/evidence/`** altında olmalı:

- [ ] `01-information-security-policy.md`
- [ ] `02-incident-response-plan.md`
- [ ] `03-data-processing-agreement.md` (DPA taslağı)
- [ ] `04-kvkk-compliance-statement.md`
- [ ] `05-pentest-summary.md`
- [ ] `06-architecture-diagram.png/.md`
- [ ] `07-rbac-matrix.md`
- [ ] `08-pii-inventory.md`
- [ ] `09-data-retention-policy.md`
- [ ] `10-backup-and-dr.md`
- [ ] `11-encryption-overview.md`
- [ ] `12-sub-processors.md`
- [ ] `13-vulnerability-management.md`
- [ ] `14-business-continuity.md`
- [ ] `15-employee-security-training.md` (sen tek kişiysen "founder personal training log")
- [ ] `16-sbom-current.json`

`09-customer-evidence-pack.md` detayı içerir.

---

## Bölüm L: Final Sanity Check

### L.1 Otomatik Tarama Bir Kez Daha
- [ ] `pre-deploy-auditor` agent ile final tarama → verdict GO
- [ ] OWASP ZAP baseline scan production URL'ine
- [ ] securityheaders.com → A veya A+
- [ ] Mozilla Observatory → A veya A+
- [ ] SSL Labs (ssllabs.com/ssltest/) → A
- [ ] testssl.sh ile derinlemesine TLS test

### L.2 Manuel Sanity Tests
- [ ] Çıktım URL'i incognito browser'da açılıyor mu (cookie/session karışmıyor)
- [ ] Mobile responsive (kritik flow'lar)
- [ ] 404 ve 500 sayfaları custom (default Next.js / Express değil)
- [ ] robots.txt ve sitemap.xml uygun

### L.3 İletişim
- [ ] Müşteri (Arçelik / Aon / AXA) **go-live tarihi** onayladı
- [ ] Operasyonel destek pencereleri belirli (kim ne zaman erişilebilir)
- [ ] Eskalasyon listesi yazılı
- [ ] (Solo dev için) **acil yardım listesi** — bir şey ters giderse kim/nereye danışacaksın

---

## Bölüm M: Go / No-Go Karar Tablosu

Aşağıdaki **bloker** kriterler eksiksiz olmalı:

| Bloker Kriter | Durum |
|---|---|
| 0 high/critical CVE | ☐ |
| MFA admin'lerde aktif | ☐ |
| HTTPS + HSTS aktif | ☐ |
| Encryption at rest aktif | ☐ |
| Audit log çalışıyor | ☐ |
| Backup test edildi (restore drill başarılı) | ☐ |
| Sentry hata yakalıyor | ☐ |
| Rate limiting login + sensitive endpoint'lerde | ☐ |
| Pen test (varsa) Critical/High kapatıldı | ☐ |
| Status page aktif | ☐ |
| Incident response runbook hazır | ☐ |
| KVKK aydınlatma metni yayında | ☐ |

**Tüm bloker'lar yeşilse GO. Bir tane bile kırmızıysa NO-GO.**

---

## Bölüm N: Go-Live Sonrası İlk 24 Saat

Canlıya çıktıktan sonra **gözünü 4 şeyden ayırma**:

1. **Sentry hata oranı** — yeni issue spike'ı var mı?
2. **5xx oranı** — beklenenin üstünde mi?
3. **Failed login** — anormal patern var mı?
4. **DB performance** — query sürelerinde anomali var mı?

İlk 24 saat:
- [ ] Saat başı kontrol et
- [ ] Status page güncel tut (incident varsa)
- [ ] Hızlı rollback için hazır ol

İlk hafta:
- [ ] Günde 2 kez 30 dk gözden geçir
- [ ] İlk haftalık audit (`05-audit-cadence.md`)

→ **`05-audit-cadence.md`** ile günlük operasyona geç
