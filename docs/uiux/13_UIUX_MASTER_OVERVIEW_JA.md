# SkyTrace UI/UXマスター概要 — 日本語版

## 1. 今回決定した最終方針

SkyTraceの外側は、単なる「宇宙風ニュースアプリ」にはしません。

最終コンセプトは、

> **SkyTrace — Living Observatory**  
> 世界の空を観測し、静かな紙面で読み、証拠の軌跡を辿る場所。

です。

画面全体は、次の3つの思想を役割ごとに組み合わせます。

- **Living Observatory 45％**：空・時間・大気・静かな光
- **Celestial Newspaper 35％**：読みやすい紙面・信頼・記録
- **Global Signal Atlas 20％**：地図・時間軸・Case同士の関係

全画面に同じ割合で混ぜるのではなく、

- Today上部や起動体験は「観測所」
- Case詳細や長文は「紙面」
- MapやSearch、Timelineは「Atlas」

を主役にします。

## 2. 体験の3段階

### Observe — 観測する

最初の数秒で、今日の世界の空に何が起き、何が変化したかを把握します。

使う場所：

- 起動
- Today上部
- World Sky Pulse
- Mapの世界表示
- Widget

### Read — 読む

一つのCaseを、事実・証言・推定・不足情報・矛盾に分けて理解します。

使う場所：

- Daily Briefing
- Case詳細
- AI統合記事
- 出典
- 訂正履歴

### Trace — 辿る

どの情報がいつ追加され、なぜ評価が変わり、何が根拠になったかを辿ります。

使う場所：

- Map
- Search
- Timeline
- Evidence
- Sources
- Related Cases

## 3. 見た目を作る3つの素材

### 世界＝Atmosphere

World Sky PulseやMap背景など、世界・時刻・大気を感じる場所に使います。

- 星の写真を背景に敷かない
- 粒子を常時飛ばさない
- 巨大な地球を回さない
- 昼夜やCase分布を静かに抽象化する

### 操作＝Glass

Liquid Glassは、操作部分に限定します。

- Tab Bar
- Navigation
- MapのFilter
- Search
- 一時的な操作パネル

記事本文、出典、評価の説明には使いません。

### 理解＝Editorial Surface

Caseを読む場所は、静かな紙面にします。

- 安定した背景
- 読みやすい文字幅
- 十分な余白
- 見出しと罫線による階層
- カードの乱用を避ける

合言葉は、

> **操作はガラス、理解は紙面、世界は大気。**

です。

## 4. ナビゲーション

4タブを正式採用します。

1. **今日**：世界概況、重要な変化、Case一覧
2. **地図**：場所・時間・関連性
3. **探す**：Case、場所、年代、現象、出典
4. **設定**：表示、通知、AI・情報方針、データ、Plus

タブを切り替えても各画面の位置やNavigation状態を保持します。

## 5. Todayの完成構造

Todayは単なるニュースフィードではありません。

### 1. World Sky Pulse

画面上部約25〜30％。

表示：

- 日付
- 今日の世界概況1文
- 新規・更新Caseの静かな信号
- 最終更新時刻
- 地図へ移る操作

### 2. Daily Briefing

3〜5行の短い編集要約。

- 参照Case数
- 参照資料数
- 更新時刻
- AI／編集状態

### 3. Priority Case

今日もっとも意味のある変化があったCaseを1件だけ大きく表示します。

「話題だから」ではなく、

- 公的資料追加
- 評価変更
- 独立報告増加
- 位置精度改善
- 訂正

などの理由を見せます。

### 4. Since Your Last Visit

再訪ユーザーには、前回から変わった部分だけを表示します。

### 5. Case Stream

通常のCase一覧。

同じカードを延々と並べず、Lead・Compact Row・地域グループなどを使い分けます。

## 6. Mapの完成構造

- MapKitの全画面地図
- 上部に期間・Filter・現在地
- 下部に3段階のSheet
- 状態ごとの形を持つMarker
- 時間軸
- 地図と同じ結果を読めるList

### Bottom Sheet

1. 閉じた状態：期間と件数
2. 中間：地域・Case一覧
3. 展開：Case概要

