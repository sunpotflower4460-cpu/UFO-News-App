# V3 Implementation Log — Clarity / Trust / Editorial Depth

正本は `SKYTRACE_UIUX_V3_WORLD_CLASS_DIRECTIVE.md`。作業ブランチ `uiux/v3-clarity-trust`（main から作成）。
実CI（`ios.yml`, macOS / Swift 6 / iOS 17 simulator）で build + unit tests green を各フェーズで確認。

## Phase V3-0 — Baseline
- `docs/uiux/V3_BASELINE_REVIEW.md` 作成：P0各項目を実在コードへ対応づけ、非目標を明文化。
- ベースラインは merged main（PR #2/#3/#4 反映済み、CI green）。

## Phase V3-1 — Trust & Interaction P0（実装済み・CI green: 879645b）

| P0 | 実装 | 主な変更ファイル |
|----|------|------------------|
| P0-01 | `AppRouter`（tab selection）導入。Today「地図で見る」CTA→Mapタブ遷移。 | `App/AppRouter.swift`(新), `App/RootTabView.swift`, `App/SkyTraceApp.swift`, `Features/Today/TodayV2View.swift`, `DesignSystem/Components/WorldSkyPulse.swift` |
| P0-02 | WorldSkyPulseのVoiceOver分離（要約=1要素／CTA=独立ボタン）。文言「地図で見る」。 | `DesignSystem/Components/WorldSkyPulse.swift`, `Resources/SkyStrings.swift` |
| P0-03 | CaseCardをV2ステータス語彙（`CaseStatusLabel/Glyph`+`v2Status`）へ統一。a11yも。 | `DesignSystem/Components/CaseCard.swift` |
| P0-04 | Search：300ms debounce＋Task cancel、空検索スキップ、実際の`matchReason`、facetsは`allCases`から。 | `Features/Research/ResearchViewModel.swift`, `Features/Research/SearchV2View.swift`, `Resources/SkyStrings.swift` |
| P0-05 | Evidence（記録）とSources（引用）を分離。`EvidenceItem`を記録性のある出典から導出。二重表示解消。 | `Domain/Models/EvidenceItem.swift`(新), `Domain/Models/UAPCase+V2.swift`, `DesignSystem/Components/EvidenceItemRow.swift`(新), `Features/CaseDetail/CaseDetailV2View.swift` |
| P0-06 | Related Casesを`NavigationLink`で遷移可能に（関連理由をa11yに含む）。 | `Features/CaseDetail/CaseDetailV2View.swift` |
| P0-07 | LongFormを`article.blocks`順に走査。最初のgatedでロック挿入、順序不変。 | `Features/LongForm/LongFormView.swift` |
| P0-08 | Map：detent選択をstate化、選択でSheet`.medium`＋一覧スクロール、クラスタは範囲フィット、7pt廃止。 | `Features/Map/MapV2View.swift` |
| P0-09 | Settings：キャッシュ削除を実動（確認＋件数＋成功haptic）、通知は`UNUserNotificationCenter`実権限連動。 | `Features/Settings/SettingsView.swift`, `Services/NotificationService.swift`(新), `Data/Repositories/LibraryStore.swift`, `Domain/Repositories/Repositories.swift` |
| P0-10 | Today：`Loadable`で状態UI（skeleton／cached・offline／partial／error+retry）。既存の`SkeletonCard`/`InlineBanner`/`ErrorStateView`を活用。 | `Features/Today/TodayV2View.swift` |

- ユニットテスト追加：`AppRouterTests`（tab切替）。
- CI設定：`ios.yml`を`uiux/**`のpushでも実行。
- CI検出バグ修正：`NotificationService`で非Sendableな`UNNotificationSettings`が@MainActor境界を越える問題→continuationで`authorizationStatus`のみ取得。

## Decisions
- **D-V3-001**：Evidence/Sources役割分離（Evidenceは記録性のある出典から導出。実データ接続時は直接投入）。
- **D-V3-002**：通知トグルをOS権限（未設定/拒否/許可）に連動。

## 完了条件（V3-1）達成状況
- 動かないCTA無し（P0-01/06）／検索一致理由の流用無し（P0-04）／出典重複無し（P0-05）／premium gateで記事順不変（P0-07）／Map選択がSheetへ反映（P0-08）／7pt廃止（P0-08）／unit tests green（CI）。✅

## Phase V3-2 — Today & Case Clarity（進行中・実CI green）

