# SkyTrace プロダクト・システム設計図

最終更新想定：2026-07-13  
対象：iOS App Store初回リリース、およびその後の拡張  
作業名：SkyTrace（名称・Bundle IDは後から一括変更可能にする）

---

## 1. ビジョン

SkyTraceは、世界中で報告されるUAP／UFO関連情報を、ニュース、観測記録、公式資料、航空・衛星・天文・気象データと照合し、読者が「何が分かり、何がまだ分からないか」を追跡できる観測ニュースアプリである。

このプロダクトは、未知を娯楽として消費するだけでも、未知を最初から否定するだけでもない。

目指す立ち位置は次の中間地点である。

- 驚きは残す
- 断定は急がない
- 情報源は隠さない
- 誤りは更新する
- AIを権威化しない
- 不明を不明のまま丁寧に扱う

### 1.1 成功の定義

初回リリース時の成功は、報告数の多さではなく以下で測る。

- 事例の出典をユーザーが追える
- AI記事の根拠と不確実性が見える
- 説明済み事例も価値あるコンテンツとして残る
- 後日更新が版管理される
- サブスクで読む明確な価値がある
- App Store審査に耐える完成度がある

### 1.2 絶対にしないこと

- 地球外起源を確率表示する
- 情報不足を「本物」と表現する
- 証拠のない国家・企業・個人への断定を掲載する
- 権利不明の本文・画像・動画を無断再配布する
- AIが見つけた“それらしい話”を出典なしで混ぜる
- 出典先の規約を無視した大量取得を行う

---

## 2. プロダクト原則

### P1. Provenance First

すべての重要情報は、どの出典・計算・観測から来たか追跡できなければならない。

### P2. Uncertainty Is a Feature

不確実性を隠さず、情報不足、矛盾、推論をUI上で明示する。

### P3. One Event, Many Reports

ニュース記事単位ではなく、「空で起きた一つの事象」を中心に複数報告を束ねる。

### P4. Explain Before Mystify

既知現象との照合を先に行い、それでも残る部分を未解明として示す。

### P5. Version the Truth

記事を上書きして終わらせず、評価がどう変わったかを履歴として保存する。

### P6. Native App Value

単なるWeb記事一覧ではなく、MapKit、通知、オフラインキャッシュ、ブックマーク、StoreKit、アクセシビリティ等のiOSネイティブ価値を持つ。

### P7. Privacy by Default

読むだけならアカウント不要。正確な現在地を要求しない。追跡広告を使わない。

---

## 3. リリース戦略

### Release 1.0：Read / Map / Synthesis / Subscription

- 世界ダイジェスト
- 事例一覧
- 地図
- 事例詳細
- 出典
- 基本照合
- AI統合記事
- サブスク
- 通知
- ローカルブックマーク
- 編集・公開用Admin

### Release 1.1：Evidence Q&A / Better Verification

- 記事内質問
- より詳細な衛星・天文照合
- 訂正通知
- 高度フィルター

### Release 1.2以降：Account / Sync

- Sign in with Apple
- 端末間ブックマーク同期
- ウォッチリスト同期
- アプリ内アカウント削除

### Release 2.0：User Reports

- 撮影・投稿
- GPS、方角、時刻、端末情報の明示的取得
- モデレーション
- 通報、ブロック、削除、問い合わせ
- 近隣観測者通知

初回申請にUGCを入れない理由：

- App Review Guideline 1.2に対応するフィルタ、通報、ブロック、運営対応が必要
- 写真・動画・位置情報のプライバシー設計が増える
- 著作権、個人情報、悪質投稿への運用負荷が大きい
- 閲覧体験と課金価値だけで十分に独立したアプリとして成立する

---

## 4. 情報設計とナビゲーション

初回版のタブは4つを基本とする。

1. **Today**：今日の世界、注目事例、ブリーフィング
2. **Map**：世界地図、クラスタ、フィルター
3. **Research**：過去事例、検索、Plus記事
4. **Settings**：通知、課金、方針、サポート

ブックマークはTodayまたはResearch内のセグメントとして置く。5タブに増やす場合も、画面密度と片手操作を確認してから決める。

### 4.1 Today画面

#### 上部

- 現在の日付
- `Last updated`表示
- 通信状態
- 本日の短い観測コピー

#### 世界概況カード

