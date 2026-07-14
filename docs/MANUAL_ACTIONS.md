# Manual Actions — 人間の操作が必要な項目

Claude Codeが実行できない、または資格情報・契約・実機が必要な項目のみを記載する。
開発全体はこれらで停止しない（fixture/mock/feature flagで前進済み）。

## 最優先（Phase 1 完了確認）

- **M-001 Xcodeでのビルド・テスト確認（必須）**
  本コードはLinux環境で作成しており、コンパイル・テスト・Simulator確認を実行できていない。
  macOS + Xcode 26 で以下を実行し、結果を`PROGRESS.md`へ記録する。
  ```bash
  make ios-project     # XcodeGen推奨（brew install xcodegen）／未導入なら python 生成にfallback
  make ios-build
  make ios-test
  open apps/ios/SkyTrace.xcodeproj
  ```
  ビルドエラーが出た場合は、Swift 6 strict concurrency 起因の指摘が中心と想定される。修正して再push。

- **M-002 スクリーンショット取得**
  主要画面（`SCREENSHOT_INDEX.md`の一覧）をSimulatorで撮影し、`docs/screenshots/`へ保存。
  最小幅/標準/最大幅のiPhoneとLight/Darkで。

## App Store / StoreKit（Phase 6・10）

- **M-010** Apple Developer Program登録、正式Bundle IDの登録。
- **M-011** App Store Connectでサブスクリプショングループと商品（月/年）を作成。商品IDを`SubscriptionIDs`／`.storekit`／`project.yml`と一致させる。
- **M-012** 契約・税・銀行情報（Paid Apps Agreement）。
- **M-013** Sandboxテスター作成、実機でのSandbox購入/復元確認手順の実施。
- **M-014** App Store Server Notifications V2のエンドポイントURL登録（Phase 6のサーバ実装後）。

## Legal / インフラ（Phase 7）

- **M-020** プライバシー/利用規約/サポートの本番HTTPS URLを用意しデプロイ。`LegalPage.externalURL`のホスト`skytrace.example.com`を実ドメインへ置換。`ReleaseLinkAudit`がプレースホルダーを検出する。
- **M-021** App Privacy（Nutrition Label）回答を`PrivacyInfo.xcprivacy`と一致させる。
- **M-022** App Icon（1024pt）とアクセント/起動色の最終アセット。現在はプレースホルダーのカラーセットのみ。

## データソース権利（Phase 3）

- **M-030** 利用したい情報源（報道API、専門DB等）の利用規約確認と、必要な場合の書面許諾/提携。
- **M-031** attribution文言の確認。
- **M-032** NUFORC/MUFON等はadapter skeletonのみ、許諾取得まで本番無効（`DATA_SOURCE_REGISTRY.md`）。

## AI（Phase 5）

- **M-040** LLMプロバイダーのAPIキー（サーバ側`.env`のみ。iOSへは埋め込まない）。未設定時は`FakeLLMProvider`で動作。

## V2 UI/UX（追加）

- **M-050 Widget拡張ターゲットの追加（Xcode必須）**
  `apps/ios/SkyTrace/Widgets/SkyWidgets.swift` に Widget content views・`TimelineProvider`・`StaticConfiguration`（`SkyTodayWidget`）を実装済み。ただし実際にホーム/ロック画面へ出すには、Xcodeで **Widget Extension ターゲット**を追加し、その `@main WidgetBundle` から `SkyTodayWidget` を参照する必要がある（extensionのInfo.plist/capability/App Groupはコード生成では追加できない）。content viewsは共有可能。
- **M-051 実機/Simulator確認（macOS必須）**
  V2画面のVoiceOver読み上げ順・Dynamic Type AX5・Reduce Motion/Transparency・スクリーンショット（`docs/uiux/`のScreenshot Story）・Instruments計測。`docs/uiux/UI_REVIEW_REPORT.md`の🟡項目。
- **M-052 タブのV2/旧切替**
  現在`RootTabView`はV2画面を表示。旧Phase 1画面（`TodayView`等）はコード内に残置。必要なら内部フラグ化して切替可能。
