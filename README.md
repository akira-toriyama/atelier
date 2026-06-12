# atelier

macOS 向け Swift アプリ家系の **ワークスペース枠組み**。各アプリは
それぞれ独立した GitHub リポジトリ。atelier はソースを持たず、アプリの実体は
[**ghq**](https://github.com/x-motemen/ghq) ツリー
（`$(ghq root)/github.com/<owner>/<app>`）に置き、atelier は **clone / pull /
run / stop のオーケストレーションだけ**を担う。実体は1か所（ghq）なので、
普段 ghq で開発するコピーと atelier が起動するコピーが一致する（二重持ち無し）。

## Apps

| app | 役割 | run.sh |
|---|---|---|
| [chord](https://github.com/akira-toriyama/chord) | グローバル キー+マウス ホットキー常駐 | ✓ |
| [facet](https://github.com/akira-toriyama/facet) | ワークスペース / ウィンドウ マネージャ | ✓ |
| [glance](https://github.com/akira-toriyama/glance) | stdin を非アクティブ NSPanel に表示する one-shot CLI | ✓ |
| [halo](https://github.com/akira-toriyama/halo) | アクティブウィンドウのネオンリング | ✓ |
| [jig](https://github.com/akira-toriyama/jig) | jq 互換 JSON プロセッサ CLI（humane errors） | ✓ |
| [perch](https://github.com/akira-toriyama/perch) | キーボード駆動 UI ナビゲータ（hint mode） | ✓ |
| [sill](https://github.com/akira-toriyama/sill) | 共有テーマ基盤（Palette / PaletteKit / Effects） | — (library) |
| [wand](https://github.com/akira-toriyama/wand) | カーソル基準のマウス自動化（cast / tome） | ✓ |

共通家風: Swift 6 / macOS 13+ / ヘキサゴナル3層 / TOML 設定 /
`LSUIElement` 常駐 / README EN+JA / gitmoji + Conventional Commits /
Homebrew 配布。**sill** が family の共有テーマライブラリ。

前提: [`ghq`](https://github.com/x-motemen/ghq)（`brew install ghq`）。

## Install

atelier 取得 → 全アプリ取得まで **ワンライナー**（すべて ghq ツリーに入る）:

```sh
ghq clone git@github.com:akira-toriyama/atelier.git && \
  cd "$(ghq root)/github.com/akira-toriyama/atelier" && ./clone.sh
```

atelier を ghq で取得して `./clone.sh` を叩くだけ。グローバル git 設定には一切
触れず **atelier 内で完結**する。ghq 自体に clone 時フックは無いため「ghq clone
した瞬間に自動発火」はできない（それはグローバルな `init.templateDir` が要る）ので、
取得後に `./clone.sh` を 1 回叩く形をそのまま 1 行にまとめている。

## Usage

一括 (bulk) がデフォルト。`clone` / `pull` / `run` / `stop` で family 全体を操作する。
アプリの実体は ghq ツリー（`$(ghq root)/github.com/<owner>/<app>`）。

```sh
# clone — 全アプリを ghq get で取得
./clone.sh              # 足りないものだけ取得（一括）
./clone.sh --update     # 既存も更新（ghq get -u）
./clone.sh --https      # SSH ではなく HTTPS で取得

# pull — 各 clone を git pull --ff-only
./pull.sh               # 全 clone 済みアプリを一括 pull
./pull.sh perch         # 単体 pull
./pull.sh --list        # clone 済みアプリ一覧

# run — 各アプリの run.sh に委譲
./run.sh                # 全アプリをバックグラウンド一括起動（→ /tmp/atelier-<app>.run.log）
./run.sh perch          # 単体をフォアグラウンド起動（引数素通し: ./run.sh facet --dev）
./run.sh --list         # run.sh を持つアプリ一覧

# stop — 各アプリの stop.sh に委譲
./stop.sh               # 全アプリ一括停止
./stop.sh perch         # 単体停止
./stop.sh --list        # stop.sh を持つアプリ一覧
```

アプリの追加・削除は [`apps.txt`](apps.txt) を編集する（ロスターは clone / pull /
run / stop 共通）。スクリプトは [`lib.sh`](lib.sh) の共通ヘルパ（ghq パス解決・
ロスター読み込み）を source する。
