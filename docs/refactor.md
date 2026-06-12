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

各 app の sill 採用（origin/main）: facet `0.5.0` / halo `0.5.0` / glance `0.5.0` /
**perch `0.5.0`**（[perch#114](https://github.com/akira-toriyama/perch/pull/114) merged ✅・
視覚差 watch list の host verify は残）/ **wand `0.4.0`**（Track 2 の line-pets dedup と
同時に bump）。← Track 0 の残りは wand のみ。

## Phase 1.5 計画

glance 出荷で phase 1 完了。**Track 4 のゲートは外れた**（family review 着手可）。
依存順: **Track 0 → 1 → 2**、**Track 3（meta）は最初から並走**。

### Track 0 — pin 衛生（最優先・rollout を解錠）
- [x] **perch**: `.upToNextMinor(from: "0.3.0")` → **`"0.5.0"`** ✅
      （[#114](https://github.com/akira-toriyama/perch/pull/114) merged。pre-release
      commit pin も実タグ 0.5.0 へ再解決済）。⚠ bestForeground の WCAG 化で hint pill
      onPrimary に視覚差があり得る → **host verify のみ残**（watch list 参照）。
- [ ] **wand**: `0.4.0` → `0.5.0` bump（line-pets dedup を解錠）。stale コメント更新。
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
- [ ] **wand line-pets dedup**: ローカル3複製を削除し sill へ。
      `WandCore/Models.swift` の `LinePet` enum、`GestureOverlay.swift` の
      `drawCardLinePets`、`LauncherPanel.swift` の `TomePetsView` → `Effects.drawLinePets`。
      ⚠ 速度（cast 110 / tome 160 vs sill 既定 120）と tome `chaseGap`（28 vs sill 固定 24）の
      微差。`speed:` は明示、chaseGap は sill にパラメータ追加か 24 受容を判断。要 visual review。
      arcade/burst/decal manager は wand 固有 → **残す**。
- [ ] **EffectIntensity 採用**: perch（ローカル enum 削除 → sill `Palette.EffectIntensity`。
      `.scale`→`.multiplier` の置換が ~15 箇所。shim `var scale { CGFloat(multiplier) }` 推奨）。
      facet/halo は intensity knob が無い＋halo は Palette 依存が増えるため **既定スキップ**（欲しければ採用）。
- [ ] **canonical/suggest 検証の統一**（仕組みのみ・policy は各 app）:
      facet（theme typo に `suggest()` の "did you mean"）、perch（`perchCanonicalThemeName`
      → sill `canonical`＋`suggest`、random 解決と loud-reject policy はローカル維持）、
      wand（`wandCanonicalThemeName` を sill で wrap、+neon/+splatoon 拡張は維持）。
- [ ] **pet 名検証の警告統一**: facet/halo/wand は今 `LinePet(rawValue:)` で**無言ドロップ**。
      `canonicalLinePetNames` で検証＋clamp-and-log に揃える。
- [ ] **facet effect-name dedup**（Track 1 の pure リスト消費）。
- [ ] **halo 色変換 dedup**（Track 1 の bridge 消費）。
- [ ] **config キー命名の統一**: facet `cycle-seconds` vs wand `color-cycle-ms` 等、family 横断の
      不揃いを揃える（冒頭の目標「config.toml の一貫性」の第一歩）。
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
- wand line-pets: 速度/chaseGap の微差。
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
