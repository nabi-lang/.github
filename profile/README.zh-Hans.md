<p align="center">
  <img src="https://raw.githubusercontent.com/nabi-lang/nabi/main/assets/logo.svg" alt="Nabi" width="96">
</p>

<h1 align="center">Nabi</h1>

<p align="center">
  规则清晰，如蝶般自由。
</p>

<p align="center">
  <a href="https://github.com/nabi-lang">English</a> &middot;
  <a href="https://github.com/nabi-lang/.github/blob/main/profile/README.ko.md">한국어</a> &middot;
  简体中文 &middot;
  <a href="https://github.com/nabi-lang/.github/blob/main/profile/README.zh-Hant.md">繁體中文</a>
</p>

<p align="center">
  <a href="https://nabi-lang.org/zh-hans/">网站</a> &middot;
  <a href="https://docs.nabi-lang.org">文档</a> &middot;
  <a href="https://packages.nabi-lang.org">包</a> &middot;
  <a href="https://playground.nabi-lang.org">在线试用</a> &middot;
  <a href="https://github.com/nabi-lang/nabi/discussions">讨论</a>
</p>

```sh
curl -fsSL https://nabi.sh | sh
nabi new hello && cd hello && nabi run   # Hello, world!
```

## 核心

- [**nabi**](https://github.com/nabi-lang/nabi) - 编译器、运行时、标准库、`nabi` 工具和 `nabils` 语言服务器
- [**spec**](https://github.com/nabi-lang/spec) - 语言与标准库规范（英文、韩文、中文）
- [**docs**](https://github.com/nabi-lang/docs) - docs.nabi-lang.org 的指南、示例和错误页面
- [**www**](https://github.com/nabi-lang/www) - nabi-lang.org 的页面
- [**nabi-lang.org**](https://github.com/nabi-lang/nabi-lang.org) - nabi-lang.org 和 docs.nabi-lang.org 的生成器
- [**packages.nabi-lang.org**](https://github.com/nabi-lang/packages.nabi-lang.org) - 包注册表：网站与服务器
- [**packages-index**](https://github.com/nabi-lang/packages-index) - 注册表索引
- [**playground.nabi-lang.org**](https://github.com/nabi-lang/playground.nabi-lang.org) - 浏览器在线试用
- [**web**](https://github.com/nabi-lang/web) - 各网站共用的设计令牌、组件和脚本
- [**.github**](https://github.com/nabi-lang/.github) - 共享工作流与 Action、标签、规则集、社区政策

## 编辑器

- [**nabi-syntax**](https://github.com/nabi-lang/nabi-syntax) - TextMate 与 tree-sitter 语法，以及 Nabi 高亮库
- [**nabi.vscode**](https://github.com/nabi-lang/nabi.vscode) - Visual Studio Code 扩展
- [**nabi.zed**](https://github.com/nabi-lang/nabi.zed) - Zed 扩展
- [**nabi.vim**](https://github.com/nabi-lang/nabi.vim) - Vim 与 Neovim 插件

## 包

官方包；用 `nabi add <name>` 添加。

| 包 | |
|---|---|
| [json](https://github.com/nabi-lang/json) | JSON：值树、严格解析器、写出器、`#[derive(Json)]`、JSON Pointer |
| [toml](https://github.com/nabi-lang/toml) | TOML 1.1.0：值树、解析器与写出器、`#[derive(Toml)]` |
| [csv](https://github.com/nabi-lang/csv) | 流式 CSV 读写器、`#[derive(Csv)]` |
| [markdown](https://github.com/nabi-lang/markdown) | Markdown 转 HTML：CommonMark 及 GitHub 扩展 |
| [regex](https://github.com/nabi-lang/regex) | 线性时间正则表达式，默认支持 Unicode |
| [http](https://github.com/nabi-lang/http) | HTTP/1.1 与 HTTP/2 客户端和服务器，明文或 TLS 1.3 |
| [linalg](https://github.com/nabi-lang/linalg) | 稠密线性代数：乘积、分解、特征值问题 |
| [sparse](https://github.com/nabi-lang/sparse) | 稀疏矩阵、Krylov 求解器、稀疏 Cholesky 与 LU |
| [autodiff](https://github.com/nabi-lang/autodiff) | 自动微分：前向、超对偶、Taylor 与反向模式 |
| [special](https://github.com/nabi-lang/special) | 特殊函数：Gamma、Bessel、Zeta、椭圆函数等 |
| [stats](https://github.com/nabi-lang/stats) | 统计：描述统计、分布、检验、回归 |
| [optimize](https://github.com/nabi-lang/optimize) | 优化：最小化、约束、最小二乘、求根 |
| [interpolate](https://github.com/nabi-lang/interpolate) | 插值、样条、平滑与数值积分 |
| [ode](https://github.com/nabi-lang/ode) | 微分方程：自适应、刚性、辛及边值求解器 |
| [signal](https://github.com/nabi-lang/signal) | 信号处理：FFT、滤波器、频谱、重采样 |
| [table](https://github.com/nabi-lang/table) | 列式表格：CSV、JSON lines、Arrow 与 Parquet 读写、分组、连接 |
| [plot](https://github.com/nabi-lang/plot) | 科学绘图：输出 SVG、PNG 和终端 |
| [units](https://github.com/nabi-lang/units) | 编译期检查单位的物理量 |
| [spatial](https://github.com/nabi-lang/spatial) | 游戏与图形数学：向量、四元数、矩阵、形状 |
| [nabi-syntax](https://github.com/nabi-lang/nabi-syntax) | Nabi 与 NABION 分词器及 HTML 高亮器 |

## 参与贡献

请阅读 [CONTRIBUTING.md](https://github.com/nabi-lang/.github/blob/main/CONTRIBUTING.md)（提交需按 DCO 签署）、[行为准则](https://github.com/nabi-lang/.github/blob/main/CODE_OF_CONDUCT.md) 和 [GOVERNANCE.md](https://github.com/nabi-lang/.github/blob/main/GOVERNANCE.md)。
问题请发到 [讨论区](https://github.com/nabi-lang/nabi/discussions)；安全漏洞请私下报告（[SECURITY.md](https://github.com/nabi-lang/.github/blob/main/SECURITY.md)）。

<p align="center"><sub><a href="https://daminstudio.com">DaminStudio</a> 出品</sub></p>
