# News First / AI Second — Baseline (before/after)

対象: `SKYTRACE_NEWS_FIRST_PRODUCTION_DIRECTIVE.md` / `CLAUDE_CODE_NEWS_FIRST_KICKOFF.md`
ブランチ: `product/news-first-production-foundation`（このセッションでは既存の
作業ブランチ `claude/new-session-a8tzzb` 上で実装）

> 本環境はLinuxのため、実SimulatorでのScreenshot取得ができない
> （`docs/PROGRESS.md`のこれまでの制約と同じ）。本ドキュメントは実装した
> コード構造から情報順序を記述する。実画像は `MANUAL_ACTIONS.md` M-061 の
> `ScreenshotUITests` 実行後に追加する。

## 1. Case Detail — 情報順序 before/after

### Before（V3、本セッション開始時点）

```text
1. CaseLeadVisual（抽象雰囲気ビジュアル、ステータス色）
2. CaseStatusLabel（大きめのステータス表示）
3. タイトル
4. 場所・位置精度
5. 発生/公開/最終検証 時刻
6. ProvenanceRow（出典数・独立報告数）
7. CaseExecutiveSummary（現時点の判断・有力な説明候補・未解決点）
8. 前回からの変化
9. 何が起きたか（要約＋現在の評価）
10. 確認済みの事実
11. 現在の評価（8軸 AssessmentDimensionRow、常時展開）
12. 一致している点／食い違う点
13. 資料（Evidence records）
14. 映像・画像（あれば）
15. 既知現象との照合
16. 更新タイムライン
17. 出典
18. 関連する事例
19. AI・編集方針（AI統合記事リンク＋開示文＋信頼のしくみリンク）
```

課題: 8軸評価・現時点の判断が画像・出典より先に、しかも常時展開で表示される。
画像はタイトルから遠く、標準/コンパクトのCaseCardには画像が一切ない。

### After（News First / AI Second）

```text
1. NewsCaseHeader
   - ステータスは小さいアイコンのみ（コンパクトバッジ）
   - タイトル
   - 媒体名（"○○が報道" / "○○ほかN媒体が報道"）
   - 場所・位置精度
   - 発生日時・最初の報道日時・最終更新
2. PrimaryNewsMediaView（画像・映像を最上部、権利ゲート済み）
   - 権利確認済み → 大きなインライン画像/映像＋出典/権利/「元の画像/映像を見る」
   - 権利未確認 → リンクのみ（画像は表示しない）
   - 画像なし → ObservationGlyph（抽象ビジュアル、最後の手段）
3. PrimarySourceActions（「○○の記事を読む」等、最大3件、媒体種別で動詞を変更）
4. PremiumSummarySection（「3分でわかるまとめ」— Free: 冒頭のみ＋Paywall / Plus: 全文）
5. このニュースで確認できること（旧「確認済みの事実」を改題）／何が起きたか／既知現象との照合
6. 資料（Evidence records）
7. 元ニュース・資料（出典一覧、旧「出典」を改題）
8. 前回からの変化／更新タイムライン
9. AIReferenceDisclosure「AIの補足を見る」（既定：閉）
   - 中身：現時点の判断（旧CaseExecutiveSummary）→ AI統合記事リンク → 開示文 → 信頼のしくみ
10. DetailedAssessmentDisclosure「詳しい確認データ」（既定：閉）
    - 中身：8軸評価（やさしい言い換え済み）＋ 一致している点／食い違っているところ
11. 関連する事例
```

完了条件チェック（指示書§18）:
- [x] 最初の1画面にAI判断を出さない（AI関連コンテンツは全てdisclosure内）
- [x] 画像またはニュース情報が最初に見える
- [x] 1タップで元記事へ移動（`PrimarySourceActions`）
- [x] AI補足は初期状態で閉じている（`@State private var isExpanded = false`）
- [x] Premium価値が要約として分かる（`PremiumSummarySection`）
- [x] 専門語を知らなくても読める（下記コピー変更）

## 2. Today — 情報順序 before/after

### Before

```text
1. WorldSkyPulse（世界概況ヒーロー、250pt、新規/統合/更新の3数値）
2. Daily Sky Briefing リード（AIDisclosureBadgeが最初に見える）
3. 注目の事例（Priority Case、sparklesアイコンの理由ラベル）
4. 昨日からの更新
5. 今週更新された事例
```

### After

