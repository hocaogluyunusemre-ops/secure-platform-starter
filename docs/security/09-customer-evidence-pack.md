# 09 — Müşteri Evidence Pack

> Kurumsal müşteri (Arçelik, Aon, AXA, vb.) seninle çalışmadan önce **güvenlik anketi** gönderir. 40+ soru sorar. Bu doküman her sorunun cevabının nerede olduğunu söyler ve `evidence/` klasörünün yapısını tanımlar.

Hedef: Müşteri "DPA gönderir misin?" diye sorduğunda **5 dakika içinde** PDF göndermek. Her şey hazır olsun.

---

## Neden Önemli?

Kurumsal satış sürecinde güvenlik anketi (Security Questionnaire / Vendor Risk Assessment) standart adımdır. Sen solo dev olsan bile karşıdaki **kurumsal compliance team**'idir. Onların check-list'i var, sorularına net cevap vermen gerek.

Tipik anketler (1500-3000+ soru):
- **SIG (Standardized Information Gathering)** — Shared Assessments
- **CAIQ (Consensus Assessments Initiative Questionnaire)** — Cloud Security Alliance
- **SOC 2 Type II** — kurumsal de-facto standart (sertifika)
- Müşteriye özel anketler

Sertifikan olmasa bile (SOC 2 / ISO 27001), her bir soruya **kanıtlı cevap** verebilirsen kurumsal müşteri seninle çalışır.

---

## Evidence Pack Klasör Yapısı

`docs/security/evidence/` altında **16 standart doküman**:

```
evidence/
├── 01-information-security-policy.md         ← Bilgi güvenliği politikası
├── 02-incident-response-plan.md              ← Olay müdahale planı (07'den özet)
├── 03-data-processing-agreement.md           ← DPA taslağı
├── 04-kvkk-compliance-statement.md           ← KVKK uyumluluk beyanı
├── 05-pentest-summary-YYYY-MM-DD.md          ← Pen test özet raporu
├── 06-architecture-diagram.md                ← Mimari diyagram
├── 07-rbac-matrix.md                         ← Rol-yetki matrisi
├── 08-pii-inventory.md                       ← Kişisel veri envanteri
├── 09-data-retention-policy.md               ← Veri saklama politikası
├── 10-backup-and-dr.md                       ← Yedekleme & DR
├── 11-encryption-overview.md                 ← Şifreleme genel bakış
├── 12-sub-processors.md                      ← Alt-yüklenici listesi
├── 13-vulnerability-management.md            ← Zafiyet yönetimi
├── 14-business-continuity.md                 ← İş sürekliliği planı
├── 15-employee-security-training.md          ← Personel güvenlik eğitimi
└── 16-sbom-current.json                      ← Güncel SBOM
```

Her dosya için aşağıda **template** ve **ne içermeli** detayı.

---

## 01. Information Security Policy

> "Güvenlik politikanız var mı?" sorusuna cevap.

### Template

```markdown
# Bilgi Güvenliği Politikası
**Şirket:** [Şirket Adı]
**Versiyon:** 1.0
**Son güncelleme:** YYYY-MM-DD
**Onaylayan:** [Yönetici / Founder]

## 1. Amaç
Bu politika, [Şirket Adı]'nın bilgi varlıklarını korumak için
benimsediği prensipleri ve standartları tanımlar.

## 2. Kapsam
Tüm çalışanlar, alt-yükleniciler ve sistemlere erişimi olan
3. taraflar için geçerlidir.

## 3. Yönetim Çerçevesi
- **Standartlar:** OWASP Top 10:2025, NIST SSDF, KVKK
- **Audit:** [Audit cadence dokümanı linki]
- **Roller:** [DPO varsa], CTO/Founder

## 4. Bilgi Sınıflandırması
| Sınıf | Açıklama | Örnek |
|---|---|---|
| Public | Herkese açık | Marketing materyali |
| Internal | Şirket içi | Roadmap, code |
| Confidential | Hassas | Müşteri verisi (anonimleştirilmiş) |
| Restricted | En kritik | PII, kimlik, finansal |

## 5. Erişim Kontrolü
- **Least privilege** ilkesi
- **MFA** zorunlu (admin rolleri)
- **Periyodik review** (çeyreklik)
- Detay: `evidence/07-rbac-matrix.md`

## 6. Veri Güvenliği
- At-rest encryption: AES-256
- In-transit encryption: TLS 1.2+
- Detay: `evidence/11-encryption-overview.md`

## 7. Olay Müdahale
Detay: `evidence/02-incident-response-plan.md`

## 8. Eğitim
Detay: `evidence/15-employee-security-training.md`

## 9. Politika Yönetimi
- Yıllık review
- Major değişikliklerde versiyon güncelleme
- Versiyon geçmişi git'te
```

