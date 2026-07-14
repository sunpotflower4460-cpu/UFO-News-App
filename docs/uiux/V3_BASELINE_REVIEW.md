# V3 Baseline Review — Clarity / Trust / Editorial Depth

対象: 2026-07-14 の `main`（V2 Aether Editorial System マージ後）。作業ブランチ `uiux/v3-clarity-trust`。
正本は `SKYTRACE_UIUX_V3_WORLD_CLASS_DIRECTIVE.md`。矛盾時の優先順位は Kickoff の通り（安全/出典/課金/プライバシー > CLAUDE.md > V3指示書 > 既存UI/UX文書 > 現状実装）。

## ベースライン状態

- `main` は実CI（macOS / Xcode 16.4 / Swift 6 / iOS 17 simulator）で **build + unit tests green**。
- 既存資産で残すもの（V3でも保持）: Aether世界観、独立設計のLight mode、状態を色＋形状＋ラベルで表す仕組み、未解明≠地球外、多軸評価、What Changed独立表示、出典/訂正/評価根拠を無料、Map/List parity、contextual paywall、初回起動で権限強制しない、Reduce Motion/Transparency配慮、標準ナビ＋StoreKit 2。

## V3の非目標（この改善でやらないこと）

- V2の全削除・新規UI化はしない（既存Phase 1画面 `TodayView`/`MapView`/`ResearchView` も残す）。
- 単一「真実度/宇宙船確率」スコアを追加しない。UFO・宇宙人を断定するコピー/図像を追加しない。
- 出典・訂正・評価根拠をPlus限定にしない。
- 全画面をガラス/宇宙背景にしない（Brand Zone / Quiet Zone を分ける）。
- 本番デプロイ・App Store提出・StoreKit商品作成はしない。

## P0 マッピング（現状コード → 最小修正方針）

| P0 | 実在箇所 | 現状 | 最小修正 | 状態 |
|----|----------|------|----------|------|
| P0-01 Today地図CTA無反応 | `WorldSkyPulse.swift`（`onOpenMap` 既定`{}`）/ `TodayV2View.swift`（未配線）/ `RootTabView.swift`（selection無し） | CTAが空動作 | `AppRouter`（tab selection）を導入し `onOpenMap:{ router.openMap() }` | ✅ 実装 |
| P0-02 VoiceOver不能 | `WorldSkyPulse.swift` ヒーロー全体 `children:.ignore` 内にButton | ボタンが到達不能 | 要約部を独立a11y要素、CTAは別Buttonとして分離 | ✅ 実装 |
| P0-03 CaseCard旧語彙 | `CaseCard.swift`（`StatusBadge(status:)`） | 地図/検索はV2グリフ、カードは旧7語彙 | `CaseStatusGlyph`/`CaseStatusLabel(v2Status)` へ統一、a11yも `v2Status.labelKey` | 実装中 |
| P0-04 Search流用 | `SearchV2View.swift` / `ResearchViewModel.swift`（debounce無/空検索/`priorityReason`流用/`DemoCases`タグ） | 検索体験が仮 | VMにdebounce+cancel、実match reason、facetsは `allCases` から | 予定 |
| P0-05 Evidence/Sources重複 | `CaseDetailV2View.swift`（両節が `c.sources`） | 同一出典が二重表示 | `EvidenceItem` を導出しEvidenceは実証拠、Sourcesは出典に役割分離 | 予定 |
| P0-06 Related非遷移 | `CaseDetailV2View.swift` 関連事例が静的`HStack` | タップ不可 | 各行を `NavigationLink { CaseDetailV2View }` に | 実装中 |
| P0-07 LongForm順序 | `LongFormView.swift`（free/gated 別filter） | 記事順が壊れる | `article.blocks` を順走査、最初のgatedでロック挿入 | 実装中 |
| P0-08 Map選択/Sheet非同期・7pt | `MapV2View.swift`（detent状態無/固定12°/`.system(size:7)`） | 選択がSheetに反映されない・極小文字 | detent selection、選択で`.medium`+scrollTo、cluster bbox zoom、7pt廃止 | 実装中（7pt先行） |
| P0-09 Settings仮操作 | `SettingsView.swift`（clearCacheはhapticのみ/通知はローカルのみ） | 動かない操作 | 実キャッシュ削除（確認+結果）、`UNUserNotificationCenter` 権限連動 | 予定 |
| P0-10 状態UI | Today/Map/Search は全画面`ProgressView`のみ；`Loadable<T>` 既存（`Services/Loadable.swift`）だが未活用 | 骨格/cached/offline/partial/error/empty 欠如 | 各画面を `state` で分岐、skeleton/cached/offline/error/empty を通す | 予定 |

## 参考（実装で使う既存土台）

- 状態: `Services/Loadable.swift`（`.idle/.loading/.loaded/.partial/.failed(_,cached:)`）、`RepositoryError`（`.offline/.notFound/.partial/...`）。State views: `DesignSystem/Components/StateViews/StateViews.swift`（`ErrorStateView`/`EmptyStateView`）。
- 検索: `CaseRepository.search(query:filters:) -> [UAPCase]`（fixtureは `CaseSearch.run`）。
- Typography: `SkyTypography`（`screenHero/sectionHeading/cardHeadline/body/supporting/metadata/scoreNumber`）。一部Viewが `.caption2`/`.system(size:5|7)` を直書き → V3で是正。
- Status: 旧 `CaseStatus`(7) と V2 `SkyCaseStatus`(8)、移行は `SkyCaseStatus(_ legacy:)` / `UAPCase.v2Status`。

## 完了条件（V3-1）

動かないCTA無し・検索一致理由の流用無し・出典重複無し・premium gateで記事順不変・Map選択がSheetへ反映・7pt表示廃止・unit/UI tests green。
