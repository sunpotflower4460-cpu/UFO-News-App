import Foundation

/// Central localization layer for Phase 1.
///
/// Rationale (see docs/DECISIONS.md): the UI/UX plan forbids inline string
/// literals in views and asks for a Strings-Catalog-style separation. During
/// Phase 1 (no build environment on the authoring host) this in-code table is
/// the single source of truth so the UI is never empty or shows raw keys. It is
/// structured for a 1:1 migration to `Localizable.xcstrings` in a later phase —
/// keys are identical to those exported in Resources/Localizable.xcstrings.
enum SkyStrings {

    /// Resolve a key for the current locale, Japanese primary, English fallback.
    static func t(_ key: String) -> String {
        let ja = table[key]?.ja
        let en = table[key]?.en
        if isEnglish { return en ?? ja ?? key }
        return ja ?? en ?? key
    }

    /// Resolve with a single positional `%@` substitution.
    static func t(_ key: String, _ arg: CVarArg) -> String {
        String(format: t(key), arg)
    }

    static func t(_ key: String, _ a: CVarArg, _ b: CVarArg) -> String {
        String(format: t(key), a, b)
    }

    private static var isEnglish: Bool {
        (Locale.current.language.languageCode?.identifier ?? "ja") == "en"
    }

    private struct Pair { let ja: String; let en: String }

    private static let table: [String: Pair] = merged(
        general, tabs, status, statusV2, assessV2, scores, evidence, sourceKinds, ai,
        explanation, today, briefing, map, research, caseDetail,
        paywall, settings, states, welcome, filters, location, article
    )

    /// V2 assessment dimensions, change kinds, related-case relations.
    private static let assessV2: [String: Pair] = [
        "assess.sourceIndependence": .init(ja: "報告の独立性", en: "Source independence"),
        "assess.timeConsistency": .init(ja: "時刻の整合", en: "Time consistency"),
        "assess.locationPrecision": .init(ja: "位置精度", en: "Location precision"),
        "assess.mediaProvenance": .init(ja: "映像資料の来歴", en: "Media provenance"),
        "assess.officialCorroboration": .init(ja: "公的確認", en: "Official corroboration"),
        "assess.knownPhenomenonFit": .init(ja: "既知現象との一致", en: "Known-phenomenon fit"),
        "assess.unresolvedContradictions": .init(ja: "未解決の矛盾", en: "Unresolved contradictions"),
        "assess.missingInformation": .init(ja: "不足情報", en: "Missing information"),
        "assess.level.strong": .init(ja: "高", en: "Strong"),
        "assess.level.moderate": .init(ja: "中", en: "Moderate"),
        "assess.level.limited": .init(ja: "低", en: "Limited"),
        "assess.level.insufficient": .init(ja: "判定材料不足", en: "Insufficient"),
        "assess.sectionTitle": .init(ja: "現在の評価", en: "Current assessment"),
        "assess.basis.independence": .init(ja: "独立報告 %@件・出典 %@件", en: "%@ independent · %@ sources"),
        "assess.basis.timeOk": .init(ja: "出典間で時刻の大きな矛盾は確認されていません", en: "No major time conflicts across sources"),
        "assess.basis.timeConflict": .init(ja: "出典間で時刻・内容に食い違いがあります", en: "Sources conflict on time or detail"),
        "assess.basis.media": .init(ja: "映像・撮影メタデータの確かさに基づきます", en: "Based on footage and capture metadata"),
        "assess.basis.official": .init(ja: "公的・一次資料の有無に基づきます", en: "Based on presence of official/primary records"),
        "assess.basis.known": .init(ja: "既知現象で説明できる度合い（高いほど説明可能）", en: "Degree explainable by known phenomena"),
        "assess.basis.contradiction": .init(ja: "未解決の矛盾 %@件", en: "%@ unresolved contradictions"),
        "assess.basis.missing": .init(ja: "不足している重要情報 %@件", en: "%@ missing critical items"),
        "change.sectionTitle": .init(ja: "前回からの変化", en: "What changed"),
        "change.newEvidence": .init(ja: "資料が追加", en: "Evidence added"),
        "change.assessmentChanged": .init(ja: "評価が変更", en: "Assessment changed"),
        "change.correction": .init(ja: "訂正", en: "Correction"),
        "change.locationRefined": .init(ja: "位置精度が改善", en: "Location refined"),
        "change.officialUpdate": .init(ja: "公式資料の更新", en: "Official update"),
        "change.contradiction": .init(ja: "矛盾が判明", en: "Contradiction found"),
        "related.sectionTitle": .init(ja: "関連する事例", en: "Related cases"),
        "related.sameTimeRegion": .init(ja: "同じ時間・地域", en: "Same time/region"),
        "related.similarAppearance": .init(ja: "似た見え方", en: "Similar appearance"),
        "related.sameExplanation": .init(ja: "同じ説明候補", en: "Same explanation"),
        "related.sharedSource": .init(ja: "共通の出典", en: "Shared source"),
        "related.historical": .init(ja: "歴史的比較", en: "Historical comparison"),
        "case.whatHappened.v2": .init(ja: "何が起きたか", en: "What happened"),
        "case.confirmedFacts": .init(ja: "確認済みの事実", en: "Confirmed facts"),
        "case.evidence": .init(ja: "資料", en: "Evidence"),
    ]

