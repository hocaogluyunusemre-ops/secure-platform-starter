# Secure Platform Starter

> Solo developer'lar için kurumsal sınıf güvenlik şablonu. Her yeni B2B / B2C platformda bu repo'yu template olarak kullan, müşterin Arçelik, Aon, AXA gibi kurumlar olsa bile arkanı kollamış olarak başla.

Bu repo; **OWASP Top 10:2025**, **NIST SSDF (SP 800-218)**, **OWASP ASVS** ve **OWASP Cheat Sheet Series** standartlarına dayalı pratik bir uygulama. Akademik bir döküman değil — Claude Code ile birlikte iş yapan bir solo developer'ın kullanacağı somut bir araç.

---

## Bu repo'yu neden kullanmalısın?

Tek başına platform yapıyorsun. Ama müşterilerin:
- Güvenlik anketi gönderir (40+ soru)
- Pen test raporu ister
- KVKK / GDPR uyumluluğu ister
- Mimari diyagramı ister
- Audit log örneği görmek ister

Sen ise:
- Tek dev'sin, ayrı bir security mühendisi yok
- Hızlı go-live baskısı altındasın
- Her platformda aynı işleri sıfırdan yapmak istemiyorsun

Bu repo bunu çözer. **Bir kez kur, her platformda kopyala**, kurumsal müşterinin sorabileceği her güvenlik sorusunun cevabı zaten klasör içinde olsun.

---

## Felsefe

1. **Defense in depth** — Tek duvar değil, 7 katman. Birisi delinirse diğeri tutsun.
2. **Shift-left** — Güvenlik bug'ı production'da değil, IDE'de yakalanmalı. Sonra CI'da, sonra staging'de — production ucu.
3. **Otomatize et** — Bir şeyi 2 kez yaptıysan, otomatize et. CI'a, agent'a, IaC'a ver.
4. **Kanıt üret** — Yapılan her güvenlik adımının izi `evidence/` altında olsun. Kurumsal müşteri sorduğunda göstereceksin.
5. **Sürdürülebilir minimum** — Hiç yapılmayan mükemmel kontroldense, her hafta yapılan iyi kontrol değerli.

---

## Üç Faz Yaklaşımı

```
┌────────────────┐    ┌────────────────┐    ┌────────────────┐
│  FAZ 1         │ →  │  FAZ 2         │ →  │  FAZ 3         │
│  Proje Başında │    │  Kod Yazarken  │    │  Canlıya Çıkış │
│  (Kickoff)     │    │  (Coding)      │    │  (Pre-Launch)  │
└────────────────┘    └────────────────┘    └────────────────┘
       ↓                       ↓                       ↓
  Temeli kur            Disiplini koru          Kanıtla & yayınla
  CLAUDE.md doldur      RBAC + Zod + audit log  Pen test, evidence
  Agent'lar kur         Her PR güvenlik check   Customer security pack
```

Her faz için bir checklist var. Bittiğinde işaretliyorsun, kanıtı `docs/security/evidence/` altına koyuyorsun. Canlıya çıktıktan sonra **`05-audit-cadence.md`**'deki periyodik denetim takvimine geçiyorsun.

---

## Repo Yapısı

```
secure-platform-starter/
├── README.md                                ← buradasın
├── CLAUDE.md                                ← Claude Code'un her oturumda okuduğu anayasa
├── Makefile                                 ← `make setup`, `make security`, vb. kısayollar
├── SECURITY.md (kurulum sonrası)            ← Responsible disclosure (template'ten)
├── .claude/
│   ├── settings.json                        ← Claude Code izin/limit ayarları + hooks
│   └── agents/                              ← Specialized güvenlik subagent'ları
│       ├── security-guardian.md             ← Kod güvenlik review (read-only)
│       ├── pre-deploy-auditor.md            ← Canlıya çıkış denetçisi (read-only)
│       ├── threat-modeler.md                ← Mimari tehdit modeli
│       └── dependency-watchdog.md           ← Bağımlılık güvenlik tarayıcı
├── scripts/security/
│   ├── setup.sh                             ← TEK SEFERLIK kurulum (idempotent)
│   ├── validate-bash-command.sh             ← Bash hook (tehlikeli komut bloku)
│   └── check-secret-patterns.sh             ← Edit/Write hook (secret pattern bloku)
├── templates/                               ← Setup tarafından kopyalanacak dotfile'lar
│   ├── .gitignore.template
│   ├── .gitleaks.toml.template
│   ├── .editorconfig.template
│   ├── .prettierrc.template
│   ├── .eslintrc.cjs.template
│   └── SECURITY.md.template
├── docs/security/
│   ├── 00-foundation.md                     ← Felsefe + framework referansları
│   ├── 01-phase-1-project-kickoff.md        ← Faz 1 detaylı checklist
│   ├── 02-phase-2-coding-rules.md           ← Faz 2 OWASP Top 10:2025 mapping
│   ├── 03-phase-3-pre-launch.md             ← Faz 3 canlıya çıkış kontrolü
│   ├── 04-master-checklist.md               ← Uçtan uca tek bakışta
│   ├── 05-audit-cadence.md                  ← Günlük/haftalık/aylık/yıllık ritim
│   ├── 06-tooling-catalog.md                ← Tool kataloğu — ne ne işe yarar
│   ├── 07-incident-response.md              ← Olay müdahale runbook
│   ├── 08-kvkk-compliance.md                ← KVKK Türkiye-özel
│   └── 09-customer-evidence-pack.md         ← Kurumsal müşteri için kanıt paketi
└── .github/workflows/
    └── security.yml                         ← CI security pipeline (13 paralel job)
```

