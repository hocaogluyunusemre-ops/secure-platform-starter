# 07 — Incident Response Runbook

> Bir şey ters gitti. Panik yapmak yerine **yazılı bir planı** takip et. Bu doküman tam o plan.

Felsefe: **İyi olmuş bir incident response, kötü olmuş bir incident'tan daha az hasar verir.** Hız, doğruluk ve şeffaflık.

---

## 1. Severity Sınıflandırması

Bir alarm geldiğinde / şüphe duyduğunda **ilk 5 dakika** sınıflandır:

| Severity | Tanım | Tipik Örnek | İlk Yanıt Süresi |
|---|---|---|---|
| **P0 — Critical** | Sistem comprehensively down VEYA aktif veri sızıntısı | Production down, ransomware, hacker veri çekiyor | **15 dakika** |
| **P1 — High** | Önemli feature çalışmıyor VEYA güvenlik açığı aktif sömürülmüş | Login down, kritik API 500 dönüyor, IDOR açığı tespit | **1 saat** |
| **P2 — Medium** | Performans degradation VEYA sınırlı etki | Yavaşlık, küçük feature down, az kullanıcıyı etkileyen bug | **4 saat** |
| **P3 — Low** | Kullanıcı etkisi minimum, planlanabilir | Logo bozuk, edge case bug | **24 saat** |

### Sınıflandırma Soruları
- Kaç kullanıcı etkileniyor? (1 mi, 100 mü, hepsi mi?)
- Veri etkilenmiş mi? (silinmiş, sızdırılmış, bütünlüğü bozulmuş)
- Kötü niyetli aktör var mı? (bug mı, saldırı mı?)
- KVKK kapsamına giriyor mu? (kişisel veri etkilenmiş mi)
- Müşteri biliyor mu, bilmesi gerekiyor mu?

---

## 2. Incident Response Akışı (NIST 800-61 + Praktik)

```
┌────────┐   ┌──────────┐   ┌──────────┐   ┌────────────┐   ┌─────────┐   ┌─────────────┐
│ DETECT │ → │  TRIAGE  │ → │ CONTAIN  │ → │ ERADICATE  │ → │ RECOVER │ → │ POSTMORTEM  │
└────────┘   └──────────┘   └──────────┘   └────────────┘   └─────────┘   └─────────────┘
   ↓            ↓               ↓                ↓                ↓               ↓
  Alarm,      Severity         Yayılmayı       Kök nedeni      Servisi          Yazılı
  şüphe       belirle,         engelle         gider           normalleştir     analiz
              kanıt başlat     (rate limit,                                     blame-free
                               IP block,                                        action items
                               feature flag)
```

### Detect (Tespit)
Kaynak ne olabilir:
- Sentry yeni high-impact issue
- CloudWatch / Datadog alarm
- Status page kontrol başarısız
- Kullanıcı bildirimi (`security@<domain>` mail, support ticket)
- Bağımsız researcher (responsible disclosure)
- Senin gözlemin (anormal log pattern, garip latency)

**Aksiyon:** Saatini not et. Bu **incident timeline**'ın 0. dakikası.

