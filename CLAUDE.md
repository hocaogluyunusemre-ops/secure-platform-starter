# CLAUDE.md

> Bu dosya Claude Code'un her oturumda otomatik okuduğu yerdir. Projenin "anayasası" gibidir. Yeni proje başlatırken `<<TUTUCU>>` alanlarını doldur.

---

## 1. Proje Bağlamı

| Alan | Değer |
|---|---|
| **Proje adı** | `<<PROJE_ADI>>` |
| **Kısa açıklama** | `<<1-2 cümle: ne işe yarıyor, kim kullanıyor>>` |
| **Müşteri tipi** | `<<B2B / B2C / B2B2C>>` |
| **Hassasiyet seviyesi** | `<<Düşük / Orta / Yüksek — kişisel veri varsa Yüksek>>` |
| **Kullanıcı rolleri** | `<<örn: Admin, Operasyon, Müşteri, Read-only>>` |
| **Tech stack** | `<<örn: Next.js 14 + TypeScript + Postgres>>` |
| **Hosting** | `<<örn: AWS ECS, eu-central-1>>` |
| **Veri lokasyonu** | `<<örn: AWS Frankfurt — KVKK için Türkiye/AB>>` |
| **KVKK kapsamı** | `<<Evet / Hayır>>` |
| **Production URL** | `<<https://...>>` |
| **Status page** | `<<https://...>>` |

---

## 2. Hassas Dosyalar — İZİNSİZ DOKUNMA

Aşağıdaki dosya/dizinlerde Claude **mutlaka kullanıcıya sorar** ve onay almadan değişiklik yapmaz:

- `.env*` ve tüm secret dosyaları
- `auth/`, `lib/auth/` veya kimlik doğrulama ile ilgili her dosya
- `middleware.ts` (RBAC kontrolleri burada)
- `lib/audit-log.ts` (audit log mekanizması)
- `lib/rate-limit.ts` (rate limiting)
- `infra/`, `terraform/`, `cdk/` (altyapı kodu)
- `.github/workflows/` (CI pipeline'ı)
- Veri tabanı migration dosyaları (`migrations/`, `prisma/schema.prisma`)
- `package.json` — yeni dependency eklerken önce sor
- `next.config.js` — security headers burada
- `.claude/settings.json` ve `.claude/agents/*` — Claude Code yapılandırması

---

## 3. Kod Yazma Kuralları (Hard Rules)

Her API endpoint, server action veya backend handler için **5'li altın kural**:

```typescript
// 1. AUTHENTICATION — kim?
const session = await requireSession();

// 2. AUTHORIZATION — yetkili mi?
requireRole(session, ['admin', 'operasyon']);

// 3. INPUT VALIDATION — geçerli mi?
const input = MySchema.parse(rawInput);

// 4. BUSINESS LOGIC — işi yap

// 5. AUDIT LOG — ne yapıldı?
await auditLog({
  actor: session.userId,
  action: 'CREATE_CLAIM',
  resource: claim.id,
  metadata: { ... }
});
```

Bu sırayla. Schema yoksa endpoint yok. Auth check ilk satırda. Audit log son satırda.

### Frontend kuralları
- **`dangerouslySetInnerHTML`** kullanmadan önce kullanıcıya sor
- **External link** açılırken `rel="noopener noreferrer"` zorunlu
- Form'larda **client + server validation** ikisi birden — sadece client yetmez
- Secret HİÇBİR koşulda client koduna girmez. `NEXT_PUBLIC_` prefix'li bir değişken secret olamaz
- LocalStorage'a token koyma — httpOnly cookie kullan
- Inline event handler yerine event listener kullan (CSP uyumluluğu)

### TypeScript kuralları
- `any` kullanma — gerçekten gerekiyorsa `unknown` + type guard
- Tüm fonksiyonlar typed input/output döndürür
- `// @ts-ignore` kullanma — çözümü bul veya kullanıcıya sor
- Strict mode açık olacak

### Database kuralları
- **Asla** string concat ile SQL inşa etme — her zaman parameterized query / ORM
- Soft delete tercih et, hard delete sadece KVKK silme talebinde
- Her sensitive tablo için `created_at`, `updated_at`, `deleted_at` kolonu olacak
- Migration'lar her zaman reversible olacak (`up` + `down`)

---

## 4. "Stop and Ask" Listesi

Aşağıdaki durumlarda Claude **işlem yapmaz, kullanıcıya sorar**:

### Üretim etkisi olabilecek
- Production'a deploy
- Migration / schema değişikliği
- Service restart
- DNS / domain değişikliği
- AWS resource silme veya değiştirme
- Cron job ekleme/değiştirme

### Veri etkisi olabilecek
- `DROP`, `DELETE`, `TRUNCATE` içeren SQL
- Tablo veya kolon silme
- Index drop
- Bulk update / delete

### Güvenlik etkisi olabilecek
- IAM, RBAC veya yetki kuralı değiştirmek
- Rate limiting değiştirmek
- Security header veya CSP gevşetmek
- CORS politikası değiştirmek
- Audit log'u devre dışı bırakmak veya filtrelemek
- Test'i `skip` etmek, security check'i bypass etmek
- `.env` veya secret dosyasına ekleme/değişiklik

### Bağımlılık etkisi olabilecek
- Yeni bir 3. parti servis/SDK eklemek
- Bir dependency'nin major version yükseltmesi
- Yeni MCP server bağlamak
- npm install çalıştırmak

### Geri dönüşsüz işlemler
- `git push --force`, `git rebase` ana branch'lerde
- `rm -rf`
- AWS S3 bucket boşaltma
- Kullanıcı silme

---

## 5. Asla Yapma Listesi (Hard Limits)

Bu liste rica değil, kuraldır. Claude bu işlemleri **kullanıcı onay verse bile** yapmaz:

| Kural | Sebep |
|---|---|
| Secret'ları kod içine hardcode etme | A02:2025 Security Misconfiguration |
| `eval()`, `Function()` veya dinamik kod yürütme | A05:2025 Injection |
| HTTP (HTTPS değil) endpoint'lerle haberleşme (gelişim ortamı dışında) | A04:2025 Cryptographic Failures |
| SQL'i string concat ile inşa etme | A05:2025 Injection |
| Şifre/token'ı plaintext loglama | A09:2025 Security Logging Failures |
| CORS'u `*` yapma (üretimde) | A01:2025 Broken Access Control |
| CSP'yi `unsafe-eval` veya `unsafe-inline` ile geniş bırakma | A02:2025 Security Misconfiguration |
| KVKK kapsamındaki kişisel veriyi log/error/analytics'e yansıtma | KVKK ihlali |
| Şifreyi MD5/SHA1 ile hash'leme | A04:2025 Cryptographic Failures |
| JWT'yi `none` algoritması ile imzalama | A07:2025 Authentication Failures |
| Pickle/serialize edilmiş untrusted data deserialize etme | A08:2025 Data Integrity Failures |

---

## 6. Otomatik Kontroller (CI'da Senin Yerine Çalışıyor)

Aşağıdaki kontroller her PR'da otomatik koşar. Hepsi yeşil olmadan merge yok:

| Kontrol | Tool | Yakaladığı OWASP kategori |
|---|---|---|
| TypeScript type check | `tsc` | A05 (tip kaynaklı injection) |
| Lint + security plugin | `eslint-plugin-security` | A05, A06 |
| Unit + integration testler | Vitest, Jest | A06 (insecure design) |
| Dependency vulnerability scan | `npm audit`, Snyk, Dependabot | A03 |
| Secret scanning | `gitleaks`, GitHub push protection | A02 |
| SAST (static analysis) | Semgrep | A01, A05, A07 |
| IaC scanning (varsa) | Checkov, tfsec | A02 |
| License compliance | `license-checker` | A03 (supply chain) |
| Container scan (varsa) | Trivy | A03 |
| SBOM üretimi | CycloneDX | A03 |
| Build success | — | — |

Detay için: `.github/workflows/security.yml`

---

## 7. Subagent'lar

Bu projede dört güvenlik odaklı subagent çalışır. Her birinin **kendine özel yetki sınırı** var:

| Agent | Görev | Tool kapsamı |
|---|---|---|
| `security-guardian` | Kod güvenlik review | Read-only (Read, Grep, Glob, Bash) |
| `pre-deploy-auditor` | Canlıya çıkış öncesi tam denetim | Read-only |
| `threat-modeler` | Mimari tehdit modeli (STRIDE) | Read-only + WebFetch |
| `dependency-watchdog` | Bağımlılık güvenlik tarayıcı | Read + Bash (sadece `npm audit`) |

**Hiçbiri kod yazmaz, hiçbiri deploy etmez, hiçbiri yetki değiştirmez.** Hepsi rapor üretir, ana ajan (sen + Claude) kararı verir.

Detay: `.claude/agents/*.md`

---

## 8. İlgili Dökümanlar

| Doküman | Ne zaman kullanılır |
|---|---|
| `docs/security/00-foundation.md` | Felsefe, OWASP Top 10:2025, NIST SSDF — başlangıç okuması |
| `docs/security/01-phase-1-project-kickoff.md` | Faz 1: Proje başında |
| `docs/security/02-phase-2-coding-rules.md` | Faz 2: Kod yazarken günlük rehber |
| `docs/security/03-phase-3-pre-launch.md` | Faz 3: Canlıya çıkmadan önce |
| `docs/security/04-master-checklist.md` | Uçtan uca tek liste |
| `docs/security/05-audit-cadence.md` | Yayında periyodik denetimler |
| `docs/security/06-tooling-catalog.md` | "X için hangi tool?" sorusu |
| `docs/security/07-incident-response.md` | Bir şey ters gidince |
| `docs/security/08-kvkk-compliance.md` | KVKK uyumluluk |
| `docs/security/09-customer-evidence-pack.md` | Kurumsal müşteri için kanıt paketi |

---

## 9. Çalışma Tarzı

- **Setup tek seferlik:** Yeni proje başında `make setup` çalıştırılmış olmalı. Yoksa kullanıcıya hatırlat. İlerleyen oturumlarda yeni global tool kurma — `make setup` zaten halletti.
- **Plan Mode** kullan: Karmaşık değişikliklerde önce plan çıkar, sonra uygula
- **Küçük commit'ler:** Her commit tek bir mantıksal değişiklik
- **TODO'ları kod içinde bırakma:** GitHub Issue aç, referansla
- **Bilmiyorsan, söyle:** Tahmin etme, "bunu doğrulayalım" de
- **Yeni bir saldırı türü duyduğunda:** `docs/security/` altına ekle, repo'nun zenginleştir
- **Branch protection:** main'e direkt push yok, PR + CI yeşil + review sonrası merge

---

## 10. Bilgi Tazeleme

Bu repo statik değil. Aşağıdaki kaynakları dönemsel olarak takip et:

- **OWASP Top 10**: 4 yılda bir güncelleniyor (next: ~2029)
- **OWASP Cheat Sheet Series**: Sürekli güncel — `cheatsheetseries.owasp.org`
- **NIST SSDF**: Major güncellemeler için `csrc.nist.gov/projects/ssdf`
- **CVE / Dependabot alerts**: GitHub'da otomatik takip
- **AWS Security Bulletins**: AWS hesabına email aboneliği

Yeni bir teknoloji eklediğinde (yeni framework, yeni veritabanı, yeni cloud servis) **`docs/security/06-tooling-catalog.md`**'ye o teknolojiye özel kuralları ekle.
