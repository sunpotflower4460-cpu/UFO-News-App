# SkyTrace — App Store 提出ガイド（手動作業まとめ）

このドキュメントは、**あなた（人間）が手動で行う必要がある残り作業のすべて**を、
順番どおりにまとめたものです。コード側の準備（アプリ本体、App Icon、法務ページ、
提出メタデータ下書き、バージョン1.0.0、Privacy Manifest、自動更新、多言語、
メディア権利ゲート）は完了しCIは green です。ここから先は、Apple アカウント・契約・
実機・設定トグルが必要なため、Claude Code では実行できません。

- 対象バージョン：**1.0.0（build 1）**
- 最終更新：2026-07-15
- 関連資料：`docs/APP_STORE_METADATA.md`（ASCへ貼り付ける文言一式）、
  `docs/MANUAL_ACTIONS.md`（項目ID M-0xx の対応表）、`docs/APP_STORE_CHECKLIST.md`

> 💡 全体像：**① 公開URLを実在化 → ② Apple契約・ID作成 → ③ 実機ビルド確認 →
> ④ ASCに情報入力 → ⑤ 提出**。所要は Apple 審査待ちを除き実働 半日〜1日程度。

---

## 0. 事前に用意するもの

| 必要なもの | 用途 | 備考 |
|-----------|------|------|
| Mac + **Xcode 26** | Archive / アップロード / 実機確認 | 本リポジトリは Linux/CI で作成。実機ビルドは Mac 必須 |
| **Apple ID** | Developer Program 登録 | 二要素認証を有効に |
| クレジットカード | Developer Program 年会費（**$99/年**） | 個人 or 法人 |
| iPhone 実機（推奨） | Sandbox 課金テスト | Simulator でも一部可 |
| 支払い受取用の**銀行口座・税情報** | Paid Apps 契約 | サブスク配信に必須 |
| 支払い可能な**サポート用メールアドレス** | サポートページ・審査連絡 | 個人Gmailでも可 |

---

## STEP 1 — 公開URL（プライバシー/規約/サポート）を実在化する 〔最優先〕

アプリ内の法務リンクは既に GitHub Pages 用に配線済みです。**Pages を有効化するだけ**で
実在URLになります。これをしないと審査でリンク切れ（404）になります。

### 1-1. GitHub Pages を ON
1. GitHub リポジトリ → **Settings** → 左メニュー **Pages**
2. **Build and deployment → Source** を **「GitHub Actions」** に設定
3. 保存すると、`.github/workflows/pages.yml` が `docs/site/` を自動公開します
   （手動実行する場合：**Actions** タブ → “Deploy legal/support site” → **Run workflow**）
4. 数分後、以下が開けることを確認：
   - プライバシー：`https://sunpotflower4460-cpu.github.io/UFO-News-App/privacy/`
   - 利用規約：`https://sunpotflower4460-cpu.github.io/UFO-News-App/terms/`
   - サポート：`https://sunpotflower4460-cpu.github.io/UFO-News-App/support/`

### 1-2. サポート連絡先メールを実アドレスに
初期値は暫定の `support@skytrace.app`（未運用）です。実際に受信できる住所へ変更します。
1. `scripts/generate_legal_site.py` の `SUPPORT_CONTACT = "support@skytrace.app"` を実アドレスへ
2. 再生成してコミット：
   ```bash
   python3 scripts/generate_legal_site.py
   git add docs/site && git commit -m "docs(site): set real support contact" && git push
   ```
3. main に入れば Pages が自動再デプロイされます。

> 🔁 **独自ドメインにしたい場合**：将来 `example.com` ではない自社ドメインを使うなら、
> `apps/ios/SkyTrace/Features/Settings/LegalPages.swift` の `externalURL` のホストを
> 差し替え、Pages のカスタムドメイン設定を行えば移行できます（任意・後回し可）。

---

## STEP 2 — Apple Developer Program に登録

1. <https://developer.apple.com/programs/> → **Enroll**
2. Apple ID でサインイン、個人（Individual）または法人（Organization）を選択
   - 法人は **D-U-N-S番号**が必要で承認に数日かかることがあります
3. 年会費 **$99** を支払い、登録完了を待つ（個人は即〜数時間）

---

## STEP 3 — Bundle ID（App ID）を登録し、コードを実値へ差し替え

現在はプレースホルダー `com.example.skytrace` です。あなたのアカウント固有のIDに変えます。

