# Shimaenaga ハイライト定義範囲

決定日: 2026-10-23。文書作成: 2026-10-24。対象: 雪夜 Yukiyo / 流氷 Ryuhyo。

## 1. 今回の決定と成果物

この文書は、次の配色設計・実装で扱う対象と確認条件を確定するもの。
設計時点の検討記録を含む。現在の公開対象はNeovim本体のテーマとプラグイン連携。
「取り込み済み」は定義ファイルの存在を意味し、見た目の完成や実際の利用確認を意味しない。

- 標準構文、Treesitter、LSP、エディタ UI と、現在の LazyVim 環境を重点対応する。
- 現在設定されている全言語を最初の確認対象に含める。Lean / SuperCollider も同時に扱う。
- 参照元から取り込んだ、現在使っていない統合も維持する。ただし個別の描画保証は別扱い。
- 本文・サイドバー・フロートを透過できることを条件とする。非透過表示も維持する。
- テーマ標準の意味付けは元パレットを基準とし、リファクタリング優先度の独自配色は任意の追加設定に分離する。
- 外部アプリ向けのテーマ出力は現在の公開対象に含めない。Neovim内蔵ターミナルの配色は維持する。

### 判定の読み方

| 分類 | 意味 |
| --- | --- |
| 継承で対応 | 既存の共通定義、取り込み済み統合、またはプラグインの標準リンクを使う。専用の色値は増やさない |
| 専用定義が必要 | 固有の状態・固定色・透過への追従などについて、テーマ側の定義／リンク／連携が必要 |
| 実機確認が必要 | 実際のキャプチャ、LSP、表示タイミング、上書き順などを確認してから専用定義の要否を確定する |

分類と確認状況は別の軸。継承を採用しても描画確認は必要。
表中の `*` は対象ファミリーを表す記法であり、その名前をそのまま Neovim に登録するものではない。
対象グループ欄は代表例。網羅単位は、表の役割・ファミリーと付録の設定済み言語・プラグイン一覧。
実装時には各ファミリーの具体名をローカルの構文・プラグイン定義から展開する。

### 今回確認した事実

- `lua/shimaenaga/groups/` は65ファイル（ローダー1、標準4、プラグイン統合60）。
- `semantic.lua` で主要な役割を上書きし、最後に利用者の `on_highlights` を適用する構成。
- `~/.config/nvim/lua/plugins/colorscheme.lua` は本文・サイドバー・フロートの透過を指定している。
- 手元の foot は `alpha=0.85`、Hyprland は Blur 有効。これらの設定は変更しない。
- Shimaenaga の現在の既定値は `transparent=false`、sidebars / floats は `dark`。目標の透過構成とは区別する。
- `Pmenu` は現在 `semantic.lua` で背景色を固定している。透過指定への追従は今後の修正対象。
- 既存の `scripts/check.lua` は本文 `Normal` の透過等を検査するが、全 UI の透過や全言語の描画は検査していない。

## 2. 共通ハイライトの対象

出典: `groups/syntax.lua`、`groups/treesitter.lua`、`groups/semantic_tokens.lua`、
`groups/editor.lua` と `semantic.lua`。確認状況はソース照合済み、描画は全項目未確認。

### 構文・Treesitter・LSP

背景欄の「文字」は背景を付けず、所属ウィンドウの透過／非透過に従う。

