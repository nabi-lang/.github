# Security policy

This policy covers every repository of the nabi-lang organization: the
toolchain, the standard library, the packages, the editor support, the sites
and the package registry. A repository's own `SECURITY.md` may add to it
(supported versions, scope notes) but does not change the process below.

## Reporting a vulnerability

Do not report security issues in public issues, pull requests or
Discussions.

- Preferred: GitHub private vulnerability reporting. On the affected
  repository, open the **Security** tab and choose **Report a
  vulnerability**. If you do not know which repository is affected, use
  [nabi-lang/nabi](https://github.com/nabi-lang/nabi/security/advisories/new).
- Or email security@nabi-lang.org.

Include what you can of: the affected repository and version (`nabi version
-v`, or the package version), the target, a minimal reproduction, the impact
you see, and whether the issue is already public.

A malicious or compromised package in the registry at packages.nabi-lang.org
is reported the same way, on
[nabi-lang/packages.nabi-lang.org](https://github.com/nabi-lang/packages.nabi-lang.org/security/advisories/new).

## What happens next

1. We acknowledge the report within 14 days, usually much sooner.
2. We confirm or reject the issue, assess its severity and assign it to a
   track (below). We tell you which track and why.
3. We develop the fix, keep you informed of progress, and agree with you on
   a disclosure date.
4. We publish a GitHub security advisory with the fix. CVE IDs are requested
   through GitHub as the CNA. You are credited in the advisory unless you
   prefer otherwise.

If you do not hear back within 14 days, email security@nabi-lang.org again
or mention it, without details, in a Discussion asking a maintainer to check
the security inbox.

## Tracks

Modeled on the Go project's security policy. The track decides how a fix is
developed and disclosed.

### PRIVATE

For issues that are severe and practically exploitable: memory corruption
reachable from safe code or untrusted input, remote code execution, a
broken check in `core::crypto` or `std::net::tls`, an integrity bypass in
`nabi` package downloads or toolchain installs, a compromise of the
registry.

- The fix is developed in a private fork through a draft GitHub security
  advisory. Nothing is pushed in public before the release.
- Embargo: the disclosure date is set when the fix is ready and is at most
  90 days after the report. We aim for much shorter. If the issue becomes
  public or is exploited in the wild, the embargo ends and we release as
  soon as the fix is ready.
- A pre-announcement (the affected component and the release date, no
  details) is posted in GitHub Discussions about three days before the
  release.
- The fix ships as a patch release of the latest series, together with the
  advisory.

### PUBLIC

For issues with low severity or that need unusual conditions to exploit:
denial of service from trusted input, a hardening gap, an issue only
reachable through `unsafe` code that already misuses an API.

- The fix is developed in the open, through a normal pull request, and
  ships in the next scheduled release.
- An advisory is published when the fix ships, if users need to act.

## Supported versions

Nabi is pre-1.0. Security fixes land on the latest 0.x series of the
toolchain and the latest release of each package only. A repository's own
`SECURITY.md` says what applies there.

## Scope notes

`core::crypto` and `std::net::tls` are Nabi's own code, written from the
published standards and tested against NIST CAVP and Wycheproof vectors.
They have had no independent audit and are experimental. Reports about them
are welcome and follow the same process.