    /// V2 (Aether) 8-status vocabulary labels.
    private static let statusV2: [String: Pair] = [
        "v2.status.newReport": .init(ja: "新規報告", en: "New report"),
        "v2.status.underReview": .init(ja: "調査継続", en: "Under review"),
        "v2.status.informationInsufficient": .init(ja: "情報不足", en: "Information insufficient"),
        "v2.status.knownExplanationLikely": .init(ja: "既知現象の可能性", en: "Known explanation likely"),
        "v2.status.explained": .init(ja: "説明済み", en: "Explained"),
        "v2.status.disputed": .init(ja: "争点あり", en: "Disputed"),
        "v2.status.corrected": .init(ja: "訂正済み", en: "Corrected"),
        "v2.status.archived": .init(ja: "アーカイブ", en: "Archived"),
    ]

    private static func merged(_ dicts: [String: Pair]...) -> [String: Pair] {
        var out: [String: Pair] = [:]
        for d in dicts { out.merge(d) { _, new in new } }
        return out
    }

    // MARK: - Tables

    private static let general: [String: Pair] = [
        "app.name": .init(ja: "SkyTrace", en: "SkyTrace"),
        "action.continue": .init(ja: "続ける", en: "Continue"),
        "action.start": .init(ja: "始める", en: "Get started"),
        "action.retry": .init(ja: "再試行", en: "Retry"),
        "action.openDetail": .init(ja: "詳細を開く", en: "Open detail"),
        "action.seeDetail": .init(ja: "詳細を見る", en: "See detail"),
        "action.readMore": .init(ja: "続きを読む", en: "Read more"),
        "action.close": .init(ja: "閉じる", en: "Close"),
        "action.viewPolicy": .init(ja: "詳しい方針を見る", en: "See full policy"),
        "action.share": .init(ja: "共有", en: "Share"),
        "action.bookmark": .init(ja: "保存", en: "Bookmark"),
        "action.bookmarked": .init(ja: "保存済み", en: "Bookmarked"),
        "label.sources": .init(ja: "出典 %@", en: "%@ sources"),
        "label.independent": .init(ja: "独立報告 %@", en: "%@ independent"),
        "label.demo": .init(ja: "デモデータ", en: "DEMO DATA"),
        "label.plus": .init(ja: "Plus", en: "Plus"),
        "label.updated": .init(ja: "更新あり", en: "Updated"),
        "label.lastVerified": .init(ja: "最終検証 %@", en: "Last verified %@"),
        "label.lastUpdated": .init(ja: "最終更新 %@", en: "Last updated %@"),
        "label.occurred": .init(ja: "発生", en: "Occurred"),
        "label.published": .init(ja: "公開", en: "Published"),
    ]