### Triage (Önceliklendirme)
- Severity belirle (P0/P1/P2/P3)
- **Incident channel aç** (Slack #incident-YYYY-MM-DD, veya Discord, veya gerçek bir doc)
- Incident commander seç (solo dev'sen sen, ama rolü açıkça üstlen)
- Initial timestamp + ne öğrendin yaz

**Aksiyon:** `incidents/YYYY-MM-DD-shorttitle.md` dosyası aç.

### Contain (Kapat)
**Yayılmayı durdur. Düzeltme sonra.** Acil müdahale seçenekleri:

| Senaryo | Containment |
|---|---|
| Bir endpoint exploit ediliyor | Rate limit sıkılaştır, gerekirse endpoint disable et |
| Bir IP saldırıyor | WAF / Cloudflare'den IP block |
| Bir hesap compromise | Hesabı disable et, tüm session'ları invalidate et |
| Bir 3. parti API key sızmış | Anahtarı revoke et |
| Database injection | Vulnerable endpoint disable / read-only mode |
| Ransomware şüphesi | Etkilenen servisleri DOWN — backup'lara dön |
| Kötü deploy | **Rollback** — yeni özelliği sonra tartışırız |

**Hata yapma:** Containment, "düzeltme" değil. Düzeltmeden önce yayılmayı durdur.

### Eradicate (Kök neden)
- Saldırgan hala içeride mi?
- Açıklık nerede? (kod, config, infra)
- Compromise edilen credential'lar var mı? (rotate et)
- Backdoor / persistence mekanizması bırakılmış mı?
- Logları analiz et — saldırgan ne kadar süredir içerideydi?

### Recover (Toparlanma)
- Servisi normalleştir
- Kullanıcıyı bilgilendir (status page güncelle)
- Monitoring'i sıkılaştır (aynı saldırı tekrar olursa hemen yakala)
- 24-48 saat **heightened monitoring** (alarm threshold'ları geçici düşür)

### Postmortem (Olay Sonrası Analiz)
**24 saat içinde** taslak, **1 hafta içinde** final.

Format:
```markdown
# Postmortem: [Incident Title]
**Tarih:** YYYY-MM-DD
**Severity:** P0
**Süre:** Detect → Recover: X saat Y dakika
**Etkilenen kullanıcı:** ~N kişi
**Etkilenen veri:** [açıkla]

## Özet (5 cümle)
[Ne oldu, ne kadar sürdü, ne yaptık]

## Timeline
- HH:MM — Alarm geldi (ilk tespit)
- HH:MM — Triage, P0 declared
- HH:MM — Containment: X yapıldı
- HH:MM — Kök neden tespit edildi
- HH:MM — Fix deploy edildi
- HH:MM — Servis normalleşti
- HH:MM — Kullanıcı bilgilendirme

## Kök Neden
[Teknik olarak ne oldu? Mümkünse 5-Why analizi]

## Etki
- **Kullanıcı:** [kaç kişi, ne yaşadı]
- **Veri:** [etkilenen veri tipi, KVKK ihlali var mı?]
- **İş:** [revenue impact, müşteri ilişkisi etkisi]

## Ne İyi Gitti?
[Neyi doğru yaptık, hangi mekanizmalar işe yaradı]

## Ne Kötü Gitti?
[Neyi yanlış yaptık, neyi geç fark ettik]

## Tetikleyicilerimiz
[Bu incident'ın olmasının sebepleri — yapısal, kültürel, teknik]

## Action Items
| # | Aksiyon | Sahip | Süre | Status |
|---|---|---|---|---|
| 1 | [Önleyici aksiyon] | [Kim] | [Tarih] | [Open/Done] |
```

**Blame-free olmalı.** Kişiyi suçlama, sistemi suçla. "Emre yanlış yaptı" yerine "Erken uyarı sistemi yetersizdi."

---

## 3. KVKK Veri İhlali — 72 Saat Kuralı

KVKK Madde 12: **Kişisel veri ihlali tespit edildiğinde, en geç 72 saat içinde** Kişisel Verileri Koruma Kurumu'na bildirim zorunlu.

### KVKK Kapsamına Giriyor mu? (Karar Kriterleri)
EVET ise:
- Kişisel veri etkilendiyse (isim, email, TC kimlik, vs.)
- Veri yetkisiz kişiler tarafından erişildi VEYA değiştirildi VEYA silindi
- Hesap verileri sızdırıldı

HAYIR ise:
- Sadece kullanıcı kendi verisini gördü
- Veri encrypted ve key sızmadı
- Anonymous/aggregate data

**Karar verilmiyorsa:** Bildirim yap. Daha sonra "ihlal yoktu" demektense, yapmış olmak güvenli.

### Bildirim Adımları
1. **İlk 24 saat:** Etkiyi belirle, hangi veri tipi, kaç kişi
2. **48 saat:** Bildirim taslağı hazırla
3. **72 saat:** KVKK Kurumu'na bildirim ([Bildirim formu](https://www.kvkk.gov.tr/Icerik/2030/Veri-Ihlali-Bildirim-Formu))
4. **Etkilenen kullanıcılara:** ihlal "yüksek risk" oluşturuyorsa **mümkün olan en kısa sürede** ayrıca bilgilendir

### Bildirim İçeriği
Form'da istenir:
- İhlal tarihi (saat dahil)
- İhlal tespiti tarihi
- İhlal türü (yetkisiz erişim / silme / değiştirme / ifşa)
- Veri kategorisi (kişisel / özel nitelikli)
- Etkilenen kişi sayısı
- Olası sonuçlar
- Alınmış / alınacak önlemler

---

## 4. İletişim Şablonları

### 4.1 İlk Müşteri Bildirimi (P0/P1)
**Konu:** [PROJE_ADI] — Servis Etkileniyor: [kısa başlık]

**Body:**
> Sayın [Müşteri Adı],
>
> [PROJE_ADI] platformunda [Tarih, Saat] itibariyle [Servis adı] hizmetinde bir aksaklık tespit ettik. Şu an [genel durum açıklaması].
>
> Mevcut durum:
> - Etki: [neyin etkilendiği]
> - Tahmini sebep: [varsa, belirsizse "araştırılıyor" yaz]
> - Yapılan müdahale: [containment adımları]
> - Tahmini çözüm süresi: [varsa]
>
> Status sayfamızdan gerçek zamanlı takip edebilirsiniz: [URL]
>
> Yenilemeleri her [X] dakikada bir paylaşacağız.
>
> Saygılarımla,
> [Adın]

### 4.2 Status Page Update
> **Investigating** — [Saat]: [Servis] üzerinde sorun yaşıyoruz. Araştırılıyor.
>
> **Identified** — [Saat]: Sorunun kaynağı [tespit] olarak belirlendi. Çözüm üzerinde çalışıyoruz.
>
> **Monitoring** — [Saat]: Düzeltme uygulandı. Servis normale döndü, izlemeye devam ediyoruz.
>
> **Resolved** — [Saat]: Sorun çözüldü. Postmortem [tarih]'e kadar paylaşılacaktır.

### 4.3 KVKK Veri İhlali Bildirimi
Resmi form üzerinden ([Form](https://www.kvkk.gov.tr/Icerik/2030/Veri-Ihlali-Bildirim-Formu)). Bizim hazırladığımız taslak:

```markdown
# KVKK Veri İhlali Bildirimi
**Veri Sorumlusu:** [Şirket Adı]
**VERBİS Sicil No:** [Numara]
**Bildirim Tarihi:** YYYY-MM-DD

## İhlal Detayları
- **İhlal tarihi:** YYYY-MM-DD HH:MM
- **Tespit tarihi:** YYYY-MM-DD HH:MM
- **İhlal türü:** [yetkisiz erişim / silme / değiştirme / ifşa]
- **İhlalin teknik tabiati:** [açıkla]

## Etkilenen Veri
- **Kategori:** [kişisel / özel nitelikli]
- **Veri tipleri:** [örn. ad-soyad, email, telefon, TC kimlik no]
- **Etkilenen kişi sayısı:** [tahmini]
- **Etkilenen kayıt sayısı:** [tahmini]

## Olası Sonuçlar
[Kişiler için potansiyel zarar — kimlik hırsızlığı, finansal kayıp, vs.]

## Alınan Önlemler
1. [Containment]
2. [Eradication]
3. [Recovery]
4. [Önleyici aksiyon]

## İletişim
- **Veri Koruma Görevlisi (varsa):** [İsim, email, telefon]
- **İletişim:** security@[domain]
```

### 4.4 Etkilenen Kullanıcı Bildirimi
**Konu:** Hesabınızı Etkileyebilecek Bir Güvenlik Olayı Hakkında Bilgilendirme

**Body:**
> Sayın [Kullanıcı],
>
> [PROJE_ADI] olarak, sizi etkileyebilecek bir güvenlik olayını **şeffaflıkla** paylaşmamız gerekiyor.
>
> **Ne oldu?**
> [Tarih]'te [genel durum]. Bu olay sonucunda **[veri tipleri]** etkilenmiş olabilir.
>
> **Sizden ricamız:**
> 1. Şifrenizi değiştirin: [Link]
> 2. Geçen 30 günde anormal aktivite görürseniz bize bildirin
> 3. (Eğer şüpheliyse) Banka kartınızla ilgili bankanızı uyarın
>
> **Bizim aldığımız önlemler:**
> - [Liste]
>
> **Sorularınız için:** [İletişim email]
>
> Bu olay için derin üzüntümüzü bildiriyoruz. Sürecin her adımında şeffaf olmaya çalışıyoruz.
>
> Saygılarımızla,
> [PROJE_ADI] Ekibi

---

## 5. Forensic Veri Toplama

Olay devam ederken **kanıtları kaybetme**:

### Toplanması Gerekenler
- [ ] CloudWatch / app log'ları (incident saatleri)
- [ ] Database snapshot (olay anına yakın)
- [ ] AWS CloudTrail log'ları (kimin ne yaptığı)
- [ ] VPC Flow Logs (network trafiği)
- [ ] WAF / Cloudflare log'ları
- [ ] Sentry error stack trace
- [ ] Kullanıcı sessions (etkilenen account'lar)
- [ ] Audit log dump (incident saatlerine ait)

### Saklama
- Tüm log'ları **read-only** copy halinde başka bir yere taşı
- En az **1 yıl** sakla (KVKK + olası dava için)
- Encryption ile koru

### Chain of Custody
Eğer hukuki süreç olabilirse:
- Toplanan kanıtın kim tarafından, ne zaman, nasıl alındığı yazılı
- Hash'i alınmış (kanıt değiştirilmedi ispatı)
- Sealed (zaman damgalı) backup

---

## 6. Senaryolara Göre Hızlı Aksiyon Kartları

### Senaryo: "DB Compromise — saldırgan veri çekiyor"
1. **0 dk:** Database connection'ları kes (read-only mode veya tamamen kapat)
2. **5 dk:** WAF'ta tüm trafiği bloklayan bir kural koy (bakım sayfası)
3. **10 dk:** AWS CloudTrail incele — saldırgan IP, hesap
4. **15 dk:** Compromise edilmiş credential'ları rotate et
5. **30 dk:** Forensic snapshot al (DB + logs)
6. **1 saat:** Saldırı vektörünü tespit et, fix et
7. **2 saat:** Servisi gradually aç
8. **24 saat:** KVKK bildirimi (gerekiyorsa)
9. **1 hafta:** Postmortem yayınla

### Senaryo: "Ransomware — sistem kilitlendi"
1. **0 dk:** Etkilenen sistemleri network'ten izole et
2. **5 dk:** Backup'ların etkilenmediğini doğrula
3. **10 dk:** Fidye ödeme **YASAK** (kabul etme)
4. **15 dk:** Yetkili makamları haberdar et (USOM, KVKK)
5. **30 dk:** Backup'tan restore başlat (drilledın senaryo bu zaten)
6. **2 saat:** Saldırı vektörünü tespit et
7. **24 saat:** Müşteri + KVKK bildirimi

### Senaryo: "Insider Threat — bir hesap hain davranıyor"
1. Hesabı **immediate disable** et
2. Tüm session'larını invalidate et
3. Audit log incelemesi başlat — son 90 gün ne yaptı
4. Erişim verdiği hassas veri var mı?
5. Hukuki süreç gerekirse yetkili makamlar
6. Erişim politikasını yeniden gözden geçir (least privilege)

### Senaryo: "Phishing — bir ekibin hesabı ele geçirildi"
1. Hesabı disable et
2. Şifre + MFA reset
3. Etkilenen hesabın last 30 gün aksiyonlarını incele
4. Yan kullanıcılara phishing uyarısı
5. Email gateway'de phishing rule sıkılaştır

### Senaryo: "Supply Chain — npm package'da malware tespit"
1. Etkilenen package'i belirle (`npm ls <package>`)
2. Kullanıldığı yerleri tespit (`grep -r <package>`)
3. Package'i remove veya pin previous version
4. Production deploy revert (eğer malware production'a gittiyse)
5. CI cache temizle, fresh install
6. Compromise olduysa secret rotation
7. Postmortem: nasıl içeri girdi, daha sıkı kontrol nasıl?

### Senaryo: "DDoS"
1. Cloudflare "Under Attack Mode" aktif et
2. Rate limit sıkılaştır
3. Origin IP gizle (Cloudflare orange cloud zorunlu)
4. AWS Shield kontrolü
5. Saldırgan IP'leri WAF'ta block
6. Saldırı süresinde monitoring artır

---

## 7. Iletişim Listesi (Doldur)

> Bu liste her sözleşmede güncellenmeli. **`evidence/incident-contact-list.md`** dosyasında tut, gizli.

| Kim | Rol | Email | Telefon | Saat |
|---|---|---|---|---|
| Sen | Tech lead / IR commander | [...] | [...] | 7/24 |
| Müşteri 1 (Arçelik) ana contact | Müşteri | [...] | [...] | İş saati |
| Müşteri 1 acil | Acil iletişim | [...] | [...] | 7/24 |
| AWS support (Business plan) | Cloud | — | aws.amazon.com/premiumsupport | 7/24 |
| Cloudflare support | CDN/WAF | — | dashboard | 7/24 |
| Hukuk müşaviri | Avukat | [...] | [...] | İş saati |
| KVKK Kurumu | Yasal | bilgi@kvkk.gov.tr | 0312 216 50 50 | İş saati |
| USOM | Siber olay | [...] | 0312 218 1818 | 7/24 |
| Pen test firması | Acil consult | [...] | [...] | İş saati |

---

## 8. Plan Hazırlığı (Pre-Incident)

İncident olmadan **şimdi** hazırla:

- [ ] Bu doküman güncel mi?
- [ ] İletişim listesi güncel mi?
- [ ] Status page hazır mı, sen nasıl güncelliyorsun?
- [ ] Backup restore drill yapıldı mı (son 90 gün)?
- [ ] Mock incident tabletop yapıldı mı (son 90 gün)?
- [ ] Forensic data toplama prosedürü test edildi mi?
- [ ] Communication template'leri elinde hazır mı?
- [ ] AWS Personal Health Dashboard email aboneliğin var mı?
- [ ] On-call notification kanalı (telefon, slack) test edildi mi?

---

## 9. Solo Dev için Önemli Notlar

1. **Yardım iste.** Solo'sun ama yalnız değilsin. Kötü bir incident'ta:
   - Hukuk müşavirin var (yoksa hemen bul)
   - AWS Business Support açık (incident için kritik)
   - Bir mentor / pen test firması ile aramayı dener misin?

2. **Hızlı kararlardan kaçın.** İlk 30 dakikada panik yapma. Containment yap, sonra düşün.

3. **Yazılı kal.** Her dakika notal. Sonradan postmortem için.

4. **Şeffaf ol.** Müşteri sorduğunda dürüst ol. "Hata yaptık, X yaptık, bir daha olmaması için Y yaptık" — saklamaya çalışmaktan iyidir.

5. **Stres yönetimi.** Incident sonrası 24-48 saat dinlen. Tükenmiş haldeyken yeni hata yaparsın.

---

## 10. Reference

- NIST 800-61: Computer Security Incident Handling Guide
- KVKK Madde 12 ve Veri İhlali Bildirim Tebliği
- USOM (Ulusal Siber Olaylara Müdahale Merkezi): <https://www.usom.gov.tr/>
- KVKK: <https://www.kvkk.gov.tr/>
- TR-CERT: <https://www.usom.gov.tr/tehdit/>
