# SkyTrace UI/UXプランシート

最終更新想定：2026-07-13  
対象：iOS App Store初回リリース  
正本範囲：画面構成、情報階層、視覚表現、操作、アクセシビリティ、課金導線、UI品質基準  
作業名：SkyTrace（仮称）

---

## 0. この文書の役割

この文書は、SkyTraceを「宇宙テーマの情報一覧」ではなく、世界水準のニュース／観測アプリとして成立させるためのUI/UX正本である。

- プロダクト思想・システム・データ・AI・権利は `docs/ARCHITECTURE.md` を正本とする。
- 実装順序・完了条件は `docs/CLAUDE_CODE_PHASES.md` を正本とする。
- 本文書は、視覚・情報設計・画面遷移・操作感・コピー・課金体験の正本とする。
- 競合アプリの見た目をコピーしない。Appleプラットフォームに自然で、SkyTrace固有の人格を持つデザインを作る。

矛盾時の判断：

1. 安全・法令・App Store要件
2. 出典と不確実性の正確な提示
3. 読みやすさ・操作しやすさ
4. 本文書のUX方針
5. 装飾的な未来感

未来感は重要だが、真実性と可読性を上回ってはならない。

---

# 1. UX North Star

## 1.1 一文で表す体験

> 30秒で今日の世界の空を把握でき、3分で一つの事例を根拠まで深く理解できる。

## 1.2 利用者に残したい感情

- 「何かが起きている」という静かな高揚
- 「煽られていない」という安心
- 「どこまで分かっているか追える」という信頼
- 「また明日、空を見に来たい」という継続性

## 1.3 アプリの人格

SkyTraceは、陰謀論者でも懐疑論者でもない。

人格は次の組み合わせとする。

- 冷静な科学記者
- 夜空を愛する観測者
- 出典を隠さない編集者
- 未知を雑に消費しない案内人

文章は断定を急がず、曖昧に逃げない。

---

# 2. コアデザイン原則

## P1. Signal Over Spectacle

情報を最優先し、演出は信号を見つけやすくするために使う。

- 星空を本文背景にしない
- 強いグローを常用しない
- 点滅・警報・レーダー音のような煽りを避ける
- 写真がなくても成立する編集デザインを作る

## P2. Layered Depth

情報を一度に全部見せず、三段階で深くする。

1. **Glance**：30秒で見出し、状態、地域、時刻
2. **Scan**：概要、一致点、照合候補、4軸スコア
3. **Investigate**：出典、矛盾、タイムライン、AI統合記事

## P3. Trust Is Visible

信頼性は説明文の奥に隠さず、画面そのものに埋め込む。

常に見えるもの：

- 発生日時と公開日時の違い
- 最終検証日時
- 出典数と独立報告数
- AI生成／人間確認の状態
- 位置精度
- 変更・訂正履歴

## P4. Unknown Is Not Alien

未解明度は、地球外起源の確率ではない。

- 「本物」「偽物」の二値表示をしない
- 単一の信ぴょう性点数で結論を作らない
- 説明済み事例も価値ある学習コンテンツとして扱う

## P5. Native Before Novel

Apple標準の操作を尊重する。

- SwiftUIのNavigationStack、TabView、Sheet、ShareLink等を優先
- ナビゲーションと主要コントロールにiOS 26のLiquid Glassを段階利用
- コンテンツカードを過剰にガラス化しない
- 独自操作を作る前に標準操作で解決できないか検討する

## P6. Free Value Before Paywall

無料ユーザーにも毎日使う理由を与える。

- 初回起動直後に全画面Paywallを出さない
- 本日の一覧・地図・短い要約・出典は無料で体験可能
- 深い統合記事を読みたい瞬間にPlusを提示
- 課金しない利用者を意図的に不便にしない

## P7. Calm Daily Ritual

通知・更新・モーションを静かに設計する。

- 緊急性を誇張しない
- 通知頻度をユーザーが選べる
- 既知現象と判明した更新も、発見として丁寧に知らせる

---

# 3. 想定ユーザーと主要ジョブ

## 3.1 Casual Observer

目的：今日どこで何が報告されたかを短時間で知る。

必要：

- 見出し
- 地図
- 短い要約
- 状態
- 更新日時

## 3.2 Curious Reader

目的：注目事例を煽りなしで深く読む。

必要：

- AI統合記事
- 一致点／矛盾点
- 既知現象照合
- 出典
- 更新履歴

## 3.3 Evidence-minded User

目的：どう評価されたかを自分で確かめる。