### 重要原則

- 地図だけでしか探せない情報を作らない
- 位置が曖昧なCaseは範囲と説明を表示する
- Clusterは数字だけでなく新規・更新構成を示す
- 色だけで状態を分けない

## 7. Searchの完成構造

検索前にも、探索の入口を表示します。

- 最近見たCase
- 保存した検索
- 更新されたCase
- 地域
- 年代
- 現象テーマ

入力中は候補を、

- Case
- 場所
- 日付
- 現象
- 出典
- Collection

に分類します。

結果は記事単位ではなくCase単位を基本にします。同じ出来事の記事が5本あっても、5件の別結果にはしません。

## 8. Case詳細の完成構造

Case詳細は、アプリで最も重要な画面です。

順番を固定します。

1. Header
2. What Changed／前回からの変化
3. What Happened／何が起きたか
4. Current Assessment／現在評価
5. Confirmed Facts／確認済み事実
6. Agreement／一致点
7. Contradictions／矛盾点
8. Evidence／資料
9. Explanations Considered／検討した説明
10. Timeline／理解の変化
11. Sources／出典
12. Related Cases／関連Case

### 真実度は1個の数字にしない

以下を別々に表示します。

- 報告の独立性
- 時刻の整合
- 位置精度
- 映像資料の来歴
- 公的確認
- 既知現象との一致
- 未解決の矛盾
- 不足情報

### What Changed

以前読んだユーザーには、

- 資料が2件追加
- 位置精度20km→3km
- 情報不足→既知現象の可能性あり

などを最初に見せ、Timelineや根拠へつなげます。

## 9. 色と質感

### Dark

- 真っ黒ではなく、青と緑をわずかに含む夜色
- 紙面は少し明るい墨青
- 文字は純白を避けた柔らかな白
- アクセントは大気光の青緑
- 意味のある変化には月光のような淡い金

### Light

- 真っ白ではなく青白い大気
- 紙面はわずかに温かい白
- 文字は墨色
- 青緑と空色
- 変化や時間に淡い金

### 使用量

- 背景・無彩色：80％
- 青緑：12％
- 淡金：5％
- 状態色：3％

## 10. 形の意味

- 中央点＋円：新規
- 開いた円：調査継続
- 欠けた円：情報不足
- 半円：既知現象の可能性あり
- 菱形：説明済み
- ずれた2本の弧：意見・資料の対立
- 修正記号付き菱形：訂正
- 輪郭四角：Archive

同じ形をMap、一覧、Case詳細、Timeline、Widgetで使います。

## 11. 文字・余白

- 基本はAppleのSystem Font
- UIはSF系
- 編集見出しはSystem Serifを慎重に使用
- 本文はDynamic Type対応
- AX5まで崩れない
- 4pt Grid
- 画面余白16〜20pt
- セクション間32〜48pt
- 本文をカードへ閉じ込めない

## 12. モーション

モーションは未来感の飾りではなく、場所と変化を理解させるために使います。

### 使う場面

- Todayの信号がMap上の位置へつながる
- Map MarkerがCase Previewへつながる
- PreviewのTitleとStatusが詳細Headerへつながる
- Timelineに新情報が追加された時だけ線が伸びる

### 使わないもの

- 常時点滅
- レーダー走査
- 大量のStagger Animation
- 長い起動演出
- Confetti

Reduce Motion時はCrossfade中心にします。

## 13. 触覚と音

### 触覚

- Marker選択、Filter切替：軽い選択感
- Case保存、検索保存：柔らかな確定感
- 削除、失敗：警告

### 音

通常操作は無音です。

起動音、宇宙音、レーダービープは使いません。

## 14. アクセシビリティ

必須対応：

- VoiceOver
- Dynamic Type AX5
- Increase Contrast
- Differentiate Without Color
- Reduce Transparency
- Reduce Motion
- 44×44pt以上のTouch Target
- MapのList代替
- Video Caption／Transcript
- iPad Keyboard Focus

### 完成基準

