# 02 — Faz 2: Kod Yazarken

> Günlük kod yazma rehberi. Her kuralın **OWASP Top 10:2025 kategorisi** ile bağı belirtildi. Yanına çık çıkmaz `security-guardian` agent'ı koştur.

---

## Bölüm 1: A01:2025 — Broken Access Control

### 1.1 Authentication ilk satırda
Her API endpoint, server action veya backend handler'ı **session check ile başlar**:

```typescript
// ✅ DOĞRU
export async function POST(req: Request) {
  const session = await requireSession();  // throws if not authenticated
  // ... rest
}

// ❌ YANLIŞ
export async function POST(req: Request) {
  const data = await req.json();
  // ... auth check unutulmuş
}
```

### 1.2 Authorization her sensitive işlemde
Authentication "kim?" sorusu, authorization "yetkili mi?" sorusu — **ikisi farklı**:

```typescript
// ✅ DOĞRU
const session = await requireSession();
requireRole(session, ['admin', 'operator']);  // throws if not authorized

// ❌ YANLIŞ
const session = await requireSession();
// authorization yok — herhangi authenticated user yapabilir
```

### 1.3 IDOR (Insecure Direct Object Reference) önleme
ID ile resource çekerken **owner check** zorunlu:

```typescript
// ✅ DOĞRU
const claim = await db.claim.findFirst({
  where: { id: claimId, userId: session.userId }  // ← owner constraint
});

// ❌ YANLIŞ
const claim = await db.claim.findUnique({ where: { id: claimId } });
// User A, User B'nin claim'ini çekebilir!
```

### 1.4 SSRF önleme (yeni: A01'de)
User input'undan gelen URL'lere fetch atıyorsan **allowlist** zorunlu:

```typescript
// ✅ DOĞRU
const ALLOWED_HOSTS = ['api.partner.com', 'webhook.acme.com'];
const url = new URL(userProvidedUrl);
if (!ALLOWED_HOSTS.includes(url.hostname)) {
  throw new Error('Disallowed host');
}
// Ek olarak: 169.254.169.254 (AWS metadata) gibi internal IP'leri block et
const response = await fetch(url);

// ❌ YANLIŞ
const response = await fetch(userProvidedUrl);  // SSRF — internal services'e erişim mümkün
```

### 1.5 Path traversal
Dosya yolu kullanıcıdan geliyorsa:

```typescript
// ✅ DOĞRU
const safe = path.normalize(userPath).replace(/^(\.\.[\/\\])+/, '');
const filePath = path.join(SAFE_BASE_DIR, safe);
if (!filePath.startsWith(SAFE_BASE_DIR)) throw new Error('Path traversal');

// ❌ YANLIŞ
const filePath = path.join(SAFE_BASE_DIR, userPath);  // ../../../etc/passwd
```

---

## Bölüm 2: A02:2025 — Security Misconfiguration

### 2.1 Security Headers
`next.config.js` (veya middleware) için minimum:

```javascript
const securityHeaders = [
  { key: 'Content-Security-Policy', value: "default-src 'self'; script-src 'self' 'unsafe-inline' https://js.sentry-cdn.com; ..." },
  { key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubDomains; preload' },
  { key: 'X-Frame-Options', value: 'DENY' },
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
  { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
];
```

**CSP nuance:** `unsafe-inline` ve `unsafe-eval` mümkün olduğunca kaçın; nonce veya hash kullan.

### 2.2 Default credential YOK
Setup script'inde "create admin user with password admin123" YOK. İlk admin'i:
- Manuel oluştur
- Strong password ile
- MFA zorunlu

### 2.3 Production'da debug kapalı
- `NODE_ENV=production` doğru set
- Verbose error stack trace kullanıcıya gitmiyor
- Source map upload Sentry'ye, response'a değil

### 2.4 CORS sıkı
```typescript
// ✅ DOĞRU
const corsOrigin = process.env.CORS_ORIGIN; // "https://app.example.com"

// ❌ YANLIŞ
res.setHeader('Access-Control-Allow-Origin', '*');  // production'da yasak
```

---

## Bölüm 3: A03:2025 — Software Supply Chain Failures

### 3.1 Yeni dependency eklemeden önce
- [ ] **Sebebi yazılı** — neden bu paket?
- [ ] **Maintainer aktif mi?** — son commit 6 ay içinde
- [ ] **Download sayısı yeterli mi?** — npm trends'te (en az 10k/hafta önerilir)
- [ ] **GitHub stars / issues** sağlıklı mı
- [ ] **License uygun mu?** — GPL ürününü açık kaynaka çevirir
- [ ] `dependency-watchdog` agent ile tara