| 役割 | 対象グループ例 | 継承・専用定義の方針 | 背景 |
| --- | --- | --- | --- |
| コメント・文書コメント | `Comment`, `@comment`, `@comment.documentation` | 継承で対応。本文と区別しつつ読めること | 文字 |
| 文字列・文字 | `String`, `Character`, `@string`, `@character` | 継承で対応 | 文字 |
| エスケープ・正規表現 | `SpecialChar`, `@string.escape`, `@string.regexp` | 継承で対応。通常文字列との区別を確認 | 文字 |
| 数値・真偽値・定数 | `Number`, `Float`, `Boolean`, `Constant`, `@constant.*` | 継承で対応。null / nil / None、列挙値も役割を記録 | 文字 |
| 変数・組み込み変数 | `Identifier`, `@variable`, `@variable.builtin` | 継承で対応。self / this / cls を含む | 文字 |
| 引数・メンバー・プロパティ | `@variable.parameter`, `@variable.member`, `@property` | 継承で対応。変数との区別を確認 | 文字 |
| 関数・メソッド・呼び出し | `Function`, `@function.*` | 継承で対応。組み込み関数の分類も確認 | 文字 |
| 型・組み込み型・型引数 | `Type`, `Structure`, `Typedef`, `@type.*`, `@lsp.type.typeParameter` | 継承で対応。LSP の固有トークンは実機確認が必要 | 文字 |
| クラス・構造体・インターフェース・列挙 | `@lsp.type.class/struct/interface/enum/enumMember` | 継承で対応。型と値を混同しないか確認 | 文字 |
| 名前空間・モジュール・属性 | `@module.*`, `@attribute`, `@lsp.type.namespace/decorator` | 継承で対応。言語固有の意味は実機確認が必要 | 文字 |
| 条件・反復・戻り値・例外・修飾子 | `Statement`, `Conditional`, `Repeat`, `Keyword`, `Exception`, `@keyword.*` | 継承で対応。インポート、ストレージ、非同期・コルーチンも含む | 文字 |
| 演算子・プリプロセッサ・マクロ | `Operator`, `PreProc`, `Include`, `Define`, `Macro` | 継承で対応。LSP / Treesitter の分類差を確認 | 文字 |
| 括弧・区切り・特殊記号 | `Delimiter`, `@punctuation.*` | 継承で対応。本文と区別できること | 文字 |
| LSP 修飾情報 | `@lsp.mod.*`, `@lsp.typemod.*` | 実機確認が必要。readonly / static / defaultLibrary / deprecated 等を棚卸しし、既存の意味を覆わない | 文字・必要な装飾 |
| TODO・注記 | `Todo`, `@comment.todo/note/error/warning` | 継承で対応。todo-comments の追加表示は別表 | 文字・状態表示 |
| 言語限定の上書き | `@*.言語`, `lean*`, `sc*`, `review*` 等 | 実機確認が必要。共通定義で不足するものだけ専用定義にする | 文字 |

テーマはキャプチャを付けるパーサーや LSP を実装しない。
トークンが発行されない場合は、その経路を「適用なし」と記録し、別の経路での確認と区別する。

### エディタ・診断・変更・端末

| 役割 | 対象グループ例 | 継承・専用定義の方針 | 背景 |
| --- | --- | --- | --- |
| 本文・非アクティブ本文 | `Normal`, `NormalNC`, `EndOfBuffer` | 継承で対応。非アクティブ時も確認 | 透過追従 |
| 行番号・サイン帯・空白 | `LineNr`, `CursorLineNr`, `SignColumn`, `NonText`, `Whitespace` | 継承で対応。帯に意図しない背景が残らないこと | 基本は透過追従 |
| カーソル・現在行・現在列 | `Cursor`, `CursorLine`, `CursorColumn`, `ColorColumn` | 継承で対応。カーソルと位置識別を維持 | 必要な位置表示を残す |
| 選択 | `Visual`, `VisualNOS` | 継承で対応。通常文字を読めること | 選択背景を残す |
| 検索・置換 | `Search`, `IncSearch`, `CurSearch`, `Substitute` | 継承で対応。現在一致とその他一致を区別 | 一致背景を残す |
| 対応括弧 | `MatchParen` | 継承で対応。通常の括弧との差を確認 | 識別用の装飾・背景を残す |
| 折り畳み・インデント | `Folded`, `FoldColumn`, `Conceal`, プラグインのガイド | 実機確認が必要。ガイドと折り畳み行を区別 | ガイドは文字、折り畳み行は状態背景可 |
| 境界・フロートの枠と題名 | `WinSeparator`, `FloatBorder`, `FloatTitle` | 継承で対応。枠と本文の不自然な塗り分けを点検 | 通常面は透過追従 |
| ステータスライン・タブ・ウィンドウバー | `StatusLine*`, `TabLine*`, `WinBar*` | 実機確認が必要。現在位置・モード・アクティブ状態の背景を許容 | 状態背景可、空き面の扱いを確認 |
| 補完メニュー・説明 | `Pmenu*`, `BlinkCmp*` | 専用定義が必要。メニュー全体の固定背景と選択行を分ける | 通常面は透過、選択背景を残す |
| Quickfix・場所一覧・メッセージ | `QuickFixLine`, `Title`, `ErrorMsg`, `WarningMsg`, `MoreMsg` | 継承で対応 | 通常面は透過、選択・状態背景可 |
| 診断本文・サイン・仮想テキスト | `Diagnostic{Error,Warn,Info,Hint}*` | 継承で対応。severity の対応を統一 | 通常は文字、強調背景は実機確認 |
| 診断下線・不要・非推奨 | `DiagnosticUnderline*`, `DiagnosticUnnecessary`, `DiagnosticDeprecated` | 継承で対応。下線・薄色・取り消し線を確認 | 通常背景を維持 |
| 差分・Git | `DiffAdd/Change/Delete/Text`, `@diff.*`, `GitSigns*` | 継承で対応。行差分と文字差分を区別 | 差分背景を残す、サイン帯は透過 |
| ANSI 16色 | `terminal_color_0` ～ `terminal_color_15` | 継承で対応。通常・明色、前景・背景の役割を確認 | 端末面の透過設定に追従 |

