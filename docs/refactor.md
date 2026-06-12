# atelier — 全体リファクタ

swift app family（facet / perch / wand / halo / glance ＋ 共有ライブラリ **sill**、
別系統に chord）の重複を **sill（共有コード）** と **atelier（共有メタ）** に寄せ、
drift-free な family 一貫性を作る横断リファクタの**正典 tracker**。

**北極星** = 「facet の theme を真似て」を二度と言わない。

**目標（2026-06-12 追加）**: **config.toml も family で一貫性が欲しい** — キー命名・語彙・
構造が app を跨いで揃っている状態。専用 workstream は立てず、Track 2 の**キー命名統一**＋
phase 1.6 の **TOML parser 共通化**の積み上げで**結果的にそうなる**のが理想形
（揃えるのは共通 concern のみ。app ドメイン固有の語彙＝死守リストは対象外）。
**構造の参照スタイルは wand の config.toml**（決定ログ「TOML 構造の参照スタイル」参照）。

> **このファイル = 唯一の正典 tracker**（バトンはここで受け渡す）。phase 1（theme→sill
> 移行・glance 含む）の経緯は git 履歴と各 merged PR が記録。旧 `sill-migration-handoff.md`
> は phase 1 出荷完了をもって**退役・削除済**（2026-06-12）— 生きた ritual / 不変条件は
> 下の「[運用 ritual / 不変条件](#運用-ritual--不変条件全-track-共通)」に統合。
> 旧 `perch/docs/atelier.md`（wishlist）と Desktop メモもこれに統合・破棄済。

## 置き場の決定（不変方針）

- **共有コード** → `sill`（既存 Palette / PaletteKit / Effects ＋ `still` ベンチ。
  必要なら module を増やす。新 repo は作らない）。
- **共有メタ**（CI / docs / scripts）→ `atelier` repo、または org の
  `akira-toriyama/.github`（reusable workflow）。
- アプリ実体は ghq ツリー（`$(ghq root)/github.com/<owner>/<app>`）。atelier は
  オーケストレーションと family 計画のみ。

## 進捗ダッシュボード

| Phase | 状態 |
|------|------|
| **1. theme→sill 移行**（facet/perch/wand/halo/glance） | ✅ **完了・6/6 出荷（北極星到達）** |
| **1.5. 仕上げ**（pin 衛生 / knob・pets dedup / meta 共通化） | 🔧 ← 本計画（着手中） |
| **1.6. TOML 共通化**（4本→sill 1モジュール、golden test 駆動） | ⬜ 切り出し |
| **2. border 共通化**（halo/facet/perch の BorderFX 統一） | 💤 parking（将来） |

sill 現況: **タグ 0.6.0**（2026-06-12 出荷）。Palette（pure）/ PaletteKit（AppKit）/
Effects（pure＋AppKit animator）/ still。EffectIntensity は 0.4.0、LinePet は 0.5.0、
**effect/pet 名リスト＋LinePet が Palette へ移動・NSColor(HexColor) bridge・drawLinePets
chaseGap は 0.6.0** で着地（Effects は `@_exported import Palette` で互換維持）。

各 app の sill 採用（origin/main）: wand `0.6.0` ✅（#143）/ perch `0.6.0` ✅（#116）/
halo `0.6.0` ✅（#12）/ facet `0.6.0`（#198 CI 待ち）/ **glance `0.5.0`**（sill の
effect/pet 語彙を使わないため bump は急がない — Track 4 の揃え目で実施）。

## Phase 1.5 計画

glance 出荷で phase 1 完了。**Track 4 のゲートは外れた**（family review 着手可）。
依存順: **Track 0 → 1 → 2**、**Track 3（meta）は最初から並走**。

### Track 0 — pin 衛生（最優先・rollout を解錠）
- [x] **perch**: `.upToNextMinor(from: "0.3.0")` → **`"0.5.0"`** ✅
      （[#114](https://github.com/akira-toriyama/perch/pull/114) merged。pre-release
      commit pin も実タグ 0.5.0 へ再解決済）。⚠ bestForeground の WCAG 化で hint pill
      onPrimary に視覚差があり得る → **host verify のみ残**（watch list 参照）。
- [x] **wand**: `0.4.0` → **`0.6.0`** ✅（[#143](https://github.com/akira-toriyama/wand/pull/143)。
      計画の 0.5.0 を跳ばして直接 0.6.0。⚠ **bump 単体ではビルド不能**と判明 — Effects の
      `@_exported import Palette` で `Palette.LinePet` と wand ローカル enum が衝突するため、
      line-pets dedup と不可分（同一 PR で実施）。コメントも現行化済。
- facet / halo は既に 0.5.0・クリーン（作業なし）。

### Track 1 — sill 前提（小 additive → sill 0.6）✅ 完了（0.6.0 出荷・2026-06-12）
consumer の dedup には sill 側の小追加が先に要った。**3項目すべて 0.6.0 で着地**。
- [x] **pure な effect 名リスト**を Palette（AppKit-free）から公開 → `canonicalEffectNames`
      ＋`LinePet`/`canonicalLinePetNames` を Palette へ移動。Effects は `@_exported import
      Palette` で互換維持。→ facet の effect-name dedup（Track 2）を解錠。
- [x] **Effects 到達の NSColor hex bridge** → `NSColor(_ hex: HexColor)` を Effects の
      `#if canImport(AppKit)` 下に（PaletteKit の `NSColor(hex:)` と別シグネチャ）。
      String パーサは既存 `parseColorToken(_:) -> HexColor?` を流用。→ halo の色変換 dedup を解錠。
- [x] sill 内部 drift 修正: `canonicalThemeNames`/`paletteFor` を単一 `themeCatalog`
      テーブルから導出（テーマ追加が 1 編集に）。
- 検証: ホスト実機ハーネス（XCTest 相当 28 チェック）green。sill に CI が無いため
  `swift run` の一時 executable で代替実行（[[tart-vm-available]] は private GHCR 401 で今回不使用）。

### Track 2 — block-9: knob/validation rollout ＋ dedup（Track 0,1 後）
- [x] **wand line-pets dedup** ✅（[#143](https://github.com/akira-toriyama/wand/pull/143)・
      sill 0.6.0 bump と同時）: ローカル3複製（`LinePet` enum / `drawCardLinePets` /
      `TomePetsView` 描画）を削除し `Palette.LinePet`＋`Effects.drawLinePets` へ。純減 290 行。
      速度は明示（cast 110 / tome 160）、chaseGap は sill 0.6 のパラメータで保存（cast=既定
      24*scale / tome=28*scale）。**視覚差ゼロをコードで証明**（sill の silhouette は wand から
      の一般化でバイト一致）→ スクショ verify 不要で着地。arcade/burst/decal は残置。
- [x] **EffectIntensity 採用** ✅（[perch#116](https://github.com/akira-toriyama/perch/pull/116)）:
      ローカル enum → `typealias EffectIntensity = Palette.EffectIntensity`＋CGFloat `scale`
      shim（`multiplier` の上に）。13 型箇所・18 `.scale` 箇所が無変更でコンパイル。
      facet/halo は knob 無しのため計画どおりスキップ。
- [x] **canonical/suggest 検証の統一** ✅（perch#116 /
      [wand#144](https://github.com/akira-toriyama/wand/pull/144) /
      [facet#198](https://github.com/akira-toriyama/facet/pull/198)）:
      3 app とも membership/正規化は sill `canonical(_:)` に委譲、policy（perch loud-reject、
      wand clamp-to-system、facet clamp+警告）と random 解決・wand の +neon/+splatoon は
      ローカル維持。3 app の typo ログに `suggest(_:)` の did-you-mean を追加。
- [x] **pet 名検証の警告統一** ✅（[halo#12](https://github.com/akira-toriyama/halo/pull/12) /
      facet#198。wand は #143 時点で既に標準準拠と確認）: 無言ドロップ →
      `canonicalLinePetNames` で clamp-and-log（wand の文言に統一）。
- [x] **facet effect-name dedup** ✅（facet#198）: `effectiveBorderEffect` の手コピー 8 名
      リストを `canonicalEffectNames` へ（集合一致＝挙動不変）。Track 4 の「FacetCore 最終
      dedup」該当項目もこれで消化。
- [x] **halo 色変換 dedup** ✅（halo#12）: ローカル `NSColor(hex: String)`（6桁限定）と
      `NSColor(hex: UInt32)` を retire → sill `parseColorToken`＋0.6 `NSColor(_ hex: HexColor)`
      bridge。sRGB 構築で bit 一致、文法は family 共通スーパーセットに拡大（named / #rgb /
      #rrggbbaa）。
- [ ] **config キー命名の統一**: facet `cycle-seconds` vs wand `color-cycle-ms` 等、family 横断の
      不揃いを揃える（冒頭の目標「config.toml の一貫性」の第一歩）。
      **15 件の不揃いを調査済**（2026-06-12 survey: 周期 ms/秒・effect key・width・off/none
      sentinel・theme 置き場・line-pets 三点組・font-size clamp・intensity・exclude・sound・
      shortcut-badge・色文法・-seconds/-sec・snake_case 2 keys・anim-enabled 二層規則）。
      **承認状況（2026-06-12 トミー・確定）**:
      **A 群（#1-6）全承認** — 周期は `color-cycle-ms`（ms 整数）/ 壁時計は `-seconds` /
      kebab-case / border block 内 `width` / font-size clamp 8-32 統一＋perch drift 修正 /
      `shortcut-badge`。
      **B 群確定** — #7 は両立案で決着: **「未定義 = 既定」（opt-in 機能は既定 off）＋
      明示するなら `"off"`**（enum kind の標準 disabled 値・グローバル予約語ではない）。
      perch の `"none"` → `"off"` のみ実施。#8 `""`=消音/継承 sentinel・#9 sill 共有色文法・
      #10 anim 二層規則（主スイッチ=`enabled`/同居 motion=`anim-enabled`）承認。
      **C 群** — #11: **第2段まで一気に実施**（トミー決定）: `[theme]` block（`.name`＋
      `.color-cycle-ms`、裸 key 廃止）＋ **per-view 上書き** `[tree]/[grid]/[rail].theme = ""`
      （`""`=継承で `[theme].name` に従う・facet に view 別テーマ機能を追加）。
      #13 承認: facet のカンマ文字列許容を廃止（配列のみ・`[]`=off）、三点組
      （line-pets/pet-scale/pet-lap-seconds）を標準形に、wand の font 連動 scale・pt/s は
      ドメイン差として死守。#15 = #11 の規則化（「theme は描画面を所有する block に」）。
      #12 **承認**（トミー明示・2026-06-12）: wand `[tome.decoration.border]` block 昇格
      （`.effect` / `.width` / `.color-cycle-ms`）。#14 **承認（完全統一案 a）**:
      `[exclude].apps`（bundle-id glob 配列）— halo はアプリ名→bundle-id の**意味変更込み**、
      トミーの live config は backup の上で Claude が移行。
      **15/15 全件決着**。実装は app 単位 PR（wand → halo → perch → facet、facet は
      PR-A Config 層（挙動不変）/ PR-B View 配線（per-view palette・スクショ self-verify）
      の 2 分割）。出荷 config.toml は各 PR で同時更新。
      **実装状況**: wand [#145](https://github.com/akira-toriyama/wand/pull/145) ✅ /
      halo [#13](https://github.com/akira-toriyama/halo/pull/13) ✅ /
      perch [#117](https://github.com/akira-toriyama/perch/pull/117) ✅ /
      facet PR-A [#199](https://github.com/akira-toriyama/facet/pull/199) ✅ **全 merged**。
      live config 移行: **wand/halo/perch 完了**（2026-06-12・backup-20260612-195709）。
      release publish: **wand v8.0.0 / halo v2.0.0 / perch v2.0.0** 発行・update-tap green。
- [ ] **facet PR-B（per-view palette 配線）= deferred（要専用セッション）**。PR-A で
      per-view key（`[tree]/[grid]/[rail].theme`）は parse・継承される（`""`/未定義/不明＝
      `[theme].name` 継承）が、**描画はまだ全 surface が app 既定 `pal` のまま**＝PR-A の
      文書どおりの挙動不変状態。⚠ **配線は単一グローバル `pal`（PaletteKit の `public var pal`）
      への架構変更**: 3 view が各々グローバル `pal` を直読み — `SidebarView` 34 / `GridView` 28 /
      `RailView` 17 箇所 ＋共有 chrome（PanelHost 11 / PopupMenu 10 / FacetView/Theme 8 /
      Palette 6 / BorderFX 3）。**設計**: 各 view に per-instance ResolvedPalette を注入し
      グローバル `pal` 読みを置換、per-view cycle phase/palette を持たせ、BorderFX/pets に
      surface 判別を渡す。30Hz animator（Controller.swift ~885-905）は1個の `pal` を更新し
      3 view を同時 redraw するので per-view 化が要。**CLI override（`facet --theme=`）は全
      surface で勝つ**（session 中は per-view key 無視）。**`random` は config load 毎に
      surface ごと1回解決**（毎フレームでない）。tree 系（SidebarView）は #203/#204 が直近に
      触った活発ファイル。長セッション末尾で急ぐと視覚回帰＋コンフリクト高リスク → 専用
      セッションで実装＋スクショ self-verify。
- [ ] **facet release publish ＋ facet live config 移行 = トミー判断待ち**: facet main は
      PR-A（挙動不変 key rename）に加え **#203/#204 等のトミー進行中 tree 機能**を含むため、
      release publish は in-flight 機能も出荷する。publish 後に live config 移行
      （`theme`→`[theme].name` 等・backup-first）。per-view `[tree].theme` 値の付与は PR-B 後。
- **死守（dedup しない意図的ローカル）**: perch `[overlay].accent` / frosted-pill 透過処理 /
  独自 `system` spec / pill・effect 語彙。facet の layout・animation-curve 語彙（window-manager
  ドメイン）。wand arcade/burst/decal。halo の ring/border 描画（30Hz timer・breathing・flash）。

### Track 3 — meta 共通化（並走・glance 非依存・高ROI）
土台（org `akira-toriyama/.github` の reusable workflow）は既存。taplo/glossary は利用済み。
- [ ] **commit-lint reusable 化**（5 repo: facet/halo/glance/chord/perch）: 各 repo の
      `commit-lint.yml` を thin caller（`uses: akira-toriyama/.github/.github/workflows/commit-lint.yml@main`）
      に。**ブランチ `ci/reusable-commit-lint` で 4本 PR 済**（facet#196/halo#11/glance#13/chord#74、
      checks green）＋ perch は PR 未作成（ブランチ push 済）。
      ⚠️ **gotcha（2026-06-12 判明）**: 委任すると lint チェック名が `lint`→**`lint / lint`** に変わる。
      保護ありの repo（facet/chord/perch/wand が必須 `["build","lint"]`）は必須 `lint` 不一致で
      **green でも BLOCKED**。→ **決定 Option A**: facet/chord/perch の必須から `lint` を外し
      `build` のみ残す（commit-lint は走るが merge ゲートにしない＝過剰制限の解消）。halo/glance/sill は
      **無保護のまま据え置き**（不揃いは別件の掃除、今回スコープ外）。wand は本バッチ対象外
      （commit-lint PR 未着手。将来 wand を委任する時に同じ Option A を適用）。
- [ ] **CI reusable 拡張**（commit-lint の後）: `update-tap`（input=formula 名）→ `build`
      （input=run-tests bool）。`release` は最大・非一様で**最後・部分的**。
- [ ] **CLAUDE.md**: 5 app で **byte-identical な "Roadmap board" 9行ブロック**を
      `atelier/docs/roadmap-board.md` に集約。各 CLAUDE.md は短いポインタ＋URL に。残りは app 固有で維持。
- [ ] **jig（新規 app）を後ほど確認**（2026-06-12 トミー通知）: family に **jig** が追加される。
      **CLI オンリー＝theme/sill は対象外**。確認するのは meta 面の適用可否 —
      commit-lint / taplo / build の reusable caller、auto-merge 設定、（config.toml を
      持つなら）キー命名規約と 1.6 TOML 共通化の対象かどうか。
- [ ] ~~**root scripts** 共通化~~ → **見送り**（マンデート「zero-debt ≠ 全部共有」）。70-90% 同一だが
      load-bearing な差（app 名 / bundle id / 署名 flag）が per-app で、thin wrapper の強制共有は
      bad-abstraction 化＋払い小。drift が痛くなったら再考。

### Track 4 — block-10: 仕上げ（glance 出荷後）
- [ ] FacetCore 最終 dedup（FacetConfig の手維持 name-list を Track 1 の pure リストへ）。
- [ ] 半移行で残った app ローカルの `pal` global 撤去（二重 source-of-truth 解消）。
- [ ] stale コメント一掃（perch/wand の Package.swift 等）、各 app の sill-seam doc 更新。
- [ ] **最終 family review**: 全 app が 0.5.0+・hand-copy theme/effect/pet ゼロ・drift 面消滅を確認。

## 運用 ritual / 不変条件（全 Track 共通）

旧 `sill-migration-handoff.md` §4 から統合（2026-06-12）。phase 1 で確立し、
Track 1〜4 でもそのまま使う durable な運用知識。

- **マンデート（durable・トミー明示）**: sill の theme を基準に・相性悪いのは破棄で OK・
  個性よりアプリ全般の一貫性・一通りリファクタ終わったら見直し・破壊的変更/破棄 OK・
  負債 0。⚠️ ただし **zero-debt ≠ 全部共有**（強制共有＝bad abstraction＝別種の負債）。
- **sill モジュール構成**（**0.6.0 時点**）:
  - `Palette`（pure / Sendable / Foundation-only）= `ThemeSpec`・12 preset + `system`・
    `themeCatalog`/`canonicalThemeNames`/`paletteFor`・`canonical`/`suggest`・`EffectIntensity`・
    `HexColor`/`parseColorToken`・**`canonicalEffectNames`・`LinePet`(chomp/ghost)・
    `canonicalLinePetNames`**（0.6.0 で Effects から移動＝no-AppKit Core が検証可能に）。
  - `PaletteKit`（AppKit / `@MainActor`）= `resolve(_:)`・`ResolvedPalette`・`pal` var・
    `NSColor(hex: UInt32)`・`ink(tier,of:root)`・`onPrimary`・derive recipe。
  - `Effects`（pure + AppKit-gated・`@_exported import Palette`）= `EffectSpec`
    （neon/cyber/vapor/kawaii/rainbow/chomp）・`borderEffectFor`・`drawLinePets(…chaseGap:)`・
    `blendThrough`・**`NSColor(_ hex: HexColor)` bridge**（AppKit-gated・0.6.0）。
- **各 app の sill 消費パターン**（precedent・Track 2 の dedup 判断の前提）:
  facet = full PaletteKit（`pal` global）/ perch = pure-Palette-twin / halo = Effects-only /
  wand = Palette+Effects（string-token bridge）/ glance = PaletteKit（panel 面に最適合）。
- **push ritual（全 app 共通）**: local は path-dep `../sill` で atomic 編集 → build green →
  敵対レビュー（5-6 軸）→ host verify → **sill に新 API があれば tag/release** → app を
  url+SemVer に swap → `Package.resolved` 再 pin → 単一 app PR（`Closes #N`）→ auto-merge。
  ⚠️ **path-dep を `main` に残さない**（CI/brew が壊れる）。
- **auto-merge ON**: facet/wand/perch/sill/halo/glance/chord の 7 repo
  （CI 緑で自動 squash-merge）。
- **CLT 制約**: 開発機は `swift build` のみ。`swift test`（XCTest）は **CI でしか走らない**＝
  テストのコンパイルエラーは local で出ず CI のみ（防御的に書く）。
- monorepo / submodule は**却下済**（各 app 独立 repo・sill は url+SemVer 依存）。
- **ユーザ live config の上書き ritual（2026-06-12・トミー許可）**: schema 変更の検証や
  移行で、トミー実機の `~/.config/<app>/config.toml` を**上書きして良い**。条件は
  **同一ディレクトリにバックアップを取ってから**（例: `config.toml.bak` / `config.toml.<日付>`）。
  これで host verify 時に新 schema の config を直接置いて確認できる。

## 決定ログ（grill 結果）

- **置き場 2極**: sill（code＋still）/ atelier（meta）。新 repo なし。
- **TOML**: phase 1.6 へ切り出し。chord の 434行 parser を superset 参照、golden round-trip test 駆動。
- **chord**: meta（CI/docs/scripts）に**含める**。theme 移行は対象外。
- **opt-in 収束**: 純粋な仕組み（canonical/suggest・canonicalLinePetNames・pet 警告）は family 全採用。
  見た目/依存が変わる物（perch `perchPillAlpha`、halo `EffectIntensity`）は**既定ローカル維持**、明示採用のみ。
- **border 共通化**: phase 2 parking。
- **doc 一本化（2026-06-12・旧「両者は補完・削除しない」を上書き）**: 本ファイルが唯一の
  正典 tracker。`sill-migration-handoff.md` は phase 1 出荷完了（6/6）をもって退役・削除
  （経緯は git 履歴と merged PR が保存。生きた ritual / 不変条件は §運用 ritual へ統合）。
  権威状態も本ファイル＝repo が正（セッションメモリを正本とする mirror 運用は廃止）。
- **scope guardrail（マンデート）**: 「zero-debt ≠ 全部共有」。Track 3 は **CI reusable ＋ CLAUDE.md のみ**（実重複）、**scripts 共通化は見送り**。TOML は同一 concern の正当 dedup として 1.6 で慎重に。
- **config 後方互換 不要（2026-06-12・トミー明示）**: config schema は**後方互換を気にせず破壊して良い**
  （旧キー名 / 旧 pet 名 / 旧エイリアスの維持は不要）。→ Track 2 の pet 名検証・キー命名統一は
  互換 shim を入れず素直に揃える。各 app の**出荷 config.toml は schema 変更に合わせて適宜更新**する
  （リファクタの一部として同梱）。マンデート「破壊的変更/破棄 OK」の config 面への明文化。
- **TOML 構造の参照スタイル = wand（2026-06-12・トミー）**: 直感は「省略よりは、個別に
  しっかり」。言語化すると — ① ネスト section で完全修飾・**1 block = 1 concern**
  （`[cast.overlay.trail]` 型。flat-prefix soup 禁止 — facet root 直下の `theme-cycle-seconds`
  が反例）、② **既定値でも key を省略せずに書く**（commented-out で隠さない）、③ 値の規約を
  統一（無効 = `"off"` / 継承 = `""` / 空 = `[]`）、④ inline table より**分解した個別 key**
  （`action-type`＋`action-keys` 型）、⑤ 冒頭に schema 見取り図。Track 2 のキー命名統一と
  phase 1.6 の共通 parser / 各 app config 整形の設計基準にする。
- **バトン**: GitHub Projects #5（roadmap）＋ atelier issue で管理。

## 視覚差 watch list（self-verify でマージ・2026-06-12）
**運用（トミー決定 A）**: watch list 項目は Claude が**実機で該当 app を起動 → スクショで
before/after を確認 → PR に貼付**。明らかな破綻が無ければ**そのままマージ**（人間の verify
待ちで止めない）。微妙な見た目の好みだけ事後にトミーへ共有し、必要なら追い PR で調整。
実機 config を触る場合は §運用 ritual の「ユーザ live config 上書き ritual」（要バックアップ）に従う。
- perch 0.3→0.5: bestForeground が WCAG 判定に変更（0.4.0）→ 中輝度 primary で onPrimary ink が反転し得る。
- ~~wand line-pets: 速度/chaseGap の微差~~ → **解消**（#143。パラメータ明示保存＋silhouette
  バイト一致で構造的に視覚差ゼロ）。
- （任意採用時）perch suggestedPillAlpha: フラット 0.85/0.30 → sill の連続カーブで pill 透過が変わる。

## バトンの受け方（次セッション）

**現在地（2026-06-12）**: Track 0 perch ✅ / **Track 1 ✅（sill 0.6.0 出荷）** /
Track 3 commit-lint ✅（5/5 merged・Option A で保護調整済）。**次は Track 2 rollout**
（sill 0.6 が解錠済）— 起点は **wand pin `0.4.0`→`0.6.0` bump ＋ line-pets dedup**。
Track 3 残り（update-tap / build reusable・CLAUDE.md 集約）は並走可。

1. ダッシュボードで Phase 1.5 の未チェック Track を確認。
2. **Track 2 へ**: wand pin bump → line-pets dedup（速度/chaseGap は sill 0.6 の
   `chaseGap:` で吸収）→ EffectIntensity（perch）→ canonical/suggest・pet 警告統一 →
   facet effect-name dedup（Track 1 の pure リスト消費）→ halo 色変換 dedup（NSColor bridge 消費）。
3. **sill 検証**: sill に CI が無い。テストは `swift run` の一時 executable（XCTest 相当）で
   ホスト実行 ＝ build green ＋ そのハーネスで確認（[[ tart-vm-available ]] は private GHCR 認証時のみ）。
4. 視覚差 watch list の項目は Claude が self-verify（スクショ before/after を PR に貼付）して
   マージ。人間 verify 待ちでは止めない（§視覚差 watch list）。
5. facet は活発開発中 — 小さめマージ・最新化を意識、refactor 系 facet タスクは少しなら後回し可。
6. Track 4 は最後（最終 family review）。
