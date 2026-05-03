# 05 — Periyodik Denetim Takvimi

> Sistem yayında. Şimdi disiplin lazım. Bu doküman **günlük 5 dakikadan**, **yıllık 2-3 günlük** kapsamlı denetimine kadar her ritmin ne içerdiğini tanımlar.

Felsefe: **Hiç yapılmayan mükemmel kontroldense, her hafta yapılan iyi kontrol değerli.** Solo dev gerçeği — düzeni bozmadan sürdürülebilir bir ritim.

---

## Günlük (5 dakika)

> Sabah kahveni içerken yapacağın iş. Her sabah aynı saatte alışkanlık haline getir.

### Kontrol Noktaları
- [ ] **Status page** yeşil mi? (status.<domain>)
- [ ] **Sentry** son 24 saatte yeni high-impact issue var mı?
- [ ] **CloudWatch / monitoring** son 24 saat critical alarm geldi mi?
- [ ] **Failed login** sayısı normal aralıkta mı? (kabaca son 24 saat: <100)
- [ ] **5xx hata oranı** normal mi? (<%0.1)

### Aksiyon Tetikleyicileri
- Yeni Sentry issue → triage et, gerekirse Issue aç
- Alarm → ilgili `07-incident-response.md`'ye git
- Anormal failed login → IP tarama, gerekirse block

### Otomatize Et
Bunu **manuel** yapma. Bir Slack channel veya email digest kur:
- BetterStack uptime alerts → sürekli izle
- Sentry weekly digest → her sabah maile
- AWS Personal Health Dashboard → email aboneliği

**Hedef:** 5 dakikada bitsin. 5 dakikadan uzun sürerse, panel yetersiz.

---

## Haftalık (30 dakika)

> Cuma öğleden sonra veya Pazartesi sabahı. Geçen haftayı kapatıp yeni haftaya temiz başla.

### 1. Dependency Watchdog (10 dk)
- [ ] `dependency-watchdog` agent çalıştır
- [ ] Çıkan high/critical CVE'leri triage et
- [ ] Patch'leri PR olarak hazırla (Dependabot otomatik açar — review et)
- [ ] Outdated paket listesi 2+ major behind'a düşmüşse plan

### 2. Failed Login & Anomaly Pattern (5 dk)
- [ ] Geçen hafta failed login dağılımı (hangi IP'ler, hangi user'lar)
- [ ] Suspicious pattern: tek IP'den çok user, brute force, credential stuffing
- [ ] Gerekirse IP block veya WAF kuralı

### 3. CI/CD Health (5 dk)
- [ ] Geçen hafta tüm CI run'lar başarılı mı?
- [ ] Skip edilmiş veya disable edilmiş test var mı?
- [ ] Security workflow geçiyor mu?

### 4. AWS Cost & Anomaly (5 dk)
- [ ] AWS Cost Explorer — anormal artış var mı? (%20+ haftalık değişim şüpheli)
- [ ] Yeni resource'lar planlı mı?
- [ ] Beklenmeyen region'da resource var mı? (compromise göstergesi olabilir)

### 5. Audit Log Spot Check (5 dk)
- [ ] Audit log tablosunda son haftadan rastgele 10 kayıt seç
- [ ] Hepsinin tutarlı + anlamlı olduğunu doğrula
- [ ] Boş alan, NULL actor, garip action var mı?
- [ ] Sensitive event'ler (login failures, permission changes) düzgün yazılıyor mu?

### Haftalık Çıktı
`docs/security/audit-log/YYYY-WW.md` — kısa not:
```markdown
# Hafta YYYY-WW Audit Notları
- Dep updates: 3 patch (axios, zod, prisma)
- Failed login: normal range, tek IP'den 23 deneme — IP'yi 24 saat blokladım
- CI: tüm yeşil
- AWS cost: +%5 (beklenen artış, yeni feature)
- Log spot check: temiz
```

---

## Aylık (2 saat)

> Ayın ilk Pazartesisi. Daha derin tarama. Kanıt üret.

### 1. SAST Tam Tarama (30 dk)
- [ ] Semgrep / SonarCloud full scan
- [ ] Bulguları issue olarak aç
- [ ] False positive'leri ayır, ignore listesine al
- [ ] Skor değişimi (önceki aya göre)

### 2. OWASP ZAP / DAST Scan (30 dk)
- [ ] OWASP ZAP baseline scan production URL'ine
  ```bash
  docker run -t zaproxy/zap-stable zap-baseline.py -t https://app.example.com
  ```
- [ ] Bulgular triage
- [ ] Kanıt olarak `evidence/zap-scan-YYYY-MM.html` kaydet