| 項目 | 実装 | ファイル |
|------|------|----------|
| World Pulse metrics | 3指標（新規報告/統合事例/評価更新）＋カバレッジ常時可視化＋可読性スクリム。数字はmonospaced-digit、VoiceOverは3指標を集約。 | `DesignSystem/Components/WorldSkyPulse.swift`, `Features/Today/TodayV2View.swift` |
| Case Executive Summary | Case Detail最上部に「現時点」ブロック（現状＋有力な説明候補＋未解決点）。`currentAssessment`/説明候補matchScore/gapsから導出。 | `Domain/Models/UAPCase+V2.swift`, `DesignSystem/Components/CaseExecutiveSummary.swift`(新), `Features/CaseDetail/CaseDetailV2View.swift` |
| Search 状態コンテナ（P0-10継続） | 初期ロードにSkeletonCard、失敗時ErrorStateView。`didLoad`/`loadFailed`でtry?の握り潰しを廃止。 | `Features/Research/ResearchViewModel.swift`, `Features/Research/SearchV2View.swift` |
| Map 状態コンテナ（P0-10継続） | 読み込み失敗時にoffline InlineBanner（再試行）。`MapViewModel`に`didLoad`/`loadFailed`。 | `Features/Map/MapViewModel.swift`, `Features/Map/MapV2View.swift` |

### V3-2 追加（実装済み・CI green: 38fce5b）
- **CaseSectionNavigator**（sticky section chips：概要/評価/資料/経緯/出典）。`ScrollViewReader`＋アンカーで各グループへジャンプ。12節維持、Dynamic Type/VoiceOver対応。

### V3-2 追加（レビュー指摘修正・実CI green: 4b3d14c）
- **CaseSectionNavigator** に `sections` 引数を追加。CaseDetail は内容のある節のみ渡す（evidence/timeline/sources は存在時のみ）。press/social のみの事例で「資料」チップが死にリンクにならない。
- **ResearchViewModel**：`runSearch()` が自分を起動した debounce タスクを cancel する問題を解消。`cancelDebounce()` を追加し onSubmit / selectTag / clearFilters から呼ぶ。

### V3-2 追加（CaseDetail loading skeleton）
- CaseDetail の読み込み中を素の `ProgressView` から構造スケルトン（ヘッダースラブ＋タイトル/メタ行＋2セクションブロック）へ。VoiceOver は「読み込み中」1要素、shimmer は Reduce Motion / UI テストフラグを尊重。

### V3-2 追加（Citation drawer）
- 本文 fact ブロックの出典マーカーをタップ可能な `[n]` チップ化。記事内の初出順に 1…n 番号を付与（`sources` に解決できる id のみ）。タップで **CitationDrawer**（medium/large detent）を開き、媒体名・種別・タイトル・許諾抜粋・原典への in-app リンク（SafariView）を表示。読書位置を失わない。
- `sources` が無い文脈（デバッグギャラリー等）ではプレーンな脚注へフォールバックし、出典表示が消えない。
- 変更ファイル：`Domain/…`不要。`Features/CaseDetail/ArticleBlockView.swift`, `DesignSystem/Components/CitationDrawer.swift`(新), `Features/LongForm/LongFormView.swift`, `Features/CaseDetail/CaseDetailV2View.swift`（`LongFormView` に `sources` を受け渡し）, `Resources/SkyStrings.swift`（citation.*）。

### V3-2 追加（Case Lead Visual）
- CaseDetail ヘッダーの素の atmosphere ブロックを **CaseLeadVisual** に置換。ステータス色で染めた大気＋焦点となるステータスグリフ（立体的な影・ハロー）で、各事例に非扇情的で識別可能なヒーローを付与（未許諾写真に依存しない・CLAUDE.md §7）。ステータスは色だけでなく形で区別、装飾要素なので VoiceOver からは隠し、下のテキストが状態/タイトル/場所を説明。Reduce Transparency 尊重。
- 変更ファイル：`DesignSystem/Components/CaseLeadVisual.swift`(新), `Features/CaseDetail/CaseDetailV2View.swift`。

### V3-2 追加（adaptive time metadata）
- `SkyFormat.adaptive(_:window:)` を追加：`window` 日以内は相対表現（「3日前」）、それ以外は絶対日付。CaseDetail ヘッダーの「最終確認」チップ（鮮度シグナル）へ適用。発生日時・公開日（イベント事実）は絶対日付のまま。
- 変更ファイル：`DesignSystem/Tokens/Formatters.swift`, `Features/CaseDetail/CaseDetailV2View.swift`。

### V3-2 完了
上記で V3-2（World Pulse metrics / executive summary / section navigator / citation drawer / lead visual / loading skeleton / adaptive time / 状態コンテナ）を一通り実装。次は Phase V3-3。

## 残（次フェーズ）
- **P0-10 の全画面展開**：Map/Search/CaseDetail の状態UI（skeleton/cached/offline/partial/error/empty）は V3-2 で完成（CaseDetailは既に`.failed`対応）。`MapViewModel`/`ResearchViewModel`へ`Loadable`導入も V3-2。
- **Phase V3-2**（World Pulse metrics / executive summary / section navigator / citation drawer / lead visual / state containers）
- **Phase V3-3**（Map/Explore同期・facets・recent searches）
- **Phase V3-4**（Long-form reading・contextual gate・Paywall preview・Trust Center・notification permission連携UI）
- **Phase V3-5**（Dark/Light・AX・Reduce Motion/Transparency・Instruments・App Store surface）
