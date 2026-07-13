import Foundation

/// The Today feed + daily briefing fixtures assembled from the demo cases.
enum DemoFeed {

    static let briefing = DailyBriefing(
        id: "brief_2026_07_13", date: FixtureClock.today,
        headline: "今日の空：北海の高速光点に新映像、東京湾の灯火は航空機の可能性",
        summary: "取得できた情報源内で、12件の報告を6つの事象に統合しました。北海の注目事例に2件目の映像が加わり独立報告が3件に。東京湾の灯火は航空機の可能性が高いと更新。金星の誤認1件を説明済みに。",
        tableOfContents: [
            "北海：高速光点に新しい映像", "東京湾：3つの灯火の検討",
            "説明が進んだ事例", "新しい公式資料", "観測上の注意",
        ],
        blocks: [
            Fx.heading("bh1", "今日の要点"),
            Fx.fact("bb1", "北海沿岸の注目事例に2件目の連続映像が加わり、独立報告は3件になった。既知現象では現時点で十分に説明できていない。",
                    claims: ["clm_ns"], sources: ["s_ns"], gated: true),
            Fx.fact("bb2", "東京湾岸で報告された3つの灯火は、時刻と灯火配置から航空機の可能性が高いと更新された。",
                    claims: ["clm_tk"], sources: ["s_tk"], gated: true),
            Fx.fact("bb3", "アリゾナの明るい一点は金星の誤認として説明済みに分類した。",
                    claims: ["clm_az"], sources: ["s_az"], gated: true),
            Fx.heading("bh2", "観測上の注意", gated: true),
            Fx.fact("bb4", "夕方の西の低空では、金星が『動かない明るい光』として誤認されやすい時期が続く。",
                    claims: ["clm_note"], sources: ["s_az"], gated: true),
        ],
        referencedCaseIDs: ["case_north_sea_notable", "case_tokyo_bay_lights", "case_arizona_bright_object"],
        sourceCount: 21, usedCaseCount: 6, readingMinutes: 5,
        generatedAt: FixtureClock.day(0, hour: 22, minute: 40),
        disclosure: .editorReviewed,
        tomorrowWatch: ["北海事例のレーダー記録の有無", "東京湾の追加映像"]
    )

    static let summary = GlobalSummary(
        newReportCount: 12, mergedCaseCount: 6,
        likelyExplainedCount: 3, insufficientDataCount: 1, notableUnresolvedCount: 1
    )

    static func feed() -> TodayFeed {
        let cases = DemoCases.all
        let top = [DemoCases.northSeaNotable, DemoCases.tokyoAircraft,
                   DemoCases.queenslandFireball, DemoCases.starlink]
        let updates = cases.filter(\.hasRecentUpdate)
        return TodayFeed(
            date: FixtureClock.today,
            lastUpdatedAt: FixtureClock.day(0, hour: 22, minute: 40),
            summary: summary, briefing: briefing,
            topCases: top, recentUpdates: updates,
            editorialNote: "説明済みの事例も、空を読む手掛かりとして記録に残します。",
            isPartial: false
        )
    }
}
