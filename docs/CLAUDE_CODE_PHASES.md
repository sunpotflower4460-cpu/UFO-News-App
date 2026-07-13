# Claude Code 段階実装指示書

対象：SkyTrace（仮称）  
目的：Claude Codeが、外部APIやApp Store資格情報が未準備でも止まらず、ユーザーがiPhone Simulator上で完成像を確認できるところまで一気に実装し、その後に実データ・AI・課金・申請準備を段階的に完成させる。

---

## 0. Claude Codeへ最初に渡すマスタープロンプト

以下をClaude Codeの最初の指示として使用する。

```text
このリポジトリは、iOS App Store公開を目指すUAP観測ニュースアプリ「SkyTrace（仮称）」です。

最初に必ず以下を順番に読んでください。
1. README.md
2. docs/ARCHITECTURE.md
3. docs/CLAUDE_CODE_PHASES.md
4. CLAUDE.md

目的は、単なる試作品ではなく、可能な範囲を自律的に実装し、iPhone Simulatorで完成形の主要体験を確認でき、後から実データ・AI・StoreKit本番設定へ差し替えられる状態にすることです。

重要原則：
- iOSはSwiftUIによるネイティブ実装とする。
- App Store提出はXcode 26以上・iOS 26 SDK以上を前提とし、最低対応OSは原則iOS 17とする。
- 初回App Store版ではUGC投稿機能を公開しない。
- 外部APIキーがないことを理由に停止しない。Protocol、fixture、mock server、feature flagを作り、完成UIまで進める。
- AI、DB、外部サービスの秘密鍵をiOSへ入れない。
- 記事単位ではなくCase単位でデータを統合する。
- 「未解明＝宇宙人」と扱わない。
- すべてのAI文章はclaim/sourceへ追跡可能にする。
- 規約・ライセンス未確認のサイトをスクレイピングしない。
- StoreKit 2を使用し、ローカルStoreKit Configurationで課金フローを完成させる。
- UIは未来的で美しくするが、可読性とアクセシビリティを優先する。

作業方法：
1. 現状のリポジトリを調査する。
2. docs/PROGRESS.md、docs/DECISIONS.md、docs/MANUAL_ACTIONS.mdを作る。
3. この段階指示書をPhase 0から順に進める。
4. 各Phaseの完了条件を満たしてから次へ進む。
5. 可能なテスト・ビルド・lintを必ず実行する。
6. エラーは回避して先送りせず、原因を直す。
7. 外部資格情報、Apple Developer Portal、契約、実機操作など人間しかできない箇所だけMANUAL_ACTIONS.mdへ記録する。
8. UI確認に必要なデモデータを十分に用意する。
9. 破壊的変更の前に既存コードとgit diffを確認する。
10. ユーザーの明示許可なしにgit push、課金、外部公開、本番データ削除をしない。

まずPhase 0から開始し、外部資格情報なしで実行できるPhaseを可能な限り連続して完成させてください。各Phase終了時にPROGRESS.mdを更新し、最後に「完成したもの」「未完了」「人間の操作が必要なもの」「起動方法」を簡潔に報告してください。
```

---

## 1. 自律実装の基本ルール

### 1.1 進めてよいこと

- ファイル・ディレクトリ作成
- Xcodeプロジェクト作成
- Swift、Python、TypeScript実装
- ローカルDB・fixture・mock実装
- テスト、lint、build
- ローカルStoreKit設定
- Docker Compose
- ドキュメント更新
- ローカルgit commit（リポジトリ方針とユーザー許可がある場合）

### 1.2 勝手に行わないこと

- GitHubへのpush
- App Store Connectへの本番登録・提出
- 有料API契約
- 本番クラウド作成
- 本番DB削除
- 本番通知送信
- 実在サイトの規約違反スクレイピング
- ユーザー投稿機能の本番公開

### 1.3 外部依存で詰まった場合

停止せず、次を実装する。

1. Protocol / Interface
2. Mock implementation
3. fixture
4. environment variable
5. feature flag
6. `MANUAL_ACTIONS.md`の手順
7. 依存が入った後の検証テスト

