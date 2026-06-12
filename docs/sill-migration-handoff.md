# sill 移行 — 引き継ぎ (atelier テーマ・リファクタ)

> **これは何**: app family（facet / perch / wand / halo / glance）の
> ハンドコピーされた theme を、共有基盤ライブラリ
> [**sill**](https://github.com/akira-toriyama/sill) に載せ替える初期化計画
> 「atelier」の **生きた引き継ぎドキュメント**。
> **北極星** = 「facet の theme を真似て」を二度と言わない（drift-free な
> family 一貫性）。
>
> 最終更新: **2026-06-12**。

---

## 0. 作業モデル（2026-06-12 〜）

- **atelier の調整・計画作業はこの repo（`akira-toriyama/atelier`）で行う。**
  各アプリの実体は ghq ツリー（`$(ghq root)/github.com/akira-toriyama/<app>`）の
  独立 repo で編集する（atelier はソースを持たない＝README 参照）。
- **`facet` の作業ディレクトリは facet 開発に専念**へ戻す。テーマ横断の
  リファクタ（本計画）はこの atelier repo を起点にする。
- **権威ある生の状態**は Claude のセッションメモリ `plan-atelier`（`📍 NOW 更新14`
  が cold-start 正本）。本 md はそれを repo に固定するミラー。差分が出たら
  メモリ側が正、随時このファイルへ反映する。
- monorepo / submodule は**却下済**（各 app 独立 repo・sill は url+SemVer 依存）。

---

## 1. 進捗ダッシュボード

| Phase | ブロック | 状態 | 出荷 |
|-------|---------|------|------|
| **1. sill 本体 + 検証台** | sill 内部リデザイン（Tailwind ロール名 + 12テーマ catalog） | ✅ | — |
| | still preview app（視覚検証台） | ✅ | — |
| **2. app 移行（＝「第一弾」本体）** | block-4 **facet**（先頭） | ✅ SHIPPED | PR #193 / sill `0.3.0`（後に line-pets で `0.5.0` へ bump #195） |
| | block-5 **perch**（system→.fixed+accent0） | ✅ SHIPPED | sill `0.3.0` pin |
| | block-6 **wand**（最大・cast/tome） | ✅ SHIPPED | PR #141 / sill `0.4.0` |
| | block-7 **halo** + line-pets 汎用化 | ✅ SHIPPED | PR #9 / sill `0.5.0` |
| | facet tree line-pets 配線（follow-up） | ✅ SHIPPED | PR #195 |
| | block-8 **glance**（family 最後の app） | 🔧 **実装+レビュー済・push 待ち** | 下記 §2 |
| **3. 仕上げ** | block-9 knob/validation rollout + FacetCore dedup | ⬜ 未着手 | §3 |
| | block-10 cleanup（docs・最終 family review） | ⬜ 未着手 | §3 |
| | follow-up: wand cast/tome line-pets dedup | ⬜ 未着手 | §3 |

**要約**: app 移行波は **6/6 が実装到達**（glance は push 待ち）。glance が
出れば北極星に到達、残りは横断 rollout（block-9）と掃除（block-10）のみ。

---

## 2. block-8 glance — いま終わらせるべき作業

**状態**: 実装 COMPLETE・`swift build` green・敵対レビュー済（blocker 1 修正済）。
**glance repo の branch `refactor/sill-migration`（local commit `23c1d53`）・未 push**。
（この atelier handoff も branch `docs/sill-migration-handoff` に local commit 済・未 push。）

### 2.1 確定設計（grill 結果・5問 AskUserQuestion）

| # | 論点 | 決定 |
|---|------|------|
| Q1 | 移行スコープ | **B**: chrome を sill から導出・ユーザ向け切替/config はゼロ増 |
| Q2 | 消費パターン | **B1**: PaletteKit を GlanceAdapterMacOS に（GlanceCore は Foundation-only 不変） |
| Q3 | chrome preset | **catppuccin-mocha**（#1E1E2E ≈ 旧 hardcode #1E1E1E） |
| Q4 | オーサリング範囲 | **full authorship**（本文→foreground / link→primary / 罫→border / dim テキスト→tertiary / white-alpha 群→`ink(tier,of:.foreground)`） |
| Q5 | Effects | **入れない**（Palette+PaletteKit のみ・line-pets/ring なし） |

- **glance は perch の反例**: panel + 中立 white-alpha overlay が PaletteKit の
  `resolve()`/`ink()` モデルに最適合（perch/wand が PaletteKit を避けたのは
  pill/card surface 固有解決のため・glance には当てはまらない）。
- **code-theme は別軸・不可侵**: Highlightr の `--theme`（271 code-syntax theme・
  既定 `atom-one-dark`）は触らない。chrome（panel）とは直交（Highlightr の
  背景属性は剥がして syntax token 色だけを dark chrome に乗せる既存挙動を維持）。

### 2.2 変更ファイル

- `Package.swift` — sill を **path-dep `../sill`**（url `.upToNextMinor("0.5.0")` 行は
  comment で待機）。GlanceAdapterMacOS target に `Palette` + `PaletteKit` product。
- `Sources/GlanceAdapterMacOS/ViewerPanel.swift` — `import Palette`+`import PaletteKit`。
  `chromeTheme="catppuccin-mocha"` + `chromePalette()=resolve(paletteFor(...), forceDark:true)`。
  panel bg / root layer / textColor / Style 全色を resolve から導出。
- `Sources/GlanceAdapterMacOS/MarkdownRenderer.swift` — **sill 非依存のまま**
  （全色を `Style` 経由で NSColor 受領＝既存 injection seam・**PaletteKit は
  ViewerPanel だけが import**）。Style に role 色 + derived overlay を追加。
- `Tests/GlanceAdapterMacOSTests/MarkdownRendererTests.swift` — 新スキーマ + link→primary /
  blockquote→tertiary アサート（CI-only compile）。
- `README.md` + `README.ja.md` — chrome 記述を sill 帰属へ（bilingual sync）。
- **無変更**: `GlanceLayoutManager.swift` / `GlanceCore/*` / `GlanceApp/Main.swift` /
  `Args.swift`（config-less 維持・新 CLI flag なし）。

### 2.3 敵対レビュー結果（`wf_2fa999bf-3e2`・6軸）

- layer/build・test・behavior・scope・docs = **5 CLEAN**。
- 🔴 **blocker 1（修正済）**: blockquote / HTML 本文を `muted`（mocha #6C7086）で
  描くと bg #1E1E2E 上 **WCAG 3.36:1 = AA 未達**（旧 secondaryLabelColor ~5.76:1 から
  回帰）→ **`tertiary`（foreground@0.55 = ~6.69:1）へ寄せ + `muted` フィールド削除**
  （glance は他に muted 用途なし＝zero-debt）。rebuild green。
- concern 2: lang label 6.69:1（AA 超・host verify 対象）/ bar-text 非対称（本修正で
  対称化し解消）。
- 🟢 **台帳**: glance は中立ビューア固定ダーク 1 枚（catalog switch を持たない）/
  `muted` ロール不使用（comment-dim 面が無い＝正当）/ dim テキストは全て tertiary に
  集約（blockquote / HTML / lang label / 水平線）。

### 2.4 残作業（block-8 を閉じる手順）

1. **トミー host verify**（実機目視）:
   - mocha chrome の視認性（panel bg / 本文 ソフト青白 #CDD6F4）
   - リンクが mauve（#CBA6F7）化していること
   - blockquote 本文が tertiary で**読めること**（blocker 修正の確認）
   - 全 markdown 要素（見出し / inline code / code block / table / list / 水平線）
   - **code-theme 直交**: `--theme github-light` 等の light code theme でも
     dark chrome のままで破綻しないこと
2. **push ritual**（go 後）— **sill 改変ゼロ＝新 release 不要**（既存 `0.5.0` API のみ
   消費＝halo block-7 と同型の最軽量ブロック）:
   - `Package.swift` を url `.upToNextMinor("0.5.0")` に swap（path-dep 行を comment アウト）
   - `swift build` で `Package.resolved` を生成 → **tracked 化**（`.gitignore` 確認）
   - `.github/dependabot.yml` に **swift updates block** 追加（halo の dependabot.yml を踏襲）
   - 移行 issue を作成（roadmap Project #5 / Inbox）→ **単一 glance PR**（`Closes #N`・
     `--assignee @me`）→ **auto-merge**（`gh pr merge N --squash --auto --delete-branch`）
   - ⚠️ **path-dep を `main` に残さない**（CI/brew が壊れる）

---

## 3. 仕上げ（Phase 3・glance の後）

- **block-9: knob/validation rollout + FacetCore dedup**
  - sill の `canonical(_:)`/`suggest(_:)`（validation 機構）と `EffectIntensity` を
    consumer 全体に行き渡らせ、FacetCore に残る名前リスト重複を解消。
  - cycle-* config キー命名の統一（facet `cycle-seconds` vs wand `color-cycle-ms`）。
- **block-10: cleanup / 最終 family review**
  - CLAUDE.md の `pal` 注記・各 repo docs の最終同期。
  - **🩹 sill version 揃え**: facet `0.5.0` / halo `0.5.0` / glance `0.5.0`（予定）に対し
    **perch `0.3.0` / wand `0.4.0` が遅れ**。bump 時に bestForeground WCAG fix（0.4.0）の
    波及で onPrimary text が white→black へ改善シフト → host verify 要
    （perch=pill text・facet は適用済）。
- **follow-up: wand cast/tome line-pets dedup**
  - wand の cast/tome 2 コピーを sill `drawLinePets` へ寄せて dedup（rule-of-three close）。
    wand の次 bump とセットで。

---

## 4. 押さえておく不変条件 / ritual

- **マンデート（durable・トミー明示）**: sill の theme を基準に・相性悪いのは破棄で OK・
  個性よりアプリ全般の一貫性・一通りリファクタ終わったら見直し・破壊的変更/破棄 OK・
  負債0。⚠️ ただし **zero-debt ≠ 全部共有**（強制共有＝bad abstraction＝別種の負債）。
- **sill モジュール構成**:
  - `Palette`（pure / Sendable / Foundation-only）= `ThemeSpec`・12 preset + `system`・
    `paletteFor`/`canonical`/`suggest`・`EffectIntensity`・`HexColor`。
  - `PaletteKit`（AppKit / `@MainActor`）= `resolve(_:)`・`ResolvedPalette`・`pal` var・
    `NSColor(hex:)`・`ink(tier,of:root)`・`onPrimary`・derive recipe。
  - `Effects`（pure + AppKit-gated）= `EffectSpec`（neon/cyber/vapor/kawaii/rainbow/chomp）・
    `LinePet`（chomp/ghost）+ `drawLinePets`・`blendThrough`。
- **各 app の sill 消費パターン**（precedent）:
  - facet = full PaletteKit（`pal` global） / perch = pure-Palette-twin / halo = Effects-only /
    wand = Palette+Effects（string-token bridge） / **glance = PaletteKit（panel 面に最適合）**。
- **push ritual（全 app 共通）**: local は path-dep `../sill` で atomic 編集 → build green →
  敵対レビュー（5-6 軸）→ host verify → **sill に新 API があれば tag/release** → app を
  url+SemVer に swap → `Package.resolved` 再 pin → 単一 app PR（`Closes`）→ auto-merge。
- **auto-merge ON**: facet/wand/perch/sill/halo/glance/chord の 7 repo（CI 緑で自動 squash-merge）。
- **CLT 制約**: 開発機では `swift build` のみ。`swift test`（XCTest）は CI でしか走らない＝
  テストのコンパイルエラーは local で出ず CI のみ（防御的に書く）。

---

## 5. ポインタ

- **権威**: Claude メモリ `plan-atelier`（`📍 NOW 更新14` が cold-start 正本）。
- カタログ詳細: メモリ `atelier-phase-v-catalog-proposal`（12 色テーマ + system・全 hex）。
- 各 app の repo は §README の Apps 表 / ghq ツリー。
