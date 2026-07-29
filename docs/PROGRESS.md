# SkyTrace Progress Log

> チャット報告は簡潔に。詳細な作業ログはこのファイルに置く。

---

## Phase 0 — Repository Audit & Foundation

Status: complete
Date: 2026-07-13

### Implemented
- リポジトリ監査：初期状態は空（スタブ`README.md`のみ）。破壊的変更なし。
- モノレポ構成を作成：`apps/ios`, `docs`, `scripts`（`services/`,`packages/`,`admin/`は後続Phaseで追加）。
- 正本ドキュメントを配置：`README.md`, `docs/ARCHITECTURE.md`, `docs/UI_UX_PLAN.md`, `docs/CLAUDE_CODE_PHASES.md`, `CLAUDE.md`。
- Phase 0成果物：`PROGRESS.md`, `DECISIONS.md`, `MANUAL_ACTIONS.md`, `DATA_SOURCE_REGISTRY.md`, `APP_STORE_CHECKLIST.md`, `UI_REVIEW_CHECKLIST.md`, `SCREENSHOT_INDEX.md`。
- `.gitignore`, `.env.example`, `Makefile`, 最小CI（`.github/workflows/ios.yml`）。

### Decisions
- `docs/DECISIONS.md` の D-001〜D-010 を参照。

### Remaining
- backend/admin ディレクトリはPhase 2/8で作成。

---

## Phase 1 — iOS "Finished Experience" with Fixtures

Status: complete (code) / build unverified on this host
Date: 2026-07-13

### Implemented
- **App shell**：Welcome（2画面）→ 4タブ（今日／地図／探す／設定）。`@Observable` + async/await + Repository注入。
- **Design System**：Semantic tokens（`SkyColor`/`SkySpacing`/`SkyRadius`/`SkyTypography`）、`CardSurface`/`GlassControl` modifiers、Light/Dark両対応（Dark主軸）。
- **Components**：`GlobalSummaryHero`, `DailyBriefingCard`, `CaseCard`(5 variants), `StatusBadge`, `ScoreQuadrant`(+説明Sheet), `EvidenceSection`, `ExplanationCandidateCard`, `SourceRow`, `TimelineEntryView`, `PremiumLockView`, State components（Skeleton/Empty/Error/Offline/Partial/Demo/Stale）, `ObservationGlyph`（画像不要の抽象ビジュアル）。
- **Domain models**：`UAPCase`, `CaseStatus`, `CaseScores`(4軸), `SourceReference`, `AgreementPoint`, `ContradictionPoint`, `ExplanationCandidate`, `CaseTimelineEntry`, `DailyBriefing`, `ArticleBlock`, `SynthesizedArticle`, `LocationPrecision`, `EntitlementState`。全て`Codable`/`Sendable`。
- **Fixtures**：9件のDemo Case（うち日本2件：東京湾／北海道）。全件に発生/公開/更新日時・4軸スコア・一致点・矛盾点・説明候補・タイムライン・出典・（3件はAI統合記事）。全件`DEMO`フラグ。状態網羅：explained/likely_explained/insufficient_data/notable_unresolved/disputed/withdrawn。
- **Today**：世界概況Hero、Daily Briefing（Free/Plus）、注目事例、更新、保存事例更新、Pull to Refresh、Offline/Partial/Demoバナー、Loading skeleton、Emptyコピー。
- **Map**：MapKit、ステータス別ピン、ズーム連動クラスタリング、精度リング（approximate/region_only）、位置非公開は地図非表示、フィルターバー＋詳細フィルターSheet、Bottom Sheet、代替リスト。位置許可は要求しない。
- **Case Detail**：抽象Hero、状態、発生/公開/最終検証時刻、4軸スコア（タップで根拠Sheet）、60秒要約、一致点/矛盾点、既知現象照合、現在判断、AI統合記事（Plusゲート）、情報不足、必要証拠、タイムライン、出典（SFSafariView）、AI/編集方針、Bookmark、ShareLink。
- **Research（探す）**：`.searchable`検索、構造化フィルターSheet、最近見た項目、更新事例、保存済み、Plus導線。
- **Paywall**：文脈型、StoreKit由来価格、月/年、年額の実質月額、無料体験表示、復元、規約/プライバシー、閉じるボタン、偽の緊急性なし、購入後は元の場所へ復帰（sheet dismiss）。
- **StoreKit**：`SubscriptionProviding`抽象、`StoreKitSubscriptionService`（本番）＋`FakeSubscriptionProvider`（Debug/Preview）、`SkyTrace.storekit`ローカル設定（月/年＋7日無料体験）、共有Schemeに配線済み。Entitlement状態：free/active/grace/retry/expired/revoked、通信障害だけで即ロックしない。
- **Settings**：購読状態/復元/管理、通知（ローカルトグル＋価値説明）、外観（システム/ダーク/ライト）、データ、編集/AI/スコア/出典/訂正の各方針、プライバシー/規約、サポート、About、Debug（データソース切替/entitlement上書き/状態プレビュー）。
- **Legal pages**：8ページのネイティブ原稿（プレースホルダーではない）＋本番URL（`example.com`は`ReleaseLinkAudit`で提出前に検出）。
- **Accessibility**：全状態を色＋アイコン＋語で表現、CaseCardの結合VoiceOverラベル、Dynamic Type（`@ScaledMetric`／`fixedSize`）、Reduce Motion（skeleton/glyphアニメ停止）、44pt以上のタップ領域、`textSelection`。
- **Feature flags**：UGC/AI-QA/cloud account/export はすべて既定false、Debug UIは`#if DEBUG`のみ。
- **Tests**：Unit（Fixture整合/citation gate/検索/購読状態/リポジトリfallback/bookmark/ReleaseLinkAudit）、UI（4タブ/Today→詳細/Map/検索/Settings、`-uitest-skip-welcome`）。
- **Project**：`apps/ios/project.yml`（XcodeGen＝正本）＋`scripts/generate_xcodeproj.py`（直接開ける`.xcodeproj`を生成、共有Scheme＋StoreKit配線）。