必要：

- 独立報告数
- 証拠品質
- 説明候補
- 情報不足
- 原典リンク

## 3.4 Returning Subscriber

目的：毎日の短い習慣として世界の空を追い、重要事例の変化を知る。

必要：

- Daily Sky Briefing
- 昨日からの変化
- 保存事例の更新
- 個別通知

---

# 4. 情報アーキテクチャ

## 4.1 推奨タブ

ユーザー表示名：

1. **今日** — `Today`
2. **地図** — `Map`
3. **探す** — 内部機能名 `ResearchHub`
4. **設定** — `Settings`

### Researchから「探す」への整理

既存設計のResearch機能は削除せず、ユーザー向けラベルを「探す」とする。

理由：

- 検索を主要機能として見つけやすくする
- 「Research」は一般利用者には少し専門的
- 深掘り記事、過去事例、保存、フィルターを一つの探索ハブへ統合できる

内部コードやAPI名は`Research`のままでもよい。表示ラベルはローカライズ可能にする。

## 4.2 タブ別責務

### 今日

- 今日の世界概況
- Daily Sky Briefing
- 注目事例
- 新しい更新
- 保存事例の変化

### 地図

- 時間と空間から探す
- ピン／クラスタ
- 地域・状態・日付フィルター
- 事例ミニカード

### 探す

- 常にアクセス可能な検索
- 日付・地域・状態・形状・スコアのフィルター
- Plus統合記事
- 保存済み
- 最近見た事例
- テーマ別コレクション

### 設定

- 通知
- 表示
- 購読
- データ／オフライン
- 編集方針
- AI方針
- 出典・権利
- プライバシー／利用規約／サポート

## 4.3 グローバル遷移

- Case Card → Case Detail
- Briefing Card → Daily Briefing Detail
- Map Pin → Bottom Sheet → Case Detail
- Source Row → SFSafariViewControllerまたはシステムブラウザ
- Plus Lock → Contextual Paywall
- Bookmark → ローカル保存、同期は将来
- Share → ShareLink

モーダルを多用せず、読み物はNavigationStackで深く進む。

---

# 5. 主要ユーザーフロー

## 5.1 初回起動

推奨：長いオンボーディングを置かない。

### 画面1：短いウェルカム

- ロゴ
- 中心コピー
- 「世界の空で報告されたことを、出典とともに追跡します」
- `始める`

### 画面2：編集方針の短い説明

3項目のみ：

- 未解明を地球外起源とは断定しません
- AI文章は出典へ追跡できます
- 読むだけならアカウントも位置情報も不要です

- `続ける`
- `詳しい方針を見る`

### 通知許可

初回起動直後には要求しない。

Todayを一度閲覧し、通知設定をユーザーが開いた時、または保存事例の更新通知を初めて有効にした時に価値説明を出す。

## 5.2 毎日の利用

1. Todayを開く
2. 世界概況を10秒で見る
3. 注目事例を1〜3件確認
4. PlusならBriefing全文を読む
5. 気になる事例を保存
6. 後日の更新通知から再訪

## 5.3 深掘り

1. Case Detailを開く
2. 概要と状態を見る
3. 一致点／矛盾点を確認
4. 照合候補を見る
5. 統合記事を読む
6. 出典を開く
7. タイムラインで評価変化を見る

## 5.4 課金

1. 無料価値を体験
2. Briefingまたは詳細分析のPlus部分へ到達
3. 読める内容の目次・冒頭を確認
4. Contextual Paywall
5. StoreKitで購入
6. 完了後、元の記事の続きへ即時復帰

購入後にホームへ飛ばさない。

---

# 6. ビジュアルコンセプト

## 6.1 コンセプト名

> Observatory Editorial — 静かな観測所の編集室

宇宙船の操縦席ではなく、世界中の観測記録が集まる未来の編集室。

## 6.2 視覚比率

- 70%：高品質なニュース／読み物
- 20%：観測機器の精密さ
- 10%：宇宙的な詩情

## 6.3 避ける表現

- 緑の宇宙人、円盤アイコンの乱用
- VHSノイズ、グリッチ常用
- 赤い警告の連発
- すべて大文字の軍事風コピー
- 暗すぎる本文
- 無意味な3D回転や粒子
- どのカードにもグラデーション

## 6.4 Liquid Glassの使い方

iOS 26では、Liquid Glassは主に次へ限定する。

- Tab Bar
- Navigation Bar
- Bottom Sheet上部の操作領域
- フローティングフィルターボタン
- 一時的なコントロール