### Soru Eşleştirme
- "Information security policy var mı?" → ✓
- "Periyodik review var mı?" → Yıllık review yazılı
- "Yönetim onayı var mı?" → Onaylayan alanı dolu

---

## 02. Incident Response Plan

> Genel `07-incident-response.md`'nin **tek sayfalık özet** versiyonu.

### Template

```markdown
# Olay Müdahale Planı (Özet)
**Versiyon:** 1.0
**Detay:** `docs/security/07-incident-response.md`

## 1. Severity Sınıflandırması
| Severity | Yanıt Süresi |
|---|---|
| P0 (Critical) | 15 dakika |
| P1 (High) | 1 saat |
| P2 (Medium) | 4 saat |

## 2. Akış
Detect → Triage → Contain → Eradicate → Recover → Postmortem

## 3. KVKK İhlal Bildirimi
72 saat içinde KVKK Kurumu'na bildirim.
Detay form: <https://www.kvkk.gov.tr/Icerik/2030/Veri-Ihlali-Bildirim-Formu>

## 4. İletişim
- **Security email:** security@[domain]
- **24/7 incident:** [telefon]
- **Status page:** status.[domain]

## 5. Test
- Çeyreklik tabletop exercise
- Yıllık DR drill
```

---

## 03. Data Processing Agreement (DPA) Taslağı

> Müşteri imzalayacak. Hukuki belge — avukatla onaylat.

KVKK doc Bölüm 10.3'te detayları var. Template örneği:

```markdown
# Veri İşleme Sözleşmesi
**Veri Sorumlusu (Controller):** [Müşteri]
**Veri İşleyen (Processor):** [Senin Şirketin]
**Tarih:** YYYY-MM-DD
**Sözleşme No:** [...]

## 1. Tanımlar
[KVKK Madde 3'teki tanımlar]

## 2. İşlenen Veri Kategorileri ve Kişi Grupları
| Kategori | Kişi grubu |
|---|---|
| Kimlik (ad, soyad) | [Müşteri]'nin müşterileri |
| İletişim (email, tel) | ... |
| Müşteri işlem | ... |

## 3. İşleme Amacı
[Müşteri]'nin tarafından [PROJE_ADI] hizmetinin sunulması.

## 4. İşleme Süresi
Sözleşme süresince + [N] yıl yasal saklama.

## 5. Talimatlar
İşleyen, sadece Sorumlu'nun yazılı talimatları doğrultusunda
veri işler.

## 6. Güvenlik Tedbirleri
- Encryption at-rest ve in-transit
- MFA
- Audit logging
- ...
- Detay: `evidence/01-information-security-policy.md`

## 7. Alt-Yükleniciler
Detay: `evidence/12-sub-processors.md`.
Yeni alt-yüklenici eklendiğinde [N] gün önceden bildirim.

## 8. Veri İhlali Bildirimi
İşleyen, ihlal tespit edildikten sonra **24 saat** içinde
Sorumlu'yu bilgilendirir.

## 9. Veri İade ve Silme
Sözleşme bitiminde [N] gün içinde:
- Tüm kişisel veri ya iade edilir, ya silinir, ya anonimize edilir.
- Yasal saklama yükümlülüğü olan veriler için anonimizasyon.

## 10. Denetim
Sorumlu, yıllık audit hakkına sahiptir. [N] gün önceden bildirim.

## 11. Hukuk ve Yetkili Mahkeme
Türk Hukuku, [il] Mahkemeleri.
```