- 取得した新規ソース数
- 統合事象数
- 説明候補優勢
- 情報不足
- 注目未解決

「世界中のすべてを網羅」と誤認させないため、文言は「取得できた情報源内」とする。

#### Daily Sky Briefing

- Plusユーザー：全文
- Freeユーザー：冒頭と目次、購読導線
- AI生成日時
- 人間レビュー有無
- 使用した事例数と出典数

#### Top Cases

- 3〜5件
- 地域、発生日時、状態、未解明度
- 出典数
- 更新バッジ

### 4.2 Map画面

- MapKit標準地図
- 注目度に応じたピンの大きさは使用可
- 色だけで状態を伝えず、形・ラベル・VoiceOverを併用
- 位置精度は`exact / approximate / region_only / withheld`を持つ
- センシティブな位置は丸める
- ピン密集時はクラスタリング
- タップでBottom Sheet

フィルター：

- 日付範囲
- 状態
- 証拠品質
- 未解明度
- 形状・見え方
- 昼／夜
- 更新あり

### 4.3 Case Detail画面

推奨セクション順：

1. 状態と更新日時
2. 事象概要
3. 4軸スコア
4. 一致している点
5. 食い違う点
6. 既知現象との照合
7. 現時点の判断
8. 情報不足
9. 今後必要な証拠
10. 更新タイムライン
11. 出典
12. 編集・AI方針へのリンク

「スコアだけ見て結論を誤解する」ことを避けるため、各スコアに説明文と`Learn more`を付ける。

### 4.4 Research画面

Free：

- 基本検索
- 直近事例
- 状態フィルター

Plus：

- 高度フィルター
- AI統合記事全文
- 類似事例
- 期間比較
- 更新履歴

### 4.5 Paywall

Paywallは煽らない。

表示要件：

- 何が解放されるか
- 月額／年額
- 請求期間
- 自動更新
- 無料体験がある場合の終了後価格
- 購入を復元
- 利用規約
- プライバシーポリシー
- Appleの購読管理への導線

初回起動直後に全画面Paywallを出さない。ユーザーが無料価値を体験した後、Plus記事を開いたタイミングで提示する。

---

## 5. ビジュアルデザイン

### 5.1 世界観

「宇宙観測所 × 科学ニュース × 静かな未来感」。

避ける：

- 安っぽい緑色の宇宙人
- 点滅過多
- 赤い警告ばかりの陰謀論的表現
- 画面全体に強いグロー
- 本文の可読性を落とす星空背景

### 5.2 カラー役割

具体的な色値は実装時にアクセシビリティ検証する。

- Background：深い青黒
- Surface：わずかに明るい観測パネル
- Primary：淡いシアン
- Accent：紫〜青のスペクトル
- Caution：アンバー
- Explained：緑寄り。ただし色だけに依存しない
- Disputed：赤寄り。ただし恐怖表現にしない

### 5.3 タイポグラフィ

- SF Pro / system font
- Dynamic Type完全対応
- 本文最小サイズを固定しない
- 数値カードは等幅数字を適用してよい
- 長文記事は行間を広めにする

### 5.4 モーション

- 地図やスコア更新に短い移行
- Reduce Motion時は縮退
- 常時回転・点滅はしない
- 重要情報の読解を妨げない

### 5.5 iOS 26対応

- Xcode 26 / iOS 26 SDKでビルド
- iOS 26の新しい外観は`if #available(iOS 26, *)`で段階利用
- 最低対応をiOS 17に保ち、主要機能をOS限定にしない
- Liquid Glass的表現を採用する場合も可読性とコントラストを優先

---

## 6. ドメインモデル

### 6.1 Case

同一の空の事象を表す中心エンティティ。

主な属性：

```text
id
slug
title
summary
occurred_at_start
occurred_at_end
published_at
last_verified_at
latitude
longitude
location_precision
country_code
region_name
locality_name
status
visibility
source_count
report_count
evidence_quality_score
independence_score
known_phenomena_match_score
unresolvedness_score
priority_score
human_review_status
created_at
updated_at
```

### 6.2 Report

目撃者記録、公式報告、ニュース内の目撃記述など、一つの報告単位。

```text
id
case_id
source_document_id
reporter_type
reported_at
occurred_at
location_text
normalized_location
observation_direction
estimated_duration_seconds
object_count
shape_tags
color_tags
motion_tags
sound_reported
raw_excerpt
language
independence_group_id
```

