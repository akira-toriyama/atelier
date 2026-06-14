# CLI 文法規約（family 共通）＋ 統一計画

> family 全 CLI の **yabai 式 domain-verb 文法**の正典。`facet` 先頭で導入し、関連 app を同系統に
> 揃える「横断リファクタ第4の共通化」（theme / TOML / border に続く）。
> **これが CLI 文法の正典** — 進捗 tracker は [`refactor.md`](refactor.md) Phase 3（ここを指すポインタ）。
> 着手ブリーフは 8 app 実コード調査＋敵対批評（2026-06-14・ultracode）で接地。

## 規約本文

全 family の **daemon-control CLI** は yabai 式の文法に従う:

    <tool> <domain> --<verb> [VALUE ...] [--modifier [VALUE]]

- **ドメイン subcommand**: コマンドを名詞ドメイン（window / workspace / lens / tag …）に束ねる（yabai の `-m <domain>` 相当）。
- **flag-verb + 空白区切り引数**: 動作は `--verb`、値はその後に**空白区切り**で続ける（`--verb=value` は使わない）。
  複数値は空白で並べるだけ（`--only a b c`）。値の中に区切り文字（`,` `:` 等）を予約しない。
- **modifier は合成**: 追加 `--flag` で verb を修飾（`--follow` / `--active`）。
- **read/query 口**: 各ドメインに現状を出す `--show`（machine-readable は `--show --json`）。script + 補完用。
- **補完前提**: 値が常に bare 単語なので bash/zsh/fish 補完が verb→値で効く。補完スクリプトを同梱し、
  動的値（タグ名・WS 名…）は machine-readable list で供給。
- **exit code**: 0 成功 / 2 usage・typo（loud stderr・silent fallback 禁止）/ 3 daemon 未起動。
- **canonical only**: bare-flag alias なし・verb 無し位置引数なし。1 動作 1 形。
- **モデルは yabai**（`yabai -m window --toggle float`）。aerospace の純 positional は不採用
  （modifier の多いドメインに flag の方がスケールするため）。

破壊時は deprecation シムを残さず**完全置換**し、`--help` / README(bilingual) / 移行ガイドを必ず更新する。

### 規約への追補（調査＋批評で確定・2026-06-14）

1. **値トークン仕様（D0）**: 値要求 verb（arity≥1）の**直後トークンは符号付き / `-` 始まりでも値として消費**する。
   曖昧時・明示したい時は `--` で「以降は全て値」を宣言。`--verb=value` 全廃に伴う第一仕様（下記 D0）。
2. **適用範囲**: domain-verb 文法は **daemon-control CLI 専用**。data-processing（stdin→出力の one-shot）と
   orchestrator（family bulk）は domain-verb 対象外で、**横断 sub-規約**（loud error / canonical-only /
   machine-readable / no silent fallback / alias 整理）にのみ整合する。
3. **exit 3 の限定**: `3 = daemon 未起動` は daemon-control app 横断の共通床。OUT app は `3=daemon` を持たず
   `0/2 + app 固有`（例: jig `3=compile error`／`5=runtime` は jq 互換で温存・`3=daemon` 規約から除外）。
4. **`-h`/`-V` carve-out**: canonical-only の「bare-flag alias なし」の唯一の例外として `-h`/`-V` のみ
   family 横断で許容（POSIX/GNU muscle memory）。それ以外の短縮 alias は削除。

## 適用範囲 — 判定表（8 app）