    private static let tabs: [String: Pair] = [
        "tab.today": .init(ja: "今日", en: "Today"),
        "tab.map": .init(ja: "地図", en: "Map"),
        "tab.research": .init(ja: "探す", en: "Explore"),
        "tab.settings": .init(ja: "設定", en: "Settings"),
    ]

    private static let status: [String: Pair] = [
        "case.status.explained": .init(ja: "説明済み", en: "Explained"),
        "case.status.likely_explained": .init(ja: "説明候補あり", en: "Likely explained"),
        "case.status.insufficient_data": .init(ja: "情報不足", en: "Insufficient data"),
        "case.status.under_review": .init(ja: "調査継続", en: "Under review"),
        "case.status.notable_unresolved": .init(ja: "注目・未解決", en: "Notable, unresolved"),
        "case.status.disputed": .init(ja: "争点あり", en: "Disputed"),
        "case.status.withdrawn": .init(ja: "取り下げ", en: "Withdrawn"),
    ]

    private static let scores: [String: Pair] = [
        "score.evidenceQuality.title": .init(ja: "証拠品質", en: "Evidence quality"),
        "score.independence.title": .init(ja: "独立報告性", en: "Independent corroboration"),
        "score.knownPhenomenaMatch.title": .init(ja: "既知現象一致度", en: "Known-phenomena match"),
        "score.unresolvedness.title": .init(ja: "未解明度", en: "Unresolvedness"),
        "score.evidenceQuality.explanation": .init(
            ja: "元映像・撮影時刻・位置・継続時間など、証拠そのものの確かさを示します。",
            en: "How solid the underlying evidence is — original footage, capture time, location, duration."),
        "score.independence.explanation": .init(
            ja: "別々の人物・地点からの、転載でない報告がどれだけあるかを示します。",
            en: "How many genuinely independent (non-reposted) reports corroborate the case."),
        "score.knownPhenomenaMatch.explanation": .init(
            ja: "値が高いほど、航空機・衛星・火球などの既知現象で説明できる可能性が高いことを示します。",
            en: "A HIGHER value means the case is MORE likely explained by a known phenomenon."),
        "score.unresolvedness.explanation": .init(
            ja: "既知現象で説明しきれず残る部分の大きさです。高くても地球外起源は意味しません。",
            en: "The residual that known explanations don't cover. High does NOT mean extraterrestrial."),
        "score.moreExplained": .init(ja: "高いほど説明可能", en: "Higher = more explainable"),
        "score.strongerSignal": .init(ja: "高いほど信号が強い", en: "Higher = stronger signal"),
        "score.learnMore": .init(ja: "評価の根拠を見る", en: "How this was assessed"),
        "score.sectionTitle": .init(ja: "4軸スコア", en: "Four-axis scores"),
    ]

    private static let evidence: [String: Pair] = [
        "evidence.agreements": .init(ja: "一致している点", en: "Points of agreement"),
        "evidence.contradictions": .init(ja: "食い違う点", en: "Points of contradiction"),
        "evidence.missing": .init(ja: "情報不足", en: "Missing information"),
        "evidence.needed": .init(ja: "今後必要な証拠", en: "Evidence still needed"),
        "evidence.role.supports": .init(ja: "支持", en: "Supports"),
        "evidence.role.contradicts": .init(ja: "反証", en: "Contradicts"),
        "evidence.role.contextualizes": .init(ja: "文脈", en: "Context"),
    ]

    private static let sourceKinds: [String: Pair] = [
        "source.type.official": .init(ja: "公式", en: "Official"),
        "source.type.press": .init(ja: "報道", en: "Press"),
        "source.type.scientific": .init(ja: "科学", en: "Scientific"),
        "source.type.database": .init(ja: "専門データベース", en: "Database"),
        "source.type.social": .init(ja: "一般報告", en: "Social report"),
        "source.type.open_data": .init(ja: "オープンデータ", en: "Open data"),
        "sources.sectionTitle": .init(ja: "出典", en: "Sources"),
        "sources.openLink": .init(ja: "外部リンクを開く", en: "Open external link"),
    ]