### 6.3 Source

媒体・組織・データ提供者。

```text
id
name
source_type
officiality_tier
homepage_url
terms_url
license_status
commercial_use_status
automation_permission
attribution_requirement
robots_checked_at
reviewed_at
notes
```

### 6.4 SourceDocument

個別記事、PDF、公開ページ、データレコード。

```text
id
source_id
canonical_url
external_id
title
author
published_at
retrieved_at
language
content_hash
raw_storage_key
allowed_excerpt
rights_status
metadata_json
```

### 6.5 Claim

文書から抽出した検証可能な主張。

```text
id
case_id
claim_type
normalized_text
subject
predicate
object
certainty
origin
created_by_model
review_status
```

### 6.6 EvidenceLink

主張と出典、計算結果を結ぶ。

```text
id
claim_id
source_document_id
verification_run_id
support_type  # supports / contradicts / contextualizes
quote_locator
confidence
```

### 6.7 VerificationRun

航空、衛星、火球、天文、天候、画像等の照合実行。

```text
id
case_id
provider
verification_type
input_snapshot
result_json
result_summary
match_score
status
started_at
completed_at
algorithm_version
```

### 6.8 ExplanationCandidate

```text
id
case_id
category
label
match_score
supporting_evidence_count
contradicting_evidence_count
limitations
status
```

### 6.9 ArticleVersion

AI統合記事の版。

```text
id
case_id
version_number
headline
lead
body_blocks_json
source_document_ids
claim_ids
model_provider
model_name
prompt_version
quality_gate_result
human_review_status
published_at
supersedes_version_id
correction_note
```

### 6.10 DailyBriefing

```text
id
briefing_date
locale
headline
summary
body_blocks_json
case_ids
source_document_ids
model_metadata
human_review_status
published_at
```

### 6.11 User-local entities

初回版では端末内：

- Bookmark
- ReadState
- NotificationPreference
- FilterPreset

クラウドアカウント導入後に同期モデルを追加する。

---

## 7. 状態遷移

### 7.1 Case pipeline

```text
discovered
  -> normalized
  -> cluster_candidate
  -> clustered
  -> verification_pending
  -> verifying
  -> draft_ready
  -> review_needed | auto_publishable
  -> published
  -> updated
  -> explained | notable_unresolved | disputed | withdrawn
  -> archived
```

### 7.2 公開条件

最低公開条件：

- 一意のCase ID
- 発生日時または「不明」の明示
- 地域または「不明」の明示
- 少なくとも1つの利用可能な出典
- 出典の取得日時
- 権利状態が公開可能
- AI記事の場合、引用整合性ゲート通過
- 個人情報・名誉毀損チェック通過

### 7.3 自動公開禁止条件

- 高い社会的影響がある断定
- 軍・政府・個人の不正を示唆
- 出典がSNS一件のみ
- 動画の真偽に重大な疑義
- 位置や個人情報がセンシティブ
- AI監査が不合格
- 出典間の重大矛盾

---

## 8. 情報源戦略

### 8.1 Tier A：公的・一次資料

候補：

- AARO公式公開資料
- NASA公開資料・CNEOS火球データ
- 各国の航空・気象・宇宙機関
- 公開レーダー・事故・打ち上げ情報

利用方針：

- 原則として最優先
- 文書更新を監視
- PDFや動画はメタデータと要約を保存
- 原本リンクを必ず表示

### 8.2 Tier B：報道

- 正式契約したニュースAPI
- RSS配信を明示している媒体
- GDELT等の発見用メタデータ

全文の無断保存・再配布はしない。取得できる範囲をライセンスに合わせる。

### 8.3 Tier C：専門データベース

NUFORC、MUFON等。

- 規約を個別確認
- 自動取得・商用要約の書面許可がない場合は本番無効
- 許可取得までは手動入力またはfixtureのみ
- Source Registryに契約状態を保存

### 8.4 Tier D：SNS・動画

初回版では自動取得を中核にしない。

利用する場合：

- 公開URLと投稿メタデータを手掛かりとして保存
- 投稿本文や動画を無断再配布しない
- 位置、顔、車両番号等を公開しない
- 転載元をたどり、原投稿を優先

### 8.5 Provider Adapter

すべての外部ソースは以下のインターフェースを実装する。

