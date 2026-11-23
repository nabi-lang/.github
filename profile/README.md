<p align="center">
  <img src="https://raw.githubusercontent.com/nabi-lang/nabi/main/assets/logo.svg" alt="Nabi" width="96">
</p>

<h1 align="center">Nabi</h1>

<p align="center">
  Clear rules, free as a butterfly.
</p>

<p align="center">
  English &middot;
  <a href="https://github.com/nabi-lang/.github/blob/main/profile/README.ko.md">한국어</a> &middot;
  <a href="https://github.com/nabi-lang/.github/blob/main/profile/README.zh-Hans.md">简体中文</a> &middot;
  <a href="https://github.com/nabi-lang/.github/blob/main/profile/README.zh-Hant.md">繁體中文</a>
</p>

<p align="center">
  <a href="https://nabi-lang.org">Site</a> &middot;
  <a href="https://docs.nabi-lang.org">Docs</a> &middot;
  <a href="https://packages.nabi-lang.org">Packages</a> &middot;
  <a href="https://playground.nabi-lang.org">Playground</a> &middot;
  <a href="https://github.com/nabi-lang/nabi/discussions">Discussions</a>
</p>

```sh
curl -fsSL https://nabi.sh | sh
nabi new hello && cd hello && nabi run   # Hello, world!
```

## Core

- [**nabi**](https://github.com/nabi-lang/nabi) - compiler, runtime, standard library, the `nabi` tool and the `nabils` language server
- [**spec**](https://github.com/nabi-lang/spec) - the language and standard library specification, in English, Korean and Chinese
- [**docs**](https://github.com/nabi-lang/docs) - the guide, examples and error pages of docs.nabi-lang.org
- [**www**](https://github.com/nabi-lang/www) - the pages of nabi-lang.org
- [**nabi-lang.org**](https://github.com/nabi-lang/nabi-lang.org) - the generator of nabi-lang.org and docs.nabi-lang.org
- [**packages.nabi-lang.org**](https://github.com/nabi-lang/packages.nabi-lang.org) - the package registry: site and server
- [**packages-index**](https://github.com/nabi-lang/packages-index) - the registry's index
- [**playground.nabi-lang.org**](https://github.com/nabi-lang/playground.nabi-lang.org) - the browser playground
- [**web**](https://github.com/nabi-lang/web) - design tokens, components and scripts the sites share
- [**.github**](https://github.com/nabi-lang/.github) - shared workflows and actions, labels, rulesets, community policies

## Editors

- [**nabi-syntax**](https://github.com/nabi-lang/nabi-syntax) - TextMate and tree-sitter grammars, and a Nabi highlighter library
- [**nabi.vscode**](https://github.com/nabi-lang/nabi.vscode) - Visual Studio Code extension
- [**nabi.zed**](https://github.com/nabi-lang/nabi.zed) - Zed extension
- [**nabi.vim**](https://github.com/nabi-lang/nabi.vim) - Vim and Neovim plugin

## Packages

The official packages. They come with the toolchain, so code that uses one needs no `nabi add`; other packages from [packages.nabi-lang.org](https://packages.nabi-lang.org) are added with `nabi add <name>`.

| Package | |
|---|---|
| [json](https://github.com/nabi-lang/json) | JSON: a value tree, a strict parser, writers, `#[derive(Json)]`, JSON Pointer |
| [toml](https://github.com/nabi-lang/toml) | TOML 1.1.0: a value tree, parser and writer, `#[derive(Toml)]` |
| [csv](https://github.com/nabi-lang/csv) | Streaming CSV reader and writer, `#[derive(Csv)]` |
| [markdown](https://github.com/nabi-lang/markdown) | Markdown to HTML: CommonMark plus GitHub extensions |
| [regex](https://github.com/nabi-lang/regex) | Regular expressions in linear time, Unicode by default |
| [http](https://github.com/nabi-lang/http) | HTTP/1.1 and HTTP/2 client and server, over plaintext or TLS 1.3 |
| [linalg](https://github.com/nabi-lang/linalg) | Dense linear algebra: products, factorizations, eigenproblems |
| [sparse](https://github.com/nabi-lang/sparse) | Sparse matrices, Krylov solvers, sparse Cholesky and LU |
| [autodiff](https://github.com/nabi-lang/autodiff) | Automatic differentiation: forward, hyper-dual, Taylor and reverse mode |
| [special](https://github.com/nabi-lang/special) | Special functions: gamma, Bessel, zeta, elliptic and more |
| [stats](https://github.com/nabi-lang/stats) | Statistics: descriptive, distributions, tests, regression |
| [optimize](https://github.com/nabi-lang/optimize) | Optimization: minimization, constraints, least squares, roots |
| [interpolate](https://github.com/nabi-lang/interpolate) | Interpolation, splines, smoothing and quadrature |
| [ode](https://github.com/nabi-lang/ode) | Differential equations: adaptive, stiff, symplectic and boundary value solvers |
| [signal](https://github.com/nabi-lang/signal) | Signal processing: FFTs, filters, spectra, resampling |
| [table](https://github.com/nabi-lang/table) | Column-oriented tables: CSV, JSON lines, Arrow and Parquet I/O, group-by, joins |
| [plot](https://github.com/nabi-lang/plot) | Scientific plotting to SVG, PNG and the terminal |
| [units](https://github.com/nabi-lang/units) | Physical quantities whose units are checked at compile time |
| [spatial](https://github.com/nabi-lang/spatial) | Game and graphics math: vectors, quaternions, matrices, shapes |
| [nabi-syntax](https://github.com/nabi-lang/nabi-syntax) | A Nabi and NABION tokenizer and HTML highlighter |

## Contributing

Read [CONTRIBUTING.md](https://github.com/nabi-lang/.github/blob/main/CONTRIBUTING.md)
(commits are signed off under the DCO), the
[Code of Conduct](https://github.com/nabi-lang/.github/blob/main/CODE_OF_CONDUCT.md)
and [GOVERNANCE.md](https://github.com/nabi-lang/.github/blob/main/GOVERNANCE.md).
Questions go to [Discussions](https://github.com/nabi-lang/nabi/discussions);
vulnerabilities are reported privately ([SECURITY.md](https://github.com/nabi-lang/.github/blob/main/SECURITY.md)).

<p align="center"><sub>Built by <a href="https://daminstudio.com">DaminStudio</a></sub></p>
