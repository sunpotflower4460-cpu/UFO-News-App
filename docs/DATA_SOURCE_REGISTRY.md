# Data Source Registry

外部情報源の権利・利用条件を一元管理する。`approved` 以外は本番workerが自動取得しない。
Phase 1では全て未接続（fixtureのみ）。この表はPhase 3のSource Registry実装の設計正本。

## 状態の定義
- `approved`：規約・商用/自動取得条件を確認済み、本番有効化可
- `manual_only`：手動入力のみ許可
- `permission_required`：書面許諾/提携が必要（既定無効）
- `prohibited`：利用不可
- `unknown`：未調査（既定無効）

## レジストリ（初期・すべて本番無効）

| Source | 種別 | 例のTier | license/terms | 商用利用 | 自動取得 | 状態 | 備考 |
|--------|------|----------|---------------|----------|----------|------|------|
| AARO（公式公開資料） | official | A | 要確認 | 要確認 | 要確認 | `unknown` | 一次資料。原本リンク必須 |
| NASA / JPL CNEOS Fireball | official/scientific | A | 公開API | 要確認 | 要確認 | `unknown` | 火球照合の候補。API unavailable fixture必須 |
| CelesTrak（TLE） | open_data | A | 利用条件あり | 要確認 | 要確認 | `unknown` | 衛星可視パス計算。TLE鮮度を記録 |
| 各国気象/航空機関 | official | A | 機関ごと | 要確認 | 要確認 | `unknown` | |
| 報道API（契約制） | press | B | 契約 | 契約 | 契約 | `permission_required` | 全文再配布禁止、抜粋のみ |
| RSS明示媒体 | press | B | 媒体ごと | 要確認 | 条件付 | `unknown` | 発見メタデータと権利を分離 |
| NUFORC | database | C | 個別確認 | 要確認 | 要確認 | `permission_required` | adapter skeletonのみ・既定無効 |
| MUFON | database | C | 個別確認 | 要確認 | 要確認 | `permission_required` | adapter skeletonのみ・既定無効 |
| SNS/動画 | social | D | 各規約 | 不可 | 不可 | `manual_only` | 手掛かりのみ、本文/動画を無断再配布しない |

## 原則
- discovery metadata（発見）と publication rights（公開）は分離。
- 無許諾スクレイピング、有料記事本文の再配布、権利不明の画像/動画ホスティングをしない。
- 各Provderは`SourceProvider`インターフェースを実装し、`enabled && approved`のみ本番実行。
- robots/termsは自動判断せず、この表で人間が管理。

## 現状の実装
- iOSは`FixtureCaseRepository`等のみを使用。実ソースProviderは未実装（Phase 3）。
- Demo事例は架空/安全抽象化で、`DEMO`フラグ付き。本番では非表示。
