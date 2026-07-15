# App Store Connect — 提出用メタデータ（下書き）

App Store Connect へそのまま貼り付けられる形の下書き。文字数は各フィールドの
Apple 上限に収めてある。**本番の Bundle ID / 商品ID / サポート連絡先は未確定**
（`MANUAL_ACTIONS.md` 参照）。翻訳は ja / en を正本とし、他ストア地域は当面 en を
流用（`Info.plist` の `CFBundleLocalizations` は12言語を宣言済み）。

バージョン：**1.0.0**（build 1） / 初回リリース

---

## 1. 基本情報

| フィールド | 値 |
|-----------|----|
| App Name（≤30） | `SkyTrace` |
| Subtitle 日本語（≤30） | `出典で追う、空の観測ニュース` |
| Subtitle English（≤30） | `Sky events, sourced & scored` |
| Primary Category | News |
| Secondary Category | Reference |
| Bundle ID | `com.example.skytrace` → **要差し替え（M-010）** |
| SKU | `skytrace-ios-001`（任意・内部管理用） |
| Price | Free（アプリ本体無料 + App内サブスク） |

### URL（GitHub Pages・実在HTTPS）
| 種別 | URL |
|------|-----|
| Privacy Policy URL | `https://sunpotflower4460-cpu.github.io/UFO-News-App/privacy/` |
| Support URL | `https://sunpotflower4460-cpu.github.io/UFO-News-App/support/` |
| Marketing URL（任意） | `https://sunpotflower4460-cpu.github.io/UFO-News-App/` |

> 前提：リポジトリ Settings → Pages → Source を「GitHub Actions」に設定（一度きり）。
> `.github/workflows/pages.yml` が `docs/site/` を自動デプロイする。

---

## 2. Promotional Text（≤170）

**日本語**
> 世界の空で報告されたUAPを、出典・証拠・不確実性とともに。断定せず、既知現象との照合を先に。4軸スコアと更新履歴で「わかっていること」と「まだ不明なこと」を分けて見せます。

**English**
> Reported sky events (UAP) with their sources, evidence, and uncertainty. No hype: known-phenomena checks first, four-axis scores, and an update history that separates what’s known from what’s still unknown.

---

## 3. Description（≤4000）

**日本語**
```
SkyTraceは、世界の空で報告されたUAP（未確認航空現象）を、出典・証拠・不確実性とともに整理する観測ニュースアプリです。センセーショナルに「宇宙人」と断定することはしません。まず航空機・衛星・火球・天体・気象などの既知現象と照合し、それでも説明しきれずに残る部分だけを「未解明」として示します。

■ Case単位で統合
個々の記事ではなく、同じ空の事象（Case）ごとに情報を束ねます。いつ・どこで・何が報告され、どの証拠がそれを支持し、どこが矛盾しているのかを一望できます。

■ 4軸スコア
単一の「信ぴょう性」点数は出しません。証拠品質・独立報告性・既知現象一致度・未解明度の4つの軸で、事象の性質を分けて表示します。「既知現象一致度が高い＝説明可能」という意味も明記します。

■ 出典と証拠を前面に
各出典には媒体名・種別・公開日時・役割（支持／反証／文脈）を明示。権利が確認できた画像・映像のみをアプリ内に表示し、権利が不明なものは情報源へのリンクのみとします。無断転載は行いません。

■ AIは編集助手
AIは複数の資料を整理し、一致点・矛盾点・情報不足を可視化して読みやすくまとめます。真実を宣言する権威ではありません。公開される各事実文は出典または照合結果へ追跡でき、推論は「推論」、不明は「不明」と明示します。

■ 更新と訂正の履歴
評価は新情報で更新し、変更履歴を残します。訂正しても過去の評価や監査記録は消しません。

■ プライバシー最小設計
読むだけならアカウント登録も正確な位置情報も不要。追跡型広告や広告IDは使いません。

■ SkyTrace Plus（サブスクリプション）
毎日のブリーフィングと、事例別のAI統合記事を読めます。自動更新サブスクリプションで、App Storeのアカウント設定からいつでも管理・解約できます。復元にも対応します。

世界中でお使いいただけるよう、多言語UIに対応しています。
```

**English**
```
SkyTrace is an observational news app that organizes reported UAP (Unidentified Anomalous Phenomena) in skies around the world, together with their sources, evidence, and uncertainty. It never sensationally declares “aliens.” It first checks against known phenomena — aircraft, satellites, fireballs, astronomical bodies, weather — and presents only what remains unexplained as “unresolved.”

■ Organized by Case
Instead of individual articles, information is grouped by the same sky event (a Case). See at a glance when and where something was reported, which evidence supports it, and where accounts contradict.

■ Four-axis scores
No single “credibility” number. Four separate axes — evidence quality, independent reporting, known-phenomena match, and unresolvedness — describe the nature of an event. A high known-phenomena match explicitly means “more likely explainable.”

■ Sources and evidence up front
Each source shows the outlet, type, publication date, and role (support / rebuttal / context). Only rights-cleared images and video appear inline; anything with unclear rights links out to the source instead. Nothing is redistributed without permission.

■ AI as an editorial assistant
AI organizes multiple sources, surfaces agreements, contradictions, and gaps, and composes them into readable articles. It is not an authority that declares the truth. Every published factual sentence can be traced to a source or a check; inference is labeled “inference” and unknowns are stated as “unknown.”

■ Update and correction history
Assessments are updated as new information arrives, with a change history. Corrections never erase past assessments or the audit record.

■ Privacy by design
Reading requires no account and no precise location. No tracking ads, no advertising identifier.

■ SkyTrace Plus (subscription)
Read the daily briefing and per-case AI synthesis. An auto-renewing subscription you can manage or cancel anytime from your App Store account settings, with restore-purchases support.

A multilingual UI so people around the world can use it.
```