---

## 04. KVKK Compliance Statement

> "KVKK uyumlu musunuz?" sorusuna **somut** cevap.

```markdown
# KVKK Uyumluluk Beyanı
**Şirket:** [Şirket Adı]
**Tarih:** YYYY-MM-DD

## VERBİS
[Kayıtlı / Kayıt eşiğinde değil]
**Sicil No:** [varsa]

## Veri Sorumlusu / İşleyen Rolü
| Senaryo | Rol |
|---|---|
| Direct B2C müşteriler | Sorumlu |
| Müşteri (Arçelik) için bayilerinin verisi | İşleyen |

## Aydınlatma Metni
URL: https://[domain]/aydinlatma-metni

## Hak Talep Süreci
- Email: kvkk@[domain]
- Yanıt süresi: 30 gün
- Kullanıcı self-service: profil sayfasından erişim/düzeltme/silme

## Yurtdışı Aktarım
Veri lokasyonu: AWS Frankfurt (eu-central-1) — AB
Yurtdışı (ABD) gerektiren servisler için:
- Açık rıza alınmaktadır
- Standart Sözleşmesel Hükümler (SCC) imzalı

## Veri İhlali Süreci
Detay: `evidence/02-incident-response-plan.md`
KVKK 72 saat süresinde uyumluyuz.

## Tedbirler
- Encryption (TLS 1.2+, AES-256)
- MFA admin rollerinde
- Audit logging
- Backup ve DR
- Vulnerability management

Detaylar evidence pack'in ilgili dosyalarındadır.
```

---

## 05. Pentest Summary

> "Pen test yaptırdınız mı?" sorusuna cevap.

Pen test **firma raporu** çoğunlukla NDA altındadır — özet versiyon paylaşılır:

```markdown
# Penetrasyon Testi Özet Raporu
**Test eden firma:** [Firma]
**Test tarihi:** YYYY-MM-DD
**Scope:** [URL'ler, API'ler]
**Methodology:** OWASP Testing Guide v4.2

## Özet Bulgular
| Severity | Toplam | Düzeltildi | Kabul Edilen Risk |
|---|---|---|---|
| Critical | 0 | 0 | 0 |
| High | 2 | 2 | 0 |
| Medium | 4 | 4 | 0 |
| Low | 3 | 3 | 0 |
| Info | 5 | — | — |

## Düzeltilmiş Critical/High
- (örnek) Authentication bypass → Düzeltildi YYYY-MM-DD,
  re-test ile doğrulandı YYYY-MM-DD.

## Kabul Edilen Riskler
[Yoksa boş bırak; varsa gerekçe ile]

## Tam Rapor
NDA altında talep üzerine paylaşılır.
İletişim: security@[domain]
```

---

## 06. Architecture Diagram

> "Mimari diyagram?" — mermaid veya draw.io.

```markdown
# Mimari Diyagram
**Versiyon:** 1.0
**Son güncelleme:** YYYY-MM-DD

## High-Level

\`\`\`mermaid
graph LR
  User[Kullanıcı] -->|HTTPS| CF[Cloudflare WAF]
  CF -->|HTTPS| ALB[AWS ALB]
  ALB -->|Internal| App[Next.js App]
  App -->|Internal TLS| DB[(Postgres RDS)]
  App -->|Internal TLS| Redis[(Redis Cache)]
  App -->|HTTPS + JWT| ExtAPI[External APIs]
  App -->|HTTPS| Sentry[Sentry]
  App -->|HTTPS| S3[S3 Storage]
\`\`\`

## Trust Boundaries
- **Internet ↔ Edge:** TLS, WAF
- **Edge ↔ App:** Private network, security groups
- **App ↔ DB:** Private subnet, IAM auth (if available), TLS
- **App ↔ External APIs:** TLS, signed JWT / API keys

## Veri Akışları
[Detay - hangi veri nereye gider]

## Region
- Production: AWS eu-central-1 (Frankfurt)
- DR: AWS eu-west-1 (Ireland)

## Hiçbir veri ABD'ye gitmez
[veya yurtdışı transferin nasıl korunduğu]
```

