# shimaenaga.nvim

[English](README.md) | **日本語**

![雪夜の枝と流氷の上にそれぞれ佇む、2羽ずつのシマエナガ](assets/shimaenaga-banner.png)

**Shimaenaga**（Long-tailed tit. 学名：*Aegithalos caudatus caudatus*）を名前に冠した、
北海道の色をイメージした Neovim のカラーテーマ。
**雪夜 Yukiyo**（dark）と **流氷 Ryuhyo**（light）を用意しています。
標準構文、Treesitter、LSP、Neovimプラグインのハイライトと、Neovim内蔵ターミナルの配色を含みます。

このリポジトリは、Neovimのカラーテーマとプラグイン連携に対象を絞っています。
バナーはGeminiで生成し、OpenAIの画像生成機能で配色を調整しました。

## インストール

以下は lazy.nvim の例です。動作検証には Neovim 0.12.6 を使用しています。

```lua
{
  "tackaaaada/shimaenaga.nvim",
  lazy = false,
  priority = 1000,
  opts = { transparent = false },
  config = function(_, opts)
    require("shimaenaga").setup(opts)
    vim.cmd.colorscheme("shimaenaga-yukiyo")
  end,
}
```

ローカルのチェックアウトを使う場合は、プラグイン指定を
`dir = vim.fn.expand("/path/to/shimaenaga.nvim")` と `name = "shimaenaga.nvim"` に置き換えます。
LazyVim では次も設定し、他のテーマを直接読み込む設定との重複を避けてください。

```lua
{ "LazyVim/LazyVim", opts = { colorscheme = "shimaenaga-yukiyo" } }
```

流氷は `shimaenaga-ryuhyo`。`shimaenaga` は `background=dark/light` に追従します。

## 透過とカスタマイズ

```lua
require("shimaenaga").setup({
  transparent = true,
  styles = {
    sidebars = "transparent",
    floats = "transparent",
  },
  on_colors = function(colors)
    -- colors.blue = "#3c9ee3"
  end,
  on_highlights = function(highlights, colors)
    -- highlights.Comment = { fg = colors.comment, italic = true }
  end,
})
```

透過は本文・フロート等の背景色を解除します。実際の透明度とBlurは端末・コンポジター側で設定します。
ステータスラインは透過時も帯を残します。

Lualine は表示項目を変えず、テーマと区切りだけ指定できます。

```lua
{
  "nvim-lualine/lualine.nvim",
  opts = { options = {
    theme = "shimaenaga",
    section_separators = { left = "", right = "" },
    component_separators = { left = "", right = "" },
  } },
}
```

## 配色

| 用途 | 色の役割 |
| --- | --- |
| キーワード | 紫 |
| 関数 | 青 |
| 型・組み込み | シアン |
| 文字列 | 緑 |
| 数値・定数 | オレンジ |
| 演算子・特殊文字 | 桜色 |
| 変数・引数・プロパティ | 本文色 |
| 括弧 | オレンジと本文色の混合 |
| 警告 | 黄 |
| エラー・削除差分 | 赤 |

雪夜の本文背景は `#070c17`、メニューは `#0b1221`、ステータスラインは `#111b2f`。
流氷は落ち着いた白 `#e9eef5` を背景に使います。
詳しくは [配色仕様](docs/color-spec.md) と [ハイライト対象](docs/highlight-scope.md) を参照してください。

## プレビュー

![雪夜と流氷でTypeScriptの構文色を並べた見本](assets/code-preview.svg)

この画像は不透明な標準配色による見本です。実際の表示は構文解析や透過の設定によっても変わります。

チェックアウトのルートで実行します。普段のNeovim設定は変更しません。

```sh
nvim --clean -c 'luafile scripts/color-preview.lua'
```

Tabで雪夜／流氷、tで透過、[ / ]で11ページを切り替えます。
雪夜のbは背景3候補の比較、流氷のbは白背景の比較です。終了は `:q!`。
実際のテーマ本体を読み込む見本は `scripts/preview.lua` です。

## 開発と検証

配色の正本は `lua/shimaenaga/palette.lua`。
配色を変更したら `python scripts/render-code-preview.py` で見本画像を再生成できます。
NeovimとPython 3.11以降で、単独の検査を実行します。

```sh
python scripts/check.py
```

既存のパレット・ハイライト・透過・プレビュー・ステータスライン配色の検査をまとめて実行します。
配布ファイルの生成や、別プラグインのインストールは不要です。
Lualineの実際の描画も確認する場合は、導入済みのLualineを明示します。

```sh
SHIMAENAGA_LUALINE_PATH=/path/to/lualine.nvim python scripts/check.py
```

検証の範囲と任意のLazyVim確認は [verification.md](docs/verification.md)、
責務の分け方は [architecture.md](docs/architecture.md) を参照してください。
`build/` は検証ログ・ローカル設定のコピー・復元用データを含むため、Git管理対象外です。

## ライセンス・出典

Apache-2.0。[LICENSE](LICENSE) と [UPSTREAM.md](UPSTREAM.md) を参照してください。
ハイライト統合は [Solarized Osaka](https://github.com/craftzdog/solarized-osaka.nvim) 由来です。