### Tests run
- `xcodebuild` / `xcodegen`：**この作業環境（Linux）では未実行**。Xcode/Swiftツールチェーンなし。
- 実施した検証：生成`project.pbxproj`の参照整合（未定義参照0）と括弧バランス（0）を`scripts`で確認。Swiftの静的検査は目視レビューのみ。
- → macOS + Xcode 26で `make ios-project && make ios-test` を実行して確定すること（`MANUAL_ACTIONS.md` M-001）。

### Visual review（Simulator/Previewで確認してほしい画面）
- Welcome → 今日（Free）→ Case Detail → 出典（SafariView）
- 今日（Plus）→ Daily Briefing 全文
- Case Detail → 4軸スコアのタップ→根拠Sheet
- Case Detail（Free）→ AI統合記事のPremiumLock → Paywall → ローカル購入 → 記事の続きへ復帰
- 地図 → フィルター → クラスタ/ピン → Bottom Sheet → 詳細
- 探す → 検索「東京」→ フィルター → 保存
- 設定 → 購入を復元 / Debug entitlement上書き / 状態プレビュー
- 各Preview：`#Preview("… · Free")` / `("… · Plus")`

### Remaining
- 実機/SimulatorでのビルドとUI/UXの目視確認（本環境では不可）。
- スクリーンショット取得（`SCREENSHOT_INDEX.md`に取得計画を記載）。
- Phase 2以降（ローカルAPI/DB、AI、実ソース）。

### Manual actions
- `MANUAL_ACTIONS.md` を参照（Xcodeビルド確認、Bundle ID、App Store Connect等）。

### Risks / known limitations
- **ビルド未検証**：Linux環境のためコンパイル・テスト・Simulator確認を実行できていない。目視レビューで明白な誤りは修正済みだが、Swift 6 strict concurrencyの微細な指摘やAPI差異が残る可能性がある。
- **文字列**：Phase 1は`SkyStrings`（コード内テーブル）を実行時の正本とし、`Localizable.xcstrings`は構造サンプルのみ。理由と移行方針はD-006。
- 生成`.xcodeproj`は本環境でXcodeを開いて検証できていない。確実な経路としてXcodeGen（`project.yml`）を併置。