| app | 種別 | 判定 | 一行ギャップ | 規模 |
|---|---|---|---|---|
| **facet** | daemon-control | **IN（先頭）** | 全 verb が `--verb=value`／view・theme・server が domain 無し top-level flag／list 口・補完なし。noun domain・canonical・0/2/3 は適合済 | large |
| **chord** | daemon-control | **PARTIAL** | config 系(`--validate/--doctor/--emit-schema`)と daemon 系(`--reload/--quit/--pause/--resume/--watch`)の2系統が明確＝config/daemon domain は切れる。実ギャップは `-h` alias と補完 | medium |
| **wand** | daemon-control | **PARTIAL** | 既に空白区切り・modifier 合成・0/2/3 適合。domain 層欠落(cast/tome/config/daemon)・`--show` 機械可読/補完なし | medium |
| **perch** | daemon-control | **PARTIAL** | flat ~26 flag・domain 無し・唯一 `--theme=` が `=value`（空文字=override 解除）・読口/補完なし。hotkey-mirror 簡潔性が制約 | medium |
| **halo** | daemon-control | **OUT** | 制御 CLI が存在しない（config.toml+hot-reload が制御面・`--emit-schema` 1個のみ）。CLI 発明は feature。実作業は `--bogus` 黙殺→loud exit 2 のみ | none |
| **glance** | data-processing | **OUT** | stdin→panel 一発・domain 0/verb 1。`--at 800 500` 既適合。in-scope は `-h/-V` alias 除去のみ | small |
| **jig** | data-processing | **OUT** | jq 互換・bare positional filter が存在理由。`exit 3=compile` が規約 `3=daemon` と衝突（TOML 統一でも OUT だった前例と整合） | large |
| **atelier** | orchestrator | **PARTIAL** | 4 script=verb・app が noun（yabai の逆形）・exit 3 無意味。表層整合のみ（`--list→--show`・alias 除去・`--` 境界） | medium |

**全 parser が hand-rolled・構造はバラバラ**（chord=宣言テーブル / facet=2-pass argv loop+canonicalize / wand=3-pass+arity table /
perch=flat `contains`）。swift-argument-parser はどこも未使用＝tokenizer を sill `CLIKit` に1本化する素地。

## 統一語彙 — 「配置規約」だけ揃える

共通 domain = `window` `workspace` `lens` `daemon` `config`（＋ app 固有: facet `scratchpad`・wand `cast`/`tome`・perch `overlay`/`ax`）。

**肝**: verb セットは揃えない。揃えるのは「lifecycle verb は `daemon` domain・config 系 verb は `config` domain に置く／
読口は `--show`／値は空白区切り」という**配置だけ**。

- **daemon domain（配置のみ）**: `<app> daemon --reload/--quit/...`。**verb セットは統一しない**
  — `wand --resign`(bundle 再署名+restart) ≠ `facet --resign`(ad-hoc sign) で**同名異義**、`chord --pause/--resume/--watch` は chord 固有。
- **config domain（配置のみ）**: `<app> config --validate/--doctor/--emit-schema`。`wand --validate` の config+items 2面性は
  実装時に解決（`config --validate --items PATH` 保持か `tome --validate` 分離か）。
- **読口 dedup**: facet `status`・chord/perch/wand `--status`・atelier `--list` を各 domain の `--show` に**配置統一**。
  形式（JSON か行か）は app local（既存 machine-readable を昇格・新 schema 強制なし）。
- **modifier**: `--json`（machine 切替・強制しない）／`--active --follow --edge --dry-run --strict`（既存を空白区切り化のみ）。
- **値の形**: 全 app `--verb VALUE`（空白区切り）。`--verb=value` 全廃。geom は `--geom 8 8 400 600` 多値化。

## 死守（揃えない・app ドメイン固有）

- **facet**: `lens --only/--toggle/--all` の tag/workspace mode 排他（requireGrouping Fail-Fast）／`scratchpad --stash/--toggle/--release`
  （i3/sway 系 named-shelf）／mark verbs・master-knob（grow/shrink/inc/dec・cycle-stack・rotate/mirror）／`workspace --focus` の
  index\|name\|relative 解決（`next`/`3` という名の WS が到達不能にならない解決を実装時に確認）／`--resign`(ad-hoc sign)・`--emit-schema`／exit 1(resign)・4(status-malformed)。
- **perch**: 11 mode の bare-noun 語彙（grid/rgrid/nudge/drag/vision/regional/menu/windows/emoji/scroll/search）／
  hotkey-mirror の単一キーストローク簡潔性（Karabiner/skhd/Raycast 一発トリガ・`overlay --activate` の打鍵増を設計で吸収）／
  `--dump-*` 診断ファミリ・DNC wire format／`--theme=` の empty-clear（移行先＝clear 専用 verb か `--theme ''` か実装時判断）。
- **wand**: cast/tome/stroke 語彙＋LURD pattern operand／`--show-menu` の cross-app spine 例外契約（外部呼出元を grep 確認）／
  `--record` の貼れる `[[cast.rule]]` 出力／`--validate` の config+items 2面／exit 3 二重意味（no-daemon＋record-tap-conflict）。