### 1.4 品質ゲート

各Phaseで最低限：

- ビルド成功
- 既存テストを壊さない
- 新規ロジックにテスト
- 秘密情報をコミットしない
- UIにPreviewまたはfixture導線
- エラー・空状態・読み込み状態を実装
- `PROGRESS.md`更新

---

# Phase 0 — Repository Audit & Foundation

## 目的

リポジトリを安全に整理し、以降の自律実装が迷わない基盤を作る。

## 作業

1. 現在のファイル、git status、README、既存アプリを調査
2. 既存実装がある場合、勝手に全面置換せず再利用可能部分を評価
3. 以下を作成
   - `docs/PROGRESS.md`
   - `docs/DECISIONS.md`
   - `docs/MANUAL_ACTIONS.md`
   - `docs/DATA_SOURCE_REGISTRY.md`
   - `docs/APP_STORE_CHECKLIST.md`
4. `.gitignore`
5. `.env.example`
6. `Makefile`
7. CIの最小構成
8. モノレポのディレクトリ
9. 命名変更を一元管理する設定

## 推奨構成

```text
apps/ios
apps/admin
services/api
services/worker
packages/contracts
packages/fixtures
packages/scoring
infra
scripts
```

## DECISIONSに記録する初期判断

- iOS native SwiftUI
- minimum iOS 17
- build with Xcode 26+
- initial release has no UGC
- no required account
- StoreKit 2
- backend AI only
- provider adapters
- Case-centric model

## 完了条件

- リポジトリ構成が説明できる
- 主要コマンドがMakefileにある
- envの必要項目が一覧化
- 秘密情報がない
- 次Phaseを開始可能

## ユーザー確認ポイント

このPhaseでは外観確認は不要。既存コードを大幅削除する必要がある場合のみ停止して理由を報告する。

---

# Phase 1 — iOS “Finished Experience” with Fixtures

## 目的

実データやAIなしでも、iPhone Simulatorでアプリの完成形を確認できる状態を作る。最重要Phase。

## 技術

- Swift 6
- SwiftUI
- iOS 17 deployment target
- Xcode 26+
- Observation
- SwiftData
- MapKit
- StoreKit 2のinterfaceだけ先に配置

## 1.1 Xcode project

作成：

- `SkyTrace` app target
- `SkyTraceTests`
- `SkyTraceUITests`
- Debug / Staging / Release configuration
- Bundle ID placeholder
- app icon placeholder
- localization Japanese / English structure

第三者ライブラリは必要最小限。UIフレームワークは入れない。

## 1.2 Architecture

```text
SkyTrace/
├── App
├── DesignSystem
├── Domain
├── Data
├── Services
├── Features
├── Resources
└── PreviewContent
```

Repository protocol：

- `FeedRepository`
- `CaseRepository`
- `BriefingRepository`
- `SubscriptionRepository`
- `SettingsRepository`

Fixture implementationとAPI implementationを差し替え可能にする。

## 1.3 Domain models

最低限：

- `UAPCase`
- `CaseStatus`
- `CaseScores`
- `SourceReference`
- `AgreementPoint`
- `ContradictionPoint`
- `ExplanationCandidate`
- `CaseTimelineEntry`
- `DailyBriefing`
- `ArticleBlock`
- `LocationPrecision`

すべて`Codable`, `Identifiable`, `Sendable`を可能な範囲で適用。

## 1.4 Demo fixtures

少なくとも8事例：

1. Starlinkで説明済み
2. 航空機灯火らしい
3. 金星の誤認
4. 情報不足
5. 複数地点の注目未解決
6. 火球と後日判明
7. 出典間に矛盾
8. 取り下げ

世界地図に広く配置し、日本の事例を2件含める。

すべて架空または公式公開過去事例を安全に抽象化し、Demo badgeを付ける。

## 1.5 Design System

作成：

- semantic colors
- typography
- spacing
- corner radius
- shadows/materials
- status badge
- score meter
- source chip
- loading skeleton
- empty state
- error banner
- premium badge
- card styles

要件：