---

## 07. RBAC Matrix

> "Rol bazlı yetkilendirme nasıl?" sorusuna tablolar.

```markdown
# Rol-Yetki Matrisi (RBAC)
**Versiyon:** 1.0

## Roller

| Rol | Açıklama | Tipik Kullanıcı |
|---|---|---|
| `super_admin` | Tüm sistem yetkisi | Founder (sen) |
| `admin` | Operasyonel yönetim | Müşteri admin'i |
| `operator` | Günlük operasyon | Müşteri çalışanı |
| `read_only` | Sadece raporlama | Müşteri yöneticisi |
| `customer` | Son kullanıcı | Bayi / müşteri |

## Yetki Matrisi

| İşlem | super_admin | admin | operator | read_only | customer |
|---|---|---|---|---|---|
| Kullanıcı oluştur | ✓ | ✓ | ✗ | ✗ | ✗ |
| Kullanıcı sil | ✓ | ✓ | ✗ | ✗ | ✗ |
| Rol değiştir | ✓ | ✓ | ✗ | ✗ | ✗ |
| Tüm verileri görüntüle | ✓ | ✓ | ✓ | ✓ | ✗ |
| Kendi verisini görüntüle | ✓ | ✓ | ✓ | ✓ | ✓ |
| Kendi verisini düzenle | ✓ | ✓ | ✓ | ✗ | ✓ |
| Audit log'u görüntüle | ✓ | ✓ (kısıtlı) | ✗ | ✗ | ✗ |
| ... | ... | ... | ... | ... | ... |

## MFA Zorunluluğu
- super_admin: ZORUNLU
- admin: ZORUNLU
- operator: ÖNERİLEN
- read_only / customer: OPSIYONEL

## Periyodik Review
Çeyreklik — kim hangi rolde, hala gerekli mi?
```

---

## 08. PII Inventory

> Kurumsal müşterinin **kesinlikle** isteyeceği envanter.

```markdown
# Kişisel Veri Envanteri
**Versiyon:** 1.0
**Son güncelleme:** YYYY-MM-DD

## Toplanan Veriler

| Veri Alanı | Veri Tipi | Toplama Yöntemi | Saklama Süresi | Şifreli? | Lokasyon |
|---|---|---|---|---|---|
| Ad, Soyad | Kimlik | Kayıt formu | Hesap yaşam süresi + 5 yıl | At-rest | DB.users |
| Email | İletişim | Kayıt formu | Hesap yaşam süresi + 5 yıl | At-rest | DB.users |
| Telefon | İletişim | Profil | Hesap yaşam süresi + 5 yıl | At-rest | DB.users |
| TC Kimlik | Özel nitelikli | Başvuru formu | Yasal 10 yıl | At-rest + KMS | DB.identities |
| IP adresi | Teknik | Otomatik (log) | 90 gün | At-rest | DB.audit_logs |
| Çerez (analytics) | Teknik | Otomatik (cookie) | 6 ay | — | Browser |
| ... | ... | ... | ... | ... | ... |

## Hassas Olmayan Veriler
[B2C platformsa ve genelde hassas veri yoksa belirt]

## Çocuk Verisi
[Toplanıyor mu? Velii rıza var mı?]

## Veri Akışı
[PII'nin nereden nereye gittiği — diagram veya açıklama]
```

---

## 09. Data Retention Policy

```markdown
# Veri Saklama Politikası
**Versiyon:** 1.0

## Genel İlke
Veriyi **amaçtan fazla** süre saklamayız. Yasal yükümlülük
süresinde anonimize ederiz.

## Kategori Bazında

| Veri | Saklama Süresi | Yasal Dayanak | Silme Yöntemi |
|---|---|---|---|
| Aktif hesap verisi | Hesap yaşam süresi | Sözleşme ifası | Hesap silindikten 30 gün sonra |
| İşlem kaydı (fatura) | 10 yıl | VUK | Anonimize |
| Audit log | 1 yıl | Güvenlik | Hard delete |
| Çerez (analytics) | 6 ay | Açık rıza | Otomatik expiry |
| Backup'lar | 90 gün | DR | Otomatik rotation |
| Sentry hata | 30 gün | Operasyon | Otomatik rotation |

## Silme Süreci
- Kullanıcı talebi → 30 gün içinde silme
- Otomatik (yaşam süresi bitti) → cron job
- Anonimize: PII'yi NULL veya hash'le, business kayıt kalır
```

