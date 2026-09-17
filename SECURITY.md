# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| latest  | ✓         |

Update this table as the project matures and older versions fall out of support.

## Reporting a vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Use [GitHub's private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing/privately-reporting-a-security-vulnerability):

1. Go to the **Security** tab of this repository.
2. Click **Report a vulnerability**.
3. Fill in the details and submit.

If private reporting is unavailable, email the maintainers directly (see the repository contact information or `CODEOWNERS`).

### What to include

- Description of the vulnerability and the component affected
- Steps to reproduce the issue
- Potential impact (data exposure, privilege escalation, denial of service, etc.)
- Any suggested fixes or mitigations (optional but appreciated)

### Response timeline

| Milestone | Target |
|-----------|--------|
| Acknowledgement | 48 hours |
| Initial assessment | 5 business days |
| Fix or mitigation plan | 30 days for critical issues |

We will coordinate a public disclosure date with you once a fix is ready. We follow [responsible disclosure](https://en.wikipedia.org/wiki/Coordinated_vulnerability_disclosure) and will credit reporters unless they prefer to remain anonymous.

## Security practices in this repository

- Enable **GitHub Advanced Security** in your repository settings (Security tab → Code security and analysis) to activate secret scanning and push protection.
- The pre-commit hook (`.githooks/pre-commit`) blocks common secret patterns locally — activate with `git config core.hooksPath .githooks`.
- Dependabot keeps dependencies up to date automatically.
- `.github/workflows/codeql.yml` is a CodeQL-ready scaffold. Add the project's languages and enable the analysis steps before treating CodeQL as active.