### 3-1. Apple で App ID を作成
1. <https://developer.apple.com/account> → **Certificates, IDs & Profiles** → **Identifiers** → **＋**
2. **App IDs** → **App** を選択
3. Bundle ID（例：`com.<yourname>.skytrace`）を **Explicit** で登録
   - Capabilities は今回特別なものは不要（In-App Purchase は既定で利用可）

### 3-2. リポジトリのプレースホルダーを差し替え（下表のとおり）

| 変更するもの | 現在値 | 変更先 | ファイル：該当箇所 |
|---|---|---|---|
| Bundle ID | `com.example.skytrace` | あなたのApp ID | `apps/ios/project.yml`（`bundleIdPrefix`, `PRODUCT_BUNDLE_IDENTIFIER`、staging行）|
| Bundle ID（Py生成器） | 同上 | 同上 | `scripts/generate_xcodeproj.py`（`com.example.skytrace` 各行）|
| Team ID | `DEVELOPMENT_TEAM: ""` | あなたの10桁TeamID | `apps/ios/project.yml`（既定は空。Xcodeの署名でも可）|

変更後、ローカルで再生成：
```bash
make ios-project        # または: xcodegen generate（apps/ios で）
```

> CI（`ios.yml`）はSimulator向けビルドのため署名不要で今のままでも green です。
> **署名が要るのは実機 Archive のとき**（STEP 7〜8）だけです。

---

## STEP 4 — App Store Connect でアプリと**サブスク商品**を作成

### 4-1. アプリを作成
1. <https://appstoreconnect.apple.com> → **My Apps** → **＋** → **New App**
2. Platform：iOS、Name：`SkyTrace`、Primary Language：日本語 or English、
   Bundle ID：STEP 3 で作ったもの、SKU：任意（例 `skytrace-ios-001`）

### 4-2. サブスクリプション商品を作成（**商品IDはコードと一致必須**）
1. アプリ → **Subscriptions** → Subscription Group を作成（例：`skytrace_plus`）
2. 商品を2つ追加し、**Product ID を下記と完全一致**させる：
   - 月額：`com.example.skytrace.plus.monthly` → **あなたのBundle IDに合わせた実値へ**
   - 年額：`com.example.skytrace.plus.yearly` → 同上
3. 価格（各国）、表示名・説明（ローカライズ）、無料トライアル（年額に1週間設定済みの想定）を設定
4. 審査用のスクショ／説明を各商品に添付

### 4-3. コード側の商品IDを一致させる
STEP 4-2 で決めた実値に、以下を合わせます（4か所）：

| ファイル：該当箇所 | 現在値 |
|---|---|
| `apps/ios/SkyTrace/Services/FakeSubscriptionProvider.swift`（`SubscriptionIDs.monthly/.yearly`）| `com.example.skytrace.plus.monthly` / `.yearly` |
| `apps/ios/SkyTrace.storekit`（`productID` 2か所）| 同上 |

> `SkyTrace.storekit` は**ローカル確認用**の構成です。実機/Sandboxでは ASC の実商品が使われます。

---

## STEP 5 — 契約・税・銀行（Paid Apps Agreement）

サブスク（有料）を配信するには必須です。
1. ASC → **Business**（Agreements, Tax, and Banking）
2. **Paid Applications** 契約に同意
3. **銀行口座**（受取先）と**税情報**（居住国のフォーム）を登録し、ステータスが
   Active になるまで進める

---

## STEP 6 — App Store Connect にメタデータを入力

`docs/APP_STORE_METADATA.md` の内容をコピペします。

- **App Information**：名称・副題・カテゴリ（News / Reference）
- **Privacy Policy URL**：`…/UFO-News-App/privacy/`（STEP 1で公開済み）
- **1.0.0 の Version 情報**：説明・キーワード・プロモーションテキスト・What's New（ja/en）
- **App Privacy**：質問に **「Data Not Collected（データ収集なし）」** で回答
  （`PrivacyInfo.xcprivacy` と一致。将来サーバ/解析/通知を足す時は同時に更新）
- **Age Rating**：全項目「なし」→ **4+**（心配なら 9+/12+ でも可）
- **App Review Information**：`APP_STORE_METADATA.md` §6 の Review Notes を貼付
  （アカウント不要／Plusの開き方／Sandbox手順／UAPは断定しない旨）
- **サポートURL**：`…/UFO-News-App/support/`