---

## 10. Backup and DR

```markdown
# Yedekleme ve Felaket Kurtarma
**Versiyon:** 1.0

## Yedekleme

| Veri | Sıklık | Retention | Lokasyon | Encryption |
|---|---|---|---|---|
| Postgres DB | Otomatik (sürekli WAL) + günlük snapshot | 30 gün PITR + 90 gün snapshot | eu-central-1 + eu-west-1 (cross-region) | KMS |
| Object storage (S3) | Versioning | 90 gün | Cross-region | SSE-KMS |
| Application code | Git history | Sınırsız | GitHub + lokal mirror | — |
| Configurations | IaC (Terraform state) | Sınırsız | S3 + DynamoDB lock | KMS |

## Felaket Kurtarma

### RPO (Recovery Point Objective)
< 1 saat (PITR ile)

### RTO (Recovery Time Objective)
< 4 saat (manuel restore + DNS failover)

### DR Strategy
- **Pilot Light:** Backup region'da minimum infrastructure ayakta
- DNS Cloudflare'de — failover hızlı
- Ayda 1 backup validation
- Çeyrekte 1 restore drill
- Yılda 1 full DR test

### Son DR Drill
**Tarih:** YYYY-MM-DD
**Sonuç:** Başarılı, RTO 3h 45m
**Detay:** `evidence/dr-drills/`
```

---

## 11. Encryption Overview

```markdown
# Şifreleme Genel Bakış
**Versiyon:** 1.0

## At-Rest Encryption

| Sistem | Algorithm | Key Management |
|---|---|---|
| Postgres RDS | AES-256 | AWS KMS (managed key) |
| S3 buckets | AES-256 | SSE-KMS |
| EBS volumes | AES-256 | AWS KMS |
| Backups (RDS snapshots, S3 versioning) | AES-256 | AWS KMS |
| Application secrets | — | AWS Secrets Manager (KMS) |

## In-Transit Encryption

| Bağlantı | Protocol | Cipher Suite |
|---|---|---|
| Internet → CF | TLS 1.3 | Modern (TLS 1.2+ minimum) |
| CF → Origin | TLS 1.2+ | Strict |
| App → DB | TLS 1.2+ | Required |
| App → External APIs | TLS 1.2+ | Required |
| Internal service-to-service | TLS 1.2+ | mTLS (gelecekte) |

## Key Rotation
- Application JWT secret: yıllık + acil rotation
- DB password: 90 günde
- API keys: yıllık veya partner gereksiniminde
- KMS keys: AWS otomatik (yıllık)

## Hashing
- Passwords: argon2id (with random salt, m=64MB, t=3, p=4)
- Tokens: SHA-256 (where appropriate)
- API key prefixes: stored hashed
```

---

## 12. Sub-Processors

```markdown
# Alt-Yüklenici (Sub-Processor) Listesi
**Versiyon:** 1.0
**Son güncelleme:** YYYY-MM-DD

## Aktif Sub-Processor'ler

| Sub-processor | Hizmet | Lokasyon | Veri kategorisi | DPA |
|---|---|---|---|---|
| AWS (Amazon Web Services) | Hosting | eu-central-1 (Frankfurt) | Tüm | ✓ AWS GDPR DPA |
| Cloudflare | CDN/WAF | Global edge | IP, request meta | ✓ |
| Sentry | Error tracking | EU | Stack trace, user ID (filtered) | ✓ |
| Auth.js (self-hosted) | Auth | Same as App | — | N/A (self) |
| GitHub | Source control | US/global | Code (no PII) | ✓ |
| Stripe (varsa) | Payment | US (with SCC) | Payment info | ✓ |
| Resend / SendGrid | Email | EU/US | Email addresses | ✓ |

## Yeni Sub-Processor Ekleme Süreci
1. DPA talep et ve imzala
2. Privacy Policy / Aydınlatma Metni güncelle
3. Müşterilere bildirim (DPA gereği — genelde 30 gün)
4. `evidence/12-sub-processors.md` güncelle
5. Audit log'a kayıt
```