- Light/Dark両対応。ただしDarkを主世界観にする
- Dynamic Type
- VoiceOver
- 色以外でも状態判別
- Reduce Motion
- コントラスト確認

## 1.6 Today

実装：

- header date / last updated
- global summary
- Daily Briefing preview
- top cases
- updates section
- pull to refresh
- offline/demo banner

状態：

- loading
- success
- partial data
- empty
- failure with cache

## 1.7 Map

実装：

- MapKit
- annotations
- clustering
- status filters
- date filters
- bottom sheet
- Case detail navigation
- approximate location rendering

位置情報許可は要求しない。ユーザー現在地ボタンも初回は不要。

## 1.8 Case Detail

実装：

- hero/header
- status
- occurred/published/updated times
- four score cards
- summary
- agreements
- contradictions
- explanation candidates
- current assessment
- missing information
- next evidence needed
- timeline
- sources
- AI disclosure
- bookmark
- share link placeholder

## 1.9 Research

- basic search
- filters
- bookmarked segment
- premium articles area
- paywall trigger

## 1.10 Settings

- notification preference UI（まだローカル）
- display settings
- subscription state
- restore placeholder
- manage subscription placeholder
- privacy / terms / editorial / AI / sources / support
- developer demo controls in Debug only

## 1.11 Preview / UI tests

- 全主要ViewにPreview
- fixture injection
- UI test：Today -> Case -> Source
- UI test：Map -> Case
- UI test：Research -> Paywall
- UI test：Bookmark

## 完了条件

- Simulatorで4タブが動く
- 8事例が表示される
- UIが空の箱ではなく完成アプリに見える
- Mapから詳細へ遷移できる
- PlusロックとPaywallが見える
- オフラインfixtureでクラッシュしない
- Dynamic Type最大付近で主要操作が可能
- unit/UI testが通る

## ユーザー確認ポイント

ここで一度、ユーザーが外観・情報量・世界観を確認できる。Claude Codeはスクリーンショット取得が可能なら主要画面を保存し、`docs/PROGRESS.md`に確認箇所を書く。

---

# Phase 2 — Local Backend, Database, and Contract

## 目的

fixtureだけのアプリから、ローカルAPIとDBを持つ実システムへ移行する。

## 2.1 Backend scaffold

- Python 3.12+
- FastAPI
- Pydantic v2
- SQLAlchemy 2
- Alembic
- PostgreSQL + PostGIS
- pytest
- Ruff
- mypyまたはpyright
- Dockerfile
- Docker Compose

## 2.2 Database

ARCHITECTUREのモデルをmigrationで実装。

最低テーブル：

- sources
- source_documents
- cases
- reports
- claims
- evidence_links
- verification_runs
- explanation_candidates
- article_versions
- daily_briefings
- case_timeline_entries
- audit_logs
- feature_flags

全文検索用index、地理index、日時indexを作る。

## 2.3 OpenAPI

- `/v1/feed/today`
- `/v1/cases`
- `/v1/cases/{id}`
- `/v1/cases/{id}/article`
- `/v1/briefings/{date}`
- `/v1/map/cases`
- `/v1/config`
- `/health`

エラー形式を統一：

```json
{
  "error": {
    "code": "CASE_NOT_FOUND",
    "message": "...",
    "request_id": "..."
  }
}
```

## 2.4 Seed

Phase 1と同じ8事例をDBへseedし、APIが同じ内容を返す。

## 2.5 iOS API integration

- URLSession client
- request timeout
- ETag
- decoding
- SwiftData cache
- fixture/API switch
- Staging config
- graceful fallback

Debug menuでFixture / Local APIを切替可能にする。

## 2.6 Tests

- migration up/down smoke test
- API contract tests
- seed tests
- iOS decoding tests
- API unavailable fallback test

## 完了条件

- `docker compose up`でAPIとDB起動
- seed後にToday/Map/CaseがAPIから表示
- API停止時にキャッシュまたはfixture fallback
- OpenAPI文書が生成
- テストが通る

---

# Phase 3 — Source Registry and Safe Ingestion

## 目的