記事本文、スコア説明、出典一覧は安定した不透明／半透明Surfaceを使い、背景が透けすぎないようにする。

iOS 17〜25では`.ultraThinMaterial`等を必要最小限に使用し、同じ情報階層を保つ。

---

# 7. デザインシステム

## 7.1 Semantic Color Tokens

実装名を固定し、View内に直接RGBを書かない。

### Dark Primary

- `canvas`：`#070B14`
- `canvasElevated`：`#0A101B`
- `surfacePrimary`：`#0E1623`
- `surfaceSecondary`：`#131E2D`
- `surfaceInteractive`：`#182638`
- `borderSubtle`：白 8〜12%
- `textPrimary`：`#F4F7FB`
- `textSecondary`：`#A9B5C7`
- `textTertiary`：`#728096`

### Signal Colors

- `signalCyan`：`#8CD9FF`
- `signalViolet`：`#A895FF`
- `signalAmber`：`#F4C56B`
- `signalGreen`：`#79D4A3`
- `signalRed`：`#EF9292`

### Meaning

- Cyan：情報、観測、選択状態
- Violet：Plus、AI統合、深掘り
- Amber：情報不足、注意、未検証
- Green：説明候補が強い／確認済み
- Red：矛盾、取り下げ、エラー。恐怖演出には使わない

Light Modeは単純反転せず、白〜淡い青灰をCanvasにし、Surface境界とテキストコントラストを再設計する。

## 7.2 Typography

原則としてSF ProとDynamic TypeのSemantic Styleを使う。

- Screen Hero：`.largeTitle` または可変の`.title`
- Section Heading：`.title2` / `.title3`
- Card Headline：`.headline`
- Body：`.body`
- Supporting：`.subheadline`
- Metadata：`.caption`
- Score Number：`.title2.monospacedDigit()`

記事本文：

- 1行が長くなりすぎない
- 行間は標準よりわずかに広く
- 見出し前後の余白を明確に
- 強調は太字を中心にし、色だけで表さない

## 7.3 Spacing

4ptベース。

- `space1` 4
- `space2` 8
- `space3` 12
- `space4` 16
- `space5` 20
- `space6` 24
- `space8` 32
- `space10` 40

画面左右の基本余白：16〜20pt。  
長文本文は読みやすい最大幅を持たせる。

## 7.4 Radius

- Small chip：10〜12
- Standard card：16
- Hero card：20〜24
- Sheet top：24以上

丸すぎて子供向けに見えないようにする。

## 7.5 Elevation

影を濃くしない。境界は次で作る。

- CanvasとSurfaceの明度差
- 1px相当のsubtle border
- ごく薄い影
- 選択時の内側ハイライト

## 7.6 Iconography

- SF Symbolsを優先
- 未解明＝円盤アイコンに固定しない
- 状態アイコン例：
  - 調査継続：`scope`
  - 説明候補あり：`checkmark.circle`
  - 情報不足：`questionmark.circle`
  - 更新あり：`arrow.triangle.2.circlepath`
  - 出典：`doc.text`
  - 独立報告：`person.2`
  - AI統合：`sparkles`

## 7.7 Imagery

初回版で記事画像が権利的に使えない場合、画像なしでも美しく成立させる。

代替：

- 地域を示す抽象的な地球グリッド
- 時刻・方角を示す小さな観測図
- 形状タグをもとにした抽象シンボル
- 地図スナップショット
- データ可視化

画像がある場合も、権利と出典が確認されたものだけ表示する。

---

# 8. コンポーネント設計

## 8.1 GlobalSummaryHero

Today最上部。

内容：

- 日付
- 「今日、世界の空で報告されたこと」
- 最終更新
- 取得ソース内の統計
- 小さな地球／軌道の抽象ビジュアル

操作：

- 統計項目タップで該当フィルター済み一覧
- Pull to Refresh

注意：「世界で発生した全件」と誤解させない。

## 8.2 DailyBriefingCard

Plusの主役。

Free表示：

- タイトル
- 1〜2段落
- 目次
- 使用事例数／出典数
- `続きを読む — Plus`

Plus表示：

- 全文導線
- 読了時間
- AI生成日時
- 人間レビュー状態

全面ぼかしは使わず、価値の一部を正直に見せる。

## 8.3 CaseCard

情報順：

1. 状態バッジ／更新バッジ
2. 地域・発生時刻
3. 見出し
4. 2〜3行の要約
5. 独立報告数・出典数
6. 未解明度は小さなメーター＋ラベル

