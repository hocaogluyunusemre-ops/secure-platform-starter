# 08 — KVKK Uyumluluğu (Türkiye)

> Türkiye'de hizmet veren bir platform için KVKK (Kişisel Verilerin Korunması Kanunu) uyumluluğu **yasal zorunluluk**. Kurumsal müşterin Arçelik / Aon / AXA gibi olduğunda da DPA (Data Processing Agreement) imzalaman gerekiyor.

> **Hukuki uyarı:** Bu doküman teknik bir referans rehberidir, hukuki tavsiye değildir. Production'a çıkmadan önce **mutlaka avukatla** aydınlatma metni ve sözleşmelerini gözden geçirtin.

---

## 1. KVKK Hızlı Özeti

KVKK = Kişisel Verilerin Korunması Kanunu (No. 6698, 2016'da yürürlüğe girdi). Avrupa GDPR'ına paralel ama bazı farkları var.

### Kapsam
- Türkiye'de yerleşik herkes
- Türkiye'de yerleşik kişilerin verisini işleyen yabancı kuruluşlar (extraterritorial)
- "Veri Sorumlusu" (Controller) ve "Veri İşleyen" (Processor) ayrımı GDPR ile aynı

### Özet İlke
> Kişisel veriyi **toplamadan önce** ne için, ne kadar süreyle, kiminle paylaşılacağını kullanıcıya **şeffafça** anlat. Açık rıza al (gerekiyorsa). Sınırlı amaçla işle. Süresi bitince sil. Talep edenlere ver / sil / taşı.

---

## 2. Roller: Sen Veri Sorumlusu musun, İşleyen mi?

Bu net olmalı. Yanlış cevap, yanlış yükümlülük demek.

### Veri Sorumlusu (Controller)
- Verinin **niçin** işleneceğine **karar veren**
- KVKK'nın ana yükümlüsü
- Aydınlatma metni hazırlamak, açık rıza almak, ihlal bildirimi yapmak senin görevin

### Veri İşleyen (Processor)
- Veriyi **başkasının adına işleyen** (genelde teknik servis sağlayıcı)
- Sorumlu'nun talimatları doğrultusunda hareket eder
- Daha sınırlı yükümlülükler ama yine de var

### Senin Durumun Genelde
| Senaryo | Rol |
|---|---|
| Kendi B2C ürünün, kullanıcı senin sitene kayıt oluyor | **Veri Sorumlusu** |
| Arçelik için bir platform yazıyorsun, Arçelik bayilerinin verisini Arçelik adına işliyorsun | **Veri İşleyen** (Arçelik = Sorumlu) |
| Aon ile kuruyorsun, ama servis senin, müşteri senin | **Veri Sorumlusu** (Aon = alt-yüklenici / partner) |

> **Hibrit durumlar var.** Her sözleşmede bu rolü açıkça yaz.

---

## 3. VERBİS Kaydı

VERBİS = Veri Sorumluları Sicil Bilgi Sistemi. <https://verbis.kvkk.gov.tr/>

### Kayıt zorunlu mu?
- **Yıllık çalışan sayısı 50+** veya **yıllık mali bilanço 25M TL+** olan ticari işletmeler için **zorunlu**
- Diğer kriterler için: <https://www.kvkk.gov.tr/Icerik/2055>

### Kayıt olduğunda doldurman gerekenler
- Veri kategorileri (kim hakkında ne tip veri tutuyorsun)
- Veri konusu kişi grupları (müşteri, çalışan, ziyaretçi)
- İşleme amaçları
- Saklama süreleri
- Yurtiçi / yurtdışı paylaşılan kişiler
- Alınan teknik / idari tedbirler

### Solo dev için
- Sen başlangıçta küçükken kayıt zorunlu olmayabilir
- Ama **kurumsal müşterin** Arçelik / Aon / AXA seninle çalışmadan önce VERBİS kaydını isteyebilir
- En iyisi: kayıt eşiğini geçmesen bile **gönüllü** kayıt yap, müşteriye güven ver

---

## 4. Aydınlatma Metni

KVKK Madde 10: Veri toplanmadan **önce** kullanıcıyı aydınlatmak zorunlu.

### Içermesi Gerekenler
- Veri Sorumlusu kim (şirket adı, iletişim)
- Hangi veri toplanıyor
- Toplama yöntemi (form, çerez, üçüncü taraf, vs.)
- Toplama amacı (hizmet sunma, yasal yükümlülük, vs.)
- Kimlere aktarılıyor (alt-yükleniciler, partner'ler)
- Yurtdışına aktarılıyor mu (AWS Frankfurt = AB, açıkça yaz)
- Saklama süresi
- KVKK Madde 11 hakları (erişim, düzeltme, silme, taşıma, itiraz)
- İletişim (genelde `kvkk@<domain>` veya `bilgi@<domain>`)

### Şablon (`evidence/aydinlatma-metni.md`'ye koy, avukatla onayla)

```markdown
# [PROJE_ADI] Kişisel Verilerin Korunması Hakkında Aydınlatma Metni

## 1. Veri Sorumlusu
[Şirket adı], [adres], VERBİS Sicil No: [varsa].
İletişim: kvkk@[domain]

## 2. Toplanan Kişisel Veriler
[PROJE_ADI] kullanımınız sırasında aşağıdaki veriler toplanmaktadır:
- **Kimlik bilgileri:** Ad, soyad, [varsa] TC kimlik no
- **İletişim bilgileri:** Email, telefon, adres
- **Müşteri işlem bilgileri:** [iş sürecine göre]
- **Teknik bilgiler:** IP adresi, tarayıcı bilgisi, oturum bilgisi (cookies)
- **[Diğer]**

## 3. Toplama Yöntemi
- Web sitesi formları
- Çağrı merkezi (varsa)
- Kullanım sırasında otomatik (cookie, log)
- Üçüncü taraf entegrasyonlar (Auth0, Stripe, vs.)

## 4. İşleme Amaçları
- [PROJE_ADI] hizmetinin sunulması
- Müşteri desteği
- Yasal yükümlülüklerin yerine getirilmesi (yasal saklama, vergi, vs.)
- Hizmet kalitesinin iyileştirilmesi
- Güvenlik (fraud prevention, audit log)

## 5. Aktarım
Verileriniz aşağıdaki kişi/kurumlarla paylaşılır:
| Kim | Amaç | Lokasyon |
|---|---|---|
| AWS (Amazon Web Services) | Hosting, hizmet sunumu | AB - Frankfurt |
| Sentry | Hata izleme | AB - Frankfurt |
| Stripe (varsa) | Ödeme | ABD (Privacy Shield / SCC ile) |
| ... |

## 6. Saklama Süresi
- Hesap aktif olduğu süre + [N] yıl (yasal saklama)
- Audit log: [M] ay
- Ödeme verileri: [yasal saklama gereği]

## 7. Haklarınız (KVKK Madde 11)
- **Erişim:** Hangi veriniz işleniyor öğrenme
- **Düzeltme:** Yanlış / eksik veriyi düzeltme
- **Silme:** Veriyi silme talebi
- **Taşıma:** Veriyi başka platforma aktarma
- **İtiraz:** İşlemeye itiraz
- **Tazminat:** İhlal sonucunda zarar varsa

Bu hakları kullanmak için: kvkk@[domain]

## 8. İletişim
Soru / talep / şikayet: kvkk@[domain]
KVKK Kurumu: <https://www.kvkk.gov.tr/>
```

### Aydınlatma Metni Nereye Koymalı?
- Web sitesinde her formun ALTINDA link
- Footer'da kalıcı link
- Kayıt formunda **checkbox**: "Aydınlatma metnini okudum ve anladım"
- API ile kayıt varsa: ilk kullanım onayı

---

## 5. Açık Rıza vs. Diğer Hukuki Sebepler

KVKK Madde 5: Veri işlemek için **açık rıza** yeterli ama **tek seçenek değil**.

### Açık Rıza Almadan İşleyebileceğin Durumlar (Madde 5/2)
- Kanunlarda açıkça öngörülmüşse (örn: vergi mevzuatı)
- Sözleşmenin kurulması veya ifası için zorunlu (servis sözleşmesi)
- Veri sorumlusunun hukuki yükümlülüğü için zorunlu
- Hak tesisi, kullanılması veya korunması için zorunlu
- Veri sorumlusunun meşru menfaati için zorunlu (kullanıcı haklarını ihlal etmemesi koşuluyla)
- Kişinin kendisi tarafından alenileştirilmiş

### Açık Rıza Gereken Durumlar
- Pazarlama emaili (newsletter, kampanya)
- Profilleme & advertising
- Hassas veri (sağlık, ırk, din — özel nitelikli veri)
- Yurtdışı transfer (uygun korumanın olmadığı ülkeye)

### Best Practice
- "Kayıt ol" formunda servisi sunmak için zorunlu veriler için **açık rıza alma** — sözleşme ifası için zorunlu sayılır
- Pazarlama için **ayrı opt-in checkbox**: pre-checked YASAK
- "Bu sitede çerez kullanıyoruz, kabul ediyor musunuz?" — analytics için açık rıza

---

## 6. Cookie Politikası

KVKK + ePrivacy benzeri yaklaşım. Cookie banner'ın aşağıdaki kategorileri sunması gerek:

| Kategori | Açıklama | Default |
|---|---|---|
| **Zorunlu (Strictly Necessary)** | Site çalışması için (auth, csrf) | Açık (rıza gereksiz) |
| **Performans / Analytics** | Google Analytics, vs. | **Kapalı** (opt-in) |
| **Pazarlama / Tracking** | Reklam ağı, retargeting | **Kapalı** (opt-in) |
| **Fonksiyonel** | Tema, dil tercihi | Tercih ediliyorsa açık (anlaşılabilir) |

### Tool önerisi
- **Cookiebot** veya **OneTrust** — kurumsal
- **Klaro** — open source, hafif
- Manuel — basit projeler için

### "Reject all" zorunlu
Kullanıcı tüm non-essential cookies'i tek tıkla reddedebilmelidir.

---

## 7. Kullanıcı Hakları — Teknik Hazırlık

KVKK Madde 11 hakları için **teknik akışların** olmalı:

### 7.1 Erişim Hakkı
Kullanıcı "verim ne?" sorusuna **30 gün içinde** cevap vermek zorundayım.

**Implementation:**
- Kullanıcı hesap → "Verilerim" sayfası
- Tek tıkla JSON / PDF export
- Email tabanlı talepler için: `kvkk@<domain>` mailbox + ticket sistemi

### 7.2 Düzeltme Hakkı
**Implementation:**
- Profil sayfasında düzenleme
- Düzeltilmeyen alanlar (TC kimlik gibi) için manuel süreç

### 7.3 Silme Hakkı (Right to Erasure)
**Implementation:**
- Kullanıcı hesap → "Hesabımı sil"
- Soft delete önce (30 gün geri alınabilir)
- Hard delete sonra (PII'yi silmek + veya anonimize)
- Audit log: silme talebi tarihi, kim talep etti

**Kritik:** Yasal saklama yükümlülüğü olan veriyi (örn. fatura) silmiyorsun, **anonimize** ediyorsun. Bu durumda KVKK uyumlu çünkü artık "kişisel veri" değil.

### 7.4 Taşıma Hakkı (Data Portability)
**Implementation:**
- Export endpoint: kullanıcı kendi verisini machine-readable formatta indirebilsin
- JSON format standart, CSV alternatif

### 7.5 İtiraz Hakkı
- Pazarlama için kolay opt-out (her email'de unsubscribe link)
- Profilleme için kolay opt-out

---

## 8. Teknik Önlemler (KVKK Madde 12)

KVKK "veri güvenliği için **gerekli teknik ve idari tedbirleri** alacaksın" diyor. Hangi tedbirler?

### Teknik Tedbirler
- Encryption at-rest ve in-transit ✓ (Faz 3 checklist)
- Strong authentication (MFA) ✓
- Access control (RBAC) ✓
- Audit logging ✓
- Backup ve DR ✓
- Vulnerability management (`05-audit-cadence.md`) ✓
- Incident response (`07-incident-response.md`) ✓
- Sub-processor due diligence ✓

### İdari Tedbirler
- Veri Koruma Görevlisi (DPO) atama (büyük kuruluşlar için)
- Çalışan eğitimi (solo'sun ama "personal training log" tut)
- Yetki düzeyleri (need-to-know prensibi)
- Düzenli denetim (audit cadence)
- Sözleşmeler (DPA, NDA)
- Veri envanteri (PII inventory)
- İhlal müdahale planı

---

## 9. Yurtdışı Veri Aktarımı

KVKK Madde 9: Yurtdışına veri aktarımı **kısıtlı**. AWS Frankfurt = AB ama yine de dikkat.

### Türkiye'den Yurtdışına Aktarım Kuralları
1. **Kişinin açık rızası** ile, VEYA
2. KVKK'nın "yeterli koruma" listesine giren ülkeler (henüz açıklanmadı tam liste; AB ülkeleri büyük olasılıkla geçecek), VEYA
3. KVKK Kurulu izni ile, VEYA
4. **Taahhütname** + Kurul izni — Standart Sözleşmesel Hükümler benzeri

### Pratikte
- AWS Frankfurt (eu-central-1) → AB - güvenli
- AWS Virginia (us-east-1) → ABD - rıza veya taahhütname gerek
- Stripe (US-based) → açık rıza + DPA
- Google Analytics → opt-in açık rıza

**Best practice:** Hassas veriyi **AB veya Türkiye region**'da tut. ABD'ye gitmek zorundaysa açık rıza al.

---

## 10. Sözleşmeler

### 10.1 Aydınlatma Metni
Yukarıda detaylı (Bölüm 4)

### 10.2 KVKK Açık Rıza Metni (gerekiyorsa)
Pazarlama, profilleme, hassas veri için ayrı.

### 10.3 Veri İşleme Sözleşmesi (DPA — Data Processing Agreement)
Müşteri (Sorumlu) ↔ Sen (İşleyen) — **mutlaka** imzalı.

İçeriği:
- İşlenen veri tipleri ve amaçları
- Süre
- Talimatlar
- Güvenlik tedbirleri (yukarıdakiler)
- Alt-yüklenici onayı
- İhlal bildirimi süreci (genelde 24-48 saat — Sorumlu'nun KVKK'ya 72 saat içinde bildirebilmesi için)
- Sözleşme bitince veri silme / iade
- Audit hakkı (Sorumlu seni denetleyebilir)

### 10.4 Sub-Processor Listesi (Alt-Yüklenici)
`evidence/sub-processors.md`:

| Sub-processor | Hizmet | Lokasyon | DPA imzalandı |
|---|---|---|---|
| AWS | Hosting | EU - Frankfurt | ✓ (AWS GDPR DPA otomatik) |
| Sentry | Error tracking | EU | ✓ |
| Cloudflare | CDN/WAF | Global | ✓ |
| Stripe (varsa) | Payment | US (with SCC) | ✓ |
| Auth.js / Clerk | Auth | varies | ✓ |

Yeni sub-processor eklediğinde:
- DPA al ve imzala
- Müşteriye bildir (DPA'da bildirim süreci yazılı olmalı)

---

## 11. İhlal Bildirimi (72 Saat)

KVKK Madde 12: **Veri ihlali tespit edildiğinde en kısa sürede ve mümkünse 72 saat içinde** Kuruma bildirim.

Detay: `07-incident-response.md` Bölüm 3.

---

## 12. Aylık / Yıllık KVKK Hijyeni

> `05-audit-cadence.md` ile entegre çalış.

### Çeyreklik
- [ ] Aydınlatma metni güncel mi (yeni veri tipi eklendi mi)?
- [ ] Sub-processor listesi güncel mi?
- [ ] PII envanter güncel mi?
- [ ] Veri silme süreci test (1 test silme yap)?
- [ ] Cookie banner kategorileri doğru mu?

### Yıllık
- [ ] Aydınlatma metni avukat review
- [ ] DPA güncellemesi
- [ ] VERBİS güncellemesi
- [ ] KVKK mevzuat değişiklikleri review (Resmi Gazete takip et)
- [ ] Türkiye yurtdışı transfer beyaz listesi yayınlandı mı kontrol

---

## 13. KVKK vs. GDPR Farkları (Kısaca)

GDPR'a benzer ama:

| Konu | KVKK | GDPR |
|---|---|---|
| İhlal bildirimi süresi | "En kısa sürede, mümkünse 72 saat" | 72 saat (sıkı) |
| Ceza | 1.000.000 TL'ye kadar (KVKK Madde 18) | 20M EUR veya cironun %4'ü |
| Yurtdışı transfer | Kurumdan açık izin gerekebilir | "Adequacy decision" + SCC |
| DPO atama eşiği | 50 çalışan / 25M ciro | Daha esnek kriterler |
| Çocuk verisi | 18 yaş altı veliye gerek | 16 yaş (üye devlet 13'e indirebilir) |
| Right to be forgotten | "Silme hakkı" — biraz daha sınırlı | Daha geniş |

---

## 14. Kaynaklar

| Kaynak | URL |
|---|---|
| KVKK Resmi Site | <https://www.kvkk.gov.tr/> |
| KVKK Mevzuat | <https://www.kvkk.gov.tr/Icerik/2030/> |
| VERBİS | <https://verbis.kvkk.gov.tr/> |
| Veri İhlali Bildirim Formu | <https://www.kvkk.gov.tr/Icerik/2030/Veri-Ihlali-Bildirim-Formu> |
| KVKK Aydınlatma Metni Hazırlama Rehberi | <https://www.kvkk.gov.tr/Icerik/5384/Aydinlatma-Yukumlulugunun-Yerine-Getirilmesi-Rehberi> |
| GDPR (karşılaştırma için) | <https://gdpr.eu/> |

---

## 15. Solo Dev için Pragmatik Notlar

1. **Avukat tut.** Aylık 1-2 saat avukat çok pahalı değil, KVKK ihlali ise çok pahalı (1M TL'ye kadar ceza). En azından aydınlatma metnini onaylatın.

2. **VERBİS kayıt** zorunlu olmasa bile, **kurumsal müşterin isteyecektir**. Önceden hazırlan.

3. **DPA template'in olsun.** Her yeni müşteride sıfırdan yazma. Bir kez avukatla yaz, bütün müşterilere sun.

4. **Aydınlatma metni canlı bir döküman.** Yeni feature, yeni veri tipi → güncelle. Site footer'da "Son güncelleme tarihi" yaz.

5. **Müşteri sorduğunda hazır ol.** Sub-processors listesi, PII envanteri, security policy — `evidence/` altında tut.

6. **Veri ihlali için tatbikat yap.** İlk gerçek incident'ında öğrenme, çeyreklik tatbikat ile öğren.