## App Store 提出準備（2026-07-15）

実装済み（コミット・CI検証）:
- **App Icon 1024pt** 生成・配線（`scripts/generate_app_icon.py`／`AppIcon-1024.png`、RGB・アルファなし）。
- **法務/サポートの実在URL**：`docs/site/`（ja+en 静的HTML）＋`pages.yml`（GitHub Pages自動デプロイ）。
  `LegalPage.externalURL` を github.io へ配線、`ReleaseLinkAudit` を clean 化（テスト更新）。
- **バージョン 1.0.0**（`project.yml`／`generate_xcodeproj.py` 同期）。
- **提出メタデータ**：`docs/APP_STORE_METADATA.md`（名称/副題/説明/キーワード/リリースノート/
  審査メモ/App Privacy回答/年齢レーティング、ja+en）。
- **スクリーンショットCI**：Pro Max（6.9"）優先で撮影するよう `screenshots.yml` を調整。

残る手動（`MANUAL_ACTIONS.md` 冒頭の一覧）:
- GitHub Pages を ON、サポートメール実アドレス化、Apple登録・Bundle ID/商品ID実値化、
  契約/税/銀行、Xcode Archive→Upload＋Sandbox実機確認、ASCメタデータ入力・提出。

## News First / AI Second — Phase 1 + Phase 2 foundation（2026-07-29）

Status: Phase 1 complete (code) / build unverified on this host（Linux、従来と同じ制約）
Status: Phase 2 local mock API foundation complete and tested (pytest green)

参照: `docs/product/NEWS_FIRST_BASELINE.md`（情報順序 before/after 詳細）、
`docs/DECISIONS.md` D-NF-001〜D-NF-007。

### Implemented — Phase 1（News First UI）

- **Domain**: `Domain/Models/NewsFirstPresentation.swift` — 既存fixtureから導出する
  `primarySources`／`primaryMedia`／`additionalMedia`／`leadOutletName`／
  `reportingOutletNames`／`firstReportedAt`／`premiumSummary`（`PremiumSummaryContent`）。
  新規並行モデルは作らず、既存`SourceReference`/`MediaAsset`を再利用（D-NF-001）。
- **新規コンポーネント**（`DesignSystem/Components/NewsFirst/`）: `NewsCaseHeader`,
  `PrimaryNewsMediaView`, `PrimarySourceActions`, `PremiumSummarySection`,
  `AIReferenceDisclosure`/`DetailedAssessmentDisclosure`（共通`CollapsibleReferenceSection`、
  既定`isExpanded = false`）。
- **CaseDetailV2View**: News First順に全面再構成（D-NF-002）。ナビゲーションアンカー・
  ブックマーク・共有ツールバーは維持。
- **CaseCard**: 全variant（featured/standard/compact/mapSheet）でメディアを先頭表示に統一。
  DEMOバッジは画像上のスクリム付きバッジへ（視認性維持、D-NF-004）。
- **TodayV2View**: 「今日の空のニュース」を最上段へ、`WorldSkyPulse`（集計数値）を後段へ移動
  （D-NF-005；視覚サイズの縮小は残課題 M-062）。Daily BriefingのAI表示を小さく。
- **BriefingDetailView / LongFormView**: `AIDisclosureBadge`をヘッダー先頭から末尾へ移動。
- **コピー**: `Localizable.xcstrings`に用語変換表を適用（既存23キー更新＋新規26キー追加、
  ja/en `translated`、他10言語は`needs_review`プレースホルダ）。銀ぴょう性/真相/UFO確率等の
  断定語は使わず、地球外起源への言及は全て否定文脈のみであることをテストで担保。

### Implemented — Phase 2（local mock API foundation）

- `docs/openapi/skytrace-v1.yaml`: 9エンドポイントのOpenAPI 3.1契約。
- `services/api`: FastAPIローカルモックサーバ。fixture専用・`isDemo: true`固定、
  `SKYTRACE_ENV=production`では起動を拒否。ETag/304、rights gate（`SourceProviderPolicy`）、
  X-Request-Id、構造化エラーボディを実装。
