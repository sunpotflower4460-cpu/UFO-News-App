# UI Review Checklist

Simulator/実機での確認項目。`✅`は設計上満たすよう実装済み、確定はSimulator確認で。

## 世界観・情報設計
- [ ] 世界観が静かすぎ/派手すぎでないか（Observatory Editorial）
- [ ] Todayの情報量が30秒で把握できるか
- [ ] Case Detailで結論と根拠を追えるか（3分）
- [ ] 4軸スコアが誤解されないか（特に既知現象一致度）
- [ ] Plusの価値が無料部分から自然に伝わるか
- [ ] 地図とニュースの主役バランス
- [ ] 日本語コピーに硬さ/煽りがないか
- [ ] Dark/Light両方でブランドが成立するか

## 動作
- [ ] 4タブが動作、主要遷移に行き止まりがない
- [ ] 8件以上のDemo Caseが空でない（9件）
- [ ] Map → 詳細へ遷移できる
- [ ] 検索・フィルター・保存が動作
- [ ] PlusロックとPaywall表示 → ローカル購入 → 解放 → Freeへ戻す（Debug）
- [ ] 購入復元が動作
- [ ] Offline/Errorでクラッシュしない（キャッシュ表示）
- [ ] Pull to Refreshの触覚と完了表示

## 状態
- [ ] Loading（skeleton）/ Empty / Error / Partial / Offline / Demo / Stale をDebug「状態プレビュー」で確認
- [ ] Demoデータが本番ニュースに見えない（DEMOバッジ）

## アクセシビリティ
- [ ] Dynamic Type最大付近で主要CTAに到達
- [ ] VoiceOverの読み順が自然（CaseCardは1要素で状態→タイトル→出典→更新）
- [ ] 色だけで状態を伝えていない
- [ ] Reduce Motionで常時アニメーション停止（glyph/skeleton）
- [ ] Bold Text / Increase Contrastで崩れない
- [ ] タップ領域44pt以上

## 端末幅
- [ ] 最小幅（iPhone SE等）
- [ ] 標準幅（iPhone 16）
- [ ] 最大幅（iPhone 16 Pro Max）