権利と規約を守る収集基盤を作り、実ソースを少量安全に取り込めるようにする。

## 3.1 Source Registry

各sourceに保存：

- source name
- official URL
- source type
- license/terms URL
- commercial use status
- automated access status
- excerpt limit
- attribution
- review date
- owner approval
- enabled environments

状態：

- `approved`
- `manual_only`
- `permission_required`
- `prohibited`
- `unknown`

`approved`以外を本番workerが自動取得しない。

## 3.2 Provider interface

実装：

- `FixtureSourceProvider`
- `ManualEntryProvider`
- `OfficialFeedProvider`（明示的RSS/JSONのみ）
- `PublicDocumentWatcher`（許可された公的ページ）

NUFORC/MUFON等はAdapter skeletonのみ。既定でdisabled。

## 3.3 Safe fetcher

- allowlist
- timeout
- max response size
- content type check
- redirect limit
- private IP拒否
- robots/termsは自動判断せずRegistryで管理
- retries/backoff
- request identification

## 3.4 Normalization

- canonical URL
- content hash
- language
- UTC dates
- location text
- allowed excerpt
- rights metadata

## 3.5 Deduplication

- canonical URL
- external ID
- content hash
- normalized title
- similarity

## 3.6 Admin source page

- source list
- status
- last sync
- terms review date
- enable/disable
- document preview
- manual import

## 完了条件

- fixture + manual sourceを取り込める
- rights gateを通らない文書が公開されない
- disabled providerは実行されない
- ingestion job履歴が見える
- 本番に無許諾スクレイパーがない

## 人間の操作

`MANUAL_ACTIONS.md`へ：

- 利用したい情報源への許諾確認
- ニュースAPI契約候補
- attribution文言確認

---

# Phase 4 — Clustering, Claims, and Verification Engine

## 目的

複数記事を同一Caseへ束ね、既知現象との照合が可能な証拠構造を作る。

## 4.1 Candidate clustering

段階：

1. time window
2. geospatial window
3. normalized descriptors
4. text similarity
5. source lineage

結果：

- cluster ID
- confidence
- reasons
- ambiguous flag

## 4.2 Independence groups

- syndication origin
- shared video URL
- shared social origin
- same press release

複数記事数と独立報告数を分ける。

## 4.3 Claim extraction

初期はrules + fixture。AI接続前でも動く。

Claim types：

- occurred_time
- location
- object_count
- color
- shape
- direction
- speed_change
- sound
- duration
- witness_count
- official_response

## 4.4 Verification provider interfaces

- flight
- satellite
- fireball
- astronomy
- weather
- launch/reentry

すべてmock providerとgolden fixturesを持つ。

## 4.5 Satellite baseline

可能なら公開軌道要素を使うProviderを実装。ただし利用条件をRegistryへ記録。

- SGP4
- observer lat/lon/time
- azimuth/elevation
- visibility
- TLE age

## 4.6 Astronomy baseline

- bright planets/moon/stars
- direction and altitude

## 4.7 Fireball baseline

公式API Adapter。API unavailable fixtureを必ず用意。

## 4.8 Scoring

- versioned algorithm
- score breakdown
- insufficient data factor
- golden tests

## 4.9 Admin review

- merge/split
- claim edit
- verification rerun
- explanation candidate approve/reject

## 完了条件

- 複数文書がCaseへ統合される
- 独立報告数が転載数と区別される
- 各Caseにclaim/evidenceがある
- mock照合結果から4軸スコアが計算される
- 同じinputで同じ結果
- スコアの理由がUIへ返る

---

# Phase 5 — AI Synthesis and Citation Safety

## 目的

複数情報と検証結果から、出典付きの統合記事を生成する。AI APIなしでもFake providerで完成させる。

## 5.1 LLM abstraction

```python
class LLMProvider(Protocol):
    async def generate_structured(
        self,
        task: str,
        schema: type[BaseModel],
        context: list[ContextBlock],
    ) -> BaseModel: ...
```

実装：

- `FakeLLMProvider`
- `RecordedLLMProvider`
- 実プロバイダー1つ（環境変数がある場合のみ）

