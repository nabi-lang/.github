<p align="center">
  <img src="https://raw.githubusercontent.com/nabi-lang/nabi/main/assets/logo.svg" alt="Nabi" width="96">
</p>

<h1 align="center">Nabi</h1>

<p align="center">
  規則清晰，如蝶般自由。
</p>

<p align="center">
  <a href="https://github.com/nabi-lang">English</a> &middot;
  <a href="https://github.com/nabi-lang/.github/blob/main/profile/README.ko.md">한국어</a> &middot;
  <a href="https://github.com/nabi-lang/.github/blob/main/profile/README.zh-Hans.md">简体中文</a> &middot;
  繁體中文
</p>

<p align="center">
  <a href="https://nabi-lang.org/zh-hant/">網站</a> &middot;
  <a href="https://docs.nabi-lang.org">文件</a> &middot;
  <a href="https://packages.nabi-lang.org">套件</a> &middot;
  <a href="https://playground.nabi-lang.org">線上試用</a> &middot;
  <a href="https://github.com/nabi-lang/nabi/discussions">討論</a>
</p>

```sh
curl -fsSL https://nabi.sh | sh
nabi new hello && cd hello && nabi run   # Hello, world!
```

## 核心

- [**nabi**](https://github.com/nabi-lang/nabi) - 編譯器、執行環境、標準函式庫、`nabi` 工具與 `nabils` 語言伺服器
- [**spec**](https://github.com/nabi-lang/spec) - 語言與標準函式庫規格（英文、韓文、中文）
- [**docs**](https://github.com/nabi-lang/docs) - docs.nabi-lang.org 的指南、範例與錯誤頁面
- [**www**](https://github.com/nabi-lang/www) - nabi-lang.org 的頁面
- [**nabi-lang.org**](https://github.com/nabi-lang/nabi-lang.org) - nabi-lang.org 與 docs.nabi-lang.org 的產生器
- [**packages.nabi-lang.org**](https://github.com/nabi-lang/packages.nabi-lang.org) - 套件登錄庫：網站與伺服器
- [**packages-index**](https://github.com/nabi-lang/packages-index) - 登錄庫索引
- [**playground.nabi-lang.org**](https://github.com/nabi-lang/playground.nabi-lang.org) - 瀏覽器線上試用
- [**web**](https://github.com/nabi-lang/web) - 各網站共用的設計權杖、元件與指令稿
- [**.github**](https://github.com/nabi-lang/.github) - 共用工作流程與 Action、標籤、規則集、社群政策

## 編輯器

- [**nabi-syntax**](https://github.com/nabi-lang/nabi-syntax) - TextMate 與 tree-sitter 文法，以及 Nabi 語法標示函式庫
- [**nabi.vscode**](https://github.com/nabi-lang/nabi.vscode) - Visual Studio Code 擴充功能
- [**nabi.zed**](https://github.com/nabi-lang/nabi.zed) - Zed 擴充功能
- [**nabi.vim**](https://github.com/nabi-lang/nabi.vim) - Vim 與 Neovim 外掛

## 套件

官方套件；用 `nabi add <name>` 加入。

| 套件 | |
|---|---|
| [json](https://github.com/nabi-lang/json) | JSON：值樹、嚴格剖析器、寫出器、`#[derive(Json)]`、JSON Pointer |
| [toml](https://github.com/nabi-lang/toml) | TOML 1.1.0：值樹、剖析器與寫出器、`#[derive(Toml)]` |
| [csv](https://github.com/nabi-lang/csv) | 串流 CSV 讀寫器、`#[derive(Csv)]` |
| [markdown](https://github.com/nabi-lang/markdown) | Markdown 轉 HTML：CommonMark 與 GitHub 擴充 |
| [regex](https://github.com/nabi-lang/regex) | 線性時間正規表示式，預設支援 Unicode |
| [http](https://github.com/nabi-lang/http) | HTTP/1.1 與 HTTP/2 用戶端和伺服器，明文或 TLS 1.3 |
| [linalg](https://github.com/nabi-lang/linalg) | 稠密線性代數：乘積、分解、特徵值問題 |
| [sparse](https://github.com/nabi-lang/sparse) | 稀疏矩陣、Krylov 求解器、稀疏 Cholesky 與 LU |
| [autodiff](https://github.com/nabi-lang/autodiff) | 自動微分：前向、超對偶、Taylor 與反向模式 |
| [special](https://github.com/nabi-lang/special) | 特殊函數：Gamma、Bessel、Zeta、橢圓函數等 |
| [stats](https://github.com/nabi-lang/stats) | 統計：敘述統計、分布、檢定、迴歸 |
| [optimize](https://github.com/nabi-lang/optimize) | 最佳化：最小化、限制條件、最小平方法、求根 |
| [interpolate](https://github.com/nabi-lang/interpolate) | 內插、樣條、平滑與數值積分 |
| [ode](https://github.com/nabi-lang/ode) | 微分方程：自適應、剛性、辛及邊界值求解器 |
| [signal](https://github.com/nabi-lang/signal) | 訊號處理：FFT、濾波器、頻譜、重新取樣 |
| [table](https://github.com/nabi-lang/table) | 欄式表格：CSV、JSON lines、Arrow 與 Parquet 讀寫、分組、合併 |
| [plot](https://github.com/nabi-lang/plot) | 科學繪圖：輸出 SVG、PNG 與終端機 |
| [units](https://github.com/nabi-lang/units) | 編譯期檢查單位的物理量 |
| [spatial](https://github.com/nabi-lang/spatial) | 遊戲與圖形數學：向量、四元數、矩陣、形狀 |
| [nabi-syntax](https://github.com/nabi-lang/nabi-syntax) | Nabi 與 NABION 語彙分析器及 HTML 語法標示 |

## 參與貢獻

請閱讀 [CONTRIBUTING.md](https://github.com/nabi-lang/.github/blob/main/CONTRIBUTING.md)（提交需依 DCO 簽署）、[行為準則](https://github.com/nabi-lang/.github/blob/main/CODE_OF_CONDUCT.md) 與 [GOVERNANCE.md](https://github.com/nabi-lang/.github/blob/main/GOVERNANCE.md)。
問題請發到 [討論區](https://github.com/nabi-lang/nabi/discussions)；安全性漏洞請私下回報（[SECURITY.md](https://github.com/nabi-lang/.github/blob/main/SECURITY.md)）。

<p align="center"><sub><a href="https://daminstudio.com">DaminStudio</a> 出品</sub></p>