    private static let ai: [String: Pair] = [
        "ai.disclosure.ai_auto": .init(ja: "AI統合・自動生成", en: "AI synthesis · auto-generated"),
        "ai.disclosure.ai_reviewed": .init(ja: "AI統合・編集確認済み", en: "AI synthesis · editor reviewed"),
        "ai.disclosure.human": .init(ja: "人間による編集記事", en: "Human-written"),
        "ai.sectionTitle": .init(ja: "AI・編集方針", en: "AI & editorial"),
        "ai.disclosureNote": .init(
            ja: "この記事はAIが複数の出典を整理して作成し、各事実文は出典へ追跡できます。",
            en: "This article was assembled by AI from multiple sources; each factual sentence traces to a citation."),
    ]

    private static let explanation: [String: Pair] = [
        "explanation.sectionTitle": .init(ja: "既知現象との照合", en: "Known-phenomena match"),
        "explanation.matching": .init(ja: "一致する条件", en: "Matching conditions"),
        "explanation.nonMatching": .init(ja: "一致しない条件", en: "Non-matching conditions"),
        "explanation.limitations": .init(ja: "データの範囲・欠損", en: "Data range / gaps"),
        "explanation.excluded": .init(ja: "除外済み", en: "Ruled out"),
        "explanation.matchScore": .init(ja: "一致度 %@", en: "Match %@"),
        "explanation.category.satellite": .init(ja: "人工衛星", en: "Satellite"),
        "explanation.category.aircraft": .init(ja: "航空機", en: "Aircraft"),
        "explanation.category.fireball": .init(ja: "火球", en: "Fireball"),
        "explanation.category.astronomical": .init(ja: "天体", en: "Astronomical"),
        "explanation.category.weather": .init(ja: "気象", en: "Weather"),
        "explanation.category.rocket": .init(ja: "ロケット・再突入", en: "Rocket / re-entry"),
        "explanation.category.drone": .init(ja: "ドローン", en: "Drone"),
        "explanation.category.camera_artifact": .init(ja: "カメラ由来", en: "Camera artifact"),
        "explanation.category.searchlight": .init(ja: "サーチライト", en: "Searchlight"),
        "explanation.category.other": .init(ja: "その他", en: "Other"),
    ]

    private static let today: [String: Pair] = [
        "today.title": .init(ja: "今日", en: "Today"),
        "today.heroTitle": .init(ja: "今日、世界の空で報告されたこと", en: "Reported in the world's skies today"),
        "today.topCases": .init(ja: "注目の事例", en: "Top cases"),
        "today.updates": .init(ja: "昨日からの更新", en: "Since yesterday"),
        "today.savedUpdates": .init(ja: "保存事例の更新", en: "Saved case updates"),
        "today.summary.reports": .init(ja: "新規報告", en: "New reports"),
        "today.summary.merged": .init(ja: "統合事象", en: "Merged events"),
        "today.summary.explained": .init(ja: "説明候補優勢", en: "Likely explained"),
        "today.summary.insufficient": .init(ja: "情報不足", en: "Insufficient data"),
        "today.summary.notable": .init(ja: "注目・未解決", en: "Notable"),
        "summary.coverage.disclaimer": .init(
            ja: "SkyTraceが取得・確認できた情報源の範囲です。世界中の全報告を網羅するものではありません。",
            en: "Reflects only sources SkyTrace could reach and verify — not every report worldwide."),
        "today.mergeSummary": .init(
            ja: "取得できた情報源内で、%@件の報告を%@の事象に統合しました。",
            en: "Merged %@ reports into %@ events within the sources we could reach."),
    ]