- **chord**: config.toml の combo 記法（`cmd + shift - 4`・`mouse.side1`・`hyper - p`）＝**config 文法であって CLI argv ではない**
  ので no-reserved-separator 規則を config に波及させない／`--pause/--resume/--watch` の chord 固有 lifecycle／`chord.bindings.v3` schema。
- **family 共通**: `<APP>_DEBUG` env var（`--debug` flag にしない・意図的設計）。
- **halo**: config-as-control-plane（runtime CLI を発明しない）。
- **glance**: stdin-as-data-channel（Unix filter 尾）／empty-stdin→silent exit 0（silent fallback 禁止の例外）。
- **jig**: bare positional filter／jq-matched flag 名(`-c`/`-r`/`-n`)／exit 0/2/3/5(3=compile)／filter LANGUAGE 記法。
- **atelier**: bulk-by-default／run の args-passthrough（`--` 境界）／ghq-tree single source／自身は daemon 化しない。
- **sill**: library ゆえ判定対象外（`CLIKit` の**提供 host**であり消費 app ではない）。

## 確定設計（トミー委任・0ベース/破壊OK 前提・2026-06-14）

| ID | 論点 | 確定 |
|---|---|---|
| **D0** | tokenizer の `-`始まり/負数/`--`終端 | 値要求 verb(arity≥1)の**直後トークンは符号付きでも値として消費**、曖昧・明示時は `--` 終端。**CLIKit の第一仕様**として最初に作る（負座標/相対 index/`-`始まり名を無言 exit 2 で壊さない） |
| **D1** | IN/OUT 線引き | daemon-control(facet/chord/wand/perch)=IN／data-processing(glance/jig)・orchestrator(atelier)・config-only(halo)=**OUT**（横断 sub-規約のみ） |
| **D2** | 破壊方針 | **完全 full-replace・シム一切なし**。inter-app 呼出（`wand --show-menu` 等）は alias を残さず**呼出元を grep 特定→同じ sweep で両側更新**。facet は**段階デリバリ**（PR1: `=`→空白／PR2: domain 再編）だが意味は full-replace |
| **D3** | 補完 | **別 PR・別完了条件**。動的値 list 口は新規 read API として facet 先行設計（文法移行を人質にしない） |
| **D4** | sill 共有 | sill 新モジュール **`CLIKit` = pure mechanism のみ**（tokenizer / `--verb VALUE` 消費 / unknown-flag loud reject / 0/2/3 exit helper / `--show` emitter）。**verb-table validator と domain/verb 語彙は app local 死守**（過剰共有＝最弱共通分母 bad-abstraction） |
| **D5** | exit code | 0/2/3 を共通床、診断拡張(facet 1,4 / perch 1 / wand 3 二重)は各 `--help`/README 明記で温存。OUT app は `0/2+固有`（jig 3=compile を 3=daemon から除外） |
| **D6** | `--show` | `--show`=人間行（greppable）／`--show --json`=機械。**JSON schema は app local**（window tree/binding/cast-tome rule/overlay state は異質ゆえ family 1本固定しない） |
| **D7** | `-h`/`-V` | この2つのみ family 横断 carve-out、他 bare-flag alias は削除 |
| **D8** | atelier passthrough | `atelier app --run facet -- args` の `--` 境界**必須化**（`--` 手前の未知 flag は atelier の loud exit 2） |

## 想定実装順 / 検証

0. **sill `CLIKit`（cornerstone）**: pure tokenizer（D0 仕様: arity-aware 値消費＋`--` 終端）＋ `--verb VALUE` 消費 ＋
   unknown-flag loud reject ＋ 0/2/3 exit helper ＋ `--show`/`--json` emitter。**verb-table validator は含めない**（app local）。
   clockless / AppKit 非依存 pure（Palette/Toml と同列の atom）。golden = CLIKit unit test（負数 / `-`始まり / `--`終端 / 多値 arity /
   optional 2nd value `--test PATTERN [BUNDLE-ID]` / empty-clear を含む）。sill は CI 無し＝`swift run` ハーネス検証。