- iOS: `Data/API/SkyTraceAPIClient.swift`（actor、URLSession、ETag、指数バックオフ、
  cancellation対応、locale header）、`APIModels.swift`／`APIMapping.swift`、
  `Data/Repositories/ProductionRepositories.swift`。`AppEnvironment.apiBaseURL`が
  明示設定された場合のみ有効化、未設定時は既存`UnconfiguredXRepository`のまま
  （`testProductionSourceNeverFallsBackToFixtures`は無改変で成立）。
  Settings開発者セクションにAPIのURL入力欄を追加（Debug-only）。

### Tests

- **iOS（Xcode必須、この環境では実行不可）**: 新規
  `NewsFirstPresentationTests.swift`（premiumSummary導出・primarySources順位・
  primaryMedia選定）、`CopyLintTests.swift`（禁止語スキャン、
  `Localizable.xcstrings`をソースから直接読み込み）、`ProductionRepositoryTests.swift`
  （`StubURLProtocol`によるAPIクライアント/マッピングの単体テスト、ETag 304、
  404は再試行しない、`apiBaseURL`未設定時はUnconfigured維持）。
  `CriticalFlowUITests`/`ScreenshotUITests`にAI補足disclosureの開閉テスト・
  primary source導線テスト・展開後スクリーンショットを追加。
- **Python（この環境で実行・green）**: `services/api/tests/test_contract.py`
  9件 — envelope必須フィールド、404の構造化エラー、ETag/If-None-Match/304、
  検索フィルタ、メディア権利ゲート（approved providerのみinline許可）、
  production起動拒否。`cd services/api && pytest tests/ -v` で再実行可能。
- **コピーLintの事前検証**: Pythonで同等ロジックを実行し、`CopyLintTests`が
  現行カタログに対してgreenになることを確認済み（Xcode実行前の妥当性チェック）。

### Visual review（Simulator/Previewで確認してほしい画面）

- Today → 「今日の空のニュース」（画像付きヒーロー）→ 「記事を読む」→ Case Detail
- Case Detail → NewsCaseHeader → 画像/映像 → 元記事ボタン → 3分でわかるまとめ
  （Free: ロック / Plus: 全文）→ 出典一覧 → 「AIの補足を見る」（タップで展開）→
  「詳しい確認データ」（タップで展開）
- Today → Daily Briefing行の「AIで整理・出典を確認」（小さな表示）
- 各新規コンポーネントの `#Preview`（Xcode Canvas）

### Remaining

- macOS + Xcode 26でのビルド・テスト・Simulator確認（`MANUAL_ACTIONS.md` M-060）。
- before/afterの実スクリーンショット取得（M-061）。
- `WorldSkyPulse`の視覚サイズ縮小（M-062、現状は表示順序のみ対応）。
- ローカルAPIをSimulatorから疎通確認（M-063）。
- 残り10言語のネイティブレビュー（M-064）。
- Phase 3以降（実ソース契約・クラスタリング・AI要約パイプライン・Admin console・staging）。

### Manual actions

`MANUAL_ACTIONS.md`「News First / AI Second」節（M-060〜M-064）を参照。

## SNSでの目撃報告（追加機能、2026-07-29）

ユーザーより「SNS投稿のうちUFO発見の可能性が高いものだけをスワイプで見られる機能」の要望。
CLAUDE.md §2／ディレクティブ§17の禁止事項（AIによる可能性判定・「UFO確率」表示）に抵触するため、
AskUserQuestionで方針を確認した上で**準拠版**（AIによる判定・スコア・並べ替えを一切行わない）
として実装。詳細は`docs/DECISIONS.md` D-NF-008/D-NF-009。

### Implemented
- `Domain/Models/SocialReportCandidate.swift`：既存の`.social`出典を案件順・出典順でそのまま
  列挙（スコアやランキングのフィールドを持たない）。