### 3.2 Lock dosyası
- [ ] `package-lock.json` veya `yarn.lock` repo'da
- [ ] CI'da `npm ci` (npm install değil) — exact version

### 3.3 SBOM
Her release'de SBOM üret:
```bash
npx @cyclonedx/cyclonedx-npm --output-file sbom.json
```

### 3.4 Postinstall script paranoia
Yeni paket eklediğinde `package.json`'ında `postinstall` script'i var mı kontrol et. Genellikle gerek yok; varsa şüphelen.

---

## Bölüm 4: A04:2025 — Cryptographic Failures

### 4.1 Şifre hash
```typescript
// ✅ DOĞRU
import bcrypt from 'bcrypt';
const hash = await bcrypt.hash(password, 12);  // cost factor >= 10

// veya argon2 (daha iyi):
import argon2 from 'argon2';
const hash = await argon2.hash(password);

// ❌ YANLIŞ
const hash = crypto.createHash('md5').update(password).digest('hex');  // MD5
const hash = crypto.createHash('sha256').update(password).digest('hex'); // salt yok, slow algoritma değil
```

### 4.2 Random / Token
```typescript
// ✅ DOĞRU
import { randomBytes } from 'crypto';
const token = randomBytes(32).toString('hex');

// ❌ YANLIŞ
const token = Math.random().toString(36).substring(2);  // tahmin edilebilir
```

### 4.3 At-rest encryption
- DB: AWS RDS encryption checkbox
- File storage: S3 server-side encryption (SSE-KMS önerilir)
- Backups: encryption zorunlu

### 4.4 In-transit encryption
- HTTPS zorunlu — HTTP redirect
- HSTS aktif
- TLS 1.2+ (1.3 ideal)
- Internal service-to-service mTLS önerilir

### 4.5 Hassas veri URL'de YASAK
```typescript
// ❌ YANLIŞ
GET /api/reset?token=abc123  // token URL'de — log'a yazılır, referrer header'a sızar

// ✅ DOĞRU
POST /api/reset
Body: { token: "abc123" }
```

### 4.6 JWT
- `none` algorithm yasak
- `HS256` simetrik anahtarla, anahtar uzun (32+ byte)
- `RS256` asimetrik tercih edilir (rotation kolay)
- Expiry kısa (15 dk access, refresh ile yenile)
- Audience (`aud`) ve issuer (`iss`) claim'leri kontrol et

---

## Bölüm 5: A05:2025 — Injection

### 5.1 SQL Injection
```typescript
// ✅ DOĞRU — parameterized
const user = await db.user.findFirst({ where: { email } });
const result = await sql`SELECT * FROM users WHERE email = ${email}`;

// ❌ YANLIŞ
const result = await db.$queryRawUnsafe(`SELECT * FROM users WHERE email = '${email}'`);
```

ORM kullanıyorsan default'ta güvendesin, ama **raw query** köşelerine dikkat.

### 5.2 XSS
```tsx
// ✅ DOĞRU — React default escape
<div>{userInput}</div>

// ❌ YANLIŞ
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// Eğer gerçekten HTML render edeceksen:
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userInput) }} />
```

### 5.3 Command Injection
```typescript
// ❌ YANLIŞ
exec(`convert ${userFile} output.png`);  // userFile = "a.png; rm -rf /"

// ✅ DOĞRU
import { execFile } from 'child_process';
execFile('convert', [userFile, 'output.png']);  // args array — shell yok
```

### 5.4 NoSQL Injection
```typescript
// ❌ YANLIŞ — MongoDB
db.users.findOne({ email: req.body.email });
// req.body.email = { $ne: null } olabilir → tüm kullanıcıları döndürür

// ✅ DOĞRU
db.users.findOne({ email: String(req.body.email) });
// veya schema validation ile
```

### 5.5 eval / Function YASAK
```typescript
// ❌ YANLIŞ
eval(userCode);
new Function(userCode)();

// ✅ DOĞRU
// kullanıcı kodu çalıştırmak istiyorsa: sandboxed (vm2, isolated-vm) — ama bu da risk
```

---

## Bölüm 6: A06:2025 — Insecure Design

### 6.1 Rate Limiting
**Her** kritik endpoint'te:

| Endpoint | Limit |
|---|---|
| Login | 5 deneme / 15 dk / IP |
| Register | 3 / saat / IP |
| Password reset | 3 / saat / email |
| OTP send | 3 / saat / phone |
| Search / API | 100 / dk / user |

Tool: Upstash Ratelimit (Vercel/serverless) veya Redis-backed library.