カード全体タップ。内部に複数の細かいボタンを置きすぎない。

Variant：

- `featured`
- `standard`
- `compact`
- `mapSheet`
- `savedUpdate`

## 8.4 StatusBadge

文言とアイコンを併用。

- 説明済み
- 説明候補あり
- 情報不足
- 調査継続
- 争点あり
- 取り下げ

「真偽不明」「本物度」のような煽る語を避ける。

## 8.5 ScoreQuadrant

4軸を2×2または縦リストで表示。

- 証拠品質
- 独立報告性
- 既知現象一致度
- 未解明度

要件：

- 色だけに依存しない
- 0〜100の数字と短い説明
- タップで評価根拠Sheet
- 既知現象一致度だけ、値が高いほど「説明可能性が高い」ことを明記

レーダーチャートは比較には便利だが誤読しやすいため、初回版の主表示にしない。

## 8.6 EvidenceSection

見出し＋項目リスト。

- 一致している点
- 食い違う点
- 情報不足
- 今後必要な証拠

各項目に根拠出典へ移動する小さなリンクを付けられる構造にする。

## 8.7 ExplanationCandidateCard

例：Starlink、航空機、火球、金星、ドローン。

表示：

- 候補名
- 一致度
- 一致する条件
- 一致しない条件
- データの範囲／欠損
- 判定日時

「一致なし」は「除外済み」と同義にしない。

## 8.8 SourceRow

- 媒体名
- 公式／報道／一般報告等の種別
- 公開日時
- 記事タイトル
- 支持／反証／文脈の役割
- 外部リンク

ドメインだけを強調せず、媒体名と資料種別を明示する。

## 8.9 TimelineEntry

- 日付
- 変更内容
- 状態変更
- 追加された出典
- スコア変化

訂正や説明済みへの変化を「格下げ」ではなく、理解が進んだ更新として表現する。

## 8.10 PremiumLock

鍵だけで閉じない。

- 解放内容の具体名
- 読める深さ
- 文脈に合うCTA

例：`5つの出典を統合した分析を読む`

## 8.11 State Components

共通実装：

- Loading Skeleton
- Empty State
- Partial Data Banner
- Offline Banner
- Error Banner
- Demo Data Banner
- Stale Data Badge

---

# 9. 画面別詳細設計

## 9.1 Launch / Welcome

### 目的

世界観と信頼性を5秒で伝える。

### 構成

- 深い青黒Canvas
- 小さく静かなSkyTraceロゴ
- 中心コピー
- 短い説明
- `始める`

### モーション

ロゴの軌道線が一度だけゆっくり描かれる。Reduce Motionでは静止。

### 禁止

- 長いローディング演出
- 強制アカウント作成
- 強制通知許可
- 強制課金

## 9.2 Today

### 上からの順序

1. Navigation Title / 日付
2. Last Updated / Offline状態
3. GlobalSummaryHero
4. DailyBriefingCard
5. Top Cases
6. Since Yesterday / 更新
7. Saved Cases Updates（保存がある場合）
8. Editorial note

### スクロール設計

- 最重要情報は最初の1画面強に収める
- Heroを巨大にしすぎない
- 重要カード以外は横スクロールを乱用しない
- Top Casesは縦読みを基本とする

### コピー例

- `今日、世界の空で報告されたこと`
- `取得できた情報源内で、12件の報告を6つの事象に統合しました。`
- `最終検証 22:40`
- `昨日から3件に新しい情報があります`

### 更新

Pull to Refresh時、短い触覚。更新がなくても明確に完了を伝える。

## 9.3 Map

### 初期状態

- 世界全体または直近事例が見える範囲
- 過剰に多数のピンを直接出さずクラスタ
- 地図の上に薄いフィルターコントロール

### 操作

- Pin tap → Bottom Sheet
- Sheet drag → Case preview
- `詳細を見る` → Case Detail
- フィルター変更 → 結果数を即表示

### 位置精度

- exact：通常ピン
- approximate：半径リング
- region_only：地域中心＋広いリング
- withheld：地図非表示または国レベル

正確でない位置を正確な点として表示しない。

### フィルターUI

Primary：

- 期間
- 状態
- 未解明度

More Filters Sheet：

- 証拠品質
- 形状
- 昼夜
- 更新あり
- 説明候補

## 9.4 探す / ResearchHub

### 上部

検索フィールドを第一級要素として常時見つけられる位置に置く。

### 初期コンテンツ

- 最近の検索
- 注目コレクション
- 今週更新された事例
- Plus深掘り
- 保存済み