### スクリーンショット
- 必須サイズ：**6.9"（1320×2868, iPhone 16 Pro Max 相当）**を1セット（Appleが縮小生成）
- CI で撮影する場合：`.github/screenshot-trigger` を touch して push すると
  `screenshots.yml` が Pro Max 優先で撮影し `docs/uiux/screenshots/` にコミットします
  （既存キャプチャあり）。最終的な**マーケ用の枠・キャプション付け**は手動で調整推奨。

---

## STEP 7 — Xcode で署名設定

1. Mac で `apps/ios/SkyTrace.xcodeproj` を開く（無ければ `make ios-project`）
2. **SkyTrace ターゲット → Signing & Capabilities**
3. **Automatically manage signing** を ON、**Team** に自分のTeamを選択
4. Bundle ID が STEP 3 の実値になっていることを確認

---

## STEP 8 — Archive してアップロード

1. Xcode の実行先を **「Any iOS Device (arm64)」** に
2. メニュー **Product → Archive**（ビルドが通ることをここで最終確認）
3. Organizer が開く → **Distribute App → App Store Connect → Upload**
4. 処理完了後、ASC の該当バージョンで **Build** に表示されるまで数分〜十数分待つ

> ⚠️ 本アプリは Linux/CI 環境で作成しており、**実機での Archive/署名は未実施**です。
> Swift 6 strict concurrency は CI で通っていますが、実機固有の指摘が出た場合は
> Xcode の指示に沿って修正してください。

---

## STEP 9 — Sandbox で課金（購入・復元）を実機確認

1. ASC → **Users and Access → Sandbox → Testers** でテスターを作成
2. iPhone：**設定 → App Store → （最下部）Sandbox Account** にテスターでサインイン
3. アプリを実機に入れて：
   - **今日タブ → Daily Briefing**、または任意の **Case → AI統合記事 → ペイウォール**
   - 月額/年額を購入 → 記事が開くこと
   - **購入を復元**が機能すること
   - 価格・期間・自動更新・無料体験・規約/プライバシー・閉じる が表示されること

---

## STEP 10 — 提出

1. ASC の 1.0.0 で **Build** を選択、全項目（メタデータ・スクショ・Privacy・Rating・Review Notes）が
   埋まっていることを確認
2. **Add for Review → Submit for Review**
3. 審査待ち（通常1〜3日）。指摘が来たら Resolution Center で対応

---

## 付録A — プレースホルダー差し替え早見表

| 種別 | 現在値（プレースホルダー） | 変更先 | 場所 |
|------|--------------------------|--------|------|
| Bundle ID | `com.example.skytrace` | あなたのApp ID | `project.yml`, `scripts/generate_xcodeproj.py` |
| Team ID | `""` | 10桁 Team ID | `project.yml`（または Xcode 署名）|
| 商品ID（月/年） | `com.example.skytrace.plus.monthly` / `.yearly` | ASCの実商品ID | `FakeSubscriptionProvider.swift`, `SkyTrace.storekit` |
| サポートメール | `support@skytrace.app` | 実アドレス | `scripts/generate_legal_site.py`（再生成）|
| 法務ホスト（任意） | `sunpotflower4460-cpu.github.io` | 独自ドメイン | `LegalPages.swift` |

> これらは互いに整合させる必要があります。特に **商品ID はコード（4か所）と ASC で完全一致**、
> **Bundle ID は Apple登録・project.yml・ASC で一致**が必須です。

---

## 付録B — よくある審査観点（事前対策済み）

| 観点 | 本アプリの状態 |
|------|----------------|
| 有料は IAP のみ・外部決済誘導なし | ✅（StoreKit 2、外部リンクなし）|
| ペイウォールに価格/期間/更新/復元/規約/プライバシー/閉じる | ✅ |
| プライバシー：読むだけでアカウント/位置不要、追跡なし | ✅（Privacy Manifest 一致）|
| リンク集ではない実体あるアプリ（地図/スコア/キャッシュ/詳細）| ✅ |
| UAP を「宇宙人」と断定しない・スコアの意味明記 | ✅（Review Notes 記載）|
| UGC/コメントなし（Release で無効）| ✅ |
| 汎用ブラウザなし（出典リンクのみ）| ✅ |

---

## 付録C — 参照

- `docs/APP_STORE_METADATA.md` — ASC に貼り付ける文言（名称/説明/キーワード/審査メモ/Privacy回答）
- `docs/MANUAL_ACTIONS.md` — 項目ID（M-010〜M-023）との対応
- `docs/APP_STORE_CHECKLIST.md` — 提出前チェック
- `docs/DECISIONS.md` — 設計判断（D-STORE-001〜005 ほか）