```text
1. 今日の空のニュース（Priority Caseを画像付きで最上段へ、"記事を読む"明示CTA）
2. 更新されたニュース（Since Last Visit）
3. 新着ニュース（Case Stream、CaseCardは全てメディア先頭）
4. 今日のニュースまとめ（旧Daily Sky Briefing、AIは行末に小さく
   「AIで整理・出典を確認」とだけ表示）
5. WorldSkyPulse（世界全体の数値、後段へ移動 — 視覚サイズの縮小はM-062残課題）
```

## 3. AIを補助役へ変更した内容

- Case Detailの「AI・編集方針」セクションを`AIReferenceDisclosure`（既定閉）に変更し、
  ラベルを「AIの補足を見る／複数の情報を読み比べるための参考情報です」に変更。
- 旧`CaseExecutiveSummary`（「現時点の判断」）をページ上部から外し、AI補足の中へ移動。
- BriefingDetailView/LongFormViewの`AIDisclosureBadge`をヘッダー先頭から末尾（footer）へ移動。
- Todayの見出しに使っていた`sparkles`アイコン（AIっぽい記号）を`newspaper`/`clock.arrow.circlepath`へ変更。
- 8軸評価・一致点/矛盾点を`DetailedAssessmentDisclosure`（既定閉）へ格下げ。

## 4. やさしくした主要コピー（抜粋、全量は git diff 参照）

| 旧 | 新 |
|---|---|
| 現在の評価（`assess.sectionTitle`） | 詳しい確認データ |
| 報告の独立性 | 別々の人・場所からの報告 |
| 映像資料の来歴 | 画像や記録の確かさ |
| 既知現象との一致 | 飛行機や人工衛星などで説明できそうか |
| 不足情報 | まだ足りない情報 |
| 一致している点 | 情報が同じところ |
| 食い違う点 | 情報が食い違っているところ |
| 確認済みの事実 | このニュースで確認できること |
| 出典 | 元ニュース・資料 |
| Daily Sky Briefing | 今日のニュースまとめ |
| 注目の事例 | 今日の空のニュース |
| AI統合記事 | 複数の情報をまとめて読む |
| AI・編集方針 | AIの補足を見る |
| データ取得に失敗しました | ニュースを読み込めませんでした。通信状態を確認して、もう一度お試しください。 |

## 5. 元記事・画像アクセス

- `PrimaryNewsMediaView`: 権利確認済みの画像/映像を最上部にインライン表示し、
  「元の画像を見る」「元の映像を見る」ボタンを必ず併記。権利未確認は
  リンクカードのみ（画像を表示しない）。
- `PrimarySourceActions`: 最大3件、媒体種別ごとに動詞を変える
  （official→「の発表を見る」、press→「の記事を読む」、scientific→「の資料を見る」等）。
- 出典一覧（`SourceRow`、旧「出典」節）はFreeユーザーでも常時閲覧可能
  （Premium限定にしない — 指示書§禁止 に対応）。

## 6. Premium要約

`PremiumSummarySection`（「3分でわかるまとめ」）:
- 「報じられていること」（Free/Plus共通、`summary`から）
- 「確認できたこと」（Plusのみ、`agreements`から）
- 「まだ分からないこと」（Plusのみ、`missingInformation`＋`contradictions`から）
- Freeユーザーは冒頭行＋`PremiumLockView`（「確認できたこと」「まだ分からないこと」が
  解放されると明示）→ 文脈型Paywall（`PaywallContext.Trigger.summary`を新設）。

## 7. 本番基盤の実装範囲（Phase 2）

- `docs/openapi/skytrace-v1.yaml`: 9エンドポイントの契約（OpenAPI 3.1）。
- `services/api`: FastAPIローカルモックサーバ（fixtureのみ、`isDemo: true`固定）。
  `pytest tests/` 9件green（ETag/304、rights gate、404、production起動拒否 等）。
- iOS: `SkyTraceAPIClient`（actor、ETag/backoff/cancellation/locale header/request-id）、
  `APIMapping`（DTO→Domain変換）、`ProductionFeedRepository`/`ProductionCaseRepository`/
  `ProductionBriefingRepository`。`AppEnvironment.apiBaseURL`が明示設定された場合のみ有効化。
- Settings開発者セクションにAPIのURL入力欄を追加（Debug-only）。

## 8. 本番化に残る外部／契約作業

`docs/MANUAL_ACTIONS.md`「News First / AI Second」節（M-060〜M-064）と、
既存のPhase 3〜6項目（実データ源の契約・権利確認・クラウドインフラ・APIキー等）を参照。