```python
class SourceProvider(Protocol):
    name: str
    async def discover(self, window: TimeWindow) -> list[DiscoveredItem]: ...
    async def fetch(self, item: DiscoveredItem) -> RawDocument: ...
    def rights_policy(self) -> RightsPolicy: ...
    def attribution(self) -> AttributionRule: ...
```

本番環境では`enabled=true`かつ権利状態が承認済みのProviderだけを実行する。

---

## 9. 既知現象との照合

### 9.1 航空機

Provider抽象：

```python
class FlightVerificationProvider(Protocol):
    async def nearby_traffic(
        self,
        occurred_at: datetime,
        lat: float,
        lon: float,
        radius_km: float,
        window_minutes: int,
    ) -> list[FlightTrack]: ...
```

開発時：fixture。  
本番：利用規約と商用条件を確認した航空データProvider。

「一致なし」は、利用したデータ内に一致が見つからないことだけを意味する。

### 9.2 人工衛星

- CelesTrak等の公開軌道要素
- SGP4で観測地点からの方位・高度・可視性を計算
- Starlink列、ISS、衛星フレア候補
- TLEの取得時刻と鮮度を保存

### 9.3 火球・流星

- NASA/JPL CNEOS Fireball API等
- 地域・時刻窓で照合
- データが後日更新される可能性を記録

### 9.4 天体

- JPL ephemeris / Skyfield等で惑星、月、明るい恒星の方位・高度
- 観測時刻と地点に対して計算
- 金星、木星、シリウス等の誤認候補

### 9.5 気象

- 雲量、雷、視程、風、降水
- サーチライト反射、レンズ内結露等の文脈
- 世界対応Providerを差し替え可能にする

### 9.6 ロケット・再突入

- 公開打ち上げ情報
- 再突入予測・報告
- ロケット雲、燃料放出等

### 9.7 画像・動画

初回版は限定的。

- ファイルハッシュ
- メタデータ有無
- 再エンコード検知
- フレーム時間の不自然さ
- 既知の転載検索は手動支援

AI画像判定を「真偽判定」として単独使用しない。

---

## 10. クラスタリング

目的：同一事象を扱う複数記事・報告を一つに束ねる。

### 10.1 候補生成

- 時刻差：基本±30分、内容により可変
- 距離：基本100km以内、超高高度現象は拡大
- 地名一致
- 形状・色・移動方向
- 記事タイトルと本文埋め込み類似度
- 同一動画URL、同一ハッシュ

### 10.2 独立性判定

複数記事が同一の通信社記事を転載している場合、独立報告は1と数える。

`independence_group_id`で、以下を同じグループにまとめる。

- 同一原稿の転載
- 同一SNS投稿の引用
- 同一動画の再投稿
- 同一発表資料の二次記事

### 10.3 人間レビュー

次のケースはAdminで統合・分離できる。

- 時刻が近いが別地域
- 広域で見えるロケット・火球
- 同じ動画が別日として拡散
- 一つの報道が複数現象を扱う

Case merge/splitは監査ログを残す。

---

## 11. スコアリング

スコアは0〜100。バージョン管理する。

### 11.1 Evidence Quality

例：

- 元ファイル：+20
- 撮影時刻が検証可能：+15
- 位置・方角：+15
- 連続映像30秒以上：+10
- 複数センサー／異なる角度：+20
- 強い圧縮・切り抜きのみ：-15
- 出典不明転載：-30

### 11.2 Independence

- 独立地点2件：上昇
- 3件以上：さらに上昇
- 同一投稿の転載：増加なし
- 証言が事前に相互影響した可能性：減点

### 11.3 Known Phenomena Match

各説明候補の最大値または重み付き集約。

- 時刻一致
- 方角一致
- 角速度一致
- 色・点滅一致
- 高度・軌道一致
- 気象条件一致

### 11.4 Unresolvedness

単純に`100 - known_match`にしない。

情報不足で説明できないだけの場合は、未解明度より`insufficient_data`を強くする。

推奨概念式：

```text
unresolvedness =
  residual_anomaly_strength
  * evidence_reliability_factor
  * data_completeness_factor
  - contradiction_penalty
```

十分な証拠がない場合、高得点になりにくい。

### 11.5 Priority Score

内部ランキング用。ユーザーへ必ずしも表示しない。