---

## 13. Vulnerability Management

```markdown
# Zafiyet Yönetimi
**Versiyon:** 1.0

## Süreç

### Tespit
- Dependabot (otomatik PR)
- `dependency-watchdog` agent (haftalık)
- Semgrep / Sonar (CI'da her commit)
- OWASP ZAP (aylık DAST)
- Prowler (aylık CSPM)
- Müşteri / araştırmacı bildirimi (security@)

### Önceliklendirme
| Severity | SLA |
|---|---|
| Critical | 24 saat içinde patch |
| High | 7 gün |
| Medium | 30 gün |
| Low | Sonraki sprint |

### Süreç
1. Tespit → Issue oluştur
2. Triage → severity ata
3. Patch / mitigate
4. Test
5. Deploy
6. Doğrula
7. Kapat (audit trail)

## Tool'lar
Detay: `docs/security/06-tooling-catalog.md`

## Risk Acceptance
Düzeltilmeyecek bulgular için yazılı kabul:
`evidence/risk-acceptance-log.md`

## SLA Performans
[Geçen çeyrekte ortalama düzeltme süresi raporla]
```

---

## 14. Business Continuity

```markdown
# İş Sürekliliği Planı
**Versiyon:** 1.0

## Senaryolar ve Yanıtlar

### Senaryo: Major AWS Region Outage
- DR region'a failover
- DNS update (Cloudflare)
- Müşteri bildirimi (status page)
- Tahmini downtime: 4 saat

### Senaryo: DB Corruption
- En son sağlam snapshot'a restore
- Veri kaybı: en fazla 1 saat (PITR)
- Tahmini downtime: 2 saat

### Senaryo: Founder (Sen) Kullanılamaz
- AWS root credentials offline'da güvenli yerde
- Yedek şifre listesi avukatla paylaşılmış (kapalı zarf)
- Yedek developer'a 30 günlük eğitim verilmiş (varsa)
- Müşteri bildirimi sistematik

### Senaryo: Anahtar Personel (Senin) İşletmeyi Kapatma Niyeti
- Müşterilere [N] ay önceden bildirim
- Veri iadesi (export) süresi
- Sub-processors'la geçiş süreci

## Test
- Yıllık BCP test
```

---

## 15. Employee Security Training

> Solo dev için: bu dosya senin **kişisel security training log**'un.

```markdown
# Personel Güvenlik Eğitimi
**Şirket:** [Şirket Adı]
**Versiyon:** 1.0

## Politika
Tüm personel (founder dahil) yıllık güvenlik eğitiminden geçer.

## Solo Dev Eğitim Logu

### YYYY (cari yıl)
- [ ] OWASP Top 10:2025 review (4 saat)
- [ ] OWASP Cheat Sheet review (her ay 1 sheet, 12 saat/yıl)
- [ ] KVKK güncel mevzuat review (2 saat)
- [ ] Phishing awareness (kendi kendine, 1 saat)
- [ ] Social engineering training (kitap/video, 2 saat)
- [ ] Major breach postmortem reading (4 saat)

### Aktivite Log
| Tarih | Aktivite | Süre | Kaynak |
|---|---|---|---|
| YYYY-MM-DD | OWASP Top 10 review | 4 saat | owasp.org |
| YYYY-MM-DD | "..." postmortem oku | 1 saat | krebs on security |
| ... |

## Yıllık Toplam Eğitim Saati
[Hedef: 25 saat/yıl]
```

---

## 16. SBOM (Software Bill of Materials)

> Otomatik üretilen JSON. Manuel oluşturulmaz.

