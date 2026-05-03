# 06 — Araç Kataloğu

> "X için hangi tool?" sorusunun tek noktadan cevabı. **7 katmanlı defense in depth**'e göre organize. Her tool'un ne işe yaradığı, alternatifleri ve solo dev için pragmatik notları.

Awesome-Security-Repos, Awesome-AppSec, OWASP'ın önerileri ve gerçek hayat tecrübesinden derlendi.

---

## Katman 1: İnternet Sınırı (Edge / WAF / CDN)

> Saldırgan ile uygulama arasındaki ilk savunma. Bot, DDoS, OWASP injection saldırılarını burada filtrele.

### WAF (Web Application Firewall)
| Tool | Tip | Maliyet | Notlar |
|---|---|---|---|
| **Cloudflare** | SaaS | Free tier var, $20/ay basic | DDoS + WAF + CDN paket; solo dev için ideal |
| **AWS WAF** | AWS | $5/ay/web ACL + per request | OWASP managed rule set; AWS stack için yerli |
| **Sucuri** | SaaS | $200+/ay | WordPress odaklı |
| **ModSecurity + nginx** | Self-hosted | Free | Maintenance ağır |

**Pragmatik tercih:** Cloudflare. Free tier ile başla, ölçek geldiğinde Pro ($20/ay).

### CDN
| Tool | Notlar |
|---|---|
| **Cloudflare** | WAF ile bütünleşik |
| **AWS CloudFront** | AWS için yerli |
| **Vercel Edge** | Next.js için yerli |

### Rate Limiting
| Tool | Notlar |
|---|---|
| **Upstash Ratelimit** | Serverless/Edge için ideal, Redis-backed |
| **Cloudflare Rate Limiting Rules** | Edge-level, ucuz |
| **express-rate-limit** | Node.js için, in-memory |
| **AWS WAF Rate-based rules** | AWS native |

### DDoS
| Tool | Notlar |
|---|---|
| **Cloudflare** | Free tier'da bile L3/L4 koruma |
| **AWS Shield Standard** | Otomatik, ek ücret yok |
| **AWS Shield Advanced** | $3000/ay, kurumsal |

---

## Katman 2: Uygulama Kodu (SAST + DAST + Code Quality)

> Kod yazılırken ve build edilirken çalışan kontroller.

### SAST (Static Application Security Testing)
Kodu çalıştırmadan analiz eder, pattern-based güvenlik açığı bulur.

| Tool | Tip | Maliyet | Notlar |
|---|---|---|---|
| **Semgrep** | Open + SaaS | Free OSS, paid Pro | Hafif, hızlı, custom rule yazılabilir; Awesome-Security-Repos'ın #1 önerisi |
| **SonarCloud** | SaaS | Free public repo, $10/ay private | Code quality + security; comprehensive |
| **GitHub CodeQL** | GitHub | GitHub Advanced Security ile | Çok güçlü ama sadece GH ile |
| **Snyk Code** | SaaS | Free tier kısıtlı | Snyk paketi içinde |
| **ESLint + plugins** | OSS | Free | `eslint-plugin-security`, `eslint-plugin-no-secrets` |

**Pragmatik tercih:**
- Hızlı başla: ESLint + `eslint-plugin-security` + Semgrep CI'da (free)
- Olgunlaş: SonarCloud ekle (kalite metrikleri için)

### DAST (Dynamic Application Security Testing)
Çalışan uygulamayı dışarıdan test eder.

| Tool | Notlar |
|---|---|
| **OWASP ZAP** | Free, baseline scan ile başla |
| **Burp Suite Community** | Free, manuel test için |
| **Burp Suite Pro** | $500/yıl, profesyonel |
| **Nuclei** | Template-based, çok hızlı, free |

**Pragmatik tercih:** OWASP ZAP baseline scan aylık otomatik koştur.

```bash
docker run -t zaproxy/zap-stable zap-baseline.py \
  -t https://app.example.com \
  -r zap-report.html
```

### Secret Scanning
| Tool | Notlar |
|---|---|
| **gitleaks** | Free, hızlı, pre-commit + CI |
| **TruffleHog** | Free, derin tarama (entropy-based) |
| **GitGuardian** | SaaS, free tier kısıtlı |
| **GitHub Push Protection** | GitHub'da ücretsiz |

**Pragmatik tercih:** gitleaks pre-commit hook + GitHub Push Protection.

### Linting
| Tool | Dil |
|---|---|
| **ESLint** | JS/TS |
| **Pylint, Bandit** | Python (Bandit security-focused) |
| **golangci-lint** | Go |
| **rubocop** | Ruby |

