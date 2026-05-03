# 04 — Master Checklist: Uçtan Uca Tek Bakışta

> Tüm 3 fazın **özet + linkli** versiyonu. Her platformda kopyala, üzerinde işaretle. Detay için Faz dökümanlarına git.

---

## ⚙️ Faz 1: Proje Başında (İlk Hafta)

> Detay: [`01-phase-1-project-kickoff.md`](./01-phase-1-project-kickoff.md)

### Repo Hijyeni
- [ ] Branch protection (PR zorunlu, force push yasak, signed commits)
- [ ] Dependabot + secret scanning + push protection
- [ ] `.gitignore` tam (.env*, node_modules, secrets)
- [ ] `SECURITY.md` ve `security@<domain>` email aktif

### Claude Code Setup
- [ ] `CLAUDE.md` doldurulmuş
- [ ] `.claude/settings.json` permissions tanımlı
- [ ] 4 güvenlik agent'ı aktif: `security-guardian`, `pre-deploy-auditor`, `threat-modeler`, `dependency-watchdog`
- [ ] Pre-commit hooks: lint + type check + secret scan

### Stack Defaults
- [ ] Security headers (CSP, HSTS, X-Frame-Options, vb.)
- [ ] TypeScript strict mode
- [ ] ESLint + security plugin
- [ ] Zod validation iskeleti

### Auth & Authz
- [ ] Auth library seçimi yazılı kararla
- [ ] Roller + RBAC matrisi tanımlı
- [ ] `requireSession()`, `requireRole()` helper'ları
- [ ] MFA stratejisi planlandı

### DB Hijyeni
- [ ] Encryption at rest aktif
- [ ] Otomatik backup + PITR
- [ ] Application user least-privilege
- [ ] `audit_logs` tablosu tasarlandı (append-only)

### Secrets
- [ ] Secrets Manager seçildi
- [ ] `.env.example` template
- [ ] Secret rotation planı

### Logging
- [ ] Sentry entegre
- [ ] Structured JSON log
- [ ] PII redaction kuralları

### CI/CD
- [ ] `.github/workflows/security.yml` aktif
- [ ] Staging + production ayrı
- [ ] IaC (Terraform/CDK) zorunlu

### KVKK
- [ ] PII envanter taslağı
- [ ] Aydınlatma metni taslağı
- [ ] VERBİS kayıt durumu

### Threat Model
- [ ] İlk threat model v1 yazıldı (STRIDE)

---

## 🛠️ Faz 2: Kod Yazarken (Sürekli)

> Detay: [`02-phase-2-coding-rules.md`](./02-phase-2-coding-rules.md)

### Her API Endpoint'in Altın Kuralı (5 Adım)
```typescript
// 1. AUTHENTICATION
const session = await requireSession();
// 2. AUTHORIZATION
requireRole(session, ['admin']);
// 3. INPUT VALIDATION (Zod)
const input = Schema.parse(rawInput);
// 4. BUSINESS LOGIC
// 5. AUDIT LOG
await auditLog({...});
```

### OWASP Top 10:2025 Hızlı Hatırlatma
| OWASP | Kural |
|---|---|
| **A01** Access Control | Owner check, RBAC, IDOR önle, SSRF allowlist |
| **A02** Misconfiguration | Security headers, default cred yok, CORS sıkı |
| **A03** Supply Chain | Lock file, SBOM, npm audit, license check |
| **A04** Crypto | bcrypt/argon2, crypto.randomBytes, TLS 1.2+ |
| **A05** Injection | Parameterized SQL, escape XSS, no eval |
| **A06** Insecure Design | Rate limit, MFA, CAPTCHA, threat model |
| **A07** Auth Failures | 12+ char password, MFA, secure session |
| **A08** Integrity | No insecure deserialize, signed commits |
| **A09** Logging | Audit log + alarm, PII redaction |
| **A10** Exception Handling | Fail-closed, generic errors, timeout |

### PR Discipline
- [ ] CI tüm checkler yeşil
- [ ] `security-guardian` review (sensitive değişikliklerde)
- [ ] Yeni endpoint → 5'li altın kural
- [ ] Yeni dependency → `dependency-watchdog`

### Testing
- [ ] Negative tests (RBAC, IDOR, rate limit) yazıldı
- [ ] Coverage >70%

---

## 🚀 Faz 3: Canlıya Çıkmadan Önce

> Detay: [`03-phase-3-pre-launch.md`](./03-phase-3-pre-launch.md)

### Bloker Kriterler (HEPSİ olmalı)
- [ ] 0 high/critical CVE (`npm audit`)
- [ ] SAST scan yeşil (Semgrep / Sonar)
- [ ] Secret scan temiz (gitleaks)
- [ ] MFA admin'lerde zorunlu
- [ ] HTTPS + HSTS aktif
- [ ] Encryption at rest aktif
- [ ] Backup + restore drill yapıldı (son 90 gün)
- [ ] Audit log yazıyor (sample row görüldü)
- [ ] Sentry hata yakalıyor
- [ ] Rate limiting login + sensitive endpoint'lerde
- [ ] Status page aktif
- [ ] Incident response runbook hazır
- [ ] KVKK aydınlatma metni yayında
- [ ] Pen test (varsa) Critical/High kapatıldı