### 文書・マークアップ・設定

| 役割 | 対象グループ例 | 継承・専用定義の方針 | 背景 |
| --- | --- | --- | --- |
| 見出し・強調・引用 | `@markup.heading.*`, `@markup.strong/italic/quote` | 継承で対応。段階と本文を区別 | 基本は文字 |
| リンク・URL・ラベル | `@markup.link.*`, `Underlined` | 継承で対応 | 文字・下線 |
| インラインコード・コードブロック | `@markup.raw.*`, 埋め込み言語の各グループ | 実機確認が必要。埋め込みの構文色を維持 | コード領域の識別背景は許容 |
| リスト・チェックボックス・表 | `@markup.list.*`, render-markdown のグループ | 継承で対応。レンダリング固有面は専用確認 | 通常面は透過、状態背景可 |
| HTML/XML タグ・属性 | `@tag`, `@tag.attribute`, `@tag.delimiter` | 継承で対応 | 文字 |
| 設定キー・値・区切り | `@property`, `@string`, `@constant`, `@punctuation.*` 等 | 実機確認が必要。JSON/YAML/TOML 等のキャプチャを照合 | 文字 |
| Re:VIEW の文書構文 | `reviewHeading`, `reviewInlineCommand`, `reviewBlockDeclaration`, `reviewComment*`, `reviewTodo` | 継承で対応。埋め込みコードも確認 | 通常面は透過、状態背景可 |

`vim-review` は執筆用の Re:VIEW 形式への対応であり、コードレビュー UI ではない。
別のコードレビュー専用プラグインを新たに導入することは今回の範囲に含めない。

## 3. 普段の環境で重点確認する統合

確認状況: ローカル設定・ロックファイル・統合一覧を照合済み。個別の描画はすべて未確認。
専用定義が必要な行でも、標準グループにリンクできる部分は継承を使う。