**Önemli ESLint plugin'leri:**
- `eslint-plugin-security` — pattern-based security
- `eslint-plugin-no-secrets` — secret detection in code
- `@typescript-eslint/eslint-plugin` — TypeScript için

---

## Katman 3: Kimlik & Yetkilendirme

### Authentication
| Tool | Tip | Notlar |
|---|---|---|
| **Auth.js (NextAuth)** | OSS | Next.js için, OAuth/credential, free |
| **Clerk** | SaaS | Hızlı kurulum, free tier var, kullanıcı arttıkça pahalı |
| **AWS Cognito** | AWS | AWS stack için yerli |
| **Supabase Auth** | SaaS | Postgres ile bütünleşik |
| **Auth0** | SaaS | Olgun, pahalı |
| **Keycloak** | OSS | Self-hosted, comprehensive |

### MFA
| Tool | Method | Notlar |
|---|---|---|
| **TOTP (Google Authenticator, Authy)** | App-based | Phishable ama yaygın |
| **WebAuthn / Passkeys** | Hardware/biometric | En güvenli, modern |
| **SMS** | Phone | SIM swap riski — son tercih |

**Pragmatik tercih:** TOTP başla, WebAuthn ekle (kurumsal müşteri talebinde).

### Şifre Hash
| Algoritma | Notlar |
|---|---|
| **argon2** | En güncel, RFC standart, en iyi |
| **bcrypt** | Olgun, yaygın, cost factor 12+ |
| **scrypt** | Memory-hard, iyi |
| **PBKDF2** | Eski ama hala kabul edilebilir |
| **MD5, SHA1, SHA256** | YASAK (salt'lı bile) |

### Password Strength Check
| Tool | Notlar |
|---|---|
| **HaveIBeenPwned API** | Breached password check, free |
| **zxcvbn** | Strength meter, free |

---

## Katman 4: Veri Güvenliği

### Veri Validation
| Tool | Dil | Notlar |
|---|---|---|
| **Zod** | TS | En popüler, type-safe |
| **Valibot** | TS | Hafif Zod alternatifi |
| **Yup** | JS | Eski jenerasyon, hala yaygın |
| **joi** | JS | Hapi.js ekosistemi |

### ORM (SQL Injection için kritik)
| Tool | Dil | Notlar |
|---|---|---|
| **Prisma** | TS | Type-safe, parameterized by default |
| **Drizzle** | TS | Lightweight, SQL-like |
| **TypeORM** | TS | Olgun |
| **Knex.js** | JS | Query builder |

**Kural:** Hangi ORM olursa olsun, **`$queryRaw`** veya **raw SQL** kullanırken parameterized parameter geçir.

### Encryption Library
| Tool | Notlar |
|---|---|
| **Node.js crypto (built-in)** | Standart, ihtiyaçların çoğu için yeterli |
| **node-forge** | OpenSSL JS port, kompleks işler için |
| **libsodium-wrappers** | Modern crypto (NaCl), tavsiye edilir |

**Asla:** Kendi crypto algoritmanı yazma. Asla.

### Secrets Manager
| Tool | Tip | Notlar |
|---|---|---|
| **AWS Secrets Manager** | AWS | Otomatik rotation, $0.40/secret/ay |
| **AWS Parameter Store** | AWS | Free, basit secrets için |
| **HashiCorp Vault** | OSS / Enterprise | Self-hosted, comprehensive |
| **Doppler** | SaaS | Multi-cloud, dev ergonomi iyi |
| **1Password Secrets Automation** | SaaS | Olgun, takım ergonomisi iyi |

---

## Katman 5: Altyapı Güvenliği

### IaC (Infrastructure as Code)
| Tool | Notlar |
|---|---|
| **Terraform** | Cloud-agnostic, en yaygın |
| **AWS CDK** | TypeScript ile AWS, dev-friendly |
| **Pulumi** | Multi-language, modern |
| **CloudFormation** | AWS native, eski jenerasyon |

**Kural:** **Hand-made resource ZERO TOLERANCE.** Cloud console'dan resource oluşturma. Her şey IaC'de.

### IaC Security Scanning
| Tool | Notlar |
|---|---|
| **Checkov** | Multi-IaC, Bridgecrew |
| **tfsec** | Terraform-specific, hızlı |
| **Trivy IaC** | Container + IaC + SBOM, tümleşik |
| **terrascan** | Policy-as-code |

### Cloud Security Posture (CSPM)
| Tool | Cloud | Notlar |
|---|---|---|
| **Prowler** | AWS, Azure, GCP, Kubernetes | OSS, 240+ AWS kontrolü, CIS/PCI-DSS/SOC2/ISO27001/GDPR/HIPAA mapping; Awesome-Security-Repos önerisi |
| **ScoutSuite** | Multi-cloud | OSS, tek kerelik audit |
| **AWS Security Hub** | AWS | Native, ücretsiz tier sınırlı |
| **AWS Config** | AWS | Compliance rules |
| **Wiz, Orca, Lacework** | SaaS | Enterprise CSPM |

**Pragmatik tercih:** AWS Security Hub açık + Prowler aylık tara.

### Container Security
| Tool | Notlar |
|---|---|
| **Trivy** | Container + IaC + SBOM, hızlı, free |
| **Docker Scout** | Docker native |
| **Snyk Container** | Comprehensive, paid |
| **Anchore** | Self-hosted option |

### S3 / Bucket Misconfiguration
| Tool | Notlar |
|---|---|
| **S3Scanner** | Public bucket finder, defensive use |
| **AWS Config / Trusted Advisor** | Built-in |

### IAM Analysis
| Tool | Notlar |
|---|---|
| **AWS IAM Access Analyzer** | Built-in, free, açık erişim bulucu |
| **PurplePanda** | OSS, privilege escalation path bulucu |
| **PMapper** | OSS, IAM permission graph |

---

## Katman 6: Gözlem & Olay Müdahale

### Error Tracking
| Tool | Notlar |
|---|---|
| **Sentry** | En yaygın, free tier var (5k err/ay), source map upload |
| **Rollbar** | Sentry alternatifi |
| **Bugsnag** | Mobile-friendly |

### Application Performance Monitoring (APM)
| Tool | Notlar |
|---|---|
| **DataDog** | Comprehensive, pahalı |
| **New Relic** | Free tier var |
| **Sentry Performance** | Sentry içinde, integrated |
| **AWS X-Ray** | AWS native, ucuz |

### Log Aggregation
| Tool | Notlar |
|---|---|
| **CloudWatch Logs** | AWS native, basit |
| **DataDog Logs** | APM ile birleşik |
| **Loki + Grafana** | OSS, self-hosted |
| **ELK / Elastic Cloud** | Olgun, kompleks |
| **BetterStack Logs** | Modern, dev-friendly |

### Uptime & Status Page
| Tool | Notlar |
|---|---|
| **BetterStack (Better Uptime)** | Uptime + status page combo |
| **Statuspage (Atlassian)** | Olgun, kurumsal |
| **UptimeRobot** | Free tier var, basit |
| **Pingdom** | Olgun, pahalı |

### Synthetic Monitoring
| Tool | Notlar |
|---|---|
| **AWS CloudWatch Synthetics** | Canary scripts, AWS native |
| **Checkly** | API + browser, dev-friendly |
| **Datadog Synthetics** | Comprehensive |

### Cloud-Native Threat Detection
| Tool | Notlar |
|---|---|
| **AWS GuardDuty** | Behavior-based threat detection, $$ |
| **AWS CloudTrail** | API audit log, ücretsiz tier var |
| **AWS VPC Flow Logs** | Network flow log, forensic için kritik |

---

## Katman 7: Geliştirme Süreci

### Pre-commit
| Tool | Notlar |
|---|---|
| **Husky** | Node.js, en yaygın |
| **lefthook** | Hızlı, multi-language |
| **pre-commit (Python)** | Multi-language, configurable |

### CI/CD Security
| Tool | Notlar |
|---|---|
| **GitHub Actions** | En yaygın, ücretsiz public |
| **GitLab CI** | Bütünleşik, security features rich |
| **CircleCI, Jenkins** | Olgun |

### Dependency Management
| Tool | Notlar |
|---|---|
| **Dependabot (GitHub)** | Otomatik PR, free |
| **Renovate** | Daha esnek, Dependabot alternatifi |
| **Snyk** | CVE-aware, free tier |

### Software Bill of Materials (SBOM)
| Tool | Notlar |
|---|---|
| **CycloneDX** | OWASP standardı, en yaygın |
| **`@cyclonedx/cyclonedx-npm`** | npm için SBOM üretici |
| **Syft** | Multi-language, container'ı da destekler |
| **SPDX** | Linux Foundation standardı |

```bash
npx @cyclonedx/cyclonedx-npm --output-file sbom.json
```

### Vulnerability Management
| Tool | Notlar |
|---|---|
| **Dependency-Track** | OSS, SBOM-based, Awesome-Security-Repos önerisi |
| **OWASP Dependency-Check** | OSS, polyglot |
| **GitHub Security Advisories** | GitHub bütünleşik |

### License Compliance
| Tool | Notlar |
|---|---|
| **license-checker** | npm için, basit |
| **fossa** | Comprehensive, paid |
| **scancode-toolkit** | OSS, derin |

---

## Spesifik Konular

### JWT Test
| Tool | Notlar |
|---|---|
| **jwt_tool** | Awesome-Security-Repos'tan, JWT pen testing — defansif olarak kendi token'larını test etmek için kullan |

### File Upload Validation
- **MIME magic bytes** doğrulama (uzantıya güvenme)
- **ClamAV** veya **VirusTotal API** ile virus scan
- Boyut limiti, type allowlist
- Cloud antivirus servisleri (Cloudflare, Cloudmersive)

### CAPTCHA
| Tool | Notlar |
|---|---|
| **Cloudflare Turnstile** | Free, modern, privacy-friendly |
| **hCaptcha** | Privacy-friendly alternative |
| **reCAPTCHA v3** | Google, ücretsiz tier |

### Rate Limiting Storage
| Tool | Notlar |
|---|---|
| **Redis** | Yaygın, dağıtık |
| **Upstash Redis** | Serverless friendly |
| **DynamoDB** | AWS native, scale-friendly |

---

## Awesome-Security-Repos'tan Diğer Notlar

Linklenen repo daha çok offensive security tool'ları (pen test, recon) listeliyor. Defensive perspektifle hangileri faydalı:

| Tool | Defensive kullanım |
|---|---|
| **PayloadsAllTheThings** | Test case'leri yazarken referans (kendi sistemini test et) |
| **TruffleHog** | Secret scanning |
| **JWT Tool** | Kendi JWT implementation'ını test |
| **Prowler** | Cloud security posture |
| **PurplePanda** | IAM privilege escalation path tespiti |
| **S3Scanner** | Kendi S3 bucket'larını public bulgu için tara |
| **OWASP ASVS** | Verifiable security standard |
| **Web Application Pentest Checklist** | Self-assessment için |

---

## Karar Matrisi: Solo Dev için Önerilen Stack

| Katman | Tool | Alternatif | Maliyet |
|---|---|---|---|
| Edge / WAF | Cloudflare | AWS WAF | Free → $20/ay |
| Rate limit | Upstash Ratelimit | express-rate-limit | Free tier var |
| SAST | Semgrep + ESLint plugin | SonarCloud | Free |
| DAST | OWASP ZAP | Burp Pro | Free |
| Secret scan | gitleaks + GitHub Push Protection | GitGuardian | Free |
| Auth | Auth.js | Clerk | Free |
| Validation | Zod | Valibot | Free |
| ORM | Prisma | Drizzle | Free |
| Secrets | AWS Secrets Manager | Doppler | $0.40/secret/ay |
| IaC | Terraform | AWS CDK | Free |
| CSPM | AWS Security Hub + Prowler | ScoutSuite | Free / kullanım bazlı |
| Container | Trivy | Snyk | Free |
| Error tracking | Sentry | Rollbar | Free tier var |
| Uptime | BetterStack | UptimeRobot | Free tier var |
| SBOM | CycloneDX | Syft | Free |
| Dep monitoring | Dependabot | Renovate | Free |
| MFA | TOTP | WebAuthn (Passkeys) | Free |
| Hash | argon2 | bcrypt | Free |
| CAPTCHA | Cloudflare Turnstile | hCaptcha | Free |

**Toplam yaklaşık aylık maliyet (small startup):** ~$30-50/ay (Cloudflare Pro + Sentry pay-as-you-go + AWS Secrets Manager).

---

## Bilgi Kaynakları

| Kaynak | Notlar |
|---|---|
| <https://owasp.org/Top10/2025/> | OWASP Top 10:2025 |
| <https://cheatsheetseries.owasp.org/> | Implementation cheat sheets |
| <https://github.com/njmulsqb/Awesome-Security-Repos> | Tool listesi (offensive odaklı) |
| <https://github.com/paragonie/awesome-appsec> | Defensive tool & resource listesi |
| <https://github.com/MahdiMashrur/Awesome-Application-Security-Checklist> | Pratik checklist |
| <https://github.com/OWASP/CheatSheetSeries> | Source repo |
| <https://csrc.nist.gov/projects/ssdf> | NIST SSDF |
| <https://www.cisecurity.org/cis-benchmarks> | CIS Benchmarks |
| <https://github.com/VoltAgent/awesome-claude-code-subagents> | Claude Code subagent örnekleri |
