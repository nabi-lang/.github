<p align="center">
  <img src="https://raw.githubusercontent.com/nabi-lang/nabi/main/assets/logo.svg" alt="Nabi" width="96">
</p>

<h1 align="center">nabi-lang/.github</h1>

<p align="center">
  <a href="https://github.com/nabi-lang/.github/actions/workflows/ci.yml"><img src="https://github.com/nabi-lang/.github/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="#license"><img src="https://img.shields.io/badge/license-MIT%20OR%20Apache--2.0-blue" alt="License: MIT OR Apache-2.0"></a>
</p>

<p align="center">
  The org profile, the shared workflows, and the building blocks of the Nabi release pipeline.
</p>

## What is here

| Path | What |
|---|---|
| `profile/README.md` | The org profile page |
| `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `SUPPORT.md` | The org's default community health files; a repository's own copy wins |
| `GOVERNANCE.md`, `TRADEMARK.md` | How decisions are made; use of the Nabi name and logo |
| `.github/ISSUE_TEMPLATE/`, `.github/PULL_REQUEST_TEMPLATE.md` | Default templates for a repository without its own |
| `.github/workflows/reusable-content.yml`, `reusable-deploy.yml` | Reusable workflows of the content repos and sites |
| `.github/workflows/reusable-package.yml` | Reusable test workflow of the package repos |
| `.github/workflows/reusable-dco.yml` | Reusable DCO sign-off check, called by every repository's CI |
| `.github/workflows/ci.yml` | This repository's own CI |
| `labels.json`, `lib/labels.sh` | The issue labels of every repository, and the script that applies them |
| `release/pipeline.json` | The manifest: every component a Nabi release reaches, and what each one receives |
| `release/pipeline.schema.json` | Its JSON Schema (`schema: 1`) |
| `actions/<verb-object>/action.yml` | Composite actions (below) |
| `lib/*.sh` | The shell the actions run (and `lib/publish-order.sh`, below); every GitHub API call goes through `lib/gh.sh`, every retry through `lib/retry.sh` |
| `tests/` | Hermetic tests of `lib/`, with fake `gh` and `curl` in `tests/shim/` |
| `rulesets/*.json` | The rulesets of the repositories (below) |

## Versioning

- Releases are immutable tags `vMAJOR.MINOR.PATCH`. There is no moving `v1` tag; a moving tag
  would change every caller at once, untested.
- Callers pin an exact release, never `@main`, the reusable workflows as well as the actions.
  Until `v1.0.2` exists on GitHub, every caller names the tag:
  `uses: nabi-lang/.github/actions/install-nabi@v1.0.2`. Once it is pushed and locked, the
  callers switch to its commit, as for third-party actions:
  `uses: nabi-lang/.github/actions/install-nabi@<sha> # v1.0.2`.
  Dependabot (`github-actions` ecosystem) bumps the pins.
- A new optional input, a new manifest kind or a new probe is a minor release. A fix is a patch.
  A removed or renamed input, or a changed default, is a major release, and the previous major
  keeps working for one Nabi series.
- The reusable workflows call the actions by tag, so the commit a release tags names that same
  tag in their `uses:` lines; a tag on a commit that still names the previous release would
  ship the new actions to direct callers only.
- The actions find `lib/` and `release/` through `github.action_path`, so an action at `v1.2.0`
  always runs the `lib/` of `v1.2.0`.

## Actions

Every action takes a `token` input that defaults to `github.token`; give it only the
permissions listed.

### `install-nabi`

Installs a Nabi toolchain from GitHub releases (never from a site). A release install downloads
the release's `SHA256SUMS` and `SHA256SUMS.minisig`, verifies the signature with the release key
and checks that its trusted comment is `nabi <version> SHA256SUMS`, checks the archive against its
line in `SHA256SUMS`, and by default verifies its build attestation with `gh attestation verify`.
Any failure, a missing `SHA256SUMS` or `.minisig` included, installs nothing. A `candidate-run`
install checks the archive against its `.sha256` only, since the dist artifacts are signed at
release. Works on
Linux, macOS and Windows runners, x64 and arm64; on Windows it takes the machine's architecture
from `RUNNER_ARCH` (or the registry), since an emulated x64 Git Bash on arm64 says `x86_64`.
`lib/toolchain.sh` also installs the x86_64 FreeBSD archive. Puts `bin` on `PATH` and sets
`NABI_HOME`.

| Input | Default | |
|---|---|---|
| `version` | | A toolchain pin: `0.2` (the newest final 0.2.x), `0.2.1` (exactly), `0.3.0-rc.1`, `latest` |
| `pin` | | Path of a `nabi.nabion`; installs what its `toolchain:` pin accepts |
| `candidate-run` | | A run id of `nabi-lang/nabi`; installs this host's archive from its `dist-*` artifacts (needs `actions: read`) |
| `home` | `~/.nabi` | `NABI_HOME` |
| `attest` | `true` | Verify the build attestation (release installs only) |
| `repo` | `nabi-lang/nabi` | The toolchain repository |

Give exactly one of `version`, `pin`, `candidate-run`. Outputs: `version` (e.g. `0.2.1`), `bin`.
Permissions: `contents: read`.

A series pin (`0.2`) takes the newest final release of the series: never a draft, a release
marked prerelease, or a tag with a `-` suffix. Only while the series has no final release at all
does it take the newest `0.2.Z-rc.N` that is not a draft, with a warning (`no final 0.2 release
yet; using 0.2.0-rc.2`); once `0.2.0` is out the series picks it. An exact pin (`0.2.1`,
`0.3.0-rc.1`) installs exactly that release, never a candidate of it. `latest` is the series rule
over every series: the newest final release, else the newest rc with a warning. Only `version`
takes it; a `nabi.nabion` pinning `latest` is refused.

The signature is checked with minisign 0.12, downloaded from its GitHub release and pinned by
SHA-256 for Linux (x64, arm64), Windows (x64, arm64) and macOS (arm64), the same pins as the
`minisign` action of `nabi-lang/nabi`; `sh lib/toolchain.sh minisign <dir>` fetches it. Other
hosts (macOS x64, FreeBSD) have no pin, so the action fails there; `lib/toolchain.sh install
--minisign <binary>` runs a minisign of your choice, with a warning.

The release key is minisign key `B33E6FE61BE5314C`:

```
untrusted comment: minisign public key B33E6FE61BE5314C
RWRMMeUb5m8+s0rEtzbR47dmyrMdlGyGQSvWUn/Ob5QYh0GHgs1GvJEs
```

It is `release_key` in `lib/toolchain.sh`. To rotate it, change `release_key` and this block in
the same release of these actions, and the key in `nabi-lang/nabi` (`keys/release.pub`,
`install.sh`, `install.ps1`, the toolchain's built-in key). A release signed with the new key
installs only with the new action release, so cut the action release before the first toolchain
release signed with the new key. `lib/toolchain.sh install --release-key <file>` trusts another
minisign public key file, for test sets signed with a throwaway key, and logs a warning naming
that key's id. No environment variable changes the key or the minisign binary, and the action has
no input for either.

### `clone-path-deps`

Clones every `Dep::path("../<repo>")` of a package from this org into `../<repo>` beside the
checkout, then their own path dependencies. A directory that is already there is kept.

| Input | Default | |
|---|---|---|
| `dir` | `.` | The package directory |
| `base` | `https://github.com/<owner>` | Where the repositories are cloned from |

No outputs. Permissions: none (public repositories).

### `check-health`

Polls until a check passes or its budget runs out, with a fresh query on every URL so the CDN
answers from the origin. With `component`, runs every `health[]` entry of that manifest
component, placeholders expanded.

| Input | Default | |
|---|---|---|
| `component` | | A manifest id; needs `version` |
| `version` | | Fills `{version}` and `{series}` |
| `pinned` | resolved | Fills `{pinned}`; by default the newest release the component's pin accepts |
| `vars` | | More values as JSON, e.g. `{"editor_version": "0.2.1"}` |
| `manifest` | this version's | Path of a manifest |
| `url`, `expect`, `budget` | `budget: 60` | One check instead of a component |
| `interval` | `60` | Seconds between tries |

What `expect` means depends on the URL:

- `https://.../healthz`: a `/healthz` body (line 1 `ok` or `failing`, then `key value` lines;
  `healthz 1`); `expect` is `key value`, and the server must report `ok`. A body that names the
  toolchain `release` (the playground today) is read as `toolchain`. A `healthz` newer than 1 is
  refused with a hint to update the blocks.
- other `https://...`: HTTP 200 and the body contains `expect`.
- `index-lag:<host>`: at most `expect` packages whose newest index line `<host>` does not serve yet.
- `compile:<host>`: `<host>/api/compile` builds a program to wasm.

No outputs; the step fails with the last reason. Permissions: `contents: read`.

### `sync-alarm-issue`

One issue per title, kept in step with a check: opened on the first red, commented on while red,
closed on the first green. An open issue with the same title and first label is reused.

| Input | Default | |
|---|---|---|
| `title` | required | The alarm's identity |
| `ok` | required | `true` or `false` |
| `body` | required | What happened, with links |
| `labels` | `alarm` | Labels of a new issue; the first narrows the search |
| `repo` | this repo | |

Outputs: `issue`, `action` (`opened`, `updated`, `closed`, `none`). Permissions: `issues: write`.

### `mint-app-token`

Mints a token of the `nabi-lang-release` App for named repositories and permissions, through
`actions/create-github-app-token` (SHA-pinned). The token is revoked when the job ends.

| Input | |
|---|---|
| `app-id`, `private-key` | The App's ID (or client ID) and key, from the environment secrets `RELEASE_APP_ID` and `RELEASE_APP_KEY` |
| `repositories` | `nabi, docs` or `nabi-lang/nabi`; required, so no token covers the whole org |
| `permissions` | `contents:write, pull-requests:write`; required |

Allowed permissions: `contents`, `pull-requests`, `issues`, `actions`, `statuses` (read or
write), `administration` and `metadata` (read). `workflows` is refused: the App never writes
workflow files. Missing credentials fail the step and say which secrets to set. Output: `token`.

### `record-release`

Reads or updates the release record (`record: 1`), a JSON block in the release issue between
`<!-- record:begin -->` and `<!-- record:end -->`, with a table rendered above it. Text outside
the markers is left alone. The record is evidence and a cache, never the authority: re-observe
GitHub before acting on it.

| Input | Default | |
|---|---|---|
| `issue` | | The release issue |
| `title` | | Without `issue`: reuse the open issue with this title, or open it |
| `labels` | `release` | Labels of a new issue |
| `patch` | | A JSON object merged in (objects deeply, arrays replaced, `events` appended); empty reads |
| `repo` | this repo | |

A patch is refused when its `state` goes back, when it marks a release `ABANDONED` at or after
`TAGGED` (that version is burned) or `SUPERSEDED` before it, or when the record is already final
(`CLOSED`, `ABANDONED`, `SUPERSEDED`). A failed step is recorded as `blocked: {state, reason}`;
the state stays at the last good one. A patch that changes nothing writes nothing.
Outputs: `issue`, `record` (compact JSON), `state`. Permissions: `issues: write`.

## Package workflow

`.github/workflows/reusable-package.yml` is what each package repository's `ci.yml` calls:

```yaml
jobs:
  package:
    name: Package
    uses: nabi-lang/.github/.github/workflows/reusable-package.yml@v1.0.2
    with:
      wasm: true          # also nabi test --target wasm32-wasip2 under wasmtime
      publish-check: true # nabi publish --dry-run
```

It installs the toolchain the package's `nabi.nabion` pins (`install-nabi` with `pin`), clones
its path dependencies (`clone-path-deps`), and runs `nabi fmt --check` and `nabi publish --dry-run`
on Linux, `nabi test` on Linux, macOS and Windows, and the wasm32-wasip2 tests on Linux.

## Publishing the packages

A package is published by its own `publish.yml` when its `vX.Y.Z` tag is pushed, as the
trusted publisher registered for that repository and workflow on packages.nabi-lang.org. A
package that depends on a sibling names it `Dep::path("../<repo>", version: "<req>")`: builds
and tests use the checkout beside it (`clone-path-deps`), and `nabi publish` writes the requirement,
so the dependency must be in the index first. `lib/publish-order.sh <workspace>` prints the
`package` components of the manifest in an order that does that, and fails on a path
dependency with no `version:`:

```sh
lib/publish-order.sh ~/src/nabi-lang     # json, linalg, special, ..., table, plot
```

Push the tags in that order, one at a time, and wait for each `publish.yml` run to pass (the
package's line is then in packages-index) before the next. Re-running a publish of a version
already in the index fails with `already in the index`: a version is published once.

## DCO workflow

`.github/workflows/reusable-dco.yml` checks that every commit of a pull request has a
`Signed-off-by:` line with its author's email (CONTRIBUTING.md, Sign your
work). Merge commits and GitHub bot authors (`<id>+<name>[bot]@users.noreply.github.com`:
Dependabot, the release App) are skipped; the `exempt` input (an extended
regex of author emails) replaces that rule. On any other event than
`pull_request` it passes without looking, so a caller may run it on push and
in the merge queue. Each repository calls it as one more job of its CI:

```yaml
jobs:
  dco:
    name: DCO
    uses: nabi-lang/.github/.github/workflows/reusable-dco.yml@v1.0.2
```

The repository's `ci-gate` job needs `dco` too.

## Labels

`labels.json` (`schema: 1`) lists the labels every repository has: `type:`,
`area:` and `status:` families, `good first issue`, `help wanted`, and the
labels the workflows set (`release`, `rehearsal`, `alarm`, `type: bug`,
`area: ci`). The issue templates use `type: bug` and `type: feature`.

```sh
lib/labels.sh --dry-run nabi-lang/json      # what it would do
GH_TOKEN=... lib/labels.sh nabi-lang/json nabi-lang/toml
```

Each label is updated (color, description) or created; labels not in the
file are kept. The token needs `issues: write` on each repository. To add a
label, add it to `labels.json` and open a PR; run the script after the
merge.

## Rulesets

| File | Applies to | Rules |
|---|---|---|
| `rulesets/main.json` | the default branch | no deletion, no force push, linear history, changes by pull request only (squash), `CI gate` green (from GitHub Actions), merge queue (squash, all green) |
| `rulesets/release-branches.json` | `release/*`, `rehearse/*` | only bypass actors create or delete them; no force push, linear history |
| `rulesets/release-tags.json` | `v*` tags | never moved or deleted |

They match nabi's `docs/releasing.md`. Before applying `main.json` and
`release-branches.json`, add the `nabi-lang-release` App as a bypass actor,
since it fast-forwards `main` to the release commit and creates and rebases
the release branches; the organization admin bypass is already there, to
break glass:

```sh
jq --argjson app "$APP_ID" \
  '.bypass_actors += [{actor_id: $app, actor_type: "Integration", bypass_mode: "always"}]' \
  rulesets/main.json > /tmp/main.json
gh api -X POST repos/nabi-lang/nabi/rulesets --input /tmp/main.json
```

Every repository with CI has a `ci-gate` job named `CI gate` in its CI workflow (`ci.yml`,
or `content.yml` in docs, spec and www) that needs every other job and runs on `merge_group`
too, so `main.json` applies unchanged everywhere. packages-index keeps its own rule: only the
registry pushes to `main`.

## Workflow names

Every workflow, job, step and action follows one naming scheme:

- File: `<category>.yml` or `<category>-<purpose>.yml`, category one of `ci`, `nightly`,
  `release`, `publish`, `deploy`, `content`, `check`, `maintenance`, `reusable` (only here).
  The same purpose has the same file name in every repository: a package has `ci.yml` and
  `publish.yml`, a site `ci.yml` and `deploy.yml`.
- Workflow `name:`: `<Category> / <Purpose>`, e.g. `CI / Test the package`,
  `Release / Build archives`, `Reusable / DCO sign-off`.
- Job: a kebab-case id; a sentence-case `name:` with the matrix values in parentheses in the
  order host, target, level, shard: `Test corpus (linux-x64, x86_64-unknown-linux-musl, -O0)`.
  The required check is the job `ci-gate`, named `CI gate`.
- Step: every step has an imperative sentence-case `name:` naming the tool and the object:
  `Install Nabi from the nabi.nabion pin`, `Verify the archive set`.
- Composite action: a verb-object directory (`install-nabi`, `record-release`), a title-case
  `name:` and a one-sentence `description:`; every input and output has a description.

## Retries

`lib/retry.sh` runs a command again on network errors, HTTP 5xx, 429 and rate limits, and git's
`RPC failed`, `early EOF` and `Could not resolve host`, after 10, 30, 90, 270 and 600 s (+-20%
jitter), within a budget (default 1100 s). A rate limit waits `Retry-After` or until
`x-ratelimit-reset` instead. Any other 4xx returns at once; on a 409 or 422 the caller looks at
GitHub again rather than repeating the write. Each retry is logged as a `::warning::`.

## The manifest

`release/pipeline.json` is plain JSON so that a runner can read it with `jq` even when the
newest Nabi is broken. Host targets stay in `nabi-lang/nabi` `release-targets.json`, and deploy
addresses stay in the private infra repo; the manifest only names them.

To add a component of an existing kind, add one entry to `components` and open a PR:

```json
{ "id": "yaml", "kind": "package", "repo": "nabi-lang/yaml",
  "on": { "patch": "verify", "series": "pin-pr" },
  "pin": { "file": "nabi.nabion", "ref": "main" },
  "publish": { "block": "publish.yml", "registry": "packages.nabi-lang.org", "environment": "release" },
  "checks": ["ci.yml"], "next": true, "gate": "block", "owner": "me" }
```

- `id` is unique; it names the component in records, alarms and run names.
- `checks` lists workflow files that exist in the repo today.
- `health[]` entries use `{version}`, `{series}`, `{prev}`, `{pinned}` or `{editor_version}`;
  `{pinned}` needs a `pin`.
- `gate` (`warn` or `block`) needs `next: true`.

CI validates the manifest against the schema, then `lib/manifest-check.sh --live` checks it
against GitHub: every repo exists, every `checks` workflow is there, every pin file holds a
toolchain pin, and the smoke runners match the toolchain's targets. A new kind needs a new
minor release of the blocks.

## Testing

```sh
tests/run.sh               # every test file
tests/run.sh retry record  # some
```

The tests put `tests/shim` first on `PATH`: a fake `gh` over a small GitHub in a JSON file, and
a fake `curl` over fixture files. Both log every call and inject faults (`502`, `429`, secondary
rate limit, lost network) per call, so the retry policy, idempotent writes and every refusal are
checked without the network. Needs `sh`, `jq`, `awk`, `tar`, `git`.

CI (`.github/workflows/ci.yml`) runs actionlint, shellcheck (also over the actions' `run:`
blocks), shfmt (`-sr`), zizmor, these tests on Linux and macOS, the manifest checks, and a real
`install-nabi` on Linux, macOS and Windows, x64 and arm64.

## License

The workflows, actions and scripts are licensed under either of
[MIT](LICENSE-MIT) or [Apache-2.0](LICENSE-APACHE), at your option.