```text
priority =
  0.30 * evidence_quality
+ 0.25 * independence
+ 0.25 * unresolvedness
+ 0.10 * recency
+ 0.10 * public_interest
- rights_risk_penalty
- privacy_risk_penalty
```

### 11.6 バージョン

`scoring_algorithm_version`を全Caseに保存。式変更時に再計算し、旧値も履歴に残す。

---

## 12. AI統合記事

### 12.1 AIの役割

AIが行う：

- 記事分類
- 翻訳
- 主張抽出
- 同一事象候補判定
- 一致点・矛盾点抽出
- 構造化記事生成
- 見出し生成
- 引用整合性監査
- 過度な断定の検知

AIに任せない：

- 地球外起源の断定
- 重大な公開判断の最終決定
- 出典にない事実の補完
- 権利判断
- 個人情報公開判断

### 12.2 記事JSON

LLMは直接Markdown全文を返すのではなく、次のような構造化形式を返す。

```json
{
  "headline": "北海道東部で報告された3つの発光体",
  "dek": "複数地点の報告を統合し、衛星・航空情報と照合した。",
  "blocks": [
    {
      "type": "fact_paragraph",
      "text": "...",
      "claim_ids": ["clm_1", "clm_4"],
      "source_ids": ["srcdoc_2", "srcdoc_8"]
    },
    {
      "type": "inference",
      "text": "...",
      "claim_ids": ["clm_9"],
      "confidence": 0.62
    },
    {
      "type": "unknown",
      "text": "物体の高度は確認できていない。",
      "missing_fields": ["altitude"]
    }
  ]
}
```

### 12.3 Quality Gates

公開前に機械検査：

- 全fact文にclaim IDがある
- claimに少なくとも1つのEvidenceLinkがある
- source documentが公開可能
- 数字・日時・場所がソースと一致
- 引用語数制限を超えていない
- 「宇宙船」「異星人」「政府が隠蔽」等の断定語を検査
- 人名・住所・車両番号等を検査
- 他事例の情報混入を検査

### 12.4 Prompt Versioning

- system prompt
- extraction prompt
- synthesis prompt
- audit prompt

をファイル管理し、`prompt_version`を保存する。

### 12.5 Human-in-the-loop

自動公開可能：

- 公的資料の更新要約
- 説明済み事例
- 低リスクの短いブリーフ

人間レビュー必須：

- 高未解明度
- 軍事・政府関連
- 実名個人が登場
- 重大な安全上の主張
- 一次資料が少ない
- 急速に拡散中

### 12.6 AIへの質問

第2段階。

- Case内のclaims/evidenceだけを検索対象にする
- Webを自由検索させない
- 回答ごとに出典を付ける
- 不明な場合は不明と答える
- レート制限とPlus entitlementを適用

---

## 13. システムアーキテクチャ

```text
[Official / Licensed / Open Sources]
             |
             v
      [Ingestion Workers]
             |
             v
 [Normalize / Deduplicate / Rights Gate]
             |
             v
 [Cluster Engine] -> [Case Store]
             |
             v
 [Verification Providers]
             |
             v
 [Claims + Evidence Graph]
             |
             v
 [LLM Synthesis + Audit]
             |
             v
     [Editorial Admin]
             |
             v
        [Public API]
             |
       +-----+------+
       |            |
    [iOS App]   [Notification Worker]
```

### 13.1 Monorepo

- iOS、API、Worker、Admin、契約、fixtureを一つのリポジトリに置く
- OpenAPIを契約の正本にする
- 共通fixtureでAPIとiOS UIをテスト

### 13.2 API

推奨エンドポイント：

```text
GET  /v1/feed/today
GET  /v1/cases
GET  /v1/cases/{id}
GET  /v1/cases/{id}/article
GET  /v1/cases/{id}/timeline
GET  /v1/briefings/{date}
GET  /v1/map/cases
POST /v1/entitlements/verify
POST /v1/device/notifications
DELETE /v1/device/notifications/{token}
GET  /v1/config
GET  /health
```

Admin：

```text
POST /admin/sources/sync
POST /admin/cases/{id}/merge
POST /admin/cases/{id}/split
POST /admin/cases/{id}/verify
POST /admin/articles/{id}/publish
POST /admin/articles/{id}/correct
```

### 13.3 APIレスポンス

