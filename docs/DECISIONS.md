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

## V3 UI/UX
- **D-V3-001 Evidence と Sources の役割分離（P0-05）**: 専用の証拠データがfixtureに無いため、`EvidenceItem` を「記録性のある出典（official/scientific/database/openData）」から導出し、Evidence節は"記録"（種別＋記録日）として表示、Sources節は引用一覧のまま。press/socialは引用のみ。両節が同じ `SourceRow` を二重表示する重複を解消。実データ接続時はEvidenceを直接投入する。
- **D-V3-002 通知トグルの権限連動（P0-09）**: ローカル`@AppStorage`のみだったトグルを`UNUserNotificationCenter`の実権限（未設定/拒否/許可）に連動。未設定は要求ボタン、拒否はシステム設定導線、許可時のみ個別トグル。

## 自動更新（Auto-refresh）
- **D-AR-001 クライアント側自動更新エンジンを先行実装**: `DataRefreshController`（`generation`カウンタ＋`lastRefreshed`）を導入し、各画面は`.task(id: generation)`で購読。フォアグラウンド復帰（`scenePhase == .active`）で即時更新＋一定間隔ポーリング（既定5分、`AppSettings.refreshInterval`）、全タブに`.refreshable`（Todayは既存）。ポーリングはLow Power Mode／UIテスト時は停止、Settingsでオン/オフ・間隔を変更可。
  - **依存**: 実際に「新しいニュースが来る」には実データ源が必要。現状は全てfixtureで、`AppEnvironment.rebuildRepositories()`の`.localAPI`分岐は未実装（fixtureへfallback）。エンジンはこのRepository seamに配線済みで、Phase 2でURLSessionベースのFeed/Case APIが入れば自動で実データに反映される。プッシュ通知配信（APNs）はさらに後段（別途）。
  - **設計理由**: 「完全自動更新」の体験をクライアント側で完成させ、バックエンド未実装でも決定的にfixtureで検証可能にするため。Repository抽象（D-008）に依存し、輸送手段に非依存。

## ソース画像・映像（Case Media）
- **D-MEDIA-001 権利ゲート＋リンクアウト方式**: 各Caseに `MediaAsset`（`kind`/`rights`/`sourceID`/`sourceURL`/`mediaURL?`/attribution/license）を導入。**権利が確認できた素材（public domain / official / Creative Commons / licensed）のみをインライン表示**し、`rights_unknown` は**情報源へのリンクのみ**（ホスティング・再配布しない）。CLAUDE.md §7・D-007 に準拠、著作権とApp Store 5.2への配慮。
  - ユーザー要望「毎回可能な限りソースのUFO画像・映像を掲載」に対し、**許諾できる範囲で毎回最大限表示**しつつ、権利未確認は必ずリンクアウトにするという解で実現。無断スクレイピング・無断ホスティングは行わない。
  - **依存**: 実際のメディアURLはPhase 2バックエンド＋実ソース接続が前提。現状はfixtureで `mediaURL=nil`（許諾済み素材は抽象 `ObservationGlyph` プレースホルダ、リンクは常時）。バックエンド接続時に実URLを流し込めば自動でインライン表示。
  - **UI**: Case Detail に「映像・画像」セクション（`CaseSection.media`、内容がある時のみ表示）。`CaseMediaSection`/`MediaAssetView`。権利バッジ・クレジット表記・情報源リンクを常に併記。

## 多言語対応（i18n）
- **D-I18N-001 Apple String Catalog へ移行（B1）**: 実CI（Xcode）が使えるため D-006 を実行。`SkyStrings` のコード内 `Pair` 表を撤去し `Localizable.xcstrings` を正本化。`SkyStrings.t` は `NSLocalizedString`＋`String(format:locale:)` で解決（公開APIは不変、約330呼び出し箇所は無変更）。以後の文字列追加はカタログを直接編集（`scripts/build_xcstrings.py` は旧表からの一括移行用の一度きりツール）。対応言語は ja/en に加え es/fr/de/pt-PT/zh-Hans/zh-Hant/ko/ar/hi/ru を宣言。未翻訳は当面 ja へフォールバック。
- **D-I18N-002 複数形・直書き修正（B2）**: 件数系（`label.sources`/`research.resultCount`）を String Catalog の複数形バリエーション（`.stringsdict`、`%lld`）へ変更し、呼び出し側は Int を渡す。直書きだった共有文言（`share.caseText`）とウィジェット文言（`widget.counts`）をカタログ経由に統一。数値は `locale:` 付きで整形。
- **残（B3）**: es/fr/de/pt · zh-Hans/zh-Hant/ko · ar/hi/ru の UI 翻訳草案（ネイティブレビュー推奨）と、アラビア語の RTL 検証。長文（LegalPages）とデモ内容の翻訳は対象外（データ／要専門レビュー）。