| 統合・役割 | 対象グループ／継承元 | 分類・確認点 | 透過方針 |
| --- | --- | --- | --- |
| blink.cmp | `BlinkCmp*`, `Pmenu*`, `Comment` | 継承で対応＋通常メニュー面の専用調整。候補・選択・種類・説明・ghost text | 通常面透過、選択背景を残す |
| fzf-lua / Snacks picker | `FzfLua*`, `SnacksPicker*` | 継承で対応。入力・一致・選択・プレビュー・枠 | 通常面透過、選択・一致を残す |
| Snacks 通知・dashboard・画像表示周辺 | `SnacksNotifier*`, `SnacksDashboard*`, 標準フロート | 継承で対応。severity、アイコン、見出し、余白。画像そのものの色は変更しない | 通常面透過 |
| Oil | `Oil*` → `Directory`, `Comment`, `Diagnostic*` 等 | 専用定義が必要。既存リンクは継承し、リンク先がない項目や固定色を補う。隠し項目・壊れたリンク・操作プレビュー | フロート透過、操作状態を識別 |
| Noice | `Noice*`, `NormalFloat`, `FloatBorder` | 継承で対応。コマンド入力・ヘルプ・長文・履歴 | 通常面透過 |
| bufferline / Lualine | `BufferLine*`, Lualine テーマ | 継承で対応。モード・アクティブ・変更・診断・非アクティブ | 状態背景可 |
| GitSigns / Lazygit 表示 | `GitSigns*`, `Diff*`, 端末 ANSI 色 | 継承で対応。ハンク・blame・プレビュー。Lazygit 本体のテーマ調整は extras 工程 | 通常面透過、差分背景を残す |
| Trouble / which-key / lazy.nvim | `Trouble*`, `WhichKey*`, `Lazy*` | 継承で対応。一覧・選択・診断・ヘルプ・インストール状態 | 通常面透過、選択・状態背景可 |
| Flash / Yanky / mini.ai / mini.pairs | `Flash*`, `Yanky*`, 標準選択・対応括弧 | 継承で対応。ジャンプ先・コピー・対応括弧。操作のみの機能には色を増やさない | 一時的な強調を残す |
| mini.icons / nvim-web-devicons | `MiniIcons*`, `DevIcon*` | 実機確認が必要。アイコン独自色の有無・可読性・役割を確認 | 背景なし |
| render-markdown | `RenderMarkdown*`, `@markup.*` | 専用定義が必要。コード領域、チェックボックス等。現在無効な見出し・リンク・表の描画機能は有効化しない | 通常面透過、コード・状態背景可 |
| Re:VIEW | `review*` → 共通構文 | 継承で対応。見出し・コマンド・コメントと設定済み6言語の埋め込みコード | 通常面透過 |
| neotest と各 adapter | `Neotest*` | 継承で対応。成功・失敗・実行中・スキップ・サマリー・出力。adapter ごとに色を増やさない | 通常面透過、状態を識別 |
| nvim-coverage | `CoverageCovered/Uncovered/Partial`, `CoverageSummary*` | 専用定義が必要。サイン、部分カバー、閾値、サマリー、カーソル行 | 通常面透過、状態背景可 |
| Lean | `lean*`, `leanInfo*`, `widget*`, `@lsp.*.lean` | 実機確認が必要。専用状態の不足は補う。goal・仮定・選択・期待型・差分・停止・LSP 切断・widget | 通常面透過、選択・差分・状態背景可 |
| SuperCollider / scnvim | `sc*` 系構文、post window 構文、`IncSearch` | 実機確認が必要。固有構文・出力・エラー・評価時の flash/fade・signature を棚卸し | 通常面透過、評価時の強調を残す |
| grug-far | `GrugFar*` → `Diff*`, `Comment`, `NormalFloat` 等 | 専用定義が必要。標準リンクは継承、追加・削除の固定色を補う。検索・置換・進捗・エラー | 通常面透過、一致・差分背景を残す |
| todo-comments | `TodoFg*`, `TodoBg*`, `TodoSign*` → 診断色 | 実機確認が必要。起動時・テーマ変更時に動的生成される色と severity を照合 | キーワード背景可、サイン帯透過 |
| Zen mode | `ZenBg`, 本文・周辺領域 | 実機確認が必要。集中表示と透過の共存。現在の機能設定は維持 | 通常面の透過を壊さない |
| Mason / LSP / formatter / lint / live-preview | `Mason*`, `Diagnostic*`, 標準 UI・構文 | 実機確認が必要。独自 UI があるものだけ定義を点検。外部ブラウザのプレビューは別工程 | 標準面の方針を継承 |

## 4. 言語・形式の確認範囲

付録Aの設定済みパーサー全件に加え、Lean、Re:VIEW、JSX を最初から含める。
各言語を後続対象へ移さない。言語ごとの専用色は必須とせず、共通定義の適用を先に確認する。
JSONC は JSON 系の関連形式として確認する。

| 分類 | 対象 | 重点シナリオ | 方針・現在の確認状況 |
| --- | --- | --- | --- |
| 一般プログラミング | Lua、TS/JS、TSX/JSX、Python、Ruby、Rust、Go、C/C++、Swift | 変数・引数・定数・型・関数・組み込み・修飾子、文書コメント | 継承で対応、言語固有差は実機確認が必要。設定照合済み／描画未確認 |
| Lean | Lean 4、infoview | Type / Prop / Sort、宣言、名前空間、証明、診断、goal と widget | 実機確認が必要。設定・プラグインソース照合済み／描画未確認 |
| 音楽プログラミング | SuperCollider | symbol、引数、クラス、関数、イベント、評価と post window | 実機確認が必要。設定照合済み／描画未確認 |
| Web・埋め込み | HTML、XML、Vue、Astro、CSS、SCSS、embedded_template | タグ・属性・selector・property・埋め込み JS/TS/CSS/Ruby | 継承で対応、injection は実機確認が必要。設定照合済み／描画未確認 |
| 設定・データ | JSON/JSONC、YAML、TOML、SQL | キー・値・真偽値・null、文字列、クエリ語、コメント | 継承で対応。設定照合済み／描画未確認 |
| ビルド・シェル | Bash、Dockerfile、Make、gomod、gosum、gowork | コマンド・変数展開・命令・依存関係・バージョン | 継承で対応。設定照合済み／描画未確認 |
| 文書・執筆 | Markdown / inline、LaTeX、Re:VIEW、Vim help | 見出し、リンク、コード、数式、環境、埋め込み構文 | 継承で対応、表示プラグインは専用確認。設定照合済み／描画未確認 |
| 構文の補助 | Vim script、diff、query、regex、printf、jsdoc、luadoc、luap | 注入された補助構文と外側の構文の共存 | 継承で対応。設定照合済み／描画未確認 |