- ISO 8601 UTC
- ローカライズ可能なraw codeと表示文を分離
- `updated_at`と`etag`
- pagination cursor
- `data_version`
- `scoring_version`

### 13.4 キャッシュ

- Today：短いTTL
- Case detail：ETag対応
- Article version：immutable URLまたはversion指定
- iOS：SwiftDataへ最後の成功レスポンスを保存
- オフライン時は「最終取得時刻」を表示

---

## 14. iOSアーキテクチャ

### 14.1 レイヤー

```text
App
├── DesignSystem
├── Features
│   ├── Today
│   ├── Map
│   ├── CaseDetail
│   ├── Research
│   ├── Paywall
│   └── Settings
├── Domain
│   ├── Models
│   ├── Repositories
│   └── UseCases
├── Data
│   ├── API
│   ├── Persistence
│   └── Mappers
├── Services
│   ├── Subscription
│   ├── Notifications
│   ├── Analytics
│   └── FeatureFlags
└── Resources
```

### 14.2 State Management

- `@Observable` ViewModel
- async use cases
- Repository protocol
- PreviewとテストでMock Repository注入
- ViewからURLSessionやStoreKitを直接呼ばない

### 14.3 Navigation

- `NavigationStack`
- Deep Link：Case ID、Briefing date
- 通知タップからCaseへ遷移

### 14.4 Error UX

- 通信失敗：キャッシュを表示し、更新ボタン
- 空状態：原因を説明
- 404：事例が統合・非公開になった可能性を表示
- 課金失敗：Appleのエラーを簡潔に説明
- 記事未生成：短い概要へフォールバック

### 14.5 Feature Flags

```text
ugc_submission_enabled = false
ai_qa_enabled = false
cloud_account_enabled = false
research_export_enabled = false
```

Remote configが落ちても、安全側のデフォルトを使う。

---

## 15. Subscription Architecture

### 15.1 StoreKit 2

- `Product.products(for:)`
- `SubscriptionStoreView`または独自UI＋StoreKit metadata
- `Transaction.updates`監視
- `Transaction.currentEntitlements`
- `AppStore.sync()`で復元
- ローカルStoreKit Configurationで開発

### 15.2 Entitlement

```text
free
plus_active
plus_grace_period
plus_billing_retry
plus_expired
plus_revoked
```

UIは一時的なネットワーク障害で即座にロックしない。

### 15.3 Server Verification

- iOSから署名済みTransaction情報を送信
- BackendでJWS検証
- App Store Server APIで必要に応じ状態確認
- App Store Server Notifications V2で更新
- Webhookは冪等処理
- original transaction IDを平文ログに過剰露出しない

### 15.4 購読導線

- restore purchases
- manage subscriptions
- terms/privacy
- 価格・期間・自動更新説明
- キャンセル後も有効期限まで利用可能
- billing retry / grace periodを考慮

### 15.5 App Review

- Sandboxで商品が取得できる状態
- Review Notesに購読導線を記載
- Plus記事への到達手順を明示
- 有料機能が空データにならないよう審査用公開記事を用意

---

## 16. Notifications

初回起動時に許可を求めない。

価値を示した後、以下を選ばせる。

- 毎日のブリーフィング
- 自分の地域周辺
- 高未解明度
- ブックマーク事例の更新
- 公式資料の新規公開

正確な現在地なしでも、国・都道府県等を手動選択できる。

通知payload：

```json
{
  "type": "case_update",
  "case_id": "case_123",
  "article_version": 4
}
```

デバイストークンは暗号化通信し、削除導線を持つ。

---

## 17. Admin Console

### 17.1 必須機能

- Source Registry
- Ingestion job status
- Raw document preview
- Duplicate candidate review
- Case merge / split
- Verification results
- Claims and evidence viewer
- Article draft diff
- Publish / schedule / retract
- Correction note
- Feature flags
- Push notification composer
- Audit log

### 17.2 ロール

- Admin
- Editor
- Analyst
- Viewer

最初は一人運用でもRBACをデータモデル上は持つ。

### 17.3 公開事故防止

- 本番公開は確認ダイアログ
- 高リスク記事は2段階承認可能
- 取り下げても監査履歴を消さない
- 削除と非公開を分ける

---

## 18. セキュリティ

### 18.1 Mobile