モデル名をコードへ固定しすぎない。

## 5.2 Prompt files

- `extract_claims.md`
- `cluster_review.md`
- `case_synthesis.md`
- `daily_briefing.md`
- `citation_audit.md`
- `tone_safety_audit.md`

バージョン番号を持つ。

## 5.3 Structured output

Article blockに：

- block type
- text
- claim IDs
- source IDs
- confidence
- inference flag

## 5.4 Citation gate

失敗条件：

- factにclaimがない
- claimにevidenceがない
- sourceがrights gate不合格
- 数値不一致
- 日付不一致
- 他Case情報混入
- 断定禁止語

## 5.5 Daily Briefing

入力：

- 当日公開Case
- 更新Case
- official documents
- status counts

出力：

- headline
- 200字summary
- overview
- notable cases
- explained cases
- updates
- limitations
- source list

## 5.6 Editorial workflow

- draft
- audit failed
- review needed
- approved
- published
- corrected
- retracted

## 5.7 iOS

- ArticleBlock renderer
- source footnotes
- AI disclosure
- human reviewed badge
- article version
- correction note

## 5.8 Tests

Golden tests：

- source contradicts summary
- missing citation
- false numeric claim
- “alien craft” unsupported assertion
- source prompt injection
- two cases mixed
- unknown correctly stated

## 完了条件

- Fake LLMで記事が生成・表示
- 実LLMキーがあれば同schemaで実行可能
- 根拠なしfactは公開不可
- 記事に出典が表示
- Daily Briefingが生成
- prompt/version/model metadataが保存

---

# Phase 6 — StoreKit 2 Subscription

## 目的

App Store向けの購読体験をローカル設定とSandboxで完成させる。

## 6.1 Products

初期：

- Plus Monthly
- Plus Yearly

商品IDをConfigで管理。

## 6.2 Local StoreKit Configuration

- monthly
- yearly
- optional trial
- localization
- subscription group

## 6.3 SubscriptionService

責務：

- load products
- purchase
- observe transaction updates
- current entitlement
- restore
- manage subscription URL
- handle pending/cancelled/failure

ViewからStoreKitを直接呼ばない。

## 6.4 Entitlement UI

状態：

- free
- active
- grace period
- billing retry
- expired
- revoked
- loading/unknown

## 6.5 Paywall

- value proposition
- localized product metadata
- period and price
- auto-renew disclosure
- restore
- terms
- privacy
- close button
- no false urgency

## 6.6 Premium gating

- Daily Briefing full body
- Case synthesis deep sections
- advanced filters

無料概要は必ず残す。

## 6.7 Server verification

Backend：

- verify signed transaction
- short-lived entitlement response
- idempotency
- App Store Server API adapter
- Server Notifications V2 endpoint skeleton
- local fake notification fixtures

資格情報がなければmock verificationを使う。

## 6.8 Tests

- purchase success
- cancel
- pending
- restore
- expiration
- grace
- revocation
- offline cached entitlement

## 完了条件

- Xcode local StoreKitで購入・復元・失効を確認
- Plus記事が解放
- Freeへ戻る
- Paywallに必要情報
- 本番商品ID設定箇所が明確
- Sandbox手順がMANUAL_ACTIONSにある

---

# Phase 7 — Notifications, Offline, Settings, Legal Surfaces

## 目的

実用アプリとして日常利用でき、審査に必要な設定・文書導線を完成させる。

## 7.1 Notifications

- onboarding後に価値説明
- user chooses category
- permission request only after action
- APNs token registration adapter
- local notification demo
- deep link

## 7.2 Offline

- last successful feed
- cached Case detail
- cached article
- bookmarks
- clear cache
- stale timestamp

## 7.3 Settings

- notification categories
- language
- appearance/system
- data refresh
- subscription
- restore
- manage subscription
- clear cache
- privacy/terms/editorial/AI/sources/support

## 7.4 Legal pages

開発用の完成原稿またはプレースホルダーではない内容を作る。

- Privacy Policy
- Terms of Use
- Editorial Policy
- AI Use Policy
- Data Sources and Licensing
- Correction Policy
- Support