### 3. AWS Security Hub & Findings (20 dk)
- [ ] AWS Security Hub findings panelini incele
- [ ] GuardDuty alert'lerini incele
- [ ] IAM Access Analyzer findings
- [ ] **Prowler** koştur:
  ```bash
  prowler aws --output-modes csv,html --severity high,critical
  ```
- [ ] Critical/High'ları kapat, Medium'ları planla

### 4. Backup Validation (15 dk)
- [ ] Otomatik backup'ların başarılı olduğunu doğrula
- [ ] Backup'ın boyutu mantıklı mı (azalmıyor mu?)
- [ ] Encryption hala aktif mi
- [ ] Çeyrekte 1 kez **restore drill** (aşağıda)

### 5. Sentry Issue Triage (15 dk)
- [ ] Yeni issue'ları gözden geçir
- [ ] Recurring issue'lar için bug fix planla
- [ ] Resolved issue'ların gerçekten çözüldüğünü doğrula

### 6. Müşteri & Bağımsız Müracaat (10 dk)
- [ ] `security@<domain>` mailbox'ı boş mu? (responder var ama unutulmasın)
- [ ] Bug bounty / responsible disclosure raporu var mı?

### Aylık Çıktı
`evidence/monthly-security-review-YYYY-MM.md`:
```markdown
# Aylık Güvenlik Review YYYY-MM

## Yapılan Taramalar
- Semgrep: X new findings (Y critical, Z high)
- ZAP: ...
- Prowler: ...
- npm audit: ...

## Kapatılan Bulgular
- ...

## Açık Bulgular & Plan
- ...

## Risk Acceptance
- ...
```

---

## Çeyreklik (1 gün — örn. tam 1 cuma)

> 3 ayda bir, daha kapsamlı bir gözden geçirme. "Yarım gün benim, yarım gün takım" diye düşün — solo dev'sen kendine ayır.

### 1. Threat Model Update (2 saat)
- [ ] Yeni feature'lar / yeni entegrasyonlar listele
- [ ] `threat-modeler` agent ile güncelle
- [ ] Yeni tehditler için mitigation planı
- [ ] `evidence/threat-model-vN.md` yeni versiyon

### 2. Restore Drill (1.5 saat)
- [ ] Production backup'ından **gerçek restore** dene (tabii test ortamına)
- [ ] Restore süresini ölç → RTO doğru mu?
- [ ] Veri tutarlılığı kontrol
- [ ] `evidence/dr-drill-YYYY-MM-DD.md` rapor yaz

### 3. Tabletop Incident Exercise (1 saat)
> Solo dev için: Hayali bir incident senaryosu üret, mental olarak çal.

Senaryo örnekleri:
- "Müşteri bana 'biri benim email ile login olmuş' yazdı"
- "Sentry'den 'unusual login from Russia' alarmı geldi"
- "AWS billing %200 artmış"
- "Müşteri portal'ından bir liste sızdırılmış, bana bildirildi"

Her senaryo için:
- İlk 15 dakika ne yapacağım?
- Kimi haberdar edeceğim?
- KVKK 72 saat gerekiyor mu?
- Iletişim taslağı (müşteri, kullanıcı, KVKK Kurumu) hazır mı?

### 4. Customer Evidence Pack Yenile (1 saat)
- [ ] PII envanteri güncel mi (yeni PII alanı eklendi mi?)
- [ ] Sub-processors değişti mi (yeni SaaS?)
- [ ] RBAC matrix değişti mi (yeni rol)?
- [ ] Architecture diagram güncel mi?
- [ ] SBOM yeniden üret (`@cyclonedx/cyclonedx-npm`)

### 5. Secret Rotation (1 saat)
- [ ] DB password rotation
- [ ] API key rotation (3. parti servislerde)
- [ ] JWT secret rotation (rolling — eski + yeni yan yana çalışsın)
- [ ] Cron `evidence/secret-rotation-log.md`'ye yaz

### 6. KVKK Compliance Review (30 dk)
- [ ] Aydınlatma metni hala doğru mu (yeni veri tipi eklendi mi?)
- [ ] Cookie banner kategorileri doğru mu
- [ ] Veri silme akışı hala çalışıyor mu (test silme yap)
- [ ] VERBİS bilgileri güncel mi

### Çeyreklik Çıktı
`evidence/quarterly-review-YYYY-QN.md` — kapsamlı rapor.

---

## Yıllık (2-3 gün)

> Yılda bir kez, tam stop, derin müracaat.