### 6.2 Account lockout
Başarısız login N kez sonrası account lock — ama legit user'ı kilitleme. **Exponential backoff** daha iyi:
- 1. fail: izin
- 2. fail: 1 sn delay
- 3. fail: 4 sn
- 4. fail: 16 sn
- 5+: captcha veya admin reset

### 6.3 CAPTCHA
Public form'larda (register, contact, password reset) — Turnstile (Cloudflare) veya hCaptcha.

### 6.4 MFA
- Admin role'lerde **zorunlu**
- Sensitive işlemlerde (password change, payment) re-auth
- TOTP veya WebAuthn (SMS son tercih — SIM swap riski)

---

## Bölüm 7: A07:2025 — Authentication Failures

### 7.1 Şifre Politikası
- Min 12 karakter (NIST 800-63B önerisi)
- Karmaşıklık zorunluluğu (numara/symbol) NIST artık önermiyor — yerine "uzun" tercih
- HaveIBeenPwned API ile breach'lenmiş şifreyi reddet
- Password manager friendly (paste'i engelleme)

### 7.2 Session Yönetimi
- HttpOnly cookie (JS erişemesin)
- Secure flag (HTTPS only)
- SameSite=Lax veya Strict
- Idle timeout: 15-30 dk
- Absolute timeout: 8-12 saat
- Logout server-side session invalidate (sadece cookie silmek değil)

### 7.3 OAuth/SSO
- `state` parameter zorunlu (CSRF koruması)
- PKCE zorunlu (mobile için)
- ID token ve access token ayrı kullan
- Sadece HTTPS callback URL

---

## Bölüm 8: A08:2025 — Software/Data Integrity Failures

### 8.1 Deserialization
```typescript
// ❌ YANLIŞ — Python örneği
pickle.loads(untrustedData)  // RCE riski

// ✅ DOĞRU
JSON.parse(untrustedData)  // sadece data, kod değil

// JS'te de:
// JSON.parse güvenli; ama eval ile JSON parse YASAK
```

### 8.2 Auto-update / dynamic imports
Eğer plugin sistemi varsa:
- Imzalı plugin'ler
- Sandbox içinde çalıştırma
- Allowlist

### 8.3 CI/CD integrity
- Branch protection
- Required signed commits
- Required reviewers
- CI workflow değişikliği: ekstra dikkat
- Self-hosted runner kullanıyorsan izole

---

## Bölüm 9: A09:2025 — Security Logging & Alerting Failures

### 9.1 Audit Log
**Her sensitive event:**

```typescript
await auditLog({
  actor: session.userId,
  actorIp: req.ip,
  action: 'CLAIM_CREATED',
  resourceType: 'claim',
  resourceId: claim.id,
  metadata: { amount: claim.amount },
  // ASLA: password, token, API key, full credit card
});
```

Loglanması gereken event'ler (örnek):
- Login success / failure
- Logout
- Password change / reset request / reset complete
- Permission change
- Role change
- Sensitive data access (başkasının verisi)
- Sensitive data export
- Admin actions
- Failed authorization (403)

### 9.2 Alert
Log'lar **alarm tetiklemiyorsa anlamsız**. Minimum alarmlar:

| Alarm | Threshold |
|---|---|
| 5xx rate | >1% / 5 dk |
| Failed login spike | >50 / dk |
| DB connection failure | >0 |
| Sentry new issue | spike |
| Disk usage | >80% |
| Cert expiry | <30 gün |

### 9.3 Log Hijyeni
- PII asla full log'a yazılmasın (email mask: `e***@gmail.com`)
- Password / token asla log'a
- Stack trace production'da kullanıcıya gitmesin (Sentry'ye gitsin)
- Log retention policy yazılı (örn: 90 gün hot, 1 yıl cold, sonra silinir)

---

## Bölüm 10: A10:2025 — Mishandling of Exceptional Conditions (YENİ)

Bu kategori 2025'te yeni. Kötü hata yönetimi başlı başına saldırı vektörü.

### 10.1 Fail-secure
Yetki kontrolü hata atınca **işlem yapılmamalı** (fail-open değil):

```typescript
// ❌ YANLIŞ — fail-open
try {
  const allowed = await checkPermission(user, resource);
  if (!allowed) throw new Error('Forbidden');
} catch (e) {
  console.error(e);
  // hiçbir şey yapma — işlem devam eder, kullanıcı yetkisiz işlem yaptı
}
proceedWithAction();

// ✅ DOĞRU — fail-closed
try {
  const allowed = await checkPermission(user, resource);
  if (!allowed) return forbidden();
} catch (e) {
  log.error(e);
  return forbidden();  // hata olsa bile kullanıcıyı reddet
}
proceedWithAction();
```

