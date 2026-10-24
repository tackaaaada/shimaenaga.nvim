# 検証

## 単独で実行できる検査

NeovimとPythonを用意し、リポジトリのルートで実行してください。
生成済みデータや外部アプリは必要ありません。

```sh
python scripts/check.py
```

次の既存検査をまとめて実行します。

- 明暗の基本色、公開setup/loadと上書き、透過、全Luaファイルの構文。
- 純粋な色計算、入力テーブルの分離、背景変更、フロート等の面設定。
- 配色プレビューの11ページ、切り替え操作、全体ハイライトの分離。
- Lualineテーマの帯の配色、ステータスラインの背景、セッション内の背景比較。

Lualineを使った実際の区切りと表示項目の描画は、別途プラグインを指定したときだけ検査します。
未指定時は描画検査をSKIPと表示し、テーマの配色検査は実行します。

```sh
SHIMAENAGA_LUALINE_PATH=/path/to/lualine.nvim python scripts/check.py
```

Neovimの各プラグインの実画面をすべて確認したことを意味しません。

## 任意のLazyVim確認

`scripts/validation/` は、利用者のLazyVim設定のコピーと導入済みプラグインを使う任意の検証です。
標準の単独テストの前提にはしません。利用者の設定・言語サーバー等によって結果が変わります。
生成される設定のコピー・ログ・サンプルはGit管理対象外の `build/verification/` に保存します。

```sh
python scripts/validation/run.py --interactive
SHIMAENAGA_QUICK=1 python scripts/validation/run.py --oil
SHIMAENAGA_QUICK=1 python scripts/validation/run.py --lualine
```

自動更新・新規プラグインの導入を止め、テーマは検証用の設定で選びます。
Neovimを終了すると元の通常設定を使えます。
開発中の個人環境の詳細記録は公開物に含めていません。
