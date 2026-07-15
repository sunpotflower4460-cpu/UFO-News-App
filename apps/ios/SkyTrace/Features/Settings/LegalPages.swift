import SwiftUI

/// Native legal / editorial pages. These ship real drafted copy (not lorem),
/// and each also points to a production HTTPS URL that must be valid in Release
/// (validated by `ReleaseLinkAudit`). See MANUAL_ACTIONS.md for hosting.
enum LegalPage: String, CaseIterable, Identifiable {
    case editorial, ai, scores, sources, correction, privacy, terms, support
    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .editorial: "legal.editorial"; case .ai: "legal.ai"; case .scores: "legal.scores"
        case .sources: "legal.sources"; case .correction: "legal.correction"
        case .privacy: "legal.privacy"; case .terms: "legal.terms"; case .support: "legal.support"
        }
    }

    var systemImage: String {
        switch self {
        case .editorial: "text.book.closed"; case .ai: "sparkles"; case .scores: "gauge.with.dots.needle.50percent"
        case .sources: "doc.text"; case .correction: "pencil.and.outline"
        case .privacy: "hand.raised"; case .terms: "doc.plaintext"; case .support: "lifepreserver"
        }
    }

    /// Production URL. Served as static pages via GitHub Pages (docs/site,
    /// deployed by .github/workflows/pages.yml). Swap the host here if a custom
    /// domain is adopted later. `ReleaseLinkAudit` enforces a valid HTTPS host.
    var externalURL: URL? {
        URL(string: "https://sunpotflower4460-cpu.github.io/UFO-News-App/\(rawValue)/")
    }

    /// Native long-form body (Japanese primary).
    var body: String {
        switch self {
        case .editorial:
            """
            SkyTraceは、世界の空で報告された事象を、出典・証拠・不確実性とともに記録する観測ニュースサービスです。

            ・「未解明」を「地球外起源」とは断定しません。
            ・記事は記事単位ではなくCase（同一の空の事象）単位で統合します。
            ・既知現象（航空機・衛星・火球・天体・気象など）との照合を先に行い、それでも残る部分を未解明として示します。
            ・評価は後日の新情報で更新し、変更履歴を残します。訂正しても過去の評価や監査記録は消しません。
            ・単一の「信ぴょう性」点数は用いず、証拠品質・独立報告性・既知現象一致度・未解明度の4軸で示します。
            """
        case .ai:
            """
            AIは、複数の資料を整理し、一致点・矛盾点・情報不足を可視化し、読みやすい記事にまとめる編集助手です。真実を宣言する権威ではありません。

            ・AIは地球外起源を断定しません。
            ・公開される各事実文は、出典または計算・照合結果へ追跡できます。
            ・推論は「推論」と明示し、不明は「不明」と記します。
            ・出典にない事実をAIが補完することはありません。
            ・生成にはモデル・プロンプトのバージョンを記録し、注目事例は人間レビューを必須にできます。
            """
        case .scores:
            """
            4軸スコアはいずれも0〜100で表します。

            ・証拠品質：元映像・撮影時刻・位置・継続時間など、証拠そのものの確かさ。
            ・独立報告性：別々の人物・地点からの、転載でない報告の多さ。
            ・既知現象一致度：値が高いほど、既知現象で説明できる可能性が高い。
            ・未解明度：既知現象で説明しきれず残る部分。高くても地球外起源は意味しません。情報不足だけで高くはなりません。
            """
        case .sources:
            """
            出典は、公的・一次資料、信頼できる報道、許諾を得た専門データベース、オープンデータを優先します。

            ・規約で禁止された自動取得は行いません。
            ・有料記事本文や、権利不明の画像・動画を再配布しません。
            ・各出典には媒体名・種別・公開日時・役割（支持／反証／文脈）を明示します。
            ・情報源ごとの利用条件はSource Registryで管理し、未承認の情報源は本番で無効化します。
            """
        case .correction:
            """
            訂正の際は、訂正日時・変更前の要旨・変更理由・新しい出典を記録します。

            ・元の評価を消さず、タイムラインに変更を残します。
            ・重大な訂正は、保存したユーザーへ任意で通知します。
            ・「説明済み」への変化は格下げではなく、理解が進んだ更新として扱います。
            """
        case .privacy:
            """
            初回リリースでは、読むだけならアカウントも正確な位置情報も不要です。

            ・追跡型広告や広告IDは使用しません。
            ・連絡先・写真ライブラリ・マイクへはアクセスしません。
            ・通知トークンは通知目的のみに使用し、削除導線を用意します。
            ・詳細は本ポリシーの外部版をご確認ください。
            """
        case .terms:
            """
            本サービスは情報提供を目的とし、報告された事象の真偽を保証するものではありません。

            ・有料のデジタルコンテンツはApp StoreのIn-App Purchaseで提供します。
            ・自動更新サブスクリプションは、期間終了の24時間前までにキャンセルできます。
            ・価格・期間・更新条件はApp Storeの表示に従います。
            """
        case .support:
            """
            ご質問・誤りのご報告は、アプリ内のサポートまたは外部サポートページからお願いします。

            ・記事の誤りは、該当CaseのAI・編集方針欄からご報告いただけます。
            ・返信には数営業日を要する場合があります。
            """
        }
    }
}

struct LegalPageView: View {
    let page: LegalPage
    @State private var linkToOpen: IdentifiedURL?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SkySpacing.x4) {
                Text(page.body)
                    .font(SkyTypography.body)
                    .foregroundStyle(SkyColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
                if let url = page.externalURL {
                    Button {
                        linkToOpen = IdentifiedURL(url: url)
                    } label: {
                        Label(SkyStrings.t("sources.openLink"), systemImage: "safari")
                    }
                    .foregroundStyle(SkyColor.signalCyan)
                }
            }
            .padding(SkySpacing.x5)
            .readingWidth()
        }
        .background(SkyColor.canvas)
        .navigationTitle(SkyStrings.t(page.titleKey))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $linkToOpen) { SafariView(url: $0.url) }
    }
}

#Preview {
    NavigationStack { LegalPageView(page: .scores) }
}