### 検索結果

- 件数
- 適用中フィルターChip
- 並び替え
- CaseCard compact
- 一致理由の短い表示

### 検索候補

- 国・地域
- 状態
- 形状タグ
- 説明候補
- 年月

自由文検索と構造化フィルターを併用する。

## 9.5 Case Detail

### Hero

- 状態
- タイトル
- 地域
- 発生日時
- 公開日時
- 最終検証
- Bookmark / Share

大きな写真がない場合でも、地図・観測方向・時間帯を使った抽象Heroで成立させる。

### 本文順序

1. 60秒要約
2. 4軸スコア
3. 何が起きたか
4. 一致している点
5. 食い違う点
6. 既知現象との照合
7. 現時点の判断
8. AI統合記事（Plus）
9. 情報不足
10. 今後必要な証拠
11. 更新タイムライン
12. 出典
13. AI／編集方針

### 60秒要約

4〜6行に収める。

- 何が報告されたか
- どれほど独立しているか
- 有力説明候補
- 何が残っているか

### Progressive Disclosure

各セクションは最初から全部畳まない。主要部分を読みやすく表示し、専門的な計算詳細だけDisclosureGroupへ入れる。

## 9.6 Daily Briefing Detail

### 記事構造

- 今日の要点3つ
- 世界概況
- 注目事例1〜3件
- 説明が進んだ事例
- 新しい公式資料
- 観測上の注意
- 使用した出典
- AI生成／レビュー情報

### 読み物品質

- 1記事3〜6分
- 導入で結論を曖昧に引き延ばさない
- 見出しを短く
- 出典番号を段落単位で追える
- 記事末尾に「明日追うもの」

## 9.7 Paywall

### 表示タイミング

- Plus記事を開いた時
- 高度フィルターを使おうとした時
- 保存事例の高度通知を有効にした時

初回起動直後には出さない。

### 構成

1. 文脈に応じた見出し
2. Plusで解放される3〜5項目
3. 月額／年額の選択
4. 年額の実質月額は誤解なく表示
5. Primary CTA
6. 購入を復元
7. 自動更新・解約の説明
8. 利用規約／プライバシー
9. 閉じる

### 推奨コピー

- `空の断片を、一つの調査記事へ。`
- `複数の出典、矛盾、既知現象との照合をまとめて読めます。`
- CTA：`SkyTrace Plusを始める`

### 禁止

- 偽のカウントダウン
- 閉じるボタンを隠す
- 年額のみを初期選択して月額を見えにくくする
- 「今だけ」等の虚偽
- システム価格と違う固定価格文言

StoreKitから取得したローカライズ済み価格を使う。

## 9.8 Settings

Section：

1. Subscription
2. Notifications
3. Appearance
4. Data & Offline
5. Editorial & AI
6. Privacy & Legal
7. Support
8. About

Debugのみ：

- Fixture/API切替
- Subscription state
- Empty/Error/Offline preview
- Feature flags

ReleaseにはDebug項目を出さない。

## 9.9 Legal / Editorial Pages

読みやすいネイティブ画面を用意し、Webリンクだけに依存しない。

- 編集方針
- AI利用方針
- スコアの読み方
- 出典と権利
- 訂正方針
- プライバシー
- 利用規約
- サポート

本番では有効な外部URLも併設する。

---

# 10. 信頼性をつくるEditorial UX

## 10.1 時刻を分ける

常に必要に応じて区別する。

- 発生日時
- 報告日時
- 記事公開日時
- アプリ取得日時
- 最終検証日時

## 10.2 Source CountとIndependent Countを分ける

`8 sources`と`2 independent reports`は意味が違う。

UI例：

- `出典 8`
- `独立報告 2`

## 10.3 AI状態

表示候補：

- `AI統合・自動生成`
- `AI統合・編集確認済み`
- `人間による編集記事`

「AI Powered」のような宣伝バッジだけにしない。

## 10.4 Correction UX

訂正時：

- 元の評価を消さない
- 何が変わったかをタイムラインに残す
- 保存ユーザーへ任意通知
- 記事冒頭に短い更新注記

## 10.5 Coverage Disclaimer

統計には、必ず取得範囲を表す。

例：

> SkyTraceが取得・確認できた情報源の範囲です。世界中の全報告を網羅するものではありません。

---

# 11. AI UX

## 11.1 AIの役割

- 複数資料の整理
- 一致点／矛盾点抽出
- 長文の要約
- 読みやすい記事化
- 検証待ち情報の明示