- 秘密情報をBundleへ入れない
- KeychainにインストールID等を保存
- ATS準拠HTTPS
- ログへ個人情報・購入情報を出さない
- jailbreak検知を必須にしない
- 証明書ピンニングは運用コストを考え、初回必須にしない

### 18.2 Backend

- 最小権限
- Secret Manager
- rate limiting
- input validation
- SSRF対策
- URL fetch allowlist / safe fetcher
- file size/type limits
- malware scan（UGC導入時）
- admin MFA
- audit log
- backups

### 18.3 AI Security

外部記事内の命令をLLM命令として扱わない。

- ソース本文はuntrusted data
- prompt injectionを無効化する区切り
- tool use allowlist
- URL fetchをLLMへ直接許可しない
- 出力schema validation
- max token / rate limits

---

## 19. プライバシー

### 19.1 初回版の最小化

- アカウント不要
- 正確な位置情報不要
- 広告ID不要
- 追跡広告なし
- 連絡先・写真ライブラリ・マイク不要
- 通知tokenは通知目的のみ
- クラッシュ情報は最小限

### 19.2 必要文書

- Privacy Policy
- Terms of Use
- Editorial Policy
- AI Use Policy
- Data Sources and Licensing
- Contact / Support
- Correction Policy

### 19.3 App Privacy

実装済みSDKを棚卸しし、App Store ConnectのPrivacy Nutrition Labelと一致させる。

Privacy Manifest：

- アプリ本体
- 利用する第三者SDK
- Required Reason API

XcodeのPrivacy Reportを提出前に確認する。

### 19.4 アカウント導入時

- Sign in with Apple
- アプリ内アカウント削除
- 削除対象と法的保管対象を明記
- Appleアカウント変更通知への対応

---

## 20. 著作権・編集方針

### 20.1 記事利用

保存対象：

- タイトル
- URL
- 発行元
- 著者
- 公開日時
- 許可された短い抜粋
- 自社独自要約
- 構造化した主張

原則保存しない／公開しない：

- 記事全文
- 有料記事本文
- 無許諾の写真・動画

### 20.2 引用

- 必要最小限
- 出典明示
- 自社記事が主、引用が従
- ソースごとの語数上限を設定可能にする

### 20.3 訂正

- 訂正日時
- 変更前の要旨
- 変更理由
- 新しい出典
- 重大訂正は通知可能

---

## 21. App Store Review設計

### 21.1 現行提出環境

2026-04-28以降、App Store ConnectへアップロードするiOSアプリはXcode 26以上かつiOS 26 SDK以上でビルドする。

### 21.2 最低機能

単なるリンク集と見なされないよう、以下を完成させる。

- ネイティブ地図
- 状態・スコアUI
- オフラインキャッシュ
- ブックマーク
- 通知
- 更新タイムライン
- StoreKit購読
- 深いCase Detail

### 21.3 サブスク

- デジタルコンテンツはIn-App Purchase
- 価格、期間、自動更新を明示
- 復元
- 利用規約、プライバシー
- 有料価値を継続提供

### 21.4 UGC

初回版では無効。将来有効化時は：

- 不適切投稿フィルター
- 通報
- ブロック
- 運営連絡先
- 迅速な対応
- 利用規約への同意
- 写真・動画・位置情報の同意

### 21.5 サポート

- Support URL
- Privacy URL
- 利用規約URL
- アプリ内問い合わせ
- すべてのリンクを提出前に自動チェック

### 21.6 Review Notes

説明する内容：

- UAPは未確認現象を意味し、地球外起源を断定しない
- スコアの意味
- AI生成箇所と出典表示
- Plus記事の開き方
- Sandbox購読テスト手順
- 投稿機能は無効であること
- 位置情報を常時利用しないこと

---

## 22. Observability

### 22.1 Metrics

- provider success rate
- documents discovered / ingested
- duplicate ratio
- cluster confidence
- verification latency
- AI generation failure rate
- citation gate failure rate
- publication delay
- API latency/error rate
- paywall conversion
- restore purchase success
- crash-free sessions

### 22.2 Logs

- request ID
- job ID
- case ID
- provider name
- algorithm version

本文や個人情報をそのままログへ出さない。

### 22.3 Alerts

- ingestion停止
- daily briefing未生成
- API error spike
- subscription webhook failure
- source terms status expired
- public article missing citation

---

## 23. テスト戦略

