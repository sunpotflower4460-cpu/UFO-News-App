# UI Implementation Log — SkyTrace UI/UX V2

このログは、V2 UI/UX（Aether Editorial System）実装の決定・逸脱・コマンドを記録する。
正本は `docs/uiux/` の各文書。矛盾時の優先順位は `09_..._PLAN.md` §21 に従う。

## ベースライン

- V2着手時点で、Phase 0/1（fixtureベースの完成体験）は PR #1 として `main` にマージ済み。
- **実CI（Xcode 16.4 / Swift 6 / iOS 17 simulator）でビルド・ユニットテストがgreen**であることを検証済み。
  - 実CIが検出した実バグ5件を修正してからマージ（`FormatStyle.timeZone` / `Haptics` MainActor / actor越しUserDefaults / `??`内await / UIテスト`@MainActor` / `CFBundleIdentifier`欠落）。
- ランナーに Xcode 26 は無くデフォルト Xcode 16.4 を使用。deployment target は iOS 17 のまま（V2文書はiOS 26推奨だが、既存プロジェクトの意図的な下限を尊重＝`09_..._PLAN.md` §2/§26 の許容範囲）。iOS 26固有表現は `if #available` で段階採用する。

## 作業ブランチ

- `claude/skytrace-uiux-v2`（`main` から作成）。

## 既存実装で保持する挙動（破壊しない）

- 4タブ（今日/地図/探す/設定）、Repository protocol による fixture/API 差し替え、StoreKit 2 抽象、アクセシビリティ基盤、feature flags（UGC off）、Privacy Manifest。
- Case中心モデル、出典・更新履歴・AI開示、Demoフラグ。

## V2での主な進化（Phase 1文書との差分）

| 項目 | Phase 1（現状） | V2目標 |
|------|----------------|--------|
| デザイン系 | SkyColor 等の semantic tokens | Aether Editorial System（atmosphere/glass/editorial の3素材、status geometry 8種） |
| Status語彙 | 7種 | 8種（newReport/underReview/informationInsufficient/knownExplanationLikely/explained/disputed/corrected/archived） |
| 評価 | 4軸スコア（数値） | Assessment dimensions（複数軸・定性＋根拠、単一真実度は不使用を継続） |
| Today | Hero+Briefing+注目+更新 | World Sky Pulse + Daily Briefing + Priority Case + Since Your Last Visit + Case Stream |
| Case詳細 | 概要/スコア/一致/矛盾/照合/記事/... | 12節（Header/What Changed/What Happened/Assessment/Confirmed Facts/Agreement/Contradictions/Evidence/Explanations Considered/Timeline/Sources/Related Cases） |
| Widget | なし | Small/Medium/Lock（fixture） |

「単一真実度スコアを出さない」「未解明＝地球外起源としない」「色だけで状態を伝えない」「出典・訂正は無料」等の原則は Phase 1 から継続。

## 実装方針（安全性）

- 各Phaseはビルドが通る単位でコミットし、実CIでgreenを確認してから次へ。
- 置換対象は、代替がビルド・テストを通るまで削除しない（`09_..._PLAN.md` §6.7）。
- V2の新Statusは、既存Statusとの対応表を持って移行する。

## 進捗

### Phase 0 — Audit & Safety
- Status: complete
- ブループリント一式を `docs/uiux/` へ配置（zip展開、日本語ファイル名2件はASCII化）。
- 本ログ作成。ベースラインは merged main（CI green）。

### Phase 1 — Design foundation & fixtures
- Status: complete（実CI green）— Aetherトークン、8ステータス幾何、AtmosphereCanvas、EditorialSurface、モーション、Design Gallery。

### モデル進化（Phase 6下地）
- Status: complete（実CI green）— AssessmentDimension/CaseChangeEntry/ConfirmedFact/RelatedCaseRef、UAPCase+V2導出、編集ロー。

### Phase 6 — Case Detail V2（12節）
- Status: complete（実CI green, 24698aa）— Header/What Changed/What Happened/Assessment/Confirmed Facts/Agreement/Contradictions/Evidence/Explanations/Timeline/Sources/Related。Design Galleryから到達。

### Phase 3/4/5 — Today/Map/Search V2 + タブ切替
- Status: complete（実CI green, 18dbd7b）— 4タブがV2画面に。WorldSkyPulse + Briefing lead + Priority Case + Since Your Last Visit + Case Stream。Design Galleryから到達。



### Phase 7 — Long-form / Phase 8 — Widgets
- Long-form: complete（実CI green, a20390a）— LongFormView（Editorial reading, Plusゲート, disclosure）。Case Detail V2 と Gallery から到達。
- Widgets: content views + TimelineProvider + StaticConfiguration をアプリターゲットに実装（in progress）。**extensionターゲット化は M-050（Xcode必須）**。Gallery に content preview。

### 残（人手/macOS）
- VoiceOver実機・AX5・Reduce Motion/Transparency確認、スクリーンショット、Instruments（M-051）。
- Widget extension ターゲット（M-050）。実データ接続（Phase 11）、App Store提出（Phase 12）。

## Decisions / Deviations
- D-V2-001: deployment target は iOS 17 を維持（既存の意図的下限）。V2のiOS 26推奨に対する逸脱理由を記録。
- D-V2-002: 文字列は当面 `SkyStrings`（コード内表）を継続使用（Phase 1のD-006を踏襲）。

## Commands
- `python3 scripts/generate_xcodeproj.py`（XcodeGen未導入時のプロジェクト生成）
- CI: `.github/workflows/ios.yml`（build-for-testing + unit tests、実コンパイル検証）
