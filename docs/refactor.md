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
| **1.5. 仕上げ**（pin 衛生 / knob・pets dedup / meta 共通化） | ✅ **完了**（Track 0-4 出荷・family review PASS・facet PR-B 出荷・**build=composite action 出荷**） |
| **1.6. TOML 共通化**（4本→sill 1モジュール、golden test 駆動） | 🚧 **sill 土台 出荷（0.7.0）**・consumer swap 残 |
| **2. border 共通化**（halo/facet/perch の BorderFX 統一） | 💤 parking（将来） |

sill 現況: **タグ 0.7.0**（2026-06-13 出荷）。Palette（pure）/ PaletteKit（AppKit）/
Effects（pure＋AppKit animator）/ **Toml（pure・新規 0.7.0）**/ still。EffectIntensity は 0.4.0、
LinePet は 0.5.0、**effect/pet 名リスト＋LinePet が Palette へ移動・NSColor(HexColor) bridge・
drawLinePets chaseGap は 0.6.0** で着地（Effects は `@_exported import Palette` で互換維持）。
**Toml（0.7.0）= 共有 TOML subset パーサ**（Foundation のみ・Sendable・Palette と同列の pure atom。
[[toml-shared-parser-design]]）。

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
- [x] **facet PR-B（per-view palette 配線）= 完了**（2026-06-13・[facet#217](https://github.com/akira-toriyama/facet/pull/217)・
      ultracode・スクショ self-verify PASS）。**設計＝`PaletteBox`（参照セル）+ shadow**: 各 pal-読み
      クラスに `var paletteBox` ＋ computed `var pal { paletteBox.pal }` を足し、旧グローバル `pal` を
      instance member で**シャドウ**。→ ~90 の `pal.foreground` 読みは**無改変**のまま surface box 経由に
      （メソッド本体の読みは churn ゼロ・closure だけ self. 要・コンパイラが検出）。Controller が tree/grid/rail
      の 3 box を所有（`resolveSurfacePalettes`）、tree chrome（PanelHost/SearchBar/HandleBar/BorderFX/
      ThemedScroller/Dnd・Preview overlay）は tree box、grid/rail view は build 時に各 box。**共有 free 関数**
      （`drawMiniMarkBadge`/`drawMiniTagDots`・#210 の `DragGhost.makeWindow/WorkspaceGhost`）と
      `PopupMenu`/`ViewContextMenu` は明示 `pal:`/`palette:` 引数（popup・drag ghost も呼び元 surface に追従）。
      **per-surface 30Hz animator**（各 surface 独立 phase）。**Main のグローバル `pal` seed は撤去**（facet 側に
      読み手ゼロ＝負債0）。**敵対レビュー（9 agent）で 3 major 修正**: ① `--theme=random`/継承 `[theme].name=random`
      は**1回共有ロール**（明示 per-view `theme="random"` のみ独立）② cycle phase の不要リセット（source 変化時のみ
      再解決＝無関係 save でアニメ継続）③ `--theme=` override が reload を跨いで保持（theme key 編集時のみ config が奪取）。
      **実機検証**: tree=dracula(紫)/grid=gruvbox(橙)/rail=""→terminal(緑) が同時独立描画＋継承確認、`--theme=rainbow` で
      全 surface 強制、無クラッシュ。⚠ **#210（drag-ghost 共有化）は本作業中に main へ先行マージ**→ 地雷現実化
      （DragGhost free 関数がグローバル `pal` を読む）。PR-B を main に rebase し DragGhost に `pal:` 引数を通して**本 PR 内で解消**。
      facet 活発開発で **#216（Controller を extension 分割）も途中マージ**→ 2 度目の rebase（applyStyle→+CLIDispatch /
      buildGrid→+Grid / buildRail→+Rail へ再配置、helper を internal 化）。auto-merge 有効。
- [x] **facet release publish ＋ facet live config 移行 = 完了**（2026-06-13・トミー publish 承認）:
      draft `v5.0.0` を `--latest` で publish（PR-A 挙動不変 rename ＋ #200-204 tree 機能を同梱出荷）。
      update-tap green（brew formula bump 済）。live config 移行（backup-`config.toml.bak-20260613-003258`）:
      `theme`→`[theme].name` / `[border].cycle-seconds`(3s)→`color-cycle-ms`(3000ms) / grid・rail・tree に
      明示 `theme = ""`（継承 sentinel）追加。tomllib でパース＋キー着地検証・diff で挙動不変を確認。
      ⚠ トミー実機 facet は **dev build（brew 管理外）**＝brew upgrade 不要、dev facet 再ビルド/reload で新 schema 反映。
      per-view `[tree].theme` への**実値付与は PR-B 後**（`""`=継承で現状の描画は不変）。
- **死守（dedup しない意図的ローカル）**: perch `[overlay].accent` / frosted-pill 透過処理 /
  独自 `system` spec / pill・effect 語彙。facet の layout・animation-curve 語彙（window-manager
  ドメイン）。wand arcade/burst/decal。halo の ring/border 描画（30Hz timer・breathing・flash）。

### Track 3 — meta 共通化（並走・glance 非依存・高ROI）
土台（org `akira-toriyama/.github` の reusable workflow）は既存。taplo/glossary は利用済み。
- [x] **commit-lint reusable 化** ✅（5 repo: facet/halo/glance/chord/perch・前セッション完了）:
      各 repo の `commit-lint.yml` を thin caller（`uses: …/.github/.github/workflows/commit-lint.yml@main`）に。
      **gotcha**: 委任で lint チェック名が `lint`→`lint / lint` に変わり、保護 repo の必須 `lint` 不一致で
      green でも BLOCKED → **Option A**: facet/chord/perch の必須から `lint` を外し `build` のみ残す。
      halo/glance/sill は無保護据え置き。wand は本件未委任（将来委任時に同 Option A）。
- [x] **update-tap reusable 化** ✅（2026-06-13・[.github#2](https://github.com/akira-toriyama/.github/pull/2)
      ＋ caller 4本: facet#209 / halo#15 / perch#119 / wand#147 全 merged）:
      facet/halo/perch/wand の byte-near-identical な `update-tap.yml`（差分は formula 名・`timeout-minutes:5`・
      `git pull --rebase` の3点のみ）を 1 本の reusable に集約。**唯一の input = `formula`**（＋optional `tag`）、
      pull-rebase と timeout:5 は**全員にベイク**（最良の共通形＝facet/halo も堅牢化）。secret は caller 渡し。
      **検証**: facet を canary に `workflow_dispatch`（空 tag→latest 解決）で reusable を実 release 無しで
      end-to-end 確認、4本とも success・各 formula の idempotent no-op（facet v5.0.0 / halo v2.0.0 /
      perch v2.0.0 / wand v8.0.0）を確認。⚠ check 名は `bump / bump` になるが **update-tap は release 発火＝
      PR ゲートでない**ため branch-protection の check-name gotcha は**無関係**（commit-lint/build と違う）。
      **glance/chord/jig は非対象**（意図的に別パターン: `[released]`・latest-fetch・厳格 validation・
      専用 release-bot・emoji commit。共通化＝過剰パラメータ化なので死守）。
- [x] **build 共通化 = 完了（composite action path・2026-06-13・ultracode）**: 当初の精密 plan は
      **reusable workflow** 前提でリスク大と判定 — ① check 名が `build`→`build / build` に変わり protected 4本
      （facet/chord/perch/wand が必須 `build`）で**旧 check が消え PR 永久 BLOCKED**＝branch-protection 入替手術が必要、
      ② 最終ステップ（package.sh / smoke）を shell 文字列で渡す ~6-9 input＝bad-abstraction。→ **composite action に切替で
      両方回避**: `setup-xcode + SPM cache + build + (optional) test` を
      [.github/actions/swift-build](https://github.com/akira-toriyama/.github/blob/main/actions/swift-build/action.yml)
      に集約し、各 caller の `build.yml` 内で**ステップ**として `uses:`。→ ジョブ名 `build` が不変＝**必須 check 名そのまま・
      手術ゼロ**、失敗モードも「PR が赤いまま」で安全（main を mergeable 不能にしない）。caller は checkout（前）＋ app 固有の
      最終ステップ（package.sh / CLI smoke / JSON sanity、後）を保持、差分は input 2つ（`build-cmd` 既定
      `swift build -c release`／jig→`./build.sh`、`run-tests` 既定 true／halo→false）に圧縮。SPM cache（旧 perch/wand のみ・
      key も drift）と concurrency+timeout を全 adopter にベイク＝**最良共通形**（update-tap と同型）。**出荷**
      （[.github#3](https://github.com/akira-toriyama/.github/pull/3)＋caller 5本 全 merged・build green:
      halo#16 / jig#9 / facet#219 / perch#121 / wand#149）。canary=halo+jig（無保護）で composite 展開・check 名 `build` 不変・
      build-cmd 上書き・run-tests=false skip を**ジョブログで実証**してから protected 3本（facet/perch/wand）を auto-merge 展開。
      **非対象**: glance/chord（divergent: no setup-xcode・custom build script・chord version-sync）、sill（CI 未設置）。
      `release` reusable は最大・非一様で**最後・部分的**（未着手）。
- [x] **CLAUDE.md roadmap board 集約** ✅（2026-06-13）: 4 app（facet/halo/perch/wand）の **byte-identical**
      （SHA-256 `f09d31e5…` 4本一致で検証）な「Roadmap board」9行ブロックを
      [atelier/docs/roadmap-board.md](roadmap-board.md) に集約（[atelier#30](https://github.com/akira-toriyama/atelier/pull/30)）、
      各 app は pointer 化（facet#207 / halo#14 / perch#118 / wand#146 / **glance#16 は新規 pointer 追加**・全 merged）。
- [x] **jig（新規 CLI app）meta 確認 = 完了** ✅（2026-06-13）: commit-lint / taplo は既に thin caller ✓。
      **auto-merge が OFF だった唯一の gap → 有効化**（`allow_auto_merge=true`・del_branch は family norm の false に揃え）。
      **config.toml なし**（cliff.toml のみ）＝**キー命名規約・1.6 TOML 共通化は対象外**。build/update-tap は
      reusable 化されても jig は divergent cohort（`./build.sh` / `[released]` updater）なので非 caller のまま。
      branch protection 無し（halo/glance/sill と同じ無保護 norm）。[[jig-new-cli-app]]。
- [ ] ~~**root scripts** 共通化~~ → **見送り**（マンデート「zero-debt ≠ 全部共有」）。70-90% 同一だが
      load-bearing な差（app 名 / bundle id / 署名 flag）が per-app で、thin wrapper の強制共有は
      bad-abstraction 化＋払い小。drift が痛くなったら再考。

### Track 4 — block-10: 仕上げ（glance 出荷後）
**2026-06-13 family drift 監査（6 並列 read-only・ultracode）で大半が解消・PASS 確認。**
- [x] **FacetCore 最終 dedup = 完了**（監査確認）: facet は完全に sill-sourced（`handCopyResidue=0`）。
      FacetConfig の手維持 name-list は facet#198 / commit 6d80720 で `canonicalThemeNames/EffectNames/
      LinePetNames` に解消済。残渣ゼロ。
- [x] **`pal` global 二重 source-of-truth = 該当なし**（監査確認）: 全 app で `palGlobalDuplication=0`。
      facet の `pal` は PaletteKit の単一正規 global（重複ではない）。per-view 化（PR-B）は二重ソース
      解消ではなく**機能追加**＝別物。よって本項目は解消（PR-B 側に内包）。
- [x] **glance を sill 0.6.0 に揃え**（dependabot #14 merged・2026-06-13）→ 全 app 0.6.0 で parity。
- [~] **stale コメント一掃**: genuine stale（誤り）は修正済 — **wand `docs/architecture.md`** の
      project 名 stroke→wand（env `WAND_TARGET_*`/config `~/.config/wand`/bundle `com.wand.app.control`・
      [wand#148](https://github.com/akira-toriyama/wand/pull/148)。gesture 概念 stroke は保持）、
      **perch** `[hotkey].combo`→`.active` doc-comment（[perch#120](https://github.com/akira-toriyama/perch/pull/120)）。
      残りの Phase V/0.3.0 migration narrative（facet/halo/perch）は**正確な履歴**ゆえ意図的に保持
      （churn しない）。halo/glance の CLAUDE.md sill-seam 拡充は任意の doc 強化（未実施）。
- [x] **最終 family review = PASS**（監査・2026-06-13）: 5 app + sill すべて `handCopyResidue=0 /
      palGlobalDuplication=0 / pathDepInMain=false`、完全 sill-sourced、全 app 0.6.0。hand-copy
      theme/effect/pet ゼロ・drift 面消滅を**確認**。北極星「facet の theme を真似て」は構造的に再発不能。

## 🔖 次セッションへの handoff（2026-06-13 更新⑤ — Phase 1.6 sill 土台 出荷）

**Phase 1.5 = 完了**。**Phase 1.6 = sill 土台 出荷済**（sill **0.7.0**・[sill#5](https://github.com/akira-toriyama/sill/pull/5)・
release 公開）。残るは **consumer swap 4本**（perch → wand → chord → facet）＋ 任意の meta `release` reusable のみ。

### Phase 1.6 — sill `Toml` モジュール = 完了（2026-06-13・ultracode）
4本の TOML parser を **sill の新 pure モジュール `Toml`**（Foundation のみ・Sendable・Palette と同列）に集約。
chord の 434行 parser が機能 superset 参照だが、**形が非互換**（chord=nested/strict/Int64、他3本=flat dotted-section/
lenient/Int）。当初案の「nested パーサ＋lossy flatten」を**捨て**、**1 コア・2 スキン**で各消費側に正確な形を直接供給:
- `Toml.parse(_) throws -> [String: Value]` = **nested・strict**（chord 用。dotted 折りたたみ・nested `[[a.b]]` AoT drill・
  `__line__` 注入・unrecognised scalar で throw）。
- `Toml.parseFlat(_) -> Document` = **flat・lenient**（facet/perch/wand 用。`Document{tables, arrays}` は **literal header
  text** keyed = 現3本の挙動そのまま → perch の quoted-header `[behavior."com.apple.Safari"]` も**書き換え不要**で一致・
  bad 行 skip・`__line__` 注入なし）。
- **superset デルタ**: hex int `0x…` / 不明エスケープ `\x`→`x` / CRLF / Equatable / **複数行配列**（perch の潜在バグ root fix・
  下記）。Value は chord の superset case set（`.stringArray` は廃し `.array`＋`asStringArray` へ）。**parse 専用**（4本とも emit 無し）。
- **golden test**: `Tests/TomlTests` が4本の**実 config.toml** fixture ＋ micro-fixture（nested 折りたたみ・AoT drill＋`__line__`・
  inline table・strict-throw vs lenient-skip・hex・escape/verbatim・複数行配列）をロック。**ローカル検証は Track-1 流の `swift run`
  ハーネスで全 PASS**（CLT に XCTest 無し・sill CI 無し。XCTest は Tart/将来 CI 用の durable 版。検証後ハーネスは撤去）。

### consumer swap 引き継ぎ（次セッター向け・各 app 1 PR）
依存順 **perch → wand → chord → facet**。各 app は §運用 ritual の push ritual（local path-dep `../sill` で atomic 編集 →
build green → 既に tag 済 sill **0.7.0** へ url+SemVer swap → `Package.resolved` 再 pin → 単一 app PR → auto-merge）。
- **perch（最初）**: 自己完結 daemon・非活発。`TOML.parse → Toml.parseFlat`、`Document=[section:[key:value]]` は `doc.tables`、
  `typealias TOMLValue = Toml.Value`。**複数行 roles バグはこの swap で直る**（[[perch-multiline-array-bug]]）。
- **wand（2番目・最易）**: flat が lossless。`parseTOMLSubset(text) → Toml.parseFlat(text)`、`doc.tables`/`doc.arrays` そのまま、
  `.stringArray` 読みは `.asStringArray` へ、private RowAccessor は新アクセサに重ねる。double 追加は無害（既存 int 読みは fallback）。
- **chord（3番目・最大面）**: `typealias TOML = Toml`（`TOML.Value`/`TOML.parse`/`TOML.ParseError`/`TOML.lineKey` 解決）。
  nested `parse` 据置・**`lineKey` は public 化済**（chord は別モジュールから `row[Toml.lineKey]` を読む）。`asInt` は Int 返しに
  なったので raw Int64 必要箇所は `asInt64`。row 構築（Config+Sequence/Remap/Expansion）の `.string`/`.int`/`.array`/`.table` は綴り同一で無改変。
- **facet（最後・活発開発）**: [[facet-active-dev]]・PR-B が #210/#216 で 2 度 rebase した churn 踏まえ**静かな時に**。
  `parseTOMLSubset → Toml.parseFlat(text).tables`、`parseTOMLArrayOfTables(text, name) → Toml.parseFlat(text).arrays[name]`（1 回 parse へ）、
  `.stringArray` マッチは `asStringArray`/`.array` へ。max-width/height の `if case .int` は**そのまま温存**（1.5 を弾く意図）。
- ⚠ **jig 非対象**: CLI・`cliff.toml`（git-cliff）のみ・config.toml 無し・本体は JSON（[[jig-new-cli-app]]）。別セッションで
  string-interpolation WIP 進行中につき jig に触るなら WIP を壊さない。
- **設計詳細**: [[toml-shared-parser-design]]。

### 1. ✅ facet release publish ＋ facet live config 移行 = 完了（2026-06-13）
- v5.0.0 を `--latest` で publish（トミー承認・PR-A ＋ tree 機能 #200-204 同梱）。update-tap green。
- live config 移行済（backup-`config.toml.bak-20260613-003258`・tomllib 検証＋diff で挙動不変確認）。
- ⚠ トミー実機は facet **dev build**（brew 管理外）— brew upgrade 不要、dev facet 再ビルドで反映。

### 2. ✅ facet PR-B（per-view palette 配線）= 完了（2026-06-13・[facet#217](https://github.com/akira-toriyama/facet/pull/217)）
- 設計＝`PaletteBox`（参照セル）+ computed `var pal` shadow で ~90 読みを無改変のまま surface box 経由化。
  詳細・敵対レビュー 3 修正・実機スクショ結果は Track 2 の「facet PR-B = 完了」項目に集約。
- ⚠ 活発開発で **#210（先行マージ）と #216（Controller 分割）に 2 度 rebase**。#210 の DragGhost free 関数は
  本 PR で `pal:` 引数化して地雷解消。auto-merge 有効（CI build 通過待ち）。
- トミー実機 facet はこのセッション末に rebased build へ再起動済（＝merged main と同等・通常 config）。

### 3. ✅ jig（新 CLI app）meta 適用確認 = 完了（2026-06-13）
- auto-merge を有効化（唯一の gap）。commit-lint/taplo は既に thin caller。config.toml 無し＝
  キー命名/TOML 1.6 対象外。詳細は Track 3 の jig 項目。

### 4. ✅ Track 3 build 共通化 = 完了（composite action・2026-06-13）／Track 4 = 完了
- **build = 完了**: reusable workflow を捨て **composite action**（`.github/actions/swift-build@main`）で
  branch-protection 手術ゼロ＋bad-abstraction 回避。caller 5本（halo/jig/facet/perch/wand）全 merged・build green。
  詳細は Track 3 の build 項目。**Track 3 で残るは任意の `release` reusable のみ**（最後・部分的・未着手）。
- **Track 4 = 完了**: family drift 監査で FacetCore dedup・pal global・最終 review すべて PASS。
  glance 0.6.0 揃え＋genuine stale コメント（wand#148/perch#120）修正済。
- その先は **Phase 1.6（TOML 共通化）**。

> このセッション④で完了（2026-06-13・ultracode）: **Phase 1.6 sill 土台**＝共有 TOML パーサ
> モジュール `Toml` を sill に新設し **0.7.0 出荷**（[sill#5](https://github.com/akira-toriyama/sill/pull/5)・release 公開）。
> 4本のパーサを 4 並列マップ→統合設計（workflow）で精査し、chord superset 参照だが**形が非互換**と判明。
> 当初の「nested＋lossy flatten」案を**捨て**、**1 コア・2 スキン**（nested `parse` strict / flat `parseFlat` lenient・
> literal-header keyed）で各消費側に正確な形を直接供給する設計に改良（perch の quoted-header も書き換え不要に）。
> **複数行配列を superset に追加**（トミー決定）＝perch の潜在バグ（複数行 `roles` が黙ってスキップ）の root fix。
> 命名は `Toml.Value`（bare/sill 流儀・トミー決定）。golden test（4本の実 config fixture＋micro）を `swift run`
> ハーネスで全 PASS 検証。**consumer 無改変＝衝突ゼロ**。次は consumer swap（perch→wand→chord→facet）。

> このセッション③で完了（2026-06-13・ultracode）: **Track 3 build 共通化**（composite action
> `.github/actions/swift-build`・[.github#3](https://github.com/akira-toriyama/.github/pull/3)＋caller 5本
> halo#16/jig#9/facet#219/perch#121/wand#149 全 merged・build green）。**reusable workflow を捨て composite action**
> にした判断で branch-protection 入替手術と bad-abstraction の両方を回避（決定ログ「build 共通化」参照）。canary（halo+jig
> 無保護）→ protected 3本の順で安全展開。⚠ jig は他セッションの string-interpolation WIP があり、build.yml のみの PR に
> 留めて WIP を温存。**→ Phase 1.5 完全完了。次は Phase 1.6（TOML 共通化）**。

> このセッション②で完了（2026-06-13・ultracode）: **item 1**（facet v5.0.0 publish＋live config 移行）/
> **item 3**（jig meta = auto-merge 有効化）/ **Track 3**: update-tap reusable（.github#2＋caller 4本・
> dispatch 検証済）・CLAUDE.md roadmap board 集約（atelier#30＋5 app pointer）/ **Track 4 全完了**
> （family drift 監査 PASS・glance 0.6.0・stale コメント wand#148/perch#120）。残るは **item 2（facet PR-B・
> 専用セッション）** と **build reusable（branch-protection リスクで defer）** のみ。build reusable は
> branch-protection 手術が要るため意図的 defer（精密 plan 記録）。

> このセッションで完了: doc 一本化（handoff 退役）/ Track 0 perch / **Track 1（sill 0.6.0 出荷）**/
> Track 3 commit-lint 5/5 + Option A 保護調整 / **Track 2 dedup 4 PR**（wand line-pets・perch
> EffectIntensity・halo 色変換・facet effect-name+pet+suggest）/ **config キー統一 15/15 決着＋
> wand/halo/perch/facet PR-A 実装** / wand v8.0.0・halo v2.0.0・perch v2.0.0 publish。

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
- **TOML 共有モジュール = 1 コア・2 スキン（2026-06-13・Phase 1.6 sill 土台で確立）**: chord は機能 superset
  だが**形が非互換**（chord=nested tree/strict throw/Int64、facet/perch/wand=flat dotted-section/lenient skip/Int）。
  当初の「nested パーサ＋lossy `flatten` 射影」案を**棄却**（flat 消費側の literal-header／inline-table-値 vs section の
  曖昧さで lossy）。代わりに **`Toml.parse`（nested・strict・chord）と `Toml.parseFlat`（flat・lenient・literal-header
  keyed・他3本）の2系統**を1つの scalar/line コア（parseValue・comment strip・multiline 蓄積・escape・hex）の上に置く。
  → 各消費側が**自分の形を無 lossy で**得る＋perch の quoted-header `[behavior."com.apple.Safari"]` も**書き換え不要**。
  `__line__` は nested `parse`（chord）のみ注入（flat は不要・無害化）。`lineKey` は public（chord が別モジュールから読む）。
- **TOML 命名 = `Toml.Value`（2026-06-13・トミー）**: sill の swift-collections 流 bare 名（Algorithms/OrderedCollections
  に倣う）。`enum Toml { enum Value }`／`Toml.parse`／`Toml.parseFlat`。消費側は `typealias TOMLValue = Toml.Value`、
  chord は `typealias TOML = Toml`。Value は chord の superset case set（`.stringArray` は廃し `.array`＋`asStringArray`）。
- **TOML 複数行配列 = superset に追加（2026-06-13・トミー）**: 4本とも単一行のみだが、perch の出荷 config が
  複数行 `roles=[…]` を持ち**黙ってスキップ→default**していた（潜在バグ [[perch-multiline-array-bug]]）。共有パーサに
  物理行跨ぎの配列蓄積（行内コメント/末尾カンマ許容）を入れ、perch swap で root fix。multi-line **inline table** は
  TOML 1.0 でも非対応ゆえ入れない（配列のみ）。「拡張は実 config 需要で正当化」の原則に合致（perch の実需要）。
- **chord**: meta（CI/docs/scripts）に**含める**。theme 移行は対象外。
- **opt-in 収束**: 純粋な仕組み（canonical/suggest・canonicalLinePetNames・pet 警告）は family 全採用。
  見た目/依存が変わる物（perch `perchPillAlpha`、halo `EffectIntensity`）は**既定ローカル維持**、明示採用のみ。
- **border 共通化**: phase 2 parking。
- **doc 一本化（2026-06-12・旧「両者は補完・削除しない」を上書き）**: 本ファイルが唯一の
  正典 tracker。`sill-migration-handoff.md` は phase 1 出荷完了（6/6）をもって退役・削除
  （経緯は git 履歴と merged PR が保存。生きた ritual / 不変条件は §運用 ritual へ統合）。
  権威状態も本ファイル＝repo が正（セッションメモリを正本とする mirror 運用は廃止）。
- **scope guardrail（マンデート）**: 「zero-debt ≠ 全部共有」。Track 3 は **CI reusable ＋ CLAUDE.md のみ**（実重複）、**scripts 共通化は見送り**。TOML は同一 concern の正当 dedup として 1.6 で慎重に。
- **CI 共通化の手段選択 = reusable workflow vs composite action（2026-06-13・build 共通化で確立）**: PR ゲートになる
  job（必須 check）の共通化は **composite action**（ステップとして `uses:`）が第一選択。reusable workflow にすると
  check 名が `build`→`build / build` に変わり、protected repo の必須 check が**消えて永久 BLOCKED**（branch-protection
  入替手術が要る・main を mergeable 不能にし得る）。composite action はジョブ名＝check 名が caller 側で不変なので**手術ゼロ**、
  失敗モードも「PR が赤いまま」で安全。さらに caller が前後に独自ステップ（checkout / package.sh / smoke）を**足せる**ので、
  最終ステップが app 固有な build には適合（reusable workflow は job 全体を奪うので最終ステップを shell 文字列 input 化＝
  bad-abstraction を強いる）。逆に **PR ゲートでない**もの（commit-lint=PR check だが Option A で外れ済 / update-tap=release
  発火 / taplo）は reusable workflow のままで良い（check 名問題が無関係）。判定軸＝「**PR の必須 check か** ＆ **caller が前後に
  ステップを足す必要があるか**」。両方 yes なら composite action。
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
- **per-view `random` の意味論（2026-06-13・PR-B 敵対レビューで確定）**: **継承 random は app-wide で1回ロール・
  明示 per-view random は独立ロール**。`[theme].name=random`＋per-view `""`（共通ケース）は3面が同じ random テーマで
  揃う（pre-PR-B の単一 `pal` 挙動を保存）。`[grid].theme="random"` のように surface が**明示的に** random を書いた
  時だけその面が独立にロール（tracker の「surface ごと1回解決」意図はこの明示ケースに適用）。`--theme=random`
  override も1回ロールを全面共有（override 契約＝全 surface 同一）。ロールは load 毎1回・無関係 save では再ロール
  しない（source 変化時のみ）。→ random を concrete に解決するので random-rolled rainbow/chomp は**アニメする**
  （pre-PR-B は random=静止だったが、毎 tick 再ピックが無くなりちらつかないので意図的に許可）。
- **per-view palette の配線 = `PaletteBox` + shadow（2026-06-13）**: グローバル `pal` を instance computed `var pal`
  でシャドウし読み site を無改変に保つのが churn/コンフリクト最小。共有 free 関数だけは明示 `pal:` 引数
  （instance shadow が届かないため）。活発 repo では「グローバル撤去 ＋ 後から free 関数抽出（#210）」が**コンフリクト無しの
  サイレント回帰**を生む → free 関数は palette を引数で取るのが family の鉄則。
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
