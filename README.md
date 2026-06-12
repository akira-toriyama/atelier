# atelier

macOS 向け Swift アプリ家系の **ワークスペース枠組み**。各アプリは
それぞれ独立した GitHub リポジトリで、このディレクトリはソースを持たず
（`.gitignore` 済み）、**clone / run のオーケストレーションだけ**を管理する。

## Apps

| app | 役割 | run.sh |
|---|---|---|
| [chord](https://github.com/akira-toriyama/chord) | グローバル キー+マウス ホットキー常駐 | ✓ |
| [facet](https://github.com/akira-toriyama/facet) | ワークスペース / ウィンドウ マネージャ | ✓ |
| [glance](https://github.com/akira-toriyama/glance) | stdin を非アクティブ NSPanel に表示する one-shot CLI | ✓ |
| [halo](https://github.com/akira-toriyama/halo) | アクティブウィンドウのネオンリング | ✓ |
| [perch](https://github.com/akira-toriyama/perch) | キーボード駆動 UI ナビゲータ（hint mode） | ✓ |
| [sill](https://github.com/akira-toriyama/sill) | 共有テーマ基盤（Palette / PaletteKit / Effects） | — (library) |
| [wand](https://github.com/akira-toriyama/wand) | カーソル基準のマウス自動化（cast / tome） | ✓ |

共通家風: Swift 6 / macOS 13+ / ヘキサゴナル3層 / TOML 設定 /
`LSUIElement` 常駐 / README EN+JA / gitmoji + Conventional Commits /
Homebrew 配布。**sill** が family の共有テーマライブラリ。

## Install

新規マシンは **clone から全アプリ取得まで一発**:

```sh
# ワンライナー（atelier を clone → そのまま全アプリ clone）
curl -fsSL https://raw.githubusercontent.com/akira-toriyama/atelier/main/install.sh | sh

# すでに atelier を clone 済みなら（中で ./clone.sh を呼ぶだけ）
./install.sh
```

Git には post-clone フックが無く（フックは clone で転送されない）、`git clone`
だけで何かを自動実行することはできない。`install.sh` は atelier を clone した後
その `clone.sh` を呼ぶ薄いラッパで、これがワンステップ化の正攻法。
HTTPS にするなら `ATELIER_PROTO=https`、取得先を変えるなら `ATELIER_DIR=path`。

## Usage

一括 (bulk) がデフォルト。`clone` / `pull` / `run` / `stop` で family 全体を操作する。

```sh
# clone — 全アプリを GitHub から取得
./clone.sh              # 足りないものだけ clone（一括）
./clone.sh --update     # 既存 clone も git pull --ff-only
./clone.sh --https      # SSH ではなく HTTPS で clone

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

アプリの追加・削除は [`apps.txt`](apps.txt) を編集する（`.gitignore` の
一覧も合わせて更新）。