### 10.2 Generic error response
Kullanıcıya internal detail gitmemeli:

```typescript
// ❌ YANLIŞ
catch (e) {
  return res.status(500).json({ error: e.stack });
}

// ✅ DOĞRU
catch (e) {
  log.error(e);  // detaylı log internal
  Sentry.captureException(e);
  return res.status(500).json({ error: 'Internal server error', requestId });
}
```

### 10.3 Timeout her yerde
- DB query timeout
- HTTP fetch timeout
- 3. parti API timeout
- Job timeout

```typescript
// ✅ DOĞRU
const controller = new AbortController();
const timer = setTimeout(() => controller.abort(), 5000);
try {
  const res = await fetch(url, { signal: controller.signal });
} finally {
  clearTimeout(timer);
}
```

### 10.4 Circuit breaker
Bağımlı bir servis çökerse, tüm sistemi çökertme. Library: `opossum` (Node.js).

---

## Bölüm 11: Frontend Özel Kurallar

### 11.1 LocalStorage'a token YASAK
- Token httpOnly cookie'de
- LocalStorage XSS ile çalınır

### 11.2 İçerik Güvenlik (CSP-friendly)
- Inline `<script>` yok — external dosya
- Inline `onclick="..."` yok — addEventListener
- `eval`, `Function` yok

### 11.3 External link güvenliği
```html
<!-- ✅ -->
<a href="..." target="_blank" rel="noopener noreferrer">

<!-- ❌ -->
<a href="..." target="_blank">
<!-- Açtığı sayfa window.opener ile parent'ı kontrol edebilir -->
```

### 11.4 Form CSRF
Same-site cookie'ler çoğu modern saldırıyı engeller, ama yine de:
- State-changing form'larda CSRF token (Auth.js otomatik halleder)
- POST/PUT/DELETE endpoint'lerinde

---

## Bölüm 12: Test Yazma Kuralları

### 12.1 Her güvenlik feature'ının testi olsun
- RBAC: yetkisiz user 403 alıyor mu?
- IDOR: User A, User B'nin verisini çekmeye çalışınca 404 mü?
- Rate limit: 6. login denemesi 429 dönüyor mu?
- CSP: header doğru mu (snapshot test)?

### 12.2 Negative tests
Sadece "happy path" değil — saldırgan path'i de test:

```typescript
test('cannot access other users claim', async () => {
  const userA = await loginAs('userA');
  const userB = await loginAs('userB');
  const claimA = await createClaim(userA);
  
  const response = await fetch(`/api/claims/${claimA.id}`, {
    headers: { Cookie: userB.cookie }
  });
  expect(response.status).toBe(404); // 403 olabilir, 200 ASLA
});
```

---

## Bölüm 13: Gözlem & PR Discipline

### 13.1 Her PR'ın checklist'i
- [ ] Lint + type check + test yeşil
- [ ] CI security workflow yeşil
- [ ] Yeni endpoint varsa: auth + RBAC + Zod + audit log var mı?
- [ ] Yeni dependency varsa: dependency-watchdog ile tarandı mı?
- [ ] Sensitive değişiklik varsa: security-guardian agent ile review edildi mi?
- [ ] CHANGELOG güncellendi mi (önemli değişikliklerde)?

### 13.2 Commit mesajı
- Conventional commits (feat:, fix:, sec:, etc.)
- `sec:` prefix güvenlik düzeltmeleri için
- Audit log için referans CVE veya issue ID

---

## Bölüm 14: Refactor & Code Hygiene

### 14.1 TODO yasak
Production kodda `// TODO: ...` bırakma. GitHub Issue aç, yorumda issue link'i.

### 14.2 Dead code sil
Kullanılmayan endpoint, kullanılmayan dependency, kullanılmayan utility fonksiyonu — sil. Saldırı yüzeyini azaltır.

### 14.3 Feature flag
Riskli yeni feature'ı feature flag arkasında deploy. Sorun çıkarsa flag'i kapat — rollback çekme.

---

## Bölüm 15: Sonraki Adım

Faz 2 sürekli yaşayan bir aşama. Faz 3'e geçmeden önce:
- [ ] Bu rehberin Bölüm 1-14'ü ekibinizce (sen + Claude Code) içselleştirildi
- [ ] Audit log gerçekten yazıyor (test ile doğrulandı)
- [ ] CI'daki tüm security adımları yeşil
- [ ] En az bir threat model güncellendi

→ **`03-phase-3-pre-launch.md`**'e geç