    private static let briefing: [String: Pair] = [
        "briefing.title": .init(ja: "Daily Sky Briefing", en: "Daily Sky Briefing"),
        "briefing.readMinutes": .init(ja: "約%@分で読めます", en: "About %@ min read"),
        "briefing.toc": .init(ja: "目次", en: "In this briefing"),
        "briefing.usedCases": .init(ja: "使用事例 %@件・出典 %@件", en: "%@ cases · %@ sources"),
        "briefing.tomorrow": .init(ja: "明日追うもの", en: "Watching tomorrow"),
        "briefing.readFull": .init(ja: "全文を読む — Plus", en: "Read the full briefing — Plus"),
        "briefing.generatedAt": .init(ja: "AI生成 %@", en: "Generated %@"),
    ]

    private static let map: [String: Pair] = [
        "map.title": .init(ja: "地図", en: "Map"),
        "map.filter.period": .init(ja: "期間", en: "Period"),
        "map.filter.status": .init(ja: "状態", en: "Status"),
        "map.filter.unresolved": .init(ja: "未解明度", en: "Unresolvedness"),
        "map.filter.more": .init(ja: "詳細フィルター", en: "More filters"),
        "map.results": .init(ja: "%@件を表示", en: "Showing %@"),
        "map.altList": .init(ja: "一覧で見る", en: "View as list"),
        "map.approximateNote": .init(ja: "おおよその位置", en: "Approximate location"),
    ]

    private static let research: [String: Pair] = [
        "research.title": .init(ja: "探す", en: "Explore"),
        "research.searchPrompt": .init(ja: "地域・状態・形状で検索", en: "Search by region, status, shape"),
        "research.recent": .init(ja: "最近見た事例", en: "Recently viewed"),
        "research.collections": .init(ja: "注目コレクション", en: "Featured collections"),
        "research.updatedThisWeek": .init(ja: "今週更新された事例", en: "Updated this week"),
        "research.saved": .init(ja: "保存済み", en: "Saved"),
        "research.plusDeepDives": .init(ja: "Plus深掘り", en: "Plus deep dives"),
        "research.resultCount": .init(ja: "%@件", en: "%@ results"),
        "research.filtersTitle": .init(ja: "フィルター", en: "Filters"),
        "research.clearFilters": .init(ja: "条件をクリア", en: "Clear filters"),
    ]

    private static let caseDetail: [String: Pair] = [
        "case.summary": .init(ja: "60秒要約", en: "60-second summary"),
        "case.whatHappened": .init(ja: "何が起きたか", en: "What happened"),
        "case.assessment": .init(ja: "現時点の判断", en: "Current assessment"),
        "case.timeline": .init(ja: "更新タイムライン", en: "Update timeline"),
        "case.article": .init(ja: "AI統合記事", en: "AI synthesis"),
        "case.shape": .init(ja: "見え方", en: "Appearance"),
    ]

    private static let paywall: [String: Pair] = [
        "paywall.heroTitle": .init(ja: "空の断片を、一つの調査記事へ。", en: "Turn fragments of the sky into one investigation."),
        "paywall.heroBody": .init(
            ja: "複数の出典、矛盾、既知現象との照合をまとめて読めます。",
            en: "Read multiple sources, contradictions, and known-phenomena checks in one place."),
        "paywall.cta": .init(ja: "SkyTrace Plusを始める", en: "Start SkyTrace Plus"),
        "paywall.restore": .init(ja: "購入を復元", en: "Restore purchases"),
        "paywall.manage": .init(ja: "サブスクリプションを管理", en: "Manage subscription"),
        "paywall.terms": .init(ja: "利用規約", en: "Terms of Use"),
        "paywall.privacy": .init(ja: "プライバシー", en: "Privacy Policy"),
        "paywall.renewNote": .init(
            ja: "自動更新されます。期間終了の24時間前までにキャンセルできます。価格はApp Storeの表示に従います。",
            en: "Auto-renews. Cancel up to 24h before the period ends. Prices follow App Store display."),
        "paywall.feature.briefing": .init(ja: "Daily Sky Briefing 全文", en: "Full Daily Sky Briefing"),
        "paywall.feature.synthesis": .init(ja: "事例別AI統合調査記事", en: "Per-case AI synthesis"),
        "paywall.feature.evidence": .init(ja: "一致・矛盾・照合根拠の詳細", en: "Detailed agreement, contradiction & matching"),
        "paywall.feature.filters": .init(ja: "高度フィルターと検索", en: "Advanced filters & search"),
        "paywall.feature.tracking": .init(ja: "更新履歴の詳細追跡", en: "Detailed update tracking"),
        "paywall.perMonth": .init(ja: "実質 %@／月", en: "≈ %@/mo"),
        "paywall.pending": .init(ja: "購入は承認待ちです。", en: "Purchase is pending approval."),
        "paywall.restored": .init(ja: "購入を復元しました。", en: "Purchases restored."),
        "paywall.nothingToRestore": .init(ja: "復元できる購入がありませんでした。", en: "No purchases to restore."),
    ]