---

## 4. Keywords（≤100・カンマ区切り）

**日本語**
```
UAP,UFO,未確認,目撃,空,ニュース,証拠,出典,天文,現象,火球,観測,スコア,検証
```

**English**
```
UAP,UFO,sighting,sky,news,evidence,sources,astronomy,phenomena,fireball,report,science,verify
```

---

## 5. What’s New（リリースノート・1.0.0）

**日本語**
> SkyTrace 初回リリース。UAPをCase単位で整理し、4軸スコア・出典・証拠・更新履歴とともに表示します。アプリ内自動更新、権利確認済みメディアの表示、多言語UI、SkyTrace Plusサブスクリプションに対応。

**English**
> The first release of SkyTrace. Explore UAP organized by Case, with four-axis scores, sources, evidence, and an update history. Includes in-app auto-refresh, rights-cleared media, a multilingual UI, and the SkyTrace Plus subscription.

---

## 6. App Review Information（審査担当への情報）

- **Sign-in required?** No. 読むだけならアカウント不要（`D-003`）。デモアカウント不要。
- **Demo account:** 不要（アカウント機能なし）。
- **Contact:** （提出者の氏名・電話・メール＝App Store Connect 上で入力）

### Review Notes（コピー用）
```
About the content
- "UAP" means Unidentified Anomalous Phenomena. This app does NOT claim an
  extraterrestrial origin. It checks known explanations (aircraft, satellites,
  fireballs, weather, astronomy) first and labels what remains as "unresolved."
- No single "credibility" score is shown. Four axes are used; note that a HIGH
  "known-phenomena match" means MORE explainable (not more mysterious).
- AI-generated article sections are labeled, and each factual sentence maps to a
  source or a computed check. Inference is labeled; unknown stays unknown.

Data & privacy
- Reading requires no account and no precise location. No tracking, no IDFA.
- Settings/bookmarks are stored on-device only (UserDefaults). See the Privacy
  Manifest (PrivacyInfo.xcprivacy): no data collected, tracking = false.

Subscription (SkyTrace Plus)
- In-App Purchase only; no external payment links.
- How to reach paid content: Today tab → Daily Briefing, or open any Case →
  the AI synthesis article → paywall for gated blocks.
- The paywall shows price, period, auto-renewal, free trial (if any), Restore
  Purchases, Terms, and Privacy.
- Sandbox: sign in with a Sandbox tester in Settings → App Store, then purchase
  monthly/yearly and use "Restore Purchases." (See docs/MANUAL_ACTIONS.md M-013.)

Not in this release
- No user-generated content, comments, or public profiles (disabled).
- No always-on / precise location. In-app links open curated source pages only
  (no general-purpose web browser).
```

---

## 7. App Privacy（Nutrition Label 回答）

`PrivacyInfo.xcprivacy` と一致させること（`NSPrivacyTracking=false`、収集データ配列は空、
UserDefaults 理由 `CA92.1`）。

- **Data used to track you:** なし。
- **Data linked to you:** なし。
- **Data not linked to you:** なし（**Data Not Collected** を選択）。
- **Does this app collect data?** → **No**（初回リリースはサーバ送信・解析なし）。

> 将来サーバAPIや解析・プッシュ通知を追加した時点で、この回答と
> `PrivacyInfo.xcprivacy` を同時に更新する（`M-021`）。

---

## 8. Age Rating（推奨回答）

年齢制限アンケートは全項目「なし / None」を想定 → **4+**。
- Unrestricted Web Access：**No**（汎用ブラウザなし。出典リンクのみ）。
- Contests / Gambling / Medical など：**No**。
- 過激・暴力・成人向け表現：**None**。

> 「空の未確認現象のニュース」という性質上、心配なら 9+/12+ でも可。既定は 4+ を推奨。

---

## 9. Localizations（メタデータ言語）

- 正本：**日本語 / 英語（英米）**。
- その他のストア地域（es, fr, de, pt, zh-Hans, zh-Hant, ko, ar, hi, ru）は、
  当面 English メタデータを流用（アプリUIは各言語対応済み・B3）。必要になれば
  各地域メタデータを追加翻訳。

---

## 10. Screenshots

- `docs/uiux/screenshots/` に CI 実機キャプチャあり（Today / Map / Search /
  Settings / Case Detail、Arabic RTL・Spanish 含む）。
- App Store の必須サイズは **6.9"（iPhone 16 Pro Max 相当）** と **6.5"**。
  提出前に対象シミュレータで再キャプチャして充当（`screenshots.yml`／`M-002`）。