### 23.1 Backend

- domain unit tests
- provider contract tests
- clustering golden tests
- scoring golden tests
- rights gate tests
- AI schema tests
- citation gate tests
- API integration tests
- migration tests

### 23.2 iOS

- Repository tests
- ViewModel tests
- subscription state tests
- decoding tests
- offline cache tests
- deep link tests
- Dynamic Type screenshots
- VoiceOver labels
- UI tests for core flow

### 23.3 StoreKit

- purchase success
- user cancellation
- pending
- failed
- restore
- expiration
- grace period
- billing retry
- revoke/refund

### 23.4 App Store smoke test

- fresh install
- no network
- slow network
- API empty
- notification denied
- subscription unavailable
- dark/light mode
- largest Dynamic Type
- Japanese locale
- device rotation if supported

---

## 24. デモデータ

外部接続なしで完成形を確認するため、以下をfixtureとして持つ。

1. Starlinkで説明可能な事例
2. 航空機の灯火らしい事例
3. 情報不足の一件報告
4. 複数地点からの注目未解決事例
5. 後日、火球と判明した事例
6. 出典間で時刻が矛盾する事例
7. 取り下げられた転載動画
8. AARO等の公式過去事例

架空データには明確に`DEMO`フラグを付け、本番で表示しない。

---

## 25. 配備

### 25.1 開発

- Docker Compose
- Postgres/PostGIS
- Redis
- Local object storage
- Mock providers
- StoreKit local config

### 25.2 Staging

- 本番と同じコンテナ
- Sandbox StoreKit
- テスト通知
- 非公開Admin
- デモと少量実データ

### 25.3 Production

- Managed Postgres
- Managed Redisまたは軽量キュー
- Container hosting
- Object storage
- Secret manager
- CDN
- Backup / point-in-time recovery

特定クラウドへ強く依存しない。

---

## 26. コスト制御

- 同一記事をユーザーごとに生成しない
- Daily briefingとCase articleを一度生成し保存
- 軽量モデルで分類・抽出
- 高性能モデルは注目記事の最終統合のみ
- 埋め込みをキャッシュ
- 記事更新がない場合は再生成しない
- AI Q&AはPlusかつ回数制限
- 地図は必要範囲のみ取得

---

## 27. KPI

### Product

- Daily briefing open rate
- Case detail depth
- source link open rate
- updated-case revisit rate
- bookmark rate
- notification opt-in

### Subscription

- paywall view to trial/purchase
- month 1 retention
- annual share
- cancellation reason

### Trust

- citation correction rate
- AI factual error rate
- source complaint count
- unresolved cases later explained
- editorial response time

クリック率だけを最大化し、誇張が増える状態を成功としない。

---

## 28. 将来拡張

- ユーザー撮影モード
- 方角・仰角ガイド
- 複数地点三角測量
- Apple Watchコンパス補助
- ARで星・衛星・航空機候補表示
- 研究者向けexport
- 類似事例クラスタ
- 世界の観測所／天文台との提携
- 目撃後の近隣通知
- iPad分析画面

---

## 29. 重要な設計判断

1. **iOSネイティブ**：App Store品質、MapKit、StoreKit、通知、アクセシビリティを最大化するため
2. **初回UGCなし**：審査・安全・運用を守り、完成を早めるため
3. **アカウントなしで閲覧可**：プライバシーと離脱率を改善するため
4. **AIはサーバー側**：秘密情報、安全、モデル差し替え、監査のため
5. **記事よりCaseが中心**：重複ニュースを一つの現象へ統合するため
6. **単一の真偽スコアを使わない**：証拠品質と未解明度を混同しないため
7. **外部ソースをAdapter化**：契約・規約変更に耐えるため
8. **モックで完成UIを先に作る**：API契約待ちでもClaude Codeが停止しないため

---

## 30. 公式確認先

実装・提出直前に必ず最新版を確認する。

- Apple App Review Guidelines
- Apple Upcoming Requirements
- StoreKit / StoreKit 2 Documentation
- App Store Server API
- App Store Server Notifications
- App Privacy Details
- Privacy Manifest Documentation
- Offering Account Deletion in Your App
- Sign in with Apple Human Interface Guidelines

この設計図の要件よりAppleの最新公式要件を優先する。ただし変更内容は`docs/DECISIONS.md`に記録する。
