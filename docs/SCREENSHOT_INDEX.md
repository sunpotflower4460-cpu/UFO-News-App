# Screenshot Index

本作業環境（Linux）ではSimulatorを起動できないため、スクリーンショットは未取得。
以下は取得計画と、対応するPreview名／起動導線の一覧。macOSで撮影し`docs/screenshots/`へ保存する（M-002）。

保存規則：`docs/screenshots/<screen>-<appearance>-<size>.png`
例：`today-dark-standard.png`

| # | 画面 | 起動導線 | Preview | Appearance | 備考 |
|---|------|----------|---------|-----------|------|
| 1 | Welcome | 初回起動 | `WelcomeFlow` | Dark | 軌道線アニメ（Reduce Motionで静止） |
| 2 | 今日（Free） | タブ1 | `Today · Free` | Dark/Light | Hero＋Briefing Freeロック |
| 3 | 今日（Plus） | Debugでentitlement=active | `Today · Plus` | Dark | Briefing「続きを読む」 |
| 4 | Daily Briefing 全文 | 今日(Plus)→続きを読む | `BriefingDetailView` | Dark | |
| 5 | Case Detail（Free） | 今日→注目事例 | `Case · Free` | Dark | AI記事のPremiumLock |
| 6 | Case Detail（Plus） | Debug active→事例 | `Case · Plus` | Dark | 4軸スコア＋AI記事全文 |
| 7 | スコア根拠Sheet | Case Detail→スコアタップ | （実機） | Dark | |
| 8 | Paywall | Free→ロック→CTA | `Paywall` | Dark | 月/年、実質月額、無料体験 |
| 9 | 地図 | タブ2 | `Map` | Dark | クラスタ＋精度リング |
| 10 | 地図フィルター | 地図→詳細フィルター | （実機） | Dark | |
| 11 | 探す | タブ3 | `Research` | Dark | 検索・保存・最近 |
| 12 | 検索結果 | 探す→「東京」 | （実機） | Dark | |
| 13 | 設定 | タブ4 | `Settings` | Dark/Light | 購読/復元/Debug |
| 14 | 方針ページ | 設定→スコアの読み方 | `LegalPageView` | Dark | |
| 15 | 状態プレビュー | 設定Debug→Empty/Error/Offline | State `#Preview` | Dark | |

## App Store用スクリーンショットのストーリー（UI_UX_PLAN 19.2）
1. 今日、世界の空で報告されたこと
2. 複数の報告を、一つの事象へ統合
3. 航空・衛星・天文データと照合
4. 分かっていることと、残る謎を分けて表示
5. AI統合記事で深く読む
6. 後日の更新まで追跡