1. **facet**（先頭・CLIParse.swift seam あり）:
   - **PR1**: 全 `hasPrefix("--x=")` arm を次 argv token 消費へ書換（CLIKit 適用・`=`→空白）。挙動以外不変＝最小差分・verify 容易。
   - **PR2**: domain 再編（window/workspace/lens/scratchpad/daemon/config 配置＋view/theme/server の domain 化）。verb 名は facet のまま。
   - **PR3**: `--show`（既存 disk JSON を stdout 昇格）＋ WS/tag/mark **list 口（新規 read API）**。補完は別 PR。
   - 検証＝実機 verify（Tart demo-base swift test + skhd 経由 live）＋ golden（CLIParse/CLIKit unit）。
2. **wand**（既に空白区切り＝最小差分）: cast/tome/config/daemon の domain 配置のみ。`--show-menu` 呼出元を grep→同 sweep で更新。
   `--validate` items 2面の解決。検証＝`--validate`/`--doctor`/`cast --test` golden＋inter-app `--show-menu` 呼出 live。
3. **perch**（`--theme=`→空白＋overlay/daemon/config/ax 配置）: empty-clear の移行先確定。hotkey-mirror 簡潔性を死守設計。
   検証＝実機 verify＋`--validate`＋`--dump-*` golden。
4. **chord**（config/daemon domain 配置＋`-h` 除去）: `--pause/--resume/--watch` は chord 固有ゆえ verb 統一せず保持。
   検証＝`--validate --strict --json` golden（CI 既存）。
5. **OUT 各1 PR**: halo=`--bogus` 黙殺→loud exit 2（`open Halo.app` 正常起動を壊さない検証）／glance=`-h/-V` alias 除去／
   jig=現状維持＋`exit 3=compile を 3=daemon から除外`を doc 明記／atelier=`--list→--show` rename・alias 除去・`--` 境界必須化（bulk-default+passthrough 死守）。

各 swap 共通: sill に pure API 追加 → path-dep `../sill` で atomic 編集 → build → 実機 verify/`--validate`/golden →
url+SemVer swap → `Package.resolved` 再 pin → app PR（`Closes #N`）→ auto-merge（§push ritual）→
`--help`/README(bilingual)/移行ガイド ＋ **横断 migration cheat-sheet**（`--verb=X`→`--verb X` 機械変換＋符号付き値の `--` 注意を1枚）同時更新。

## 完了条件（文法移行 A と補完 B を分離）

**A. 文法移行（破壊変更・先行 landing）**
- 対象 app（facet/wand/perch/chord）が `<app> <domain> --verb VALUE` 文法・`--verb=value` 全廃・D0 tokenizer 仕様準拠。
- 各 domain に `--show [--json]` 読口を配置（既存 machine-readable 昇格・新 schema 強制なし・バラバラだった読口を統一）。
- exit 0/2/3 を daemon-control 共通床に、診断拡張は `--help`/README 明記。OUT app は `0/2+固有`（jig 3=compile 除外）。
- daemon/config は**配置のみ統一**（verb セット・`--show` JSON schema は app local・bad-abstraction 化なし）。
- 全対象 app の `--help`/README.md/README.ja.md/移行ガイド ＋ 横断 migration cheat-sheet を破壊変更に合わせ書換（シム無し full-replace）。
- 死守語彙が無傷（facet lens 排他/scratchpad/mark/master-knob/focus 解決、perch 11 mode/hotkey-mirror/theme empty-clear、
  wand cast/tome+LURD/show-menu 契約/validate 2面/resign 別意味、chord combo 記法/pause-watch、`<APP>_DEBUG`）。
- glance/jig/atelier/halo の OUT を文書化、横断 sub-規約（alias 除去・unknown-flag loud exit 2・machine-readable・no-silent-fallback）のみ適合。
- sill `CLIKit` は clockless/AppKit 非依存 pure・mechanism のみ。verb-table validator と domain/verb 語彙は app local 死守。

**B. 補完（別 PR・A の landing をブロックしない）**
- 動的値 list 口（WS名/tag名/mark/theme/bundle id）を新規 read API として facet で先行設計・確立。
- bash/zsh/fish 補完を各対象 app 同梱、動的値は B の list 口供給。A の文法移行は B 未完を待たず landing 可（AND 結合しない）。

## sill `CLIKit` 実装仕様（確定・実装済 2026-06-14）

