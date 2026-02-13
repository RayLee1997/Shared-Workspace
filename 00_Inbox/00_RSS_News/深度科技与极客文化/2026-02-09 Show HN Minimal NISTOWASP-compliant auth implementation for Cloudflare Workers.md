# Show HN: Minimal NIST/OWASP-compliant auth implementation for Cloudflare Workers

**Author:** vhsdev
**Published:** Mon, 09 Feb 2026 11:30:06 +0000
**Link:** https://github.com/vhscom/private-landing
**GUID:** https://news.ycombinator.com/item?id=46944084
**Tags:** 

---

## Summary

This is an educational reference implementation showing how to build reasonably secure, standards-compliant authentication from first principles on Cloudflare Workers.
Stack: Hono, Turso (libSQL), PBKDF2-SHA384 + normalization + common-password checks, JWT access + refresh tokens with revocation support, HTTP-only SameSite cookies, device tracking.
It's deliberately minimal — no OAuth, no passkeys, no magic links, no rate limiting — because the goal is clarity and auditability.
I wrote it mainly to deeply understand edge-runtime auth constraints and to have a clean Apache-2.0 example that follows NIST SP 800-63B / SP 800-132 and OWASP guidance.
For production I'd almost always reach for Better Auth instead (https://www.better-auth.com) — this repo is not trying to compete with it.
Live demo: https://private-landing.vhsdev.workers.dev/
Repo: https://github.com/vhscom/private-landing
Happy to answer questions about the crypto choices, the refresh token revocation pattern, Turso schema, constant-time comparison, unicode pitfalls, etc.
Comments URL: https://news.ycombinator.com/item?id=46944084
Points: 28
# Comments: 8

---

## Content


<p>This is an educational reference implementation showing how to build reasonably secure, standards-compliant authentication from first principles on Cloudflare Workers.<p>Stack: Hono, Turso (libSQL), PBKDF2-SHA384 + normalization + common-password checks, JWT access + refresh tokens with revocation support, HTTP-only SameSite cookies, device tracking.<p>It's deliberately minimal — no OAuth, no passkeys, no magic links, no rate limiting — because the goal is clarity and auditability.<p>I wrote it mainly to deeply understand edge-runtime auth constraints and to have a clean Apache-2.0 example that follows NIST SP 800-63B / SP 800-132 and OWASP guidance.<p>For production I'd almost always reach for Better Auth instead (<a href="https://www.better-auth.com">https://www.better-auth.com</a>) — this repo is not trying to compete with it.<p>Live demo: <a href="https://private-landing.vhsdev.workers.dev/" rel="nofollow">https://private-landing.vhsdev.workers.dev/</a><p>Repo: <a href="https://github.com/vhscom/private-landing" rel="nofollow">https://github.com/vhscom/private-landing</a><p>Happy to answer questions about the crypto choices, the refresh token revocation pattern, Turso schema, constant-time comparison, unicode pitfalls, etc.</p>
<hr>
<p>Comments URL: <a href="https://news.ycombinator.com/item?id=46944084">https://news.ycombinator.com/item?id=46944084</a></p>
<p>Points: 28</p>
<p># Comments: 8</p>


---

**ISO Date:** 2026-02-09T11:30:06.000Z