    private static let settings: [String: Pair] = [
        "settings.title": .init(ja: "設定", en: "Settings"),
        "settings.section.subscription": .init(ja: "購読", en: "Subscription"),
        "settings.section.notifications": .init(ja: "通知", en: "Notifications"),
        "settings.section.appearance": .init(ja: "表示", en: "Appearance"),
        "settings.section.data": .init(ja: "データ・オフライン", en: "Data & Offline"),
        "settings.section.editorial": .init(ja: "編集・AI方針", en: "Editorial & AI"),
        "settings.section.legal": .init(ja: "プライバシー・規約", en: "Privacy & Legal"),
        "settings.section.support": .init(ja: "サポート", en: "Support"),
        "settings.section.about": .init(ja: "このアプリについて", en: "About"),
        "settings.section.developer": .init(ja: "開発者（Debug）", en: "Developer (Debug)"),
        "settings.restore": .init(ja: "購入を復元", en: "Restore purchases"),
        "settings.manage": .init(ja: "サブスクリプションを管理", en: "Manage subscription"),
        "settings.clearCache": .init(ja: "キャッシュを消去", en: "Clear cache"),
        "settings.notif.daily": .init(ja: "Daily Briefing", en: "Daily Briefing"),
        "settings.notif.major": .init(ja: "重要な更新", en: "Major updates"),
        "settings.notif.saved": .init(ja: "保存事例の更新", en: "Saved case updates"),
        "settings.notif.region": .init(ja: "地域ウォッチ", en: "Region watch"),
        "settings.notif.primer": .init(
            ja: "通知は静かに設計されています。煽らず、重要な更新だけをお届けします。",
            en: "Notifications are calm by design — no hype, only meaningful updates."),
        "settings.appearance.system": .init(ja: "システムに従う", en: "Match system"),
        "settings.appearance.dark": .init(ja: "ダーク", en: "Dark"),
        "settings.appearance.light": .init(ja: "ライト", en: "Light"),
        "settings.dev.dataSource": .init(ja: "データソース", en: "Data source"),
        "settings.dev.fixture": .init(ja: "Fixture", en: "Fixture"),
        "settings.dev.api": .init(ja: "Local API", en: "Local API"),
        "settings.dev.entitlement": .init(ja: "購読状態を上書き", en: "Override entitlement"),
        "settings.dev.previewState": .init(ja: "状態プレビュー", en: "Preview state"),
        "legal.editorial": .init(ja: "編集方針", en: "Editorial Policy"),
        "legal.ai": .init(ja: "AI利用方針", en: "AI Use Policy"),
        "legal.scores": .init(ja: "スコアの読み方", en: "Reading the scores"),
        "legal.sources": .init(ja: "出典と権利", en: "Sources & Licensing"),
        "legal.correction": .init(ja: "訂正方針", en: "Correction Policy"),
        "legal.privacy": .init(ja: "プライバシーポリシー", en: "Privacy Policy"),
        "legal.terms": .init(ja: "利用規約", en: "Terms of Use"),
        "legal.support": .init(ja: "サポート・問い合わせ", en: "Support & Contact"),
    ]

