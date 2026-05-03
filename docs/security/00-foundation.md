# 00 — Temel: Felsefe ve Çerçeveler

> Bu doküman güvenlik repo'sunun "anayasası". Sıralı her şey buraya dayanır. Her yeni öğrenim ve her checklist maddesi, bu temel kavramlardan birini hayata geçirir.

---

## 1. CIA Triad — Her güvenlik kararının elek taşı

Güvenliği "hacker engelleme" olarak değil, üç sorunun cevabı olarak düşün:

| Harf | Açılım | Anlamı | Senin sorduğun |
|---|---|---|---|
| **C** | Confidentiality | Gizlilik | Yetkili olmayan görmesin |
| **I** | Integrity | Bütünlük | Yetkisiz değiştirilmesin |
| **A** | Availability | Erişilebilirlik | İhtiyaç anında ayakta olsun |

**Kullanımı:** Her tool/teknik incelediğinde sor — "Bu CIA'in hangi(leri)ni güçlendiriyor?"

- TLS şifreleme → C, I
- Audit log → I (inkâr edilemez)
- WAF + rate limit → A (DDoS koruması)
- MFA → C (kimliği doğrular)
- Backup + DR → A
- Encryption at rest → C
- Code signing → I

Eğer bir tool hiçbirini güçlendirmiyorsa, gerçekten gerekli mi diye sor.

---

## 2. Defense in Depth — Tek duvar değil, iç içe katmanlar

Bir saldırgan dış katmanı geçerse, içerideki katmanlar onu durdurmalı. Tipik bir web platformunda **7 katman**:

```
                                 ┌─────────────────────────────┐
                                 │  Katman 7: Geliştirme       │
                                 │  Süreci (CI, code review)   │
                                 └─────────────────────────────┘
                              ┌────────────────────────────┐
                              │  Katman 6: Gözlem           │
                              │  (Sentry, CloudWatch, log)  │
                              └────────────────────────────┘
                          ┌──────────────────────────────┐
                          │  Katman 5: Altyapı            │
                          │  (IAM, VPC, KMS)              │
                          └──────────────────────────────┘
                       ┌────────────────────────────┐
                       │  Katman 4: Veri              │
                       │  (Encryption, audit log)     │
                       └────────────────────────────┘
                    ┌────────────────────────────┐
                    │  Katman 3: Kimlik             │
                    │  (Auth, MFA, RBAC)            │
                    └────────────────────────────┘
                 ┌─────────────────────────────┐
                 │  Katman 2: Uygulama Kodu     │
                 │  (Validation, headers, CSP)  │
                 └─────────────────────────────┘
              ┌─────────────────────────────┐
              │  Katman 1: İnternet Sınırı    │
              │  (WAF, CDN, rate limit)       │
              └─────────────────────────────┘
   ┌─────────┐
   │ Saldırgan│
   └─────────┘
```

Her katmanda farklı tool'lar, farklı kontroller. Bir checklist maddesini hayata geçirirken hangi katmanı güçlendirdiğini bil.

---

## 3. OWASP Top 10:2025 — En kritik 10 web saldırı kategorisi

OWASP (Open Worldwide Application Security Project) her 4 yılda bir, gerçek saldırı verilerinden derlediği "en kritik 10" listesini yayınlıyor. **2025 versiyonu** en günceli ve bu repo onu temel alıyor.

| # | Kategori | Önceki sıra | Ne demek |
|---|---|---|---|
| **A01:2025** | Broken Access Control (SSRF dahil) | A01:2021 | Yetkisiz veri/işlem erişimi, IDOR, SSRF |
| **A02:2025** | Security Misconfiguration | A05:2021 ↑ | Default config, eksik header, açık port |
| **A03:2025** | Software Supply Chain Failures (yeni isim, genişletilmiş) | A06:2021 ↑ | Kütüphane CVE'si, malicious package, CI compromise |
| **A04:2025** | Cryptographic Failures | A02:2021 ↓ | Zayıf hash, MD5, plaintext password |
| **A05:2025** | Injection | A03:2021 ↓ | SQLi, XSS, command injection |
| **A06:2025** | Insecure Design | A04:2021 ↓ | Threat modeling eksik, insecure pattern |
| **A07:2025** | Authentication Failures | A07:2021 = | Zayıf şifre, session yönetimi |
| **A08:2025** | Software or Data Integrity Failures | A08:2021 = | Insecure deserialization, CI tampering |
| **A09:2025** | Security Logging & Alerting Failures (alert vurgusu yeni) | A09:2021 = | Log var ama alert yok |
| **A10:2025** | **Mishandling of Exceptional Conditions (YENİ)** | — | Hata yönetiminde fail-open, exception sızıntısı |