本番URLが未取得ならローカルHTMLと`MANUAL_ACTIONS`を作り、Release buildでは有効HTTPS URLを必須にするvalidationを入れる。

## 7.5 Accessibility

- VoiceOver reading order
- button labels
- score explanations
- map alternative list
- Dynamic Type
- Reduce Motion
- Increase Contrast
- minimum hit area

## 完了条件

- permission denialでも利用可能
- offlineで読める
- legal/support導線が機能
- accessibility auditの主要問題なし
- Release設定でplaceholder URLを検知

---

# Phase 8 — Editorial Admin Console

## 目的

AI自動生成だけに依存せず、公開前後を人間が管理できる状態にする。

## 技術

- Next.js
- TypeScript strict
- App Router
- secure admin auth
- accessible UI

## 8.1 Dashboard

- ingestion status
- pending clusters
- verification failures
- drafts awaiting review
- published today
- citation gate failures

## 8.2 Case editor

- metadata
- reports
- claims
- evidence
- explanation candidates
- score breakdown
- merge/split
- timeline

## 8.3 Article editor

- structured block editor
- source preview
- claim links
- diff
- approve/publish
- correction/retract

## 8.4 Source Registry

- rights state
- terms URL
- review date
- enable/disable
- attribution

## 8.5 Security

- no public signup
- MFA where provider supports
- role checks
- audit log
- CSRF/security headers

## 完了条件

- editor can publish fixture Case
- article diff and citations visible
- correction creates new version
- retraction does not erase audit history
- source can be disabled immediately

---

# Phase 9 — Hardening and App Store Readiness

## 目的

TestFlightとApp Reviewへ進める品質にする。

## 9.1 Build

- Xcode 26+
- iOS 26 SDK+
- iOS 17 deployment target
- no warnings target
- Release archive
- symbol upload setup

## 9.2 Privacy

- Privacy Manifest
- required reason APIs
- third-party SDK manifests/signatures
- App Privacy inventory
- analytics/crash SDK review
- no tracking unless explicitly needed

## 9.3 App metadata package

作成：

- app name candidates
- subtitle
- keywords
- promotional text
- description
- support URL
- privacy URL
- marketing URL optional
- review notes
- subscription description
- screenshot plan
- age rating questionnaire notes

## 9.4 App Review checklist

- all links work
- no placeholder content
- no Demo badges in production
- source rights approved
- purchase and restore work
- paywall disclosure
- app usable without account
- UGC feature disabled
- notification optional
- no private API
- no hidden external purchase link
- no unsupported claims

## 9.5 Tests

- fresh install
- upgrade
- offline
- slow API
- empty feed
- corrupted cache
- subscription changes
- denied notification
- largest text
- VoiceOver
- iPhone sizes
- Japanese/English

## 9.6 Performance

- launch time
- scrolling
- map annotations
- memory
- image loading
- battery/network

## 9.7 Security review

- dependency audit
- secrets scan
- API auth/rate limit
- admin access
- webhook verification
- SSRF
- logs

## 完了条件

- Release archive succeeds
- App Store checklist has no blocker
- privacy inventory complete
- StoreKit Sandbox verified
- TestFlight build ready
- review notes ready

---

# Phase 10 — TestFlight and Submission Support

このPhaseは人間操作が多いため、Claude Codeは手順作成と修正支援を行う。

## 10.1 Manual actions

- Bundle ID登録
- App Store Connect app record
- subscription group/products
- agreements/tax/banking
- APNs capability
- server notification URL
- privacy/support website deployment
- archive upload
- TestFlight group
- screenshots
- App Privacy answers
- age rating
- review submission

## 10.2 Claude Codeの役割

- configuration valuesの反映
- build errors修正
- screenshot automation
- review notes生成
- metadata validation
- rejection内容への修正

## 10.3 TestFlight feedback

`docs/TESTFLIGHT_FEEDBACK.md`を作り、以下で整理。

- severity
- device/OS
- reproduction
- expected/actual
- screenshot
- status

## 完了条件

