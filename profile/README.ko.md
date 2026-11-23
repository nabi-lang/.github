<p align="center">
  <img src="https://raw.githubusercontent.com/nabi-lang/nabi/main/assets/logo.svg" alt="Nabi" width="96">
</p>

<h1 align="center">Nabi</h1>

<p align="center">
  규칙은 분명하게, 나비처럼 자유롭게.
</p>

<p align="center">
  <a href="https://github.com/nabi-lang">English</a> &middot;
  한국어 &middot;
  <a href="https://github.com/nabi-lang/.github/blob/main/profile/README.zh-Hans.md">简体中文</a> &middot;
  <a href="https://github.com/nabi-lang/.github/blob/main/profile/README.zh-Hant.md">繁體中文</a>
</p>

<p align="center">
  <a href="https://nabi-lang.org/ko/">사이트</a> &middot;
  <a href="https://docs.nabi-lang.org">문서</a> &middot;
  <a href="https://packages.nabi-lang.org">패키지</a> &middot;
  <a href="https://playground.nabi-lang.org">플레이그라운드</a> &middot;
  <a href="https://github.com/nabi-lang/nabi/discussions">토론</a>
</p>

```sh
curl -fsSL https://nabi.sh | sh
nabi new hello && cd hello && nabi run   # Hello, world!
```

## 핵심

- [**nabi**](https://github.com/nabi-lang/nabi) - 컴파일러, 런타임, 표준 라이브러리, `nabi` 도구와 `nabils` 언어 서버
- [**spec**](https://github.com/nabi-lang/spec) - 언어와 표준 라이브러리 명세(영어, 한국어, 중국어)
- [**docs**](https://github.com/nabi-lang/docs) - docs.nabi-lang.org의 가이드, 예제, 오류 페이지
- [**www**](https://github.com/nabi-lang/www) - nabi-lang.org의 페이지
- [**nabi-lang.org**](https://github.com/nabi-lang/nabi-lang.org) - nabi-lang.org와 docs.nabi-lang.org를 만드는 생성기
- [**packages.nabi-lang.org**](https://github.com/nabi-lang/packages.nabi-lang.org) - 패키지 레지스트리: 사이트와 서버
- [**packages-index**](https://github.com/nabi-lang/packages-index) - 레지스트리 인덱스
- [**playground.nabi-lang.org**](https://github.com/nabi-lang/playground.nabi-lang.org) - 브라우저 플레이그라운드
- [**web**](https://github.com/nabi-lang/web) - 사이트들이 함께 쓰는 디자인 토큰, 컴포넌트, 스크립트
- [**.github**](https://github.com/nabi-lang/.github) - 공유 워크플로와 액션, 라벨, 규칙, 커뮤니티 정책

## 에디터

- [**nabi-syntax**](https://github.com/nabi-lang/nabi-syntax) - TextMate와 tree-sitter 문법, Nabi 하이라이터 라이브러리
- [**nabi.vscode**](https://github.com/nabi-lang/nabi.vscode) - Visual Studio Code 확장
- [**nabi.zed**](https://github.com/nabi-lang/nabi.zed) - Zed 확장
- [**nabi.vim**](https://github.com/nabi-lang/nabi.vim) - Vim, Neovim 플러그인

## 패키지

공식 패키지입니다. `nabi add <name>`으로 추가하세요.

| 패키지 | |
|---|---|
| [json](https://github.com/nabi-lang/json) | JSON: 값 트리, 엄격한 파서, 출력기, `#[derive(Json)]`, JSON Pointer |
| [toml](https://github.com/nabi-lang/toml) | TOML 1.1.0: 값 트리, 파서와 출력기, `#[derive(Toml)]` |
| [csv](https://github.com/nabi-lang/csv) | 스트리밍 CSV 리더와 라이터, `#[derive(Csv)]` |
| [markdown](https://github.com/nabi-lang/markdown) | Markdown을 HTML로: CommonMark와 GitHub 확장 |
| [regex](https://github.com/nabi-lang/regex) | 선형 시간 정규 표현식, 기본으로 유니코드 |
| [http](https://github.com/nabi-lang/http) | HTTP/1.1, HTTP/2 클라이언트와 서버, 평문 또는 TLS 1.3 |
| [linalg](https://github.com/nabi-lang/linalg) | 밀집 선형대수: 곱, 분해, 고윳값 문제 |
| [sparse](https://github.com/nabi-lang/sparse) | 희소 행렬, 크릴로프 솔버, 희소 촐레스키와 LU |
| [autodiff](https://github.com/nabi-lang/autodiff) | 자동 미분: 전진, 하이퍼 듀얼, 테일러, 후진 모드 |
| [special](https://github.com/nabi-lang/special) | 특수 함수: 감마, 베셀, 제타, 타원 함수 등 |
| [stats](https://github.com/nabi-lang/stats) | 통계: 기술 통계, 분포, 검정, 회귀 |
| [optimize](https://github.com/nabi-lang/optimize) | 최적화: 최소화, 제약, 최소제곱, 근 찾기 |
| [interpolate](https://github.com/nabi-lang/interpolate) | 보간, 스플라인, 평활화, 수치 적분 |
| [ode](https://github.com/nabi-lang/ode) | 미분방정식: 적응형, 강성, 심플렉틱, 경계값 솔버 |
| [signal](https://github.com/nabi-lang/signal) | 신호 처리: FFT, 필터, 스펙트럼, 리샘플링 |
| [table](https://github.com/nabi-lang/table) | 열 지향 테이블: CSV, JSON lines, Arrow, Parquet 입출력, group-by, 조인 |
| [plot](https://github.com/nabi-lang/plot) | 과학 플로팅: SVG, PNG, 터미널 출력 |
| [units](https://github.com/nabi-lang/units) | 단위를 컴파일 시간에 검사하는 물리량 |
| [spatial](https://github.com/nabi-lang/spatial) | 게임·그래픽 수학: 벡터, 쿼터니언, 행렬, 도형 |
| [nabi-syntax](https://github.com/nabi-lang/nabi-syntax) | Nabi와 NABION 토크나이저, HTML 하이라이터 |

## 기여하기

[CONTRIBUTING.md](https://github.com/nabi-lang/.github/blob/main/CONTRIBUTING.md)(커밋은 DCO에 따라 sign-off합니다), [행동 강령](https://github.com/nabi-lang/.github/blob/main/CODE_OF_CONDUCT.md), [GOVERNANCE.md](https://github.com/nabi-lang/.github/blob/main/GOVERNANCE.md)를 읽어 주세요.
질문은 [토론](https://github.com/nabi-lang/nabi/discussions)에 올려 주세요. 보안 취약점은 비공개로 신고해 주세요([SECURITY.md](https://github.com/nabi-lang/.github/blob/main/SECURITY.md)).

<p align="center"><sub><a href="https://daminstudio.com">DaminStudio</a> 만든 곳</sub></p>
