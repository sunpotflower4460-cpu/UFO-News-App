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
