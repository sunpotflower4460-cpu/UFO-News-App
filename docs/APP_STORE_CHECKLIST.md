# App Store Readiness Checklist

提出前の停止条件と確認項目。1つでも未完なら提出しない（CLAUDE_CODE_PHASES 7章）。
凡例：✅ 実装済 / 🟡 部分・要検証 / ⬜ 未着手（後続Phase）

## ビルド／プラットフォーム
- 🟡 Xcode 26+ / iOS 26 SDK / deployment target iOS 17（設定済、macOSでのビルド確認は M-001）
- 🟡 no-warnings目標（strict concurrency有効、実ビルド未確認）
- ⬜ Release archive / dSYM アップロード（Phase 9）

## サブスクリプション
- ✅ StoreKit 2、In-App Purchaseのみ（外部決済誘導なし）
- ✅ Paywallに価格/期間/自動更新/無料体験/復元/規約/プライバシー/閉じる
- ✅ 価格はStoreKit由来（ハードコードなし）
- ✅ Entitlement状態：active/pending/grace/retry/expired/revoked を扱う
- ✅ 通信障害だけで即ロックしない
- 🟡 ローカルStoreKitで購入/復元確認（Simulator確認は M-001）
- ⬜ Sandbox実機確認、サーバ署名検証（Phase 6 / M-013）

## プライバシー
- ✅ 読むだけならアカウント不要、正確な位置情報不要、追跡広告なし
- ✅ `PrivacyInfo.xcprivacy`（tracking false、UserDefaults理由CA92.1）
- 🟡 App Privacy回答と実装の一致（提出時に確認 M-021）
- ✅ 通知は初回起動で要求しない

## コンテンツ／審査適合
- ✅ ネイティブ地図・状態/スコアUI・オフラインキャッシュ・ブックマーク・更新タイムライン・深いCase Detail（リンク集ではない）
- ✅ UGC無効（feature flag false、Debug外で到達不能）
- ✅ AI記事の各事実文が出典へ追跡可能（citation gateをfixtureで担保、テスト有）
- ✅ 「宇宙人確率」等の断定指標を出さない
- 🟡 Demoデータは`DEMO`表示。**本番では非表示にすること**（現在はfixtureのみ）
- ⬜ source rights承認済みの本番データ（Phase 3）

## リンク／サポート
- 🟡 Privacy/Terms/Support URL（現在プレースホルダー`skytrace.example.com`。`ReleaseLinkAudit`が検出。M-020）
- ✅ アプリ内に編集/AI/スコア/出典/訂正の各方針ページ

## アクセシビリティ
- ✅ Dynamic Type（最大付近でCTA到達可能な設計）
- ✅ VoiceOverラベル（CaseCard結合ラベル等）
- ✅ 色以外でも状態判別（アイコン＋語）
- ✅ Reduce Motion対応
- ✅ Light/Dark両対応

## Review Notes（下書き）
- UAPは未確認現象を指し、地球外起源を断定しない。
- 4軸スコアの意味（特に既知現象一致度は「高い＝説明可能」）。
- AI生成箇所と出典表示の位置。
- Plus記事の開き方：今日 → Daily Briefing / Case Detail のAI統合記事 → Paywall。
- Sandbox購読テスト手順（M-013）。
- 投稿機能はReleaseで無効。位置情報は常時利用しない。