### 2025'te ne değişti?
- **SSRF (Server-Side Request Forgery)** artık A01'in altında — ayrı kategori değil
- **Supply chain** kategorisi büyütüldü (A03) — npm typosquatting, maintainer takeover gibi modern vektörler dahil
- **A10 yeni** — error handling konusu kendine özel kategori oldu (fail-secure vs fail-open)
- **A09'da "Alerting" eklendi** — sadece log değil, alarmı da ölçüyor

### Detay
Tam liste ve detaylı açıklamalar: <https://owasp.org/Top10/2025/>

---

## 4. NIST SSDF (Secure Software Development Framework)

NIST'in (ABD Ulusal Standartlar Enstitüsü) yayınladığı SP 800-218 dokümanı. **OWASP Top 10 "ne saldırılar var"** sorusunu cevaplıyorsa, **NIST SSDF "süreçte ne yapmalıyım"** sorusunu cevaplıyor.

4 kategoride 19 practice, toplam 42 task var. Özet:

### PO — Prepare the Organization (Organizasyonu Hazırla)
- Güvenlik gereksinimlerini yaz
- Roller ve sorumlulukları tanımla
- Toolchain'i hazırla
- Güvenlik eğitimi (sen kendin için bu repo)

### PS — Protect Software (Yazılımı Koru)
- Yazılımı yetkisiz değişiklikten koru (signed commits, branch protection)
- Yazılımı tüketime hazır hale getir (signed releases)
- Tüm release'lerin **arşivini ve çıkarımını koru** (provenance)

### PW — Produce Well-Secured Software (İyi Korunmuş Yazılım Üret)
- Güvenliği baştan tasarla (threat modeling)
- Re-use güvenli iyi-bilinen komponentleri (yeni icat etme)
- Source code'u review et (insan + tool)
- Insecure patterns kaldır
- Compromise edilmiş components için test et
- Eğitim al ve eğitim ver

### RV — Respond to Vulnerabilities (Açıklara Yanıt Ver)
- Açık keşif programı (security@... email)
- Açık doğrulama ve önceliklendirme süreci
- Açıklara yanıt ve raporlama
- Root cause analizi ve önleme

### Detay
SP 800-218 v1.1: <https://csrc.nist.gov/projects/ssdf>
SP 800-218 v1.2 (Aralık 2025 draft): aynı sayfa

---

## 5. OWASP ASVS — Verifiable Security Standard

OWASP'ın "ne kadar güvenli olmalı?" sorusuna verdiği cevap. 3 seviye:

| Level | Ne için | Hangi platformlar |
|---|---|---|
| **L1** | Tüm uygulamalar için minimum | Düşük hassasiyetli B2C |
| **L2** | Kritik veri içeren uygulamalar | Çoğu B2B SaaS, B2C orta-yüksek |
| **L3** | En yüksek değerli / kritik altyapı | Bankacılık, sağlık, askeri |

Senin durumunda (kurumsal B2B + KVKK) **L2 hedefi** uygundur.

ASVS, OWASP Top 10'u somut "test edilebilir gereksinim"lere dönüştürür. Örnek:

> ASVS V2.1.1 (Authentication): Verify that user passwords are at least 12 characters in length.

Her gereksinim **test edilebilir** ifadedir. Pen test firması veya kendi kendine test ederken kullanırsın.

GitHub: <https://github.com/OWASP/ASVS>

---

## 6. OWASP Cheat Sheet Series — Konu özelinde rehberler

OWASP Top 10 "neyi" söyler, ASVS "ne kadar"ı. **Cheat Sheet Series** ise "**nasıl**"ı söyler.

Her popüler güvenlik konusu için kısa, somut, action-oriented cheat sheet var:

- Authentication Cheat Sheet
- Session Management Cheat Sheet
- Authorization Cheat Sheet
- SQL Injection Prevention Cheat Sheet
- Cross-Site Scripting Prevention Cheat Sheet
- Cryptographic Storage Cheat Sheet
- HTTP Security Headers Cheat Sheet
- Content Security Policy Cheat Sheet
- JWT Cheat Sheet
- OAuth 2.0 Cheat Sheet
- File Upload Cheat Sheet
- Logging Cheat Sheet
- Input Validation Cheat Sheet
- ... ve 100+ tane daha