    private static let states: [String: Pair] = [
        "state.loading": .init(ja: "読み込み中…", en: "Loading…"),
        "state.offline.title": .init(ja: "オフライン", en: "Offline"),
        "state.offline.body": .init(ja: "最後に取得した内容を表示しています。", en: "Showing the last data we fetched."),
        "state.partial.body": .init(
            ja: "一部の情報源を取得できませんでした。表示内容は完全ではない可能性があります。",
            en: "Some sources couldn't be reached. This view may be incomplete."),
        "state.error.title": .init(ja: "読み込めませんでした", en: "Couldn't load"),
        "state.error.body": .init(ja: "通信を確認して、もう一度お試しください。", en: "Check your connection and try again."),
        "state.demo.body": .init(
            ja: "これはデモデータです。実際のニュースではありません。",
            en: "This is demo data — not real news."),
        "state.stale": .init(ja: "最終取得 %@", en: "Fetched %@"),
        "empty.today": .init(
            ja: "現在、確認できた新しい事例はありません。空が静かな日も記録の一部です。",
            en: "No new confirmed cases right now. Quiet skies are part of the record too."),
        "empty.search": .init(
            ja: "条件に一致する事例がありません。期間や状態を広げてみてください。",
            en: "No cases match. Try widening the period or status."),
        "empty.saved": .init(
            ja: "気になる事例を保存すると、後日の更新をここで追えます。",
            en: "Bookmark cases you're curious about to follow their updates here."),
    ]

    private static let welcome: [String: Pair] = [
        "welcome.tagline": .init(
            ja: "世界の空で報告されたことを、出典とともに追跡します",
            en: "Tracking what's reported in the world's skies — with its sources"),
        "welcome.policyTitle": .init(ja: "SkyTraceの編集方針", en: "How SkyTrace works"),
        "welcome.policy1": .init(ja: "未解明を地球外起源とは断定しません", en: "Unexplained is never called extraterrestrial"),
        "welcome.policy2": .init(ja: "AI文章は出典へ追跡できます", en: "AI writing traces back to its sources"),
        "welcome.policy3": .init(ja: "読むだけならアカウントも位置情報も不要です", en: "Reading needs no account or location"),
        "welcome.center": .init(ja: "世界の空に残された、まだ名前のないものを記録する。", en: "Recording the still-unnamed things left in the sky."),
    ]

    private static let filters: [String: Pair] = [
        "filter.window.anyTime": .init(ja: "すべて", en: "Any time"),
        "filter.window.past24h": .init(ja: "24時間", en: "24 hours"),
        "filter.window.past7d": .init(ja: "7日間", en: "7 days"),
        "filter.window.past30d": .init(ja: "30日間", en: "30 days"),
        "filter.window.thisYear": .init(ja: "今年", en: "This year"),
        "filter.updatesOnly": .init(ja: "更新ありのみ", en: "Updated only"),
        "filter.shape": .init(ja: "形状", en: "Shape"),
    ]

    private static let location: [String: Pair] = [
        "location.precision.exact": .init(ja: "正確な位置", en: "Exact location"),
        "location.precision.approximate": .init(ja: "おおよその位置", en: "Approximate"),
        "location.precision.region_only": .init(ja: "地域のみ", en: "Region only"),
        "location.precision.withheld": .init(ja: "位置非公開", en: "Location withheld"),
    ]

    private static let article: [String: Pair] = [
        "article.block.heading": .init(ja: "見出し", en: "Heading"),
        "article.block.fact_paragraph": .init(ja: "事実", en: "Fact"),
        "article.block.inference": .init(ja: "推論", en: "Inference"),
        "article.block.unknown": .init(ja: "未確認", en: "Unknown"),
        "article.block.quote": .init(ja: "引用", en: "Quote"),
        "article.block.calculation": .init(ja: "計算", en: "Calculation"),
        "article.inferenceLabel": .init(ja: "推論（確度 %@%%）", en: "Inference (%@%% confidence)"),
        "article.unknownLabel": .init(ja: "未確認", en: "Not yet known"),
        "premium.locked.title": .init(ja: "ここから先はPlus", en: "The rest is Plus"),
    ]
}