LSP は設定されているサーバーの経路で確認する。全言語への LSP やパーサーの新規導入は行わない。
その環境で使えない経路は「適用なし／理由」を記録する。表示経路そのものが使えなければ、確認は保留として残す。

## 5. 透過・Blur と独自配色

### 背景の定義範囲

本文、非アクティブ本文、サイドバー、フロート、補完の通常面は透過対象。
色を持つ枠やタイトルが、周囲に不透明な四角を作らないことも確認する。
背景色を付けないことと、全ハイライトの背景を消すことは区別する。

選択、現在の候補、検索一致、差分、評価時の強調などは、状態識別の背景を残す。
通常面に例外的な背景を残す必要があれば、状態・理由を対応表に明記してから実装する。

透過率・Blur・壁紙は Omarchy / 端末側の責務。このテーマはそれらを変更せず、
背景の有無・文字・枠・状態表示の可読性を扱う。非透過モードでは同じ役割をテーマ背景上で確認する。
明るい壁紙、暗い壁紙、模様の多い壁紙で確認し、透過時の見え方を単一の背景色の計算だけで合格にしない。

### 任意の独自配色

現在の `on_highlights` にある次の意図を、標準配色とは別の追加設定の移植対象として記録する。

- 値・定数・プリミティブ型・ローカル変数・引数・プロパティを警告側に置く。
- クラス・構造体・列挙・名前空間・インターフェース・型引数を安全側に置く。
- null / nil / None、self / cls、Ruby 定数名、TS/Go の組み込み型、Lean の専用状態などの例外を扱う。
- 現在の適用対象は Rust、TS/JS と関連 filetype、Python、Ruby、Go、Lean。
- YAML / JSON / Markdown 等へ波及しない。将来の言語追加を暗黙に行わない。

標準テーマでは無効とする。追加設定の具体的 API、色値、装飾、移植方法は次の実装計画で決める。
今回は利用中の独自配色を移動・削除しない。

## 6. 後続の検証と完了条件

読み込み、定義、描画を別々に記録する。現在の主要色の headless 検査を、
全言語・全プラグインの実際の描画確認に読み替えない。

| 検証軸 | ケース | 合格条件 |
| --- | --- | --- |
| テーマ | 雪夜／流氷、切り替え・再読込 | 役割が一致し、切り替え前の色や背景が残らない |
| 背景 | 透過／非透過、active／inactive | 指定した通常面が方針に追従し、選択・差分等は判別できる |
| 表示経路 | 従来構文、Treesitter、LSP、両者併用 | 適用可能な経路で確認し、意味を変える上書きを検出する |
| 言語 | 本文書と付録Aの全対象 | 代表コードで変数・型・値・関数・文書と固有構文を確認する |
| プラグイン | 起動／遅延読込／テーマ変更後 | 通常・選択・エラーと各プラグイン固有の状態を確認する |
| 診断・Git・テスト | severity 全種、差分全種、テスト成功・失敗・実行中・スキップ | 意味が共通の役割に揃い、通常表示から区別できる |
| 利用者の上書き | 標準／独自配色有効時／on_highlights | 標準と追加設定を分離し、最後の明示的な上書きを尊重する |
| 実表示 | 通常の端末と Blur、明暗・模様のある壁紙 | 本文・コメント・枠・選択・フロートが判読できる。利用中の設定を勝手に変更しない |

後続の記録は `対象 / 定義の存在 / 読み込み結果 / 描画結果 / 構成・再現手順 / 未解決点` を持つ。
ソース確認だけなら「描画未確認」、経路がなければ「適用なし」、環境不足なら「保留」とする。
未確認・保留を合格扱いにしない。

範囲確定の完了条件:

- [x] 共通の役割と対象グループ例を列挙した。
- [x] 設定済み言語全件と現在のプラグイン全件を照合し、付録に記録した。
- [x] 継承・専用定義・実機確認の区別を設けた。
- [x] 透過面と識別用の背景、任意の独自配色の扱いを確定した。
- [x] 描画を含む後続の検証条件を定めた。