Bir konuyu implement etmeden önce ilgili cheat sheet'i 5 dakika oku. Çok zaman kazandırır.

URL: <https://cheatsheetseries.owasp.org/>

---

## 7. KVKK — Türkiye'ye Özel

Türkiye'de hizmet veren bir platform için KVKK (Kişisel Verilerin Korunması Kanunu) uyumluluğu **yasal zorunluluk**. GDPR'a benzer ama bazı farkları var.

Detay: `08-kvkk-compliance.md`

---

## 8. CIS Benchmarks — Cloud Sertleştirme

**Center for Internet Security (CIS)** her platform için "en güvenli config nasıl olmalı" rehberi yayınlıyor:

- CIS AWS Foundations Benchmark — AWS hesabını sertleştir
- CIS Docker Benchmark — Container'ları sertleştir
- CIS Kubernetes Benchmark — K8s cluster
- CIS Postgres / MySQL Benchmark — DB

**Tool:** **Prowler** (240+ AWS kontrolü, CIS dahil) — `06-tooling-catalog.md`'de detay.

---

## 9. STRIDE — Threat Modeling Çerçevesi

Microsoft'un geliştirdiği, **mimari aşamada** kullanılan tehdit kategorisi sistemi:

| Harf | Tehdit | CIA bağlantısı |
|---|---|---|
| **S** | Spoofing | C |
| **T** | Tampering | I |
| **R** | Repudiation | I |
| **I** | Information Disclosure | C |
| **D** | Denial of Service | A |
| **E** | Elevation of Privilege | hepsi |

Yeni bir feature tasarlarken `threat-modeler` agent'ı bu çerçeveyi kullanır.

---

## 10. Çerçeveler Arası Eşleme

Bu çerçeveler ayrı ayrı kafanı karıştırmasın. Hepsi aynı şeyi farklı açıdan söylüyor:

| Sorun | Çerçeve cevap verir |
|---|---|
| **Ne korumalıyım?** | CIA Triad |
| **Hangi katmanları kurmalıyım?** | Defense in Depth (7 katman) |
| **Hangi spesifik saldırılar var?** | OWASP Top 10:2025 |
| **Süreçte ne yapmalıyım?** | NIST SSDF |
| **Ne kadar güvenli olmalı?** | OWASP ASVS (L1/L2/L3) |
| **Bunu nasıl implement ederim?** | OWASP Cheat Sheet Series |
| **Yeni feature için hangi tehditler?** | STRIDE |
| **Türkiye'de hangi yasal zorunluluk?** | KVKK |
| **AWS / Docker'ı nasıl sertleştiririm?** | CIS Benchmarks |

---

## 11. Sonraki Adımlar

Bu temeli okuduktan sonra:

1. **`01-phase-1-project-kickoff.md`** — yeni projeye nasıl başlayacaksın
2. **`02-phase-2-coding-rules.md`** — günlük kod yazma kuralları, OWASP Top 10:2025 mapping
3. **`06-tooling-catalog.md`** — hangi tool ne işe yarar
4. **`08-kvkk-compliance.md`** — Türkiye-özel uyumluluk

---

## 12. Kaynaklar (Bookmark Et)

| Kaynak | URL |
|---|---|
| OWASP Top 10:2025 | <https://owasp.org/Top10/2025/> |
| OWASP Cheat Sheet Series | <https://cheatsheetseries.owasp.org/> |
| OWASP ASVS | <https://github.com/OWASP/ASVS> |
| NIST SSDF (SP 800-218) | <https://csrc.nist.gov/projects/ssdf> |
| Awesome AppSec | <https://github.com/paragonie/awesome-appsec> |
| Awesome Application Security Checklist | <https://github.com/MahdiMashrur/Awesome-Application-Security-Checklist> |
| KVKK Resmi | <https://www.kvkk.gov.tr/> |
| CIS Benchmarks | <https://www.cisecurity.org/cis-benchmarks> |
| CWE (Common Weakness Enumeration) | <https://cwe.mitre.org/> |
| NVD (CVE database) | <https://nvd.nist.gov/> |