- external/internal TestFlightで主要フロー確認
- critical/high bugなし
- subscription sandbox確認
- App Review提出可能

---

# Phase 11 — Post-launch UGC Foundation（初回リリース後）

初回申請前に有効化しない。

## 必須要件

- terms acceptance
- report submission form
- media upload
- metadata consent
- location precision control
- automated objectionable content filter
- human moderation queue
- report content
- block abusive user
- published contact information
- deletion request
- copyright takedown workflow
- retention policy
- abuse rate limiting
- child/privacy safeguards

## 撮影データ

明示的許可後のみ：

- GPS
- timestamp
- compass/attitude
- device model
- camera metadata
- original file hash

公開位置は丸める。原位置を誰が閲覧できるか分離する。

---

## 2. Phaseごとの報告形式

Claude Codeは各Phase終了時、`docs/PROGRESS.md`を次の形式で更新する。

```markdown
## Phase N — Title

Status: complete / partial / blocked
Date:

### Implemented
- ...

### Tests run
- command: result

### Visual review
- screen/path

### Decisions
- ...

### Remaining
- ...

### Manual actions
- ...
```

最終返答は：

1. 完成したもの
2. 起動方法
3. 確認してほしい画面
4. 未完了
5. 人間操作が必要
6. 既知のリスク

---

## 3. 実装中の禁止パターン

- 巨大な1ファイルView
- View内でAPI、DB、StoreKitを直接操作
- `try!`、強制unwrapの乱用
- 本番用APIキーのハードコード
- テストを削除して通す
- エラーを握り潰す
- 仮データを本番表示
- “UFO authenticity”単一スコア
- AI生成文の出典省略
- 規約不明サイトへのcrawler作成
- 初回版でUGC feature flagをtrue
- WebViewだけの主要体験
- 購読中なのにネット障害だけで即ロック
- 無効なPrivacy/Support URLで提出

---

## 4. 実装優先順位の判断基準

迷った場合：

1. ユーザーがSimulatorで確認できるか
2. App Store審査に通るか
3. 情報の根拠を追えるか
4. オフライン・失敗時に壊れないか
5. 後からProviderを差し替えられるか
6. 運用者が訂正できるか
7. 見た目が美しいか

---

## 5. 最初の一括実装で到達してほしい地点

外部資格情報が全くない状態でも、最低限以下まで一気に進める。

- Phase 0完了
- Phase 1完了
- Phase 2のローカルAPI・seed完了
- Phase 3のSource Registryとsafe ingestion骨格
- Phase 4のmock verificationとscoring
- Phase 5のFake LLM article generation
- Phase 6のlocal StoreKit purchase flow
- Phase 7のsettings/legal/offline

つまり、ユーザーが確認する時点で：

- Todayが埋まっている
- Mapが動く
- Case detailが深い
- AI統合記事が読める
- Paywallで購読し、Plusが解放される
- 課金復元を試せる
- 出典・更新履歴が見える
- APIを止めてもキャッシュで読める

状態を目標にする。

Adminと実データ接続は、環境と作業量に応じて続行する。

---

## 6. ユーザー確認後の調整方法

ユーザーからUI修正が来た場合、Claude Codeは次の順で対応。

1. 変更要求を画面・コンポーネント・データに分解
2. 現在のDesign Systemとの整合性を確認
3. 影響範囲を説明
4. Preview/fixtureで修正
5. unit/UI test
6. 実機またはSimulator build
7. `PROGRESS.md`と`DECISIONS.md`更新

「全体を作り直す」のではなく、既存構造を維持しながら改善する。

---

## 7. App Store申請前の最終停止条件

以下が1つでも未完なら提出しない。

- privacy/support URLが無効
- subscription metadata未完
- purchase/restore未検証
- crashする主要フロー
- source rights不明の本番データ
- Demo data混入
- AI articleに根拠なし文
- Privacy Manifest不整合
- account creationありで削除機能なし
- UGC有効なのにmoderation不足
- review notesなし
- App Privacy回答が実装と不一致

Claude Codeは、見かけ上提出可能でもこの条件を破って提出を促してはならない。