---

## Nereden Başlamalı?

### Yeni proje başlatırken — TEK KOMUT

```bash
make setup
```

Bu **idempotent** kurulum:

1. Global tool'ları kontrol eder, eksikse kurar (gitleaks, jq, semgrep, trivy, claude-code)
2. NPM dev dependency'leri ekler (eslint + security plugin, prettier, husky, cyclonedx, vs.)
3. Tüm dotfile'ları yerleştirir (`.gitignore`, `.gitleaks.toml`, `.eslintrc.cjs`, `.prettierrc`, `.editorconfig`, `.nvmrc`, `SECURITY.md`)
4. Husky pre-commit hook'unu kurar (lint-staged + tsc + gitleaks)
5. `package.json`'a güvenlik script'leri ekler (`sec:audit`, `sec:secrets`, `sec:licenses`, `sec:sbom`, `sec:all`)
6. `docs/security/evidence/` klasörünü hazırlar

**Kurduysa atlar, kurmadıysa ekler.** Akış sırasında ikinci kez kurulum çalıştırmana gerek yok.

### Sonraki adımlar (kurulum bitince)

1. **`docs/security/00-foundation.md`** — felsefeyi, OWASP Top 10:2025'i ve NIST SSDF'yi anla
2. **`CLAUDE.md`**'deki `<<TUTUCU>>` alanlarını projeye göre doldur
3. **`docs/security/01-phase-1-project-kickoff.md`** — Faz 1 checklist'ini tamamla
4. **`make security`** — mevcut durumu görüntüle (audit + secrets + licenses + sbom)
5. **`.github/workflows/security.yml`** — projene uyarla, push et

### Geliştirme aşamasında
- **`docs/security/02-phase-2-coding-rules.md`** — günlük rehberin
- **`security-guardian` agent**'ı her önemli değişikliğin sonunda kullan
- **`dependency-watchdog`** haftada bir kez koşsun

### Canlıya çıkmadan önce
- **`docs/security/03-phase-3-pre-launch.md`** — kapsamlı checklist
- **`pre-deploy-auditor` agent** ile final denetim
- **`docs/security/09-customer-evidence-pack.md`** — müşteri için kanıt paketi hazırla

### Yayında
- **`docs/security/05-audit-cadence.md`** — günlük 5dk, haftalık 30dk, aylık 2sa
- **`docs/security/07-incident-response.md`** — bir şey ters giderse runbook

---

## Bu Repo "Tek Seferlik" Değil

Her oturumda öğrendiğin yeni bir şeyi (yeni saldırı vektörü, yeni tool, yeni best practice) buraya işle. Bu, zamanla **senin kurumsal güvenlik bilgi tabanın** olacak. 6 ay sonra geriye dönüp baktığında "bu repo benim CISO'm" diyeceksin.

---

## Standartlar ve Referanslar

| Standart | Ne için kullanıyoruz |
|---|---|
| **OWASP Top 10:2025** | Kod yazma kuralları, ana risk kategorileri |
| **NIST SSDF (SP 800-218)** | Genel SDLC framework, organizasyonel disiplin |
| **OWASP ASVS** | Verifiable security requirements seviyeleri |
| **OWASP Cheat Sheet Series** | Spesifik konularda implementasyon detayları |
| **CIS Benchmarks** | Cloud config (AWS, Docker) sertleştirmesi |
| **KVKK** | Türkiye-özel kişisel veri uyumluluğu |
| **CIA Triad** | Confidentiality, Integrity, Availability — tüm kararların eleği |

Tüm referans linkleri **`docs/security/00-foundation.md`** içinde.

---

## Lisans ve Notlar

Bu repo Emre'nin solo developer praktiğine göre kalibre edilmiştir:
- Türkçe ana metin, İngilizce teknik terimler
- KVKK + Türkiye / AB veri lokasyonu varsayımı
- Next.js + AWS + TypeScript + Postgres referans stack (genişletilebilir)
- Müşteri tipi: kurumsal B2B (Arçelik, Aon, AXA gibi) ve B2C ürünler

Stack farklı olduğunda kavramlar aynı kalır, sadece tool isimleri değişir.
