# SkyTrace UI/UX設計一式 — 日本語導入ガイド

## この一式でできること

今回の第4回は、これまでの収集・比較を、Claude Codeが実装へ移せるファイル群に変換したものです。

単なる雰囲気資料ではなく、次を固定しています。

- アプリ全体の思想
- Today／Map／Search／Case詳細などの構造
- Light／Darkカラー
- 文字、余白、角丸、Glassの使用範囲
- Case状態の形と意味
- モーション、触覚、音
- VoiceOver、Dynamic Type、Reduce Motion等
- Loading／Empty／Offline／Error／Plus制限
- AppアイコンとApp Storeスクリーンショット
- 完成と判定する品質基準
- Claude Codeの実装順と完成報告形式

## 最終コンセプト

### SkyTrace — Living Observatory

> 世界の空を観測し、静かな紙面で読み、証拠の軌跡を辿る場所。

体験は3段階です。

1. **Observe** — 世界の空の現在像をつかむ
2. **Read** — 一つのCaseを落ち着いて読む
3. **Trace** — 時間・場所・資料・評価変化を辿る

見た目の素材も3つに分けています。

- **世界＝Atmosphere（大気）**
- **操作＝Glass（ガラス）**
- **理解＝Editorial Surface（紙面）**

## 特に重要な禁止事項

実装中に品質が普通のアプリへ戻らないよう、次を禁止しています。

- 全画面を角丸カードだらけにする
- 全面をLiquid Glassにする
- 紫と青のAIグラデーションへ寄せる
- 巨大な回転地球やレーダーを常設する
- 光点をずっと点滅させる
- 「未解明＝宇宙人」と見える演出
- 真実度を1個のパーセントで出す
- 出典や訂正を奥へ隠す
- 初回起動で通知・位置情報・課金を押しつける
- 正常画面だけ作り、通信失敗時を放置する

## Claude Codeへ渡す方法

1. ZIPを展開します。
2. 対象リポジトリの `docs/uiux/` にファイルを入れます。
3. リポジトリのルートでClaude Codeを開きます。
4. `10_CLAUDE_CODE_KICKOFF_PROMPT.md` の本文を貼ります。
5. 既存アプリがある場合、Claude Codeには最初に現状ビルドと構造確認を行わせます。

キックオフプロンプトは、設計だけして止まらず、可能な範囲で実際のSwiftUI実装・テスト・Simulator画像・レビュー報告まで進むようにしています。

## 推奨する進め方

最初は本番APIをつながず、Fixture（見本データ）で外側を完成させます。

1. 色・文字・状態記号
2. 4タブとナビゲーション
3. Today
4. Map
5. Search
6. Case詳細
7. 長文記事・Paywall・設定
8. Widget
9. アクセシビリティとiPad
10. 本番データ接続

この順番なら、API都合でUIの思想が崩れるのを防げます。

## 完成時に確認するもの

Claude Codeから最低限、次を出してもらう設計です。

- ビルド可能なXcodeプロジェクト
- 各画面と各状態
- Fixture／Preview
- テスト結果
- Simulatorスクリーンショット
- アクセシビリティ対応内容
- 品質基準の合否レポート
- 設計から変更した箇所と理由
- 本番APIやApp Store申請へ残る作業

## ファイルを読む順番

詳細を確認したい場合は、次の順番です。

- `01_UI_UX_MASTER_PLAN.md`：全体思想
- `02_DESIGN_SYSTEM_SPEC.md`：色・文字・素材
- `03_SCREEN_BLUEPRINTS.md`：全画面
- `04_COMPONENT_INVENTORY_AND_STATE_MATRIX.md`：部品と全状態
- `05_MOTION_HAPTICS_SOUND_SPEC.md`：動き・触覚・音
- `06_ACCESSIBILITY_ADAPTIVE_LAYOUT.md`：アクセシビリティ
- `07_APP_ICON_STORE_SURFACE.md`：アイコン・ストア
- `08_UI_QUALITY_GATES.md`：完成判定
- `09_CLAUDE_CODE_IMPLEMENTATION_PLAN.md`：実装順
- `10_CLAUDE_CODE_KICKOFF_PROMPT.md`：貼り付け用指示

## 最後に

この設計の中心は、「宇宙っぽく派手にすること」ではありません。

**空の美しさ、紙面の読みやすさ、証拠を辿れる誠実さを、同じアプリの中で両立すること**です。

そのため、世界を見る入口は詩的に、Caseを読む場所は明晰に、根拠を辿る場所は構造的に作ります。

