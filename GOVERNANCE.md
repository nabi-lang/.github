# Governance

How decisions about Nabi are made, by whom, and how that is expected to
change. It covers every repository of the nabi-lang organization.

## Today: a BDFL

Nabi is young and has one maintainer, Han Damin
([@miniex](https://github.com/miniex)), who acts as its BDFL ("benevolent
dictator for life", in the usual sense of the term: the final say, not a
lifetime appointment). The BDFL:

- decides on changes to the language, the standard library and the
  toolchain, and on what goes into a release;
- merges pull requests, or delegates that per area (Teams, below);
- appoints and removes team members;
- enforces the [Code of Conduct](CODE_OF_CONDUCT.md), and may delegate
  that too.

DaminStudio, the BDFL's studio, hosts the project's infrastructure. The Nabi
name and logo are held by DaminStudio and looked after on behalf of the Nabi
project (nabi-lang). If the project moves to a neutral foundation, they move
with it ([TRADEMARK.md](TRADEMARK.md)). DaminStudio has no say in technical
questions beyond the BDFL's.

## How decisions are made

Most changes need no process: a pull request that a team member reviews and
merges. The rest are made in public, in writing.

1. **Fixes and small improvements**: a pull request. A team member of the
   area (`CODEOWNERS`) reviews and merges it through the merge queue.
2. **Larger changes** (a new standard library module, a new `nabi`
   command, a change of an existing API, a new target): an issue or a
   Discussion first, with the problem, the proposal and the alternatives.
   Once a maintainer agrees on the direction, the implementation follows as
   pull requests.
3. **Language and standard library semantics**: the
   [spec](https://github.com/nabi-lang/spec) defines them. A change is
   proposed as an issue, then written as a pull request to the spec in
   all four editions (English, Korean, Simplified and Traditional Chinese),
   together with the implementation in nabi. The BDFL accepts or declines
   it. The reasons for a decision are written in the
   issue or pull request, so a later reader can find why.
4. **Breaking changes**: Nabi is pre-1.0. A breaking change ships only in
   an `0.X.0` release and is called out in `CHANGELOG.md`.

Anyone may comment, object or propose an alternative at every step. A
decision can be revisited when new information turns up: open an issue that
links the old one and says what changed.

## Teams

Review is routed by the `CODEOWNERS` file of each repository to these
teams of the nabi-lang organization. Today the BDFL is the only member of
each; contributors are added as they take on an area.

| Team | Scope |
|---|---|
| `@nabi-lang/nabi` | Everything in nabi not covered below |
| `@nabi-lang/nabi-compiler` | `nabic`, the C compiler, the linker, the end-to-end corpus |
| `@nabi-lang/nabi-runtime` | The runtime and its collector |
| `@nabi-lang/nabi-stdlib` | `core`, `std`, `bare` |
| `@nabi-lang/nabi-tooling` | `nabi`, `nabils`, the REPL, the installers |
| `@nabi-lang/nabi-infra` | CI, release pipeline, targets, Nix; the `.github` repository |
| `@nabi-lang/docs` | docs, spec, www |
| `@nabi-lang/web` | The sites, the web kit, the package registry and its index |
| `@nabi-lang/editors` | nabi-syntax and the editor extensions |
| `@nabi-lang/packages` | The official packages |

A team member reviews and merges pull requests in the team's scope, triages
its issues, and takes part in its design discussions. Membership is by
invitation of the BDFL, after a record of good contributions and reviews in
the area. A member who has been inactive for a year is moved to an alumni
list in this file, and may come back by asking.

## How this will change

The goal is to move from one person to a group as the project grows,
without a gap in who can decide.

1. **Maintainers per area.** When an area has regular contributors, the
   BDFL invites one or more to its team with merge rights. Teams decide the
   changes in their scope by lazy consensus: a proposal stands if no member
   objects within a week.
2. **A core team.** Once there are at least three active maintainers
   besides the BDFL, they form a core team that decides cross-area
   questions (language, releases, policy) by consensus, falling back to a
   majority vote. The BDFL keeps a veto, used rarely and with written
   reasons.
3. **After 1.0.** Before Nabi 1.0 the project will review this document,
   with the aim of replacing the BDFL with an elected steering council.

Each step is a pull request to this file, open for comment for at least two
weeks before it is merged.

## Changes to this document

Changes to this file and to the other policies here (`CODE_OF_CONDUCT.md`,
`SECURITY.md`, `TRADEMARK.md`) are made by pull request to
[nabi-lang/.github](https://github.com/nabi-lang/.github) and approved by
the BDFL.
