# Manual Actions — 人間の操作が必要な項目

Claude Codeが実行できない、または資格情報・契約・実機が必要な項目のみを記載する。
開発全体はこれらで停止しない（fixture/mock/feature flagで前進済み）。

> 📘 **順番どおりの完全手順書は `docs/SUBMISSION_GUIDE.md`**（STEP 1〜10 ＋ 差し替え早見表）。
> 以下はその要約。

## 🚀 App Store 提出までに人間がやる操作（自動化済みを除いた残り一覧）

コード側の準備（アイコン・法務ページHTML・URL配線・メタデータ下書き・バージョン1.0.0・
Privacy Manifest・審査メモ）は完了済み。**以下は資格情報／契約／実機／設定トグルが必要で
Claude Codeでは実行できない**もののみ：

1. **GitHub Pages を ON**（Settings → Pages → Source: **GitHub Actions**）。以後 `docs/site/` が
   自動公開され、アプリ内Privacy/Terms/Support URLが実在化する（M-020）。
2. **サポート連絡先メールを実アドレスへ**差し替え（`scripts/generate_legal_site.py` の
   `SUPPORT_CONTACT` → 再生成 → コミット）（M-023）。
3. **Apple Developer 登録・正式 Bundle ID**（M-010）と **App Store Connect の商品ID**（M-011）を
   実値化。`project.yml`／`.storekit`／`SubscriptionIDs` の該当箇所を一括差し替え。
4. **契約・税・銀行情報**（Paid Apps Agreement）（M-012）。
5. **macOS + Xcode で Archive → Upload**、Sandbox購入/復元の実機確認（M-001／M-013）。
6. **App Store Connect でメタデータ入力**（`docs/APP_STORE_METADATA.md` からコピペ）、
   スクリーンショット添付（6.9"/6.5"、`screenshots.yml`はPro Max優先で撮影）、App Privacy回答、
   年齢レーティング、審査提出。

> それ以外（アイコン、法務サイト、URL配線、メタデータ下書き、バージョン、Privacy Manifest、
> 自動更新、多言語、メディア権利ゲート）はコミット済み・CI green。

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

- **M-020**（コード側完了 / 残：Pages を ON）プライバシー/利用規約/サポートは `docs/site/` に
  実HTMLを生成し、`LegalPage.externalURL` を `https://sunpotflower4460-cpu.github.io/UFO-News-App/…`
  へ配線済み（`ReleaseLinkAudit` は clean）。**人間の操作は Settings → Pages → Source を
  「GitHub Actions」にするのみ**。`pages.yml` が自動デプロイ。将来 独自ドメインにするなら
  `LegalPages.swift` の host を差し替え。
- **M-021** App Privacy（Nutrition Label）回答を`PrivacyInfo.xcprivacy`と一致させる。回答下書きは
  `docs/APP_STORE_METADATA.md` §7（現状は **Data Not Collected**）。
- **M-022**（完了）App Icon（1024pt, RGB, アルファなし）を
  `Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` に生成・配線済み
  （`scripts/generate_app_icon.py` で再生成可）。差し替えたい場合はPNGを置換。
- **M-023** サポート連絡先メールの実アドレス化。`scripts/generate_legal_site.py` の
  `SUPPORT_CONTACT`（暫定 `support@skytrace.app`）を実運用アドレスへ変更し再生成・コミット。

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
