# SkyTrace Decisions Log

矛盾や自律判断を記録する。重大な破壊的変更のみ事前報告。

| ID | 決定 | 理由 | 影響 |
|----|------|------|------|
| D-001 | iOS native SwiftUI / Swift 6 / Xcode 26+ / deployment target iOS 17 | 正本（ARCHITECTURE, CLAUDE.md）に準拠 | Liquid Glassは`if #available`で段階採用 |
| D-002 | 初回リリースはUGC無効。feature flag既定false、`#if DEBUG`のみDebug UI | App Review 1.2の運用負荷回避、審査早期化 | `FeatureFlags`で一元管理、Releaseで到達不能 |
| D-003 | 読むだけならアカウント/位置情報不要 | プライバシー最小化、離脱率改善 | 位置許可を一切要求しない設計 |
| D-004 | Case中心モデル・4軸スコア（単一信頼度を出さない） | 「未解明＝宇宙人」回避、証拠の見え方を保つ | `CaseScores`は4軸固定、`knownPhenomenaMatch`のみ「高い＝説明可能」を明記 |
| D-005 | StoreKit 2をPhase 1へ前倒し（Local Configuration＋Fake provider） | 本番資格情報なしで購入/復元/解放/失効をSimulator確認できる完成体験を作るため（指示書の許可事項） | Phase 6と重複しないよう`SubscriptionProviding`抽象で構造分離。実サーバ検証はPhase 6 |
| D-006 | Phase 1の文字列は`SkyStrings`（コード内ローカライズ表）を実行時の正本とし、`Localizable.xcstrings`は構造サンプルに留める | 本作業環境ではビルド不可のため、キー表示や空UIを避け決定的に日本語/英語を出す必要がある。「View内に文字列直書きしない」意図は集約により満たす | Phase 2でxcstringsへ1:1移行（キーは同一）。移行までは二重管理に注意 |
| D-007 | 画像権利未確定のため`ObservationGlyph`（抽象観測図）を既定ビジュアルに | 権利不明画像を再配布しない。画像なしで成立するデザイン方針 | 記事画像は権利確認後に追加可能な構造 |
| D-008 | 外部ソースは本Phaseで未接続。`SubscriptionProviding`同様にRepository protocolでFixture/API差し替え可能に | API契約待ちで停止しないため | `DataSourceMode`（fixture/localAPI）をDebugで切替、未実装APIはfixtureへ安全fallback |
| D-009 | Xcodeプロジェクトの正本はXcodeGen `project.yml`。加えて`scripts/generate_xcodeproj.py`で直接開ける`.xcodeproj`を生成しコミット | XcodeGenは決定的で信頼性が高い一方、ツール未導入でも開ける利便を両立。本環境ではXcodeで開いた検証ができないため二経路を用意 | どちらか一方を編集した際の同期に注意。ソース追加時は再生成 |
| D-010 | 通知は初回起動時に許可要求しない。ローカルトグルのみ（APNs配線はPhase 7） | 価値説明後に許可を出すApp Store方針 | Settingsのトグルは端末内設定。実許可要求はPhase 7 |
| D-011 | ブックマーク/最近見た項目は`UserDefaults`＋actorで実装（SwiftDataは後続） | Phase 1で確実に動作する最小構成。キャッシュ本格化はPhase 2 | 端末内のみ。同期はアカウント導入後 |
| D-012 | 火球/公式アーカイブのDemo事例は公開過去事例を「安全に抽象化」した架空データとして作成 | 無断転載・権利問題の回避、DEMO明示 | 本番では実データに差し替え、`DEMO`は非表示 |

## 未解決/要ユーザー判断
- 正式アプリ名・Bundle ID・商品ID（現在プレースホルダー`com.example.skytrace.*`）。App Store Connect登録前に一元変更（`project.yml`／`SubscriptionIDs`／`.storekit`）。