AIが行わないこと：

- 地球外起源の断定
- 出典にない事実の補完
- 人物・国家・組織への根拠なき आरोप
- 不明点を物語で埋めること

## 11.2 AI記事表示

記事冒頭または末尾に次を表示。

- 使用出典数
- 生成日時
- モデル／プロンプトの内部バージョン（一般ユーザーには簡略）
- 人間レビュー状態
- 誤り報告

## 11.3 Evidence Q&A（将来）

チャット風の人格を前面に出さず、「この記事に質問」の形にする。

回答には：

- 出典番号
- 不明の場合は不明
- 推論ラベル
- 関連セクションへのリンク

を必須とする。

---

# 12. サブスク体験

## 12.1 有料価値の定義

課金対象はニュースの存在そのものではなく、統合・追跡・深掘り。

Free：

- 今日の一覧
- 地図
- 基本要約
- 4軸スコア概要
- 出典
- 直近更新

Plus：

- Daily Sky Briefing全文
- Case Synthesis全文
- 一致／矛盾の詳細
- 照合根拠
- 更新履歴の詳細
- 高度検索／通知

## 12.2 Paywallの評価指標

- Paywall表示率ではなく、無料価値体験後の到達率
- 購入完了率
- 購入後の元コンテンツ復帰率
- Restore成功率
- 解約理由の任意フィードバック

## 12.3 Entitlement States

UIで扱う：

- unknown/loading
- eligible
- purchasing
- pending
- active
- grace period
- billing retry
- expired
- revoked
- unavailable

一時的な通信失敗だけで既知の有効権利を即時剥奪しない。

---

# 13. 通知・保存・共有

## 13.1 通知カテゴリ

- Daily Briefing：1日1回
- Major Update：重要事例に新証拠
- Saved Case Update：保存事例
- Region Watch：地域

初期デフォルト：すべてOFF。アプリ内で価値を説明して有効化。

## 13.2 通知コピー

悪い例：

- `緊急！東京にUFO出現！`

良い例：

- `東京近郊の発光体報告に、新しい映像が追加されました`
- `昨日の注目事例は、衛星フレアとの一致可能性が高まりました`

## 13.3 保存

- 端末内保存
- 保存後に軽い触覚
- 更新バッジ
- オフラインで最低限の本文を閲覧

## 13.4 共有

共有カードの本文には断定的表現を入れない。

例：

> 北海道で報告された発光体 — SkyTraceで出典と現在の評価を見る

---

# 14. 状態設計

## 14.1 Loading

- Skeletonを使用
- 無限回転を中央に置くだけにしない
- キャッシュがあれば先に表示

## 14.2 Empty

状況別コピー：

- 今日の事例なし：`現在、確認できた新しい事例はありません。空が静かな日も記録の一部です。`
- 検索0件：`条件に一致する事例がありません。期間や状態を広げてみてください。`
- 保存0件：`気になる事例を保存すると、後日の更新をここで追えます。`

## 14.3 Partial Data

一部ソース取得失敗時、全体をエラーにしない。

Banner：

> 一部の情報源を取得できませんでした。表示内容は完全ではない可能性があります。

## 14.4 Offline

- キャッシュ日時を表示
- 出典外部リンクはネット接続が必要と示す
- 再試行ボタン

## 14.5 Demo

Fixture使用時は明確な`DEMO DATA`バッジ。

架空事例を本番ニュースに見せない。

---

# 15. モーションと触覚

## 15.1 Motion

- 200〜350ms程度の短い遷移を基本
- カード出現は過度に順番表示しない
- スコア変化は値が更新された時だけ
- 地図クラスタの変化は滑らかに
- Plus解放時は静かなクロスフェード

## 15.2 Reduce Motion

- 軌道線アニメーションを静止
- パララックスなし
- 数値カウントアップなし
- シンプルなフェードへ縮退

## 15.3 Haptics

使用：

- Bookmark成功
- Filter適用
- Refresh完了
- 購入成功
- エラー

スクロールや通常のタップごとには使わない。

---

# 16. アクセシビリティ

必須：

- Dynamic Type：最大アクセシビリティサイズまで主要操作可能
- VoiceOver：カード全体の読み上げ順を設計
- 色以外の状態表現
- 44pt以上のタップ領域
- Reduce Motion
- Increase Contrastへの対応
- Bold Textで崩れない
- Light/Dark両方
- 長文で選択可能なテキストを検討

VoiceOver例：