cornerstone を sill に実装。6 app の値の形を実コードから網羅（facet/wand/perch/chord ＋ OUT-ref glance/jig）し、
D0 を解く arity 駆動 tokenizer を確定。**32 golden ケース host verify green**（`swift run` harness・撤去済／durable は
`Tests/CLIKitTests` XCTest）。pure（Foundation のみ・Sendable・zero AppKit・zero Palette）＝Palette/Toml と同列の atom。

### 核心 = arity 駆動消費（D0）
`--verb=value`→空白区切り化で `=` が担っていた「値の接着」を **arity が担う**。認識済み flag が arity≥1 なら、
次の N トークンを**符号付き/`-`始まり/空でも無条件に値として消費**する（wand `valueArities`・glance lookahead の一般化）。
`-`始まりトークンが flag か値かを判定するのは **flag 位置のみ**。値位置では verbatim に取る。

### `Arity`（app が供給・CLIKit は verb 語彙を持たない＝D4）
- `.flag` … 0値（boolean/action）。
- `.value` … 必須1値。次トークンを verbatim（符号/`-`/空 OK・bare `--` のみ拒否）。
- `.values(N)` … 必須N値が一緒に動く（`--at -100 50`＝`.values(2)`）。
- `.optional` … 0か1（bare、または次が plain word の時だけ1値）。facet `--loading`/`--remove`。
- `.requiredThenOptional(N)` … 必須N＋末尾 optional1（wand `--test PATTERN [BUNDLE]`。`--test DLU --selection x` は
  `--selection` で止まり BUNDLE を食わない）。
- `.variadic` … plain word を1個以上、次の flag/`--`/終端まで（`--only a b c`）。

### tokenizer 規則（左→右1パス）
1. `--` は **flag 位置の終端**＝以降全て positional（jig `-- -1`）。required 値は `--` 不要で無条件消費。
2. flag 位置で `-`始まり（lone `-` と空を除く）＝flag。alias 解決（既定 `-h`/`-V` のみ・D7）→ arity 不明なら
   **loud unknownFlag（exit 2）**＋did-you-mean（long flag のみ・短 flag は編集距離が密で誤誘導ゆえ提案しない）。
3. flag 位置の非 flag（bare 語・lone `-`・空）＝positional。`allowsPositionals=false`（chord 等）なら loud reject、
   `true`（facet `status`/jig filter）なら収集。
4. required 値不足は **loud missingValue（exit 2）**。

### 確定した個別解
- **負座標**（`wand --at -100 50`・`facet --pos-x -100`）＝required 値で無条件消費。**今動く呼出が無言 exit 2 になる罠を解消**。
- **perch empty-clear**: `--theme=`（clear）→ 空白区切りでは **`--theme ''`**（明示空トークン＝required 値が空文字を verbatim 消費）。
  bare `--theme`（後続無し）は missingValue（曖昧を排除）。
- **jig `-1`** は documented 通り unknownFlag（fix＝`jig -- -1`）。lone `-`＝stdin positional。
- **API**: `CLIKit.parse(_ argv:, spec:) throws -> Invocation`（`flags:[Flag]` 順序保持・`positionals:[String]`）。
  exit helper（`ExitCode.ok/usage/daemonNotRunning` ＝0/2/3・`die`/`warn` loud stderr）、`emitShow(human:json:asJSON:)`。
- **out-of-scope（app local 死守・D4）**: verb-table validation／domain・verb 語彙／allow-list・canonicalize・priority-loser
  dispatch（chord）／reject-before-dispatch 順序（perch が parse を dispatch 前に呼ぶことで保持）／`--show` の JSON schema。

> sill は CI 無し＝`swift run` harness でホスト検証（32/32 green・撤去済）。durable golden は `Tests/CLIKitTests`（Tart/将来 CI 用）。
> tag/release は **facet PR1 が path-dep `../sill` で消費→API 確定後**にまとめて（無消費タグを避ける・§push ritual）。

## バトン

進捗 tracker は [`refactor.md`](refactor.md) Phase 3。各 app の issue は roadmap Project #5
（[`roadmap-board.md`](roadmap-board.md)）。**sill `CLIKit` 実装済・verify green**。次手 = **facet PR1**（`=`→空白・CLIKit 消費）。