### Security Headers (curl test)
- [ ] CSP, HSTS, X-Frame-Options, X-Content-Type-Options, Referrer-Policy
- [ ] securityheaders.com → A veya A+
- [ ] Mozilla Observatory → A veya A+
- [ ] SSL Labs → A

### Monitoring
- [ ] Critical alarmlar tanımlı
- [ ] Synthetic canary kritik akışlarda
- [ ] On-call notification test edildi

### Customer Evidence Pack
> Detay: [`09-customer-evidence-pack.md`](./09-customer-evidence-pack.md)
- [ ] Information Security Policy
- [ ] Incident Response Plan
- [ ] Data Processing Agreement (DPA) taslağı
- [ ] PII envanteri
- [ ] Architecture diagram
- [ ] RBAC matrix
- [ ] SBOM
- [ ] Pen test summary (varsa)

### Final
- [ ] `pre-deploy-auditor` agent verdict: **GO**

---

## 🔄 Yayında: Periyodik Denetim

> Detay: [`05-audit-cadence.md`](./05-audit-cadence.md)

### Günlük (5 dk)
- [ ] Sentry: yeni high-impact issue var mı?
- [ ] Status page yeşil mi?

### Haftalık (30 dk)
- [ ] `dependency-watchdog` raporu
- [ ] Failed login pattern analizi
- [ ] CI/CD security workflow durumu

### Aylık (2 saat)
- [ ] SAST tam tarama
- [ ] OWASP ZAP scan
- [ ] AWS Security Hub findings review
- [ ] Audit log spot check
- [ ] Backup restore drill (çeyrekte 1)

### Çeyreklik (1 gün)
- [ ] Threat model güncelle
- [ ] Customer evidence pack yenile
- [ ] Tabletop incident exercise
- [ ] Restore drill

### Yıllık (2-3 gün)
- [ ] Bağımsız pen test
- [ ] Tüm secret rotation
- [ ] Disaster recovery full test
- [ ] Compliance review (KVKK)

---

## 🚨 Acil Durum: Incident

> Detay: [`07-incident-response.md`](./07-incident-response.md)

### Süreçte (P0/P1)
1. **Detect** — Alarm geldi / şüphe duydun
2. **Triage** — Severity belirle (P0/P1/P2)
3. **Contain** — Yayılmayı engelle (rate limit, IP block, feature flag)
4. **Eradicate** — Kök nedeni gider
5. **Recover** — Servisi normalleştir
6. **Postmortem** — Yazılı, blame-free, action items

### KVKK Veri İhlali
- [ ] 72 saat içinde KVKK Kurumu'na bildirim
- [ ] Etkilenen kullanıcıları bilgilendirme
- [ ] Kanıt toplama (logs, snapshot)
- [ ] Kök neden analizi
- [ ] Önleyici aksiyon planı

---

## 📋 Tek Sayfalık Kanıt İndeksi

Her platformda `evidence/` klasörü altında **bunlar olmalı**:

```
evidence/
├── 01-information-security-policy.md
├── 02-incident-response-plan.md
├── 03-data-processing-agreement.md
├── 04-kvkk-compliance-statement.md
├── 05-pentest-summary-YYYY-MM-DD.md
├── 06-architecture-diagram.md
├── 07-rbac-matrix.md
├── 08-pii-inventory.md
├── 09-data-retention-policy.md
├── 10-backup-and-dr.md
├── 11-encryption-overview.md
├── 12-sub-processors.md
├── 13-vulnerability-management.md
├── 14-business-continuity.md
├── 15-employee-security-training.md
└── 16-sbom-current.json
```

---

## 🧠 Öğrenme & Bilgi Tazeleme

### Her Hafta
- OWASP Cheat Sheet rastgele 1 sheet oku (15 dk)
- The Daily Swig veya Krebs on Security tarama (10 dk)

### Her Ay
- Türk Sertifikalı Olay Müdahale (TR-CERT) bulletin'leri
- AWS Security Bulletin
- Yeni CVE'ler için Dependabot zaten haber verir

### Her Çeyrek
- OWASP Top 10 yeniden oku (kategoriler değişebilir)
- Bir security konferans sunumu izle (BSides, DEF CON, Black Hat)

### Yıllık
- OWASP Top 10 yeni versiyonu (4 yılda bir)
- NIST SSDF major güncellemeleri
- KVKK güncellemeleri (Türkiye)

---

## 💡 Solo Dev için Pragmatik Notlar

1. **Her şeyi mükemmel yapma — sürdürülebilir yap.** Hiç yapılmayan mükemmel kontroldense, her hafta yapılan iyi kontrol değerli.
2. **Kanıt üret.** Her şey `evidence/` altında olsun. 6 ay sonra "ben gerçekten yapmış mıydım?" dediğinde ispatın olsun.
3. **Otomatize et.** Bir şeyi 2 kez yaptıysan, otomatize et. CI'a, agent'a, IaC'a ver.
4. **Kuruma değil müşteriye hazırlan.** Sertifika almıyorsun (henüz). Müşterinin güvenlik anketine cevabın olsun yeter.
5. **Risk acceptance kabul et.** Her şeyi düzeltemezsin. Düzeltemediğin riski **yazılı** kabul et — gerekçe + sahip + yeniden değerlendirme tarihi.