> 調査継続。北海道東部の3つの発光体。独立報告3件、出典5件。最終更新7月13日22時40分。詳細を開く。

地図ピンは位置・状態・件数をまとめて読む。

---

# 17. ローカライズ

初回UI：日本語＋英語構造。

- 文字列を直書きしない
- 地名は原語と日本語表示を分離
- 日時はLocale／TimeZoneを尊重
- 発生地点の現地時刻とユーザー時刻を混同しない
- 数値・小数点・購読価格をローカライズ
- 日本語見出しが英語より長短どちらにもなる前提

表示例：

- `現地時刻 21:42 / 日本時間 04:42`

必要な場合のみ併記し、常時二重表示で混雑させない。

---

# 18. プライバシーとApp Store向けUX

## 18.1 初回版

- アカウント不要
- 正確な現在地不要
- 追跡広告なし
- UGCなし
- 外部APIキーをアプリへ入れない

## 18.2 Permission Primer

通知等のシステム許可前に、アプリ内で価値を説明。

## 18.3 Privacy Copy

一般ユーザーが理解できる短い要約と、詳細ポリシーの二層。

## 18.4 App Review Path

Review Notes用に以下を固定：

- 無料で確認できる画面
- Plus Paywallへの到達手順
- StoreKit Sandbox商品
- Restore手順
- Demo／Stagingデータの説明
- UGCがReleaseで無効なこと

---

# 19. App Store表現

## 19.1 App Icon方向

コンセプト：

- 円形の地平線／惑星
- 一本の観測軌道
- 小さな未確定シグナル

避ける：

- 典型的な空飛ぶ円盤
- 緑色の宇宙人
- 細かすぎる地図
- 文字ロゴの詰め込み

iOS 26のIcon Composer対応を見据え、前景・中景・背景を分けやすい構造にする。

## 19.2 Screenshot Story

1. `今日、世界の空で報告されたこと`
2. `複数の報告を、一つの事象へ統合`
3. `航空・衛星・天文データと照合`
4. `分かっていることと、残る謎を分けて表示`
5. `AI統合記事で深く読む`
6. `後日の更新まで追跡`

スクリーンショットのキャプションで「UFOの真実を暴く」等を使わない。

---

# 20. SwiftUI実装構造

推奨：

```text
DesignSystem/
├── Tokens/
│   ├── SkyColor.swift
│   ├── SkySpacing.swift
│   ├── SkyRadius.swift
│   └── SkyTypography.swift
├── Components/
│   ├── GlobalSummaryHero.swift
│   ├── DailyBriefingCard.swift
│   ├── CaseCard.swift
│   ├── StatusBadge.swift
│   ├── ScoreQuadrant.swift
│   ├── EvidenceSection.swift
│   ├── SourceRow.swift
│   ├── TimelineEntryView.swift
│   ├── PremiumLockView.swift
│   └── StateViews/
└── Modifiers/
    ├── CardSurfaceModifier.swift
    └── GlassControlModifier.swift
```

Feature構造：

```text
Features/
├── Welcome
├── Today
├── Map
├── Research
├── CaseDetail
├── Briefing
├── Subscription
├── Settings
└── EditorialPolicy
```

## 20.1 View規則

- Viewは表示責務に集中
- 状態取得やStoreKitを直接書かない
- 300行を超える巨大Viewを避ける
- Preview fixtureを全主要コンポーネントに用意
- Layout magic numberをTokenへ移す
- MainActor／Sendableを適切に扱う

## 20.2 Preview Matrix

主要画面ごとに：

- Light/Dark
- Small/Standard/Large iPhone width
- Japanese/English
- Default/Large Accessibility Text
- Free/Plus
- Loading/Success/Empty/Error/Offline/Demo

すべての組み合わせを完全生成する必要はないが、代表ケースを自動化する。

---

# 21. UIテストと品質ゲート

## 21.1 Critical Flows

1. Welcome → Today → Case Detail → Source
2. Today → Briefing → Paywall → Local purchase → Article continuation
3. Map → Filter → Pin → Case Detail
4. Search → Filter → Save → Saved list
5. Settings → Restore purchases
6. Offline launch → Cached case
7. Dynamic Type最大 → Case Detail読了

## 21.2 Visual QA

確認端末：

- 最小幅の対応iPhone
- 標準的なiPhone
- 最大幅のiPhone

確認Appearance：

- Dark
- Light
- Increase Contrast
- Reduce Motion
- Bold Text

## 21.3 Performance Targets

開発目標：

