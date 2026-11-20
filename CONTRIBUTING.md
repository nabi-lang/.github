# Contributing to Nabi

Thanks for your interest in improving Nabi. This file applies to every
repository of the nabi-lang organization. Most repositories have their own
`CONTRIBUTING.md` with build and test steps; read that one too.

## Before you start

- Questions and ideas go to
  [GitHub Discussions](https://github.com/nabi-lang/nabi/discussions), not
  issues. See [SUPPORT.md](SUPPORT.md).
- Bugs and concrete feature requests go to the issues of the repository
  they concern. Search first; add to an existing issue rather than opening a
  second one.
- Security issues are reported privately: see [SECURITY.md](SECURITY.md).
- For anything larger than a fix (a new language feature, a new standard
  library module, a change of an existing API), open an issue or a
  Discussion first, so the design is agreed on before you write the code.
  Language and standard library changes are decided as described in
  [GOVERNANCE.md](GOVERNANCE.md).
- Everyone taking part follows the [Code of Conduct](CODE_OF_CONDUCT.md).

Issues labeled `good first issue` are small and well described; `help
wanted` means a maintainer would welcome a pull request.

## Where things are

| Repository | What |
|---|---|
| [nabi](https://github.com/nabi-lang/nabi) | Compiler, runtime, standard library, `nabi` tool, `nabils` |
| [spec](https://github.com/nabi-lang/spec) | The language and standard library specification (English and Korean) |
| [docs](https://github.com/nabi-lang/docs) | The guide, examples and error pages (English and Korean) |
| [www](https://github.com/nabi-lang/www) | The pages of nabi-lang.org |
| [nabi-syntax](https://github.com/nabi-lang/nabi-syntax) | TextMate and tree-sitter grammars |
| [nabi.vscode](https://github.com/nabi-lang/nabi.vscode), [nabi.zed](https://github.com/nabi-lang/nabi.zed), [nabi.vim](https://github.com/nabi-lang/nabi.vim) | Editor support |
| [json](https://github.com/nabi-lang/json), [http](https://github.com/nabi-lang/http), ... | The official packages, one repository each (see the [profile](profile/README.md)) |
| [nabi-lang.org](https://github.com/nabi-lang/nabi-lang.org), [packages.nabi-lang.org](https://github.com/nabi-lang/packages.nabi-lang.org), [playground.nabi-lang.org](https://github.com/nabi-lang/playground.nabi-lang.org), [web](https://github.com/nabi-lang/web) | The sites and their shared kit |
| [.github](https://github.com/nabi-lang/.github) | Shared workflows, actions, labels, rulesets, these policies |

## Pull requests

- Open the pull request against `main`. Keep it to one change; related
  small fixes may go together.
- Run the checks the repository's `CONTRIBUTING.md` lists before you push.
  CI runs the same ones.
- Fill in the pull request template. In nabi, end the description with the
  `changelog:` block; nowhere else edit `CHANGELOG.md` by hand.
- A change in observable behavior of the language or standard library
  updates the spec, in English and Korean, in the same change (or a linked
  pull request to nabi-lang/spec).
- Text in docs, spec and www is written in English and Korean together:
  `ko/` mirrors the English files. If you cannot write the Korean, say so
  in the pull request and a maintainer will add it.
- Pull requests are merged by squash through the merge queue. Do not
  force-push a branch once review has started; add commits on top.

## Licenses

Code is licensed under MIT OR Apache-2.0 (`LICENSE-MIT`,
`LICENSE-APACHE`). The text of docs, spec and www is licensed under
CC BY 4.0 (`LICENSE` in those repositories). By contributing you agree
that your contribution is licensed under the license of the repository you
contribute to.

## Sign your work

Nabi uses the Developer Certificate of Origin 1.1 (DCO, below) instead of a
CLA. By adding a `Signed-off-by` line to a commit you certify that you wrote
the change, or otherwise have the right to submit it under the repository's
license. `git commit -s` adds the line:

```text
Signed-off-by: Your Name <you@example.com>
```

Use your name and an email you can be reached at; the email must be the
commit's author email. The `DCO / Check sign-off` check fails a pull request with an
unsigned commit. To fix it, run `git commit --amend -s` (last commit) or
`git rebase --signoff main` (every commit), then push again. To sign every
commit of a clone without thinking about it, add `-s` through an alias, or
use your editor's sign-off setting.

### Developer Certificate of Origin

```text
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.


Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```

## This repository

Changes to the shared workflows and actions here reach every repository
that pins them, so they are released as tags (`README.md`, Versioning).
Before a pull request:

```sh
tests/run.sh                  # hermetic tests of lib/
shellcheck -s sh lib/*.sh tests/*.sh tests/shim/*
shfmt -sr -d lib tests
actionlint
```
