# Shimaenaga の設計メモ

2026-10-24。design-principles-coach の責務分離・DRY・不変性の観点で整理した。
色値、公開の setup/load/colorscheme とコールバックの順序、透過設定、表示項目は変更していない。

## 1. 同じ変更理由を持つ色生成を集約する

変更前は本体の色生成に加え、検証用の `backgrounds.lua` にも次の生成処理があった。

```lua
for _,tier in ipairs({600,700,800,900,950}) do
  c[name..tier] = design.blend(c.bg,c[name],(1000-tier)/1000)
end
```

派生色や互換スロットを追加すると、本体と背景比較の両方を直す必要があった。
背景を変更するという同じ理由で変わる知識なので、DRY を適用した。

- `design.lua`: RGB混合と、役割を持つ派生色の計算。エディタの設定を読まない。
- `color_scheme.lua`: 入力されたパレット・明暗・面の設定から、完全な色テーブルを作る。
- `colors.lua`: 利用者の設定を解決し、組み立てた後に `on_colors` を呼ぶ公開境界。
- 検証用の背景比較: `color_scheme.with_background` に委譲し、色計算を持たない。

`build` と `with_background` は入力を変更せず、新しいテーブルを返す。
背景だけを変更する処理では、利用者が指定した無関係な色や独自のキーを維持する。

トレードオフとしてファイルを一つ増やしたが、背景比較側から互換色スロットの知識を除ける。
公開コールバックは既存の可変テーブルの契約を維持し、無理に不変APIへ変更しない。

## 2. ハイライトを変更理由ごとに分ける

変更前の `semantic.lua` は、`@variable` 等の構文規則、`NormalFloat` 等の画面規則、
`BlinkCmpMenu` 等のプラグイン固有規則を一つの関数で上書きしていた。
補完の背景だけを変える場合も、構文・LSPの上書きと同じ関数を読む必要があった。

`highlights/` に分け、`semantic.apply` は順序だけを管理する。

1. `syntax.lua`: 従来構文・Treesitter・LSP の役割。
2. `editor.lua`: 本文・面・選択・検索・差分・診断・文書の表示。
3. `plugins.lua`: 有効なプラグインのハイライトの補正。

最後に利用者の `on_highlights` を適用する順序は変えていない。
複数グループへ同じ規則を適用する際も、属性テーブルはそれぞれコピーし、
一つのグループの変更が隣のグループへ波及しないようにする。

行数だけを基準に分割せず、変更理由と適用順序を基準にした。
トレードオフは規則の全体を読む際にファイルを移動することだが、適用順序は入口の3行で把握できる。
テストの独立した色値の期待値は仕様の検査に必要なので、製品の生成処理へ統合しない。

## 3. Oil の配色とウィンドウ管理を分離する

変更前の `groups/oil.lua` は配色を返すほか、次の状態とイベント処理も持っていた。

```lua
local M = { saved = {}, enabled = false }
```

配色定義の読み込みと、ウィンドウへの適用・復元では変更理由と副作用が異なる。
また、保存中のウィンドウ状態を外部から読める必要はなかった。

- `groups/oil.lua`: 色テーブルを受け、ハイライト定義を返す。
- `integrations/oil.lua`: イベント登録、ウィンドウ単位の適用、元の割り当ての復元を担当する。
- `theme.lua`: Oilの配色が有効なときに連携を有効化する。

保存状態は連携モジュールのローカル変数とし、検査も内部の保存テーブルを読む方法から、
実際の `winhighlight` の適用と復元を見る方法に変更した。
無関係な利用者のハイライト割り当てが残ることも確認する。

トレードオフは入口から連携モジュールへの委譲が一つ増えること。
別のウィンドウ管理フレームワークや汎用クラスは追加しない。

## 変更しないものと検証

- 配色の正本・表示される全ハイライトは維持する。
- 変更前後で両テーマ × 透過2通り × 面設定4通りの16構成を保存し、全色・全ハイライトの一致を確認。
- 新しい純粋な組み立て処理について、入力を変えないこと、返した子テーブルが入力と共有されないこと、
  背景変更で無関係な上書きを壊さないことを検査。
- 本体・専用プレビュー・Lualine・背景3候補の既存検査を再実行。
- 実際の検証用LazyVimで、Oilフロートの適用／復元とLualineのパス表示を確認。
- 普段のNeovim設定は変更しない。

主な検査コマンド:

```sh
nvim --headless --clean -l scripts/check-color-scheme.lua
nvim --headless --clean -l scripts/check.lua
nvim --headless --clean -l scripts/check-color-preview.lua
nvim --headless --clean -l scripts/check-lualine.lua
nvim --headless --clean -l scripts/check-backgrounds.lua
SHIMAENAGA_QUICK=1 python scripts/validation/run.py --oil
SHIMAENAGA_QUICK=1 python scripts/validation/run.py --lualine
```

41パーサーの実解析記録など、以前の検証と保留事項は [verification.md](verification.md) を参照。
今回の整理だけで、未確認の画面やLSPが確認済みになるものではない。