```bash
# Üretim
npx @cyclonedx/cyclonedx-npm --output-file evidence/16-sbom-current.json

# CI'da her release'de yeniden üret
# .github/workflows/security.yml içinde otomatize
```

CycloneDX standardı kullan. Müşterinin tedarikçi yönetim sistemi büyük ihtimalle SBOM kabul eder.

---

## Customer Onboarding Playbook

> Yeni kurumsal müşteri sözleşmeye gelince ne yapacaksın?

### 1. Satış Aşamasında (önbilgi)
Müşteri ilk teknik soru sorduğunda **bunu** gönder:
- `evidence/01-information-security-policy.md`
- `evidence/06-architecture-diagram.md`
- `evidence/11-encryption-overview.md`
- `evidence/12-sub-processors.md`

### 2. Due Diligence Aşamasında (compliance review)
Genelde tüm anketi karşılayacak `evidence/` ZIP'i. Çoğu müşteri:
- DPA imzalama isteği
- Soru anketi (SIG / CAIQ)
- Pen test özet rapor
- Sertifika (varsa SOC 2)

### 3. Sözleşme Aşamasında
- DPA müşteri'nin avukatı ile review
- Hizmet seviyesi anlaşması (SLA)
- Sub-processor onayı (varsa müşterinin kara listesi)

### 4. Onboarding Sonrası
- Erişim onayı (kim kim ile)
- Audit hakkı kullanımı (yıllık denetim için ayrılan zaman)
- Düzenli iletişim noktası (security contact)

---

## Sertifikasyon (Gelecekte)

`evidence/` paketin yeterince olgunlaştığında **SOC 2 Type II** veya **ISO 27001** sertifikası al. Bu:

- Kurumsal satışı 10x hızlandırır (anket sayısını dramatik azaltır)
- Maliyet: SOC 2 Type II ~$20-50k başlangıç + yıllık audit
- Süre: 3-12 ay hazırlık
- Tool: Vanta, Drata, Secureframe (otomasyon SaaS'ları)

Solo dev için: ilk 1-2 yıl evidence pack ile dene. Müşteriler X mile geldikten sonra SOC 2'ye yatırım yap.

---

## Tek-Sayfalık Müşteri Sunum

> Düşük karmaşıklıkta bir sales conversation için kullan.

```markdown
# [PROJE_ADI] — Security Snapshot

**Standartlar:** OWASP Top 10:2025, NIST SSDF, KVKK
**Hosting:** AWS Frankfurt (eu-central-1)
**Encryption:** At-rest AES-256 (KMS), In-transit TLS 1.2+
**Authentication:** MFA zorunlu (admin), strong password policy
**Backup:** PITR + cross-region snapshot, çeyreklik restore drill
**Monitoring:** Sentry, CloudWatch, BetterStack uptime
**Audit:** Aylık SAST/DAST, çeyreklik threat model, yıllık pen test
**KVKK:** Aydınlatma metni + DPA + 72 saat ihlal bildirimi süreci
**Incident Response:** Dokümante runbook, P0 yanıt 15 dk
**Sub-processors:** AWS, Cloudflare, Sentry (hepsi DPA imzalı)
**SBOM:** CycloneDX, her release'de güncel

Detaylı: evidence pack üzerinden NDA ile paylaşılır.
İletişim: security@[domain]
```

---

## Nasıl Güncel Tutulacak?

> `05-audit-cadence.md` ile entegre.

### Çeyreklik
- [ ] Tüm `evidence/` dosyalarını review
- [ ] Sub-processor değişikliği var mı?
- [ ] PII envanteri yeni veri tipi mi?
- [ ] Pen test güncel mi (yıllık tazele)?

### Yıllık
- [ ] Tüm dosyaları yeniden onayla (versiyon güncelle)
- [ ] Hukuk müşaviri review
- [ ] Müşteri feedback'leri ile zenginleştir

### Müşteri Anketi Geldiğinde
- [ ] 90% sorunun cevabı zaten evidence'ta — kopyala/yapıştır
- [ ] Eksik / yeni soru varsa, cevabı **evidence'a ekle** — bir sonraki müşteriye hazır olsun