### 1. Bağımsız Penetration Test (2-5 gün — dış firma yapar)
- [ ] Pen test scope dokümanı hazırla
- [ ] Firma seç (Türkiye'de: Bilgi Güvenliği A.Ş., Pwc, Deloitte, KPMG, EY, BeyazNet)
- [ ] Test ortamı hazırla (production-like, ama production değil)
- [ ] Sonuçları al, Critical/High'ları **immediately** kapat
- [ ] Re-test ile doğrula
- [ ] Özet raporu `evidence/pentest-summary-YYYY.md`'de

### 2. Disaster Recovery Full Test (1 gün)
- [ ] Tüm production'ı yedek bölgeye / yedek altyapıya taşı (drill)
- [ ] DNS failover test
- [ ] Read-only mode → write mode geçişi
- [ ] Müşteriye bildirim akışı test (planned drill duyurusu)
- [ ] Sonuç → RTO, RPO gerçek değerleri

### 3. Compliance Review (1 gün)
- [ ] KVKK güncel mevzuat değişiklikleri
- [ ] Aydınlatma metni avukat review
- [ ] DPA güncellemesi (alt-yüklenici listesi)
- [ ] VERBİS güncellemesi
- [ ] (Opsiyonel) ISO 27001 / SOC 2 hazırlık değerlendirmesi

### 4. Architecture Review (yarım gün)
- [ ] Mimari hala uygun mu (ölçek, yeni feature'lar)
- [ ] Tech debt envanteri
- [ ] Major version migration planları (Node.js LTS, Next.js, Postgres)
- [ ] EOL (End of Life) gelen teknolojiler için plan

### 5. Personal Training (yarım gün)
> Solo dev için: kendini güncelle.
- [ ] Yıl içindeki büyük breach'leri oku (postmortem'lerini)
- [ ] OWASP Top 10 yeni versiyonu (4 yılda bir)
- [ ] Bir security konferans (videosu) izle
- [ ] Bu repo'yu güncelle: yıl içinde öğrendiğin yeni şeyler

### Yıllık Çıktı
`evidence/annual-review-YYYY.md` — tam rapor + sonraki yıl için aksiyon planı.

---

## Genel İlke: Kanıt Üret

Her audit aktivitesinin **bir output dosyası** var. Hiçbir kontrol "yapıldı ama izi yok" olmamalı. Çünkü:

1. **Kurumsal müşteri sorduğunda** göstereceksin
2. **Sertifika sürecinde** kanıt isteniyor
3. **Incident'tan sonra** geriye dönük analiz için
4. **Sen 6 ay sonra unuttuğunda** "yapmış mıydım?" sorusunun cevabı

`evidence/` klasör yapısı:
```
evidence/
├── audit-logs/
│   ├── 2025-W18.md
│   ├── 2025-W19.md
│   └── ...
├── monthly-reviews/
│   ├── 2025-04.md
│   ├── 2025-05.md
│   └── ...
├── quarterly-reviews/
│   ├── 2025-Q1.md
│   └── ...
├── annual-reviews/
│   └── 2025.md
├── dr-drills/
│   ├── 2025-04-15.md
│   └── ...
├── pentest-reports/
│   └── pentest-summary-2025.md
├── secret-rotation-log.md
├── threat-models/
│   ├── v1-2025-04.md
│   └── v2-2025-07.md
└── ...
```

---

## Audit Cadence Özet Tablo

| Sıklık | Süre | Ana Aktiviteler | Çıktı |
|---|---|---|---|
| **Günlük** | 5 dk | Status, Sentry, alarm scan | (otomatize, dosya yok) |
| **Haftalık** | 30 dk | Dep watchdog, login pattern, CI health, log spot check | `audit-logs/YYYY-WW.md` |
| **Aylık** | 2 saat | SAST, DAST, Prowler, backup validation, Sentry triage | `monthly-reviews/YYYY-MM.md` |
| **Çeyreklik** | 1 gün | Threat model, restore drill, tabletop, evidence yenileme, secret rotation | `quarterly-reviews/YYYY-QN.md` |
| **Yıllık** | 2-3 gün | Pen test, DR full, compliance, architecture, personal training | `annual-reviews/YYYY.md` |

---

## Solo Dev Gerçekçilik

Bu liste ideal. Solo dev gerçeği:

- **Günlük 5 dk:** evet, mutlaka yap
- **Haftalık 30 dk:** evet, kesin yap
- **Aylık 2 saat:** evet, takvimde sabit randevu
- **Çeyreklik 1 gün:** muhtemelen yarıma sıkıştırırsın — sorun değil, yine de yap
- **Yıllık 2-3 gün:** pen test + DR test ayrı ayrı, en az 1 günde toparlanır

**Hiç yapılmayan mükemmel kontroldense, basitleştirilmiş ama her zaman yapılan kontrol değerli.** Listeden bir şey atmak gerekirse, "yıllık" kategorisini "yarı yıllık çeyreklik" yapma — riskli.