- AX5で重要文字が1つも切れない
- 色だけの状態が1つもない
- Map上の全CaseをListから開ける
- VoiceOverでStatus、場所、発生時刻、更新時刻、変更理由を理解できる

## 15. Loading／Empty／Offline／Error

### Loading

- Cached内容を残して更新
- Skeletonは既知Layoutのみ
- 全画面Spinnerを原則使わない

### Empty

何もない理由と、

- 期間を広げる
- Filterを解除
- Archiveを見る

を表示します。

### Offline

- 最終取得時刻
- 読める保存内容
- 接続が必要な機能

を明確にします。

### Error

「0件」と誤表示せず、何が取得できなかったかを伝えます。

## 16. Paywall

最初の起動では表示しません。

有料機能を使おうとした時に、

1. 今やろうとしたこと
2. Plusでできること
3. 実際のPreview
4. StoreKitの料金
5. 復元
6. 規約・Privacy
7. 閉じる

を表示します。

「宇宙の真実を解放」などのCopyは禁止です。

## 17. Appアイコン

推奨案：**Horizon Signal**

- 深い大気
- 地平線の弧
- 1点の信号
- 途中で開いた観測軌道

UFOそのものは描きません。

AppleのIcon Composerを使い、Light／Dark／Tinted／小さい表示を確認します。

## 18. App Storeスクリーンショット

1. 世界の空を、ひと目で。
2. 何が起き、何が変わったか。
3. 世界中のCaseを、地図から辿る。
4. 噂ではなく、Caseとして読む。
5. 一致と矛盾を、分けて見る。
6. 評価が変わった理由まで残す。
7. 複数の資料を、一つの理解へ。
8. 未知を煽らず、未知のまま見つめる。

## 19. Claude Codeの実装順

### Phase 0

既存Repository確認、現状Build、Branch作成、設計ファイル配置。

### Phase 1

Color、Typography、Spacing、Status形、Fixture、Preview。

### Phase 2

4Tab、Navigation、Onboarding。

### Phase 3

Today完成。

### Phase 4

MapとList代替。

### Phase 5

Search。

### Phase 6

Case PreviewとCase詳細。

### Phase 7

長文、Paywall、Settings。

### Phase 8

Widget。

### Phase 9

VoiceOver、AX5、iPad、Contrast。

### Phase 10

Performance、Simulator画像、Visual Regression。

### Phase 11

本番API接続。

### Phase 12

App Store申請準備。

## 20. 技術方針

- SwiftUI Native
- Xcode 26／iOS 26 SDK以降
- MapKit
- Observation
- SwiftData（保存・既読・Cache等に適切なら）
- StoreKit 2
- WidgetKit
- ActivityKitは時間が明確なFlowだけ
- 外部UI Frameworkは初期段階では使わない
- ViewはProduction APIを直接見ず、Protocol越しにFixtureと本番を切替

## 21. 品質ゲート

完成判定は、画面が存在することではありません。

- 10秒でアプリの目的が分かる
- 再訪時に変更点がすぐ分かる
- LightとDarkが両方美しい
- VoiceOverでも同じ情報構造を理解できる
- 通信失敗時も品格が崩れない
- MapとCase詳細がつながって感じられる
- 出典と訂正に迷わず届く
- AIが権威のように見えない
- iOS標準の操作感を壊さない
- App Store画像が実際の製品と一致する

## 22. 絶対に簡略化しない部分

- What Changed
- Confirmed Facts／Agreement／Contradictionsの分離
- 複数軸のAssessment
- Sourceの来歴
- Timelineの変更理由
- MapとListの両立
- Light Mode
- AX5
- Reduce Motion／Transparency
- Loading／Offline／Error
- 無料範囲の訂正・根拠

## 23. 最終的に目指す印象

SkyTraceは、派手な宇宙広告ではなく、

> 夜明け前の観測所で、世界の空に浮かんだ小さな信号を、静かな紙面と確かな資料で読み解いていくアプリ。

です。

美しさは、情報を隠す魔法ではありません。

**何が分かり、何が分からず、なぜ評価が変わったかを、最も美しく誠実に見せること。**

それをこのUI/UXの最高品質と定義します。