- キャッシュありの初回主要表示を体感的に即時
- 60fpsを妨げる常時エフェクトなし
- 長文記事のスクロールで引っかからない
- Map大量ピンはクラスタリング
- 画像は非同期・キャンセル可能・キャッシュ

具体値は計測環境とともに`docs/PROGRESS.md`へ記録する。

## 21.4 Accessibility Gate

以下を満たさないPhase 1は完了扱いにしない。

- 主要操作がVoiceOverで到達可能
- Dynamic Type最大でCTAが画面外へ消えない
- 色覚に依存しない
- Reduce Motionで常時アニメーションなし

---

# 22. Phase 1で必ず作る完成体験

外部APIなしで、次をすべて動かす。

- Welcome
- 4タブ
- 8件以上のDemo Case
- Today完成画面
- Daily Briefing Free／Plus両状態
- MapクラスタとSheet
- Search／Filter／Saved
- Case Detailの全セクション
- Paywall
- Local StoreKit商品
- Purchase／Restoreのローカル検証
- Settingsと方針ページ
- Loading／Empty／Error／Offline／Partial／Demo状態
- Light／Dark
- Dynamic Type
- VoiceOver labels

外部キー未設定を理由に、空の画面や仮ボタンでPhase 1を終えない。

---

# 23. デモ事例の編集要件

8件以上を用意：

1. Starlinkで説明済み
2. 航空機灯火の可能性が高い
3. 金星の誤認
4. 情報不足
5. 複数地点の注目未解決
6. 火球と後日判明
7. 出典間に矛盾
8. 報告取り下げ
9. 可能なら公式資料の更新例
10. 日本国内2件以上

すべてに：

- 発生／報告／更新日時
- 状態
- 4軸スコア
- 一致点
- 矛盾点
- 説明候補
- タイムライン
- 出典fixture
- AI統合記事fixture

を持たせる。

架空データはDEMOと明示する。

---

# 24. Claude Codeが残す成果物

Phase 1終了時：

- `docs/PROGRESS.md`
- `docs/DECISIONS.md`
- `docs/UI_REVIEW_CHECKLIST.md`
- `docs/SCREENSHOT_INDEX.md`
- 主要画面スクリーンショット
- UIテスト結果
- アクセシビリティ確認結果
- 未完了と手動作業

スクリーンショット取得が環境上できない場合、起動後に確認すべき画面遷移とPreview名を一覧化する。

---

# 25. 最終UIレビュー質問

ユーザー確認時は、抽象的に「どうですか」と聞くだけにしない。

確認項目：

1. 世界観は静かすぎる／派手すぎるか
2. Todayの情報量は30秒で把握できるか
3. Case Detailは結論と根拠を追いやすいか
4. 4軸スコアは誤解されないか
5. Plusの価値が無料部分から自然に伝わるか
6. 地図とニュース、どちらが主役に感じるか
7. 日本語コピーに硬さや煽りがないか
8. ダーク／ライトのどちらもブランドとして成立するか

---

# 26. 実装上の禁止事項

- 外観だけのために第三者UIライブラリを大量導入
- すべてをZStack／GeometryReaderで強引に配置
- 固定高さによるDynamic Type崩壊
- 読めない透明度
- テキストを画像化
- 本番用価格のハードコード
- 出典リンクのないAI断定文
- 状態を色だけで表現
- 主要画面のWebView化
- Previewのためだけの本番分岐
- Demo fixtureをRelease本番データとして混在
- 巨大な「宇宙レーダー」演出で記事を下へ追いやる

---

# 27. 現時点の推奨決定

- ユーザー向けタブは `今日 / 地図 / 探す / 設定`
- Darkをブランド主軸、Lightも完全対応
- iOS 26のLiquid Glassはナビゲーション／コントロール層中心
- コンテンツは安定したEditorial Surface
- 課金は文脈型Paywall
- 無料で一覧・地図・短い要約・出典を提供
- Plusは統合・深掘り・追跡に課金
- 初回版UGCなし
- 画像なしでも成立するデザイン
- Searchは主要タブ
- 4軸スコアを主表示、単一信頼度を使わない

---

# 28. 参照したApple公式設計領域

実装時には最新のApple Human Interface Guidelinesを再確認する。

- Designing for iOS
- Materials / Liquid Glass
- Layout
- Tab bars
- Searching / Search fields
- In-App Purchase
- Generative AI
- Privacy
- Accessibility
- App icons
- App Review Guidelines

仕様が変わった場合は、最新の公式ガイドを優先し、`docs/DECISIONS.md`に変更理由を記録する。