- `Features/SocialReports/SocialReportsSwipeView.swift`：Premium、`TabView(.page)`によるスワイプ
  カード。各カードは「未検証の報告」バッジ＋出典＋（許諾済みのみ）引用＋権利ゲート済みメディア＋
  「元の投稿を見る」リンクのみ。Freeユーザーは`PremiumLockView`→文脈型Paywall
  （新設`PaywallContext.Trigger.socialReports`）。
- 探す（Research）画面に入口（`socialReportsEntry`）を追加。
- 新規コピー10キーを`Localizable.xcstrings`へ追加（ja/en、他10言語は`needs_review`）。

### Tests
- `SocialReportCandidateTests.swift`：`.social`のみが対象になること、並び順がソートなしで
  case→source順であること、メディアが自ソースのものだけ紐づくこと、型に
  score/likelihoodフィールドが存在しないことを構造的に固定するテストを追加（Xcode実行待ち）。

### Remaining / Manual actions
- `MANUAL_ACTIONS.md`「SNSでの目撃報告」節（M-065）：実SNS Providerの規約確認・許諾が
  取れるまで、本番では空表示のまま（fixtureへのフォールバックなし）。

## SNSでの目撃報告 — ブラッシュアップ（2026-07-29、追加要望）

「自動でできる範囲でSNS周りをブラッシュアップしてほしい」との要望を受け、判定・スコアリングを
一切加えない範囲で以下を実施（詳細は`docs/DECISIONS.md` D-NF-010）。

### Implemented
- **専用Repository層**：`SocialReportsRepository`プロトコル＋
  `FixtureSocialReportsRepository`/`UnconfiguredSocialReportsRepository`/
  `ProductionSocialReportsRepository`を新設し、`AppEnvironment`に配線
  （既存`CaseRepository`とは独立、D-008のパターンを踏襲）。
- **バックエンド**：`docs/openapi/skytrace-v1.yaml` + `services/api`に
  `GET /v1/social/reports`を追加。`.social`出典のみ・スコア/ランクフィールドなしを
  pytestで構造的に固定（新規4件、計13件green）。fixtureに`.social`出典を1件追加
  （権利未確認プロバイダのメディア付き、rights gateの実例として）。
- **iOS UI**：見え方（shapeTags）フィルターチップ、日付ソート（事例順/新しい順/古い順）、
  ページ位置表示、Loadable導入によるオフライン/エラー再試行状態、pull-to-refresh、
  元投稿への共有（ShareLink）を追加。並べ替え・絞り込みの軸は常に「日付」か「カテゴリ」で、
  連続値スコアは一切使わない。

### Tests
- Python: `test_social_reports_only_includes_social_source_type`、
  `test_social_reports_media_is_rights_gated_and_linked_to_its_own_source`、
  `test_social_reports_response_never_contains_a_score_or_likelihood_field`、
  `test_social_reports_ordering_matches_case_then_source_order_with_no_sorting`
  （`cd services/api && pytest tests/ -v` で13件green、実行・確認済み）。
- Swift: `ProductionRepositoryTests`に`ProductionSocialReportsRepository`のデコード検証と
  Unconfigured維持テストを追加。`SocialReportCandidateTests`の構造テストを
  `caseShapeTags`追加後も更新済み（Xcode実行待ち）。

### Remaining / Manual actions
`docs/MANUAL_ACTIONS.md`「SNSでの目撃報告」節 M-066/M-067（Xcodeビルド確認、
ローカルAPI疎通確認）。

### Risks / known limitations

- 本セッションもLinux環境のため、Swiftコード全体のコンパイル確認ができていない
  （目視レビューで明白な誤りは修正済みだが、Swift 6 strict concurrencyの微細な指摘や
  API差異が残る可能性がある）。
- `WorldSkyPulse`の「小さく置く」要件は表示順序のみで対応し、視覚サイズは未縮小。
- Phase 2 APIコントラクトはNews First表示に必要な最小フィールドのみで、
  8軸評価・一致点/矛盾点・タイムライン等はPhase 3/4まで空のまま
  （`APIMapping.uapCase`のコメント参照）。