範囲確定後は、役割ごとの具体的配色、共通定義、重点プラグインと全設定済み言語、
任意の独自配色、extras の個別調整の順で計画を具体化する。

## 7. 調査の根拠

2026-10-23〜24 に確認したローカルスナップショット。リモート main の最新内容との同一性は保証しない。

- `lua/shimaenaga/{config,colors,semantic,theme}.lua` と `groups/*.lua`、Lualine / Lightline 統合。
- `~/.config/nvim/lua/config/lazy.lua`、`lua/plugins/*.lua`、`lazyvim.json`、`lazy-lock.json`。
- ローカル LazyVim の `lua/lazyvim/plugins/treesitter.lua` の既定パーサー一覧。
- ローカルの Oil、Lean、scnvim、vim-review、nvim-coverage、grug-far、todo-comments 等のグループ定義。
- `~/.config/foot/foot.ini` と `~/.config/hypr/hyprland.lua` の透過・Blur 指定。
- [Solarized Osaka の元構成](https://github.com/craftzdog/solarized-osaka.nvim/tree/main/lua/solarized-osaka)。取り込み元のローカル版は `lazy-lock.json` で `a21176efde15fab21fabda0bf2ba123ed6d7332d`。

## 付録A. 設定済みパーサーの全件照合

LazyVim 標準 23 件、利用者の追加 22 件、重複を除いた合計 41 件。
全件「継承で対応、固有差は実機確認が必要」。設定の存在を確認済みで、インストール成功や描画確認は別途記録する。

| パーサー | 設定元 | 描画確認 |
| --- | --- | --- |
| `astro` | 利用者の追加 | 未確認 |
| `bash` | LazyVim 標準 | 未確認 |
| `c` | LazyVim 標準 | 未確認 |
| `cpp` | 利用者の追加 | 未確認 |
| `css` | 利用者の追加 | 未確認 |
| `diff` | LazyVim 標準 | 未確認 |
| `dockerfile` | 利用者の追加 | 未確認 |
| `embedded_template` | 利用者の追加 | 未確認 |
| `go` | 利用者の追加 | 未確認 |
| `gomod` | 利用者の追加 | 未確認 |
| `gosum` | 利用者の追加 | 未確認 |
| `gowork` | 利用者の追加 | 未確認 |
| `html` | LazyVim 標準 | 未確認 |
| `javascript` | 標準＋追加 | 未確認 |
| `jsdoc` | LazyVim 標準 | 未確認 |
| `json` | LazyVim 標準 | 未確認 |
| `latex` | 利用者の追加 | 未確認 |
| `lua` | LazyVim 標準 | 未確認 |
| `luadoc` | LazyVim 標準 | 未確認 |
| `luap` | LazyVim 標準 | 未確認 |
| `make` | 利用者の追加 | 未確認 |
| `markdown` | LazyVim 標準 | 未確認 |
| `markdown_inline` | LazyVim 標準 | 未確認 |
| `printf` | LazyVim 標準 | 未確認 |
| `python` | 標準＋追加 | 未確認 |
| `query` | LazyVim 標準 | 未確認 |
| `regex` | LazyVim 標準 | 未確認 |
| `ruby` | 利用者の追加 | 未確認 |
| `rust` | 利用者の追加 | 未確認 |
| `scss` | 利用者の追加 | 未確認 |
| `sql` | 利用者の追加 | 未確認 |
| `supercollider` | 利用者の追加 | 未確認 |
| `swift` | 利用者の追加 | 未確認 |
| `toml` | LazyVim 標準 | 未確認 |
| `tsx` | 標準＋追加 | 未確認 |
| `typescript` | 標準＋追加 | 未確認 |
| `vim` | LazyVim 標準 | 未確認 |
| `vimdoc` | LazyVim 標準 | 未確認 |
| `vue` | 利用者の追加 | 未確認 |
| `xml` | LazyVim 標準 | 未確認 |
| `yaml` | LazyVim 標準 | 未確認 |

パーサー一覧外の重点対象: Lean（lean.nvim の構文・LSP）、Re:VIEW（vim-review の構文）、JSX（TSX 系経路）、JSONC（JSON 系経路）。

## 付録B. 現在のプラグイン全件照合

`lazy-lock.json` の 54 件を分類。ロックされていることと、その機能が常時有効であることは区別する。
表の「共通表示」は専用定義の追加を要求せず、実装時に独自 UI があれば確認対象へ加える。全件の個別描画は未確認。

| プラグイン | 対応範囲・分類 |
| --- | --- |
| `blink.cmp` | 継承で対応（`groups/blink.lua`）。普段の環境として重点確認 |
| `bufferline.nvim` | 継承で対応（`groups/bufferline.lua`）。普段の環境として重点確認 |
| `catppuccin` | 別テーマ。Shimaenaga の定義対象外 |
| `conform.nvim` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `FixCursorHold.nvim` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `flash.nvim` | 継承で対応（`groups/flash.lua`）。普段の環境として重点確認 |
| `friendly-snippets` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `fzf-lua` | 継承で対応（`groups/fzf.lua`）。普段の環境として重点確認 |
| `gitsigns.nvim` | 継承で対応（`groups/gitsigns.lua`）。普段の環境として重点確認 |
| `grug-far.nvim` | 専用定義が必要（既定リンクと固定色） |
| `lazy.nvim` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `lazydev.nvim` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `LazyVim` | 共通 UI と有効プラグインの組み合わせを重点確認 |
| `lean.nvim` | 実機確認が必要（構文・LSP・infoview・widget） |
| `live-preview.nvim` | 継承で対応（Neovim 側）。外部プレビュー配色は後続工程 |
| `lualine.nvim` | Lualine 専用テーマを継承 |
| `mason-lspconfig.nvim` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `mason.nvim` | 実機確認が必要（Mason 固有 UI と標準リンク） |
| `mini.ai` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `mini.icons` | 継承で対応（`groups/mini_icons.lua`）。普段の環境として重点確認 |
| `mini.pairs` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `neotest` | 継承で対応（`groups/neotest.lua`）。普段の環境として重点確認 |
| `neotest-jest` | 継承で対応（Neotest 共通）。成功・失敗・出力の経路を確認 |
| `neotest-playwright` | 継承で対応（Neotest 共通）。成功・失敗・出力の経路を確認 |
| `neotest-python` | 継承で対応（Neotest 共通）。成功・失敗・出力の経路を確認 |
| `neotest-rspec` | 継承で対応（Neotest 共通）。成功・失敗・出力の経路を確認 |
| `neotest-vitest` | 継承で対応（Neotest 共通）。成功・失敗・出力の経路を確認 |
| `noice.nvim` | 継承で対応（`groups/noice.lua`）。普段の環境として重点確認 |
| `nui.nvim` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `nvim-coverage` | 専用定義が必要（サイン・サマリー） |
| `nvim-lint` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `nvim-lspconfig` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `nvim-nio` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `nvim-treesitter` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `nvim-treesitter-textobjects` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `nvim-ts-autotag` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `nvim-web-devicons` | 実機確認が必要（アイコン独自色） |
| `oil.nvim` | 専用定義が必要（既存リンクを継承し、不足を補う） |
| `persistence.nvim` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `plenary.nvim` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `render-markdown.nvim` | 専用定義が必要（標準構文を継承） |
| `scnvim` | 実機確認が必要（構文・評価・post window） |
| `snacks.nvim` | 継承で対応（`groups/snacks.lua`）。普段の環境として重点確認 |
| `solarized-osaka.nvim` | 比較元・利用中の別テーマ。変更しない |
| `todo-comments.nvim` | 実機確認が必要（動的生成と診断色の参照） |
| `tokyonight.nvim` | 別テーマ。Shimaenaga の定義対象外 |
| `treesj` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `trouble.nvim` | 継承で対応（`groups/trouble.lua`）。普段の環境として重点確認 |
| `ts-comments.nvim` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `vim-abolish` | 継承で対応（共通 UI・構文・診断）。専用の配色追加は要求しない |
| `vim-review` | 継承で対応（Re:VIEW 文書構文、埋め込みコード） |
| `which-key.nvim` | 継承で対応（`groups/which-key.lua`）。普段の環境として重点確認 |
| `yanky.nvim` | 継承で対応（`groups/yanky.lua`）。普段の環境として重点確認 |
| `zen-mode.nvim` | 実機確認が必要（集中表示と透過） |

## 付録C. 未使用の取り込み済み統合

以下はローダーに登録されているが、現在のロック一覧に同名のプラグインがない統合。
定義を維持し、基本の読み込み・定義検査を行う。個別の描画確認は未実施で、今回の重点確認範囲には含めない。

| プラグイン | 継承する定義 | 確認状況 |
| --- | --- | --- |
| `alpha-nvim` | `groups/alpha.lua` | 定義あり／描画未確認 |
| `barbar.nvim` | `groups/barbar.lua` | 定義あり／描画未確認 |
| `dashboard-nvim` | `groups/dashboard.lua` | 定義あり／描画未確認 |
| `hop.nvim` | `groups/hop.lua` | 定義あり／描画未確認 |
| `incline.nvim` | `groups/incline.lua` | 定義あり／描画未確認 |
| `indent-blankline.nvim` | `groups/indent-blankline.lua` | 定義あり／描画未確認 |
| `leap.nvim` | `groups/leap.lua` | 定義あり／描画未確認 |
| `lightspeed` | `groups/lightspeed.lua` | 定義あり／描画未確認 |
| `lspsaga.nvim` | `groups/lspsaga.lua` | 定義あり／描画未確認 |
| `mini.animate` | `groups/mini_animate.lua` | 定義あり／描画未確認 |
| `mini.clue` | `groups/mini_clue.lua` | 定義あり／描画未確認 |
| `mini.completion` | `groups/mini_completion.lua` | 定義あり／描画未確認 |
| `mini.cursorword` | `groups/mini_cursorword.lua` | 定義あり／描画未確認 |
| `mini.deps` | `groups/mini_deps.lua` | 定義あり／描画未確認 |
| `mini.diff` | `groups/mini_diff.lua` | 定義あり／描画未確認 |
| `mini.files` | `groups/mini_files.lua` | 定義あり／描画未確認 |
| `mini.hipatterns` | `groups/mini_hipatterns.lua` | 定義あり／描画未確認 |
| `mini.indentscope` | `groups/mini_indentscope.lua` | 定義あり／描画未確認 |
| `mini.jump` | `groups/mini_jump.lua` | 定義あり／描画未確認 |
| `mini.map` | `groups/mini_map.lua` | 定義あり／描画未確認 |
| `mini.notify` | `groups/mini_notify.lua` | 定義あり／描画未確認 |
| `mini.operators` | `groups/mini_operators.lua` | 定義あり／描画未確認 |
| `mini.pick` | `groups/mini_pick.lua` | 定義あり／描画未確認 |
| `mini.starter` | `groups/mini_starter.lua` | 定義あり／描画未確認 |
| `mini.statusline` | `groups/mini_statusline.lua` | 定義あり／描画未確認 |
| `mini.surround` | `groups/mini_surround.lua` | 定義あり／描画未確認 |
| `mini.tabline` | `groups/mini_tabline.lua` | 定義あり／描画未確認 |
| `mini.test` | `groups/mini_test.lua` | 定義あり／描画未確認 |
| `mini.trailspace` | `groups/mini_trailspace.lua` | 定義あり／描画未確認 |
| `neo-tree.nvim` | `groups/neo-tree.lua` | 定義あり／描画未確認 |
| `neogit` | `groups/neogit.lua` | 定義あり／描画未確認 |
| `nvim-cmp` | `groups/cmp.lua` | 定義あり／描画未確認 |
| `nvim-navic` | `groups/navic.lua` | 定義あり／描画未確認 |
| `nvim-notify` | `groups/notify.lua` | 定義あり／描画未確認 |
| `nvim-scrollbar` | `groups/scrollbar.lua` | 定義あり／描画未確認 |
| `nvim-tree.lua` | `groups/nvim-tree.lua` | 定義あり／描画未確認 |
| `nvim-treesitter-context` | `groups/treesitter-context.lua` | 定義あり／描画未確認 |
| `nvim-ts-rainbow` | `groups/nvim-ts-rainbow.lua` | 定義あり／描画未確認 |
| `nvim-ts-rainbow2` | `groups/nvim-ts-rainbow2.lua` | 定義あり／描画未確認 |
| `rainbow-delimiters.nvim` | `groups/rainbow-delimiters.lua` | 定義あり／描画未確認 |
| `telescope.nvim` | `groups/telescope.lua` | 定義あり／描画未確認 |
| `ts-node-action` | `groups/ts-node-action.lua` | 定義あり／描画未確認 |
| `vim-fern` | `groups/fern.lua` | 定義あり／描画未確認 |
| `vim-gitgutter` | `groups/gitgutter.lua` | 定義あり／描画未確認 |
| `vim-glyph-palette` | `groups/glyph-palette.lua` | 定義あり／描画未確認 |
| `vim-illuminate` | `groups/illuminate.lua` | 定義あり／描画未確認 |
| `vim-sneak` | `groups/sneak.lua` | 定義あり／描画未確認 |
