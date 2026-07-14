import Foundation

/// The demo case library. All entries carry `isDemo = true` and abstracted,
/// fictional or safely-generalised details — never presented as production news.
enum DemoCases {

    static let all: [UAPCase] = [
        starlink, tokyoAircraft, arizonaVenus, hokkaidoSingle,
        northSeaNotable, queenslandFireball, saoPauloDisputed,
        manilaWithdrawn, aaroArchive
    ]

    static func article(for caseID: String) -> SynthesizedArticle? {
        DemoArticles.byCaseID[caseID]
    }

    // MARK: 1. Starlink — explained (Chile)
    static let starlink = UAPCase(
        id: "case_starlink_atacama", slug: "atacama-light-train",
        title: "アタカマ砂漠で観測された整列する光の列",
        summary: "複数の観測者が、夜空を等間隔で移動する20個以上の光点を報告。撮影時刻と方角は、直近のStarlink打ち上げ後の可視パスと高い精度で一致した。既知現象一致度が高く、説明済みと判断。",
        occurredAtStart: FixtureClock.day(-3, hour: 21, minute: 12),
        occurredAtEnd: FixtureClock.day(-3, hour: 21, minute: 18),
        publishedAt: FixtureClock.day(-2, hour: 9),
        lastVerifiedAt: FixtureClock.day(-1, hour: 14), updatedAt: FixtureClock.day(-1, hour: 14),
        latitude: -23.65, longitude: -70.40, locationPrecision: .approximate,
        countryCode: "CL", regionName: "アントファガスタ州", localityName: "アタカマ砂漠",
        timeZoneIdentifier: "America/Santiago",
        status: .explained,
        scores: CaseScores(evidenceQuality: 74, independence: 66, knownPhenomenaMatch: 92, unresolvedness: 12, algorithmVersion: "demo-1"),
        sourceCount: 6, independentReportCount: 3,
        agreements: [
            Fx.agree("ag1", "光点は一定間隔で同一方向へ移動していた", ["s1", "s2", "s3"]),
            Fx.agree("ag2", "観測時刻は現地21:12前後で複数報告が一致", ["s1", "s2"]),
        ],
        contradictions: [
            Fx.contra("co1", "光点の数は「約20」から「40以上」まで報告に幅がある", ["s2", "s4"]),
        ],
        explanationCandidates: [
            Fx.candidate("ec1", .satellite, "Starlink衛星列", 92,
                         match: ["打ち上げ後の可視パスと時刻・方角が一致", "等間隔・等速の移動", "点滅せず一定光度"],
                         nonMatch: ["一部報告の「40以上」は列の重複観測の可能性"],
                         limits: "使用した公開軌道要素は観測の18時間前取得。"),
            Fx.candidate("ec2", .aircraft, "航空機編隊", 8,
                         match: [], nonMatch: ["点滅灯がない", "等間隔すぎる"], excluded: true),
        ],
        missingInformation: [Fx.gap("mi1", "個々の光点の角速度を測定した映像は未入手")],
        neededEvidence: [Fx.gap("ne1", "三脚固定・タイムスタンプ付きの連続映像")],
        timeline: [
            Fx.timeline("t1", 2, "初報を公開。衛星照合を保留として調査継続に設定", status: .underReview),
            Fx.timeline("t2", 1, "公開軌道要素との照合が完了し、説明済みへ更新",
                        status: .explained, scoreNote: "既知現象一致度 58 → 92"),
        ],
        sources: [
            Fx.source("s1", "Observatorio Regional", .scientific, "夜間可視衛星パスの記録", daysAgo: 2, group: "g_obs"),
            Fx.source("s2", "Diario del Norte", .press, "住民が報告した『光の列』", daysAgo: 2),
            Fx.source("s3", "CelesTrak (public TLE)", .openData, "公開軌道要素データセット", daysAgo: 2),
            Fx.source("s4", "SNS投稿（手掛かり）", .social, "夜空の光点の短い動画", role: .contextualizes, daysAgo: 3),
        ],
        currentAssessment: "現時点の証拠は、直近の衛星打ち上げによる可視パスで十分に説明できる。異常な運動を示す独立した客観データは確認されていない。",
        shapeTags: ["光点", "整列", "移動"], isDemo: true
    )

    // MARK: 2. Tokyo — aircraft lights likely (Japan)
    static let tokyoAircraft = UAPCase(
        id: "case_tokyo_bay_lights", slug: "tokyo-bay-hovering-lights",
        title: "東京湾上空で停止して見えた3つの灯火",
        summary: "湾岸エリアの複数地点から、低速で移動しほぼ停止して見えた3つの灯火が報告された。進入経路・時刻は羽田周辺の航空交通と整合的で、航空機の可能性が高いが、確定には角速度データが不足。",
        occurredAtStart: FixtureClock.day(-1, hour: 19, minute: 48),
        occurredAtEnd: FixtureClock.day(-1, hour: 20, minute: 5),
        publishedAt: FixtureClock.day(-1, hour: 22),
        lastVerifiedAt: FixtureClock.day(0, hour: 22, minute: 40), updatedAt: FixtureClock.day(0, hour: 22, minute: 40),
        latitude: 35.58, longitude: 139.86, locationPrecision: .approximate,
        countryCode: "JP", regionName: "東京都", localityName: "東京湾岸",
        timeZoneIdentifier: "Asia/Tokyo",
        status: .likelyExplained,
        scores: CaseScores(evidenceQuality: 52, independence: 58, knownPhenomenaMatch: 71, unresolvedness: 34, algorithmVersion: "demo-1"),
        sourceCount: 5, independentReportCount: 2,
        agreements: [
            Fx.agree("ag1", "3つの灯火が三角形の配置で観測された", ["s1", "s2"]),
            Fx.agree("ag2", "時刻は19:48〜20:05に集中", ["s1", "s2", "s3"]),
        ],
        contradictions: [
            Fx.contra("co1", "「停止していた」報告と「ゆっくり東へ移動」報告が併存", ["s1", "s3"]),
        ],
        explanationCandidates: [
            Fx.candidate("ec1", .aircraft, "着陸進入中の航空機", 71,
                         match: ["時刻が主要空港の進入時間帯と一致", "灯火の配置が着陸灯・翼端灯と整合"],
                         nonMatch: ["「完全停止」の主観報告は視線方向の錯覚で説明が必要"],
                         limits: "商用航空機の軌跡データは本デモでは未接続。"),
            Fx.candidate("ec2", .drone, "ドローン編隊", 22,
                         match: ["低空・低速"], nonMatch: ["同期した点滅パターンの証拠なし"]),
        ],
        missingInformation: [
            Fx.gap("mi1", "灯火の角速度を測る固定カメラ映像"),
            Fx.gap("mi2", "同時刻の航空交通の独立記録"),
        ],
        neededEvidence: [Fx.gap("ne1", "複数地点からの同期タイムスタンプ映像")],
        timeline: [
            Fx.timeline("t1", 1, "初報を公開、調査継続", status: .underReview),
            Fx.timeline("t2", 0, "航空交通時間帯との整合から説明候補ありへ",
                        status: .likelyExplained, scoreNote: "既知現象一致度 44 → 71"),
        ],
        sources: [
            Fx.source("s1", "湾岸ローカル紙", .press, "『空に止まる光』の目撃相次ぐ", daysAgo: 1),
            Fx.source("s2", "地域FM", .press, "リスナーからの目撃提供", daysAgo: 1, group: "g_local"),
            Fx.source("s3", "個人観測ブログ", .social, "東京湾の灯火・観測メモ", role: .contextualizes, daysAgo: 1),
        ],
        currentAssessment: "航空機の可能性が最も高いが、『停止』という主観的印象を裏づけ／反証する客観的な角速度データが不足しており、確定は保留する。",
        shapeTags: ["光点", "三角配置", "低速"], isDemo: true
    )

    // MARK: 3. Arizona — Venus misidentification (US)
    static let arizonaVenus = UAPCase(
        id: "case_arizona_bright_object", slug: "arizona-western-sky-object",
        title: "アリゾナ西の空で輝いた動かない一点",
        summary: "日没後の西の低空で、明るく瞬く一点が約40分間観測された。方位・高度・時刻は金星の位置と精密に一致し、明滅は地平線付近の大気シンチレーションで説明できる。",
        occurredAtStart: FixtureClock.day(-5, hour: 19, minute: 30),
        occurredAtEnd: FixtureClock.day(-5, hour: 20, minute: 10),
        publishedAt: FixtureClock.day(-4, hour: 8),
        lastVerifiedAt: FixtureClock.day(-4, hour: 12), updatedAt: FixtureClock.day(-4, hour: 12),
        latitude: 33.45, longitude: -112.07, locationPrecision: .regionOnly,
        countryCode: "US", regionName: "アリゾナ州", localityName: nil,
        timeZoneIdentifier: "America/Phoenix",
        status: .explained,
        scores: CaseScores(evidenceQuality: 38, independence: 30, knownPhenomenaMatch: 95, unresolvedness: 8, algorithmVersion: "demo-1"),
        sourceCount: 3, independentReportCount: 1,
        agreements: [Fx.agree("ag1", "西の低空で瞬く明るい一点、移動せず", ["s1", "s2"])],
        contradictions: [],
        explanationCandidates: [
            Fx.candidate("ec1", .astronomical, "金星（宵の明星）", 95,
                         match: ["方位・高度・時刻が金星の計算位置と一致", "40分かけてゆっくり沈む挙動"],
                         nonMatch: [], limits: "観測地点は地域中心で近似。"),
        ],
        missingInformation: [Fx.gap("mi1", "望遠での拡大映像は未入手")],
        neededEvidence: [Fx.gap("ne1", "方位計付きの写真")],
        timeline: [Fx.timeline("t1", 4, "天体照合により説明済みで公開", status: .explained)],
        sources: [
            Fx.source("s1", "地域ニュースサイト", .press, "『西の空の謎の光』への問い合わせ", daysAgo: 4),
            Fx.source("s2", "天文同好会", .scientific, "金星位置の計算メモ", daysAgo: 4, group: "g_astro"),
        ],
        currentAssessment: "金星の誤認で高い確度で説明できる。説明済みだが、身近な誤認例として記録に残す価値がある。",
        shapeTags: ["光点", "静止", "瞬き"], isDemo: true
    )

    // MARK: 4. Hokkaido — insufficient data single report (Japan)
    static let hokkaidoSingle = UAPCase(
        id: "case_hokkaido_single", slug: "hokkaido-east-single-report",
        title: "北海道東部で報告された単独の橙色光",
        summary: "一名の観測者が、林の上空を数秒間ゆっくり移動した橙色の光を報告。映像・写真はなく、他の独立報告も現時点で確認できていない。評価に必要な情報が不足している。",
        occurredAtStart: FixtureClock.day(-2, hour: 3, minute: 20),
        occurredAtEnd: FixtureClock.day(-2, hour: 3, minute: 24),
        publishedAt: FixtureClock.day(-1, hour: 11),
        lastVerifiedAt: FixtureClock.day(-1, hour: 11), updatedAt: FixtureClock.day(-1, hour: 11),
        latitude: 43.33, longitude: 145.58, locationPrecision: .regionOnly,
        countryCode: "JP", regionName: "北海道", localityName: "道東",
        timeZoneIdentifier: "Asia/Tokyo",
        status: .insufficientData,
        scores: CaseScores(evidenceQuality: 18, independence: 12, knownPhenomenaMatch: 22, unresolvedness: 30, algorithmVersion: "demo-1"),
        sourceCount: 1, independentReportCount: 1,
        agreements: [],
        contradictions: [],
        explanationCandidates: [
            Fx.candidate("ec1", .fireball, "火球・流星", 22,
                         match: ["短時間・移動する光"],
                         nonMatch: ["『ゆっくり』という記述は典型的な火球と一致しにくい"],
                         limits: "映像がなく角速度・継続時間を検証できない。"),
        ],
        missingInformation: [
            Fx.gap("mi1", "映像・写真が一切ない"),
            Fx.gap("mi2", "第二の独立した目撃者が未確認"),
            Fx.gap("mi3", "正確な方角・仰角が不明"),
        ],
        neededEvidence: [
            Fx.gap("ne1", "同時刻・同地域の他の目撃報告"),
            Fx.gap("ne2", "近隣の固定カメラ映像"),
        ],
        timeline: [Fx.timeline("t1", 1, "単独報告として記録。情報不足のため評価を保留", status: .insufficientData)],
        sources: [
            Fx.source("s1", "読者投稿フォーム", .social, "道東での目撃メモ", role: .contextualizes, daysAgo: 1, url: nil),
        ],
        currentAssessment: "現時点では情報が不足しており、既知現象で説明することも未解明とすることもできない。追加の独立情報を待つ。",
        shapeTags: ["光点", "橙色", "移動"], isDemo: true
    )

    // MARK: 5. North Sea — notable unresolved, multi-location
    static let northSeaNotable = UAPCase(
        id: "case_north_sea_notable", slug: "north-sea-multi-station",
        title: "北海上空で複数地点が捉えた高速の光点",
        summary: "沿岸の3つの離れた地点から、通常の航空機より速く見える光点が報告され、うち2件は連続映像を伴う。既知現象との一致は限定的で、良質な証拠を残しつつ未解明部分がある注目事例。",
        occurredAtStart: FixtureClock.day(-4, hour: 22, minute: 10),
        occurredAtEnd: FixtureClock.day(-4, hour: 22, minute: 19),
        publishedAt: FixtureClock.day(-3, hour: 10),
        lastVerifiedAt: FixtureClock.day(0, hour: 15), updatedAt: FixtureClock.day(0, hour: 15),
        latitude: 57.10, longitude: 2.10, locationPrecision: .approximate,
        countryCode: "NO", regionName: "北海沿岸", localityName: nil,
        timeZoneIdentifier: "Europe/Oslo",
        status: .notableUnresolved,
        scores: CaseScores(evidenceQuality: 71, independence: 78, knownPhenomenaMatch: 34, unresolvedness: 62, algorithmVersion: "demo-1"),
        sourceCount: 8, independentReportCount: 3,
        agreements: [
            Fx.agree("ag1", "3つの離れた地点で同時間帯に観測", ["s1", "s2", "s3"]),
            Fx.agree("ag2", "2件の映像で光点の高速な水平移動が確認できる", ["s2", "s3"]),
        ],
        contradictions: [
            Fx.contra("co1", "推定される高度が報告間で大きく異なる", ["s1", "s3"]),
        ],
        explanationCandidates: [
            Fx.candidate("ec1", .aircraft, "軍用機・訓練飛行", 34,
                         match: ["高速移動"], nonMatch: ["点滅灯が確認できない", "既知の飛行情報と時刻が合わない"],
                         limits: "軍事飛行情報は本デモでは参照不可。"),
            Fx.candidate("ec2", .satellite, "衛星フレア", 18,
                         match: ["明るい一過性の光"], nonMatch: ["水平移動が長すぎる"]),
        ],
        missingInformation: [
            Fx.gap("mi1", "3地点の映像の正確な時刻同期"),
            Fx.gap("mi2", "レーダー記録の独立確認"),
        ],
        neededEvidence: [
            Fx.gap("ne1", "三角測量に足る精密な方位データ"),
            Fx.gap("ne2", "公的なレーダー・航跡情報"),
        ],
        timeline: [
            Fx.timeline("t1", 3, "3地点報告を統合して公開", status: .underReview),
            Fx.timeline("t2", 1, "2件目の映像を追加、独立報告数を3に更新", sources: ["s3"], scoreNote: "独立報告性 60 → 78"),
            Fx.timeline("t3", 0, "衛星・航空照合では説明しきれず、注目・未解決へ", status: .notableUnresolved),
        ],
        sources: [
            Fx.source("s1", "沿岸監視ボランティア", .social, "北海の高速光点・観測ログ", daysAgo: 3, group: "g_ns1"),
            Fx.source("s2", "地域公共放送", .press, "複数地点で謎の光点", daysAgo: 3, group: "g_ns2"),
            Fx.source("s3", "アマチュア天文家", .scientific, "連続フレーム解析メモ", daysAgo: 1, group: "g_ns3"),
        ],
        currentAssessment: "複数の独立地点と映像という比較的良質な証拠がある一方、既知現象では現時点で十分に説明できない。未解明部分が残るが、これは地球外起源を意味しない。",
        shapeTags: ["光点", "高速", "水平移動"], isDemo: true
    )

    // MARK: 6. Queensland — fireball, later identified
    static let queenslandFireball = UAPCase(
        id: "case_queensland_fireball", slug: "queensland-green-streak",
        title: "クイーンズランドを横切った緑色の閃光",
        summary: "広範囲で目撃された緑色の閃光。当初は正体不明だったが、後日、公的な火球データベースの記録および複数の車載カメラ映像と一致し、火球（大火球）と判明した。",
        occurredAtStart: FixtureClock.day(-6, hour: 2, minute: 5),
        occurredAtEnd: FixtureClock.day(-6, hour: 2, minute: 5),
        publishedAt: FixtureClock.day(-5, hour: 7),
        lastVerifiedAt: FixtureClock.day(-2, hour: 9), updatedAt: FixtureClock.day(-2, hour: 9),
        latitude: -27.47, longitude: 153.02, locationPrecision: .approximate,
        countryCode: "AU", regionName: "クイーンズランド州", localityName: "ブリスベン周辺",
        timeZoneIdentifier: "Australia/Brisbane",
        status: .explained,
        scores: CaseScores(evidenceQuality: 80, independence: 72, knownPhenomenaMatch: 90, unresolvedness: 10, algorithmVersion: "demo-1"),
        sourceCount: 7, independentReportCount: 4,
        agreements: [
            Fx.agree("ag1", "緑色の閃光が短時間、空を横切った", ["s1", "s2", "s3"]),
            Fx.agree("ag2", "複数の車載カメラが同時刻に記録", ["s2", "s3"]),
        ],
        contradictions: [],
        explanationCandidates: [
            Fx.candidate("ec1", .fireball, "大火球（ボリード）", 90,
                         match: ["公的火球データの記録と時刻・地域が一致", "緑色は金属燃焼と整合", "車載カメラの軌跡が一致"],
                         nonMatch: [], limits: "初期の目撃時刻には±数分の幅がある。"),
        ],
        missingInformation: [Fx.gap("mi1", "隕石片の回収は未報告")],
        neededEvidence: [Fx.gap("ne1", "地上での落下痕・回収報告")],
        timeline: [
            Fx.timeline("t1", 5, "正体不明の閃光として公開", status: .underReview),
            Fx.timeline("t2", 2, "公的火球データと車載映像が一致、火球と確定",
                        status: .explained, scoreNote: "既知現象一致度 55 → 90"),
        ],
        sources: [
            Fx.source("s1", "全国紙", .press, "夜空を横切った緑の光", daysAgo: 5),
            Fx.source("s2", "ドライブレコーダー投稿", .social, "車載カメラの記録（手掛かり）", role: .contextualizes, daysAgo: 5, group: "g_dash"),
            Fx.source("s3", "公的火球データベース", .official, "火球イベント記録", daysAgo: 2),
        ],
        currentAssessment: "後日判明した典型的な火球の例。当初の『未解明』が新情報で更新される過程そのものが記録として価値を持つ。",
        shapeTags: ["閃光", "緑色", "高速"], isDemo: true
    )

    // MARK: 7. São Paulo — disputed (sources contradict on time)
    static let saoPauloDisputed = UAPCase(
        id: "case_sao_paulo_disputed", slug: "sao-paulo-time-conflict",
        title: "サンパウロ上空の発光体、出典で時刻が矛盾",
        summary: "同一とされる発光体について、複数の報道が異なる発生時刻を伝えている。時刻の食い違いが大きく、単一事象なのか別々の現象なのかを含め、情報間の重大な矛盾がある。",
        occurredAtStart: FixtureClock.day(-3, hour: 20, minute: 0),
        occurredAtEnd: FixtureClock.day(-3, hour: 23, minute: 0),
        publishedAt: FixtureClock.day(-2, hour: 12),
        lastVerifiedAt: FixtureClock.day(-1, hour: 16), updatedAt: FixtureClock.day(-1, hour: 16),
        latitude: -23.55, longitude: -46.63, locationPrecision: .approximate,
        countryCode: "BR", regionName: "サンパウロ州", localityName: "サンパウロ",
        timeZoneIdentifier: "America/Sao_Paulo",
        status: .disputed,
        scores: CaseScores(evidenceQuality: 44, independence: 40, knownPhenomenaMatch: 30, unresolvedness: 40, algorithmVersion: "demo-1"),
        sourceCount: 5, independentReportCount: 2,
        agreements: [Fx.agree("ag1", "市内上空で明るい発光体が観測された点は一致", ["s1", "s2"])],
        contradictions: [
            Fx.contra("co1", "発生時刻が『20:00頃』と『22:40頃』で約2時間半食い違う", ["s1", "s2"]),
            Fx.contra("co2", "移動方向が北向きと南向きで逆に報じられている", ["s1", "s3"]),
        ],
        explanationCandidates: [
            Fx.candidate("ec1", .rocket, "ロケット打ち上げ・燃料放出", 30,
                         match: ["広範囲で見える明るい発光"], nonMatch: ["時刻の矛盾が大きく照合できない"],
                         limits: "時刻が確定できないため照合の信頼度が低い。"),
        ],
        missingInformation: [Fx.gap("mi1", "各報道の一次情報源と正確なタイムスタンプ")],
        neededEvidence: [Fx.gap("ne1", "タイムスタンプの検証可能な原映像")],
        timeline: [
            Fx.timeline("t1", 2, "複数報道を統合して公開", status: .underReview),
            Fx.timeline("t2", 1, "時刻・方向の重大な矛盾を確認、争点ありへ", status: .disputed),
        ],
        sources: [
            Fx.source("s1", "報道A", .press, "夜空に輝く物体、20時ごろ出現", daysAgo: 2, group: "g_sp_a"),
            Fx.source("s2", "報道B", .press, "深夜の発光体に問い合わせ相次ぐ", daysAgo: 2, group: "g_sp_b"),
            Fx.source("s3", "SNSまとめ", .social, "目撃投稿の集約（手掛かり）", role: .contextualizes, daysAgo: 2),
        ],
        currentAssessment: "出典間の時刻・方向の矛盾が大きく、同一事象かどうかも確定できない。矛盾を解消できる一次情報が必要。",
        shapeTags: ["発光体", "移動"], isDemo: true
    )

    // MARK: 8. Manila — withdrawn (reposted video)
    static let manilaWithdrawn = UAPCase(
        id: "case_manila_withdrawn", slug: "manila-reposted-clip",
        title: "マニラの『UFO動画』、転載と判明し取り下げ",
        summary: "拡散した動画は当初マニラ上空の新規報告とされたが、追跡の結果、数年前に別の国で撮影・公開された映像の転載であることが判明した。新規事象としては取り下げた。",
        occurredAtStart: nil, occurredAtEnd: nil,
        publishedAt: FixtureClock.day(-2, hour: 13),
        lastVerifiedAt: FixtureClock.day(-1, hour: 10), updatedAt: FixtureClock.day(-1, hour: 10),
        latitude: 14.60, longitude: 120.98, locationPrecision: .withheld,
        countryCode: "PH", regionName: "メトロ・マニラ", localityName: nil,
        timeZoneIdentifier: "Asia/Manila",
        status: .withdrawn,
        scores: CaseScores(evidenceQuality: 20, independence: 8, knownPhenomenaMatch: 15, unresolvedness: 5, algorithmVersion: "demo-1"),
        sourceCount: 4, independentReportCount: 0,
        agreements: [],
        contradictions: [
            Fx.contra("co1", "『マニラで昨夜撮影』という説明と、原動画の公開日が数年前で矛盾", ["s1", "s2"]),
        ],
        explanationCandidates: [
            Fx.candidate("ec1", .cameraArtifact, "過去映像の転載", 88,
                         match: ["逆画像検索で数年前の原投稿を特定", "同一のフレームとメタデータ"],
                         nonMatch: [], limits: "原投稿の撮影地は本デモでは非公開。"),
        ],
        missingInformation: [],
        neededEvidence: [Fx.gap("ne1", "（新規事象としては不要）原投稿者の確認のみ")],
        timeline: [
            Fx.timeline("t1", 2, "拡散中の動画として仮登録", status: .underReview),
            Fx.timeline("t2", 1, "原投稿を特定、転載と確認し取り下げ", status: .withdrawn),
        ],
        sources: [
            Fx.source("s1", "ファクトチェック記事", .press, "拡散動画は過去映像の転載", daysAgo: 1),
            Fx.source("s2", "逆画像検索の記録", .openData, "原投稿の照合メモ", daysAgo: 1),
        ],
        currentAssessment: "新規のUAP事象ではなく、過去映像の転載。取り下げても記録と監査履歴は消さず、誤情報の事例として保持する。",
        shapeTags: ["転載", "動画"], isDemo: true
    )

    // MARK: 9. AARO-style official archive update — explained/official
    static let aaroArchive = UAPCase(
        id: "case_official_archive", slug: "official-archive-resolution",
        title: "公式アーカイブ：過去の海上観測、機器要因で決着",
        summary: "公的機関が過去の海上での観測記録を再解析し、赤外センサーの視差効果（パララックス）による見かけの高速運動だったと結論づけた公開資料の要約。一次資料へのリンクを付す。",
        occurredAtStart: FixtureClock.day(-40, hour: 15),
        occurredAtEnd: FixtureClock.day(-40, hour: 15, minute: 3),
        publishedAt: FixtureClock.day(-2, hour: 9),
        lastVerifiedAt: FixtureClock.day(-2, hour: 9), updatedAt: FixtureClock.day(-2, hour: 9),
        latitude: 31.9, longitude: -117.3, locationPrecision: .regionOnly,
        countryCode: "US", regionName: "太平洋沖", localityName: nil,
        timeZoneIdentifier: "America/Los_Angeles",
        status: .explained,
        scores: CaseScores(evidenceQuality: 68, independence: 40, knownPhenomenaMatch: 86, unresolvedness: 14, algorithmVersion: "demo-1"),
        sourceCount: 2, independentReportCount: 1,
        agreements: [Fx.agree("ag1", "赤外映像に高速で動く物体が写っている", ["s1"])],
        contradictions: [],
        explanationCandidates: [
            Fx.candidate("ec1", .cameraArtifact, "センサーのパララックス効果", 86,
                         match: ["カメラの旋回と物体の見かけ速度が対応", "距離推定と整合"],
                         nonMatch: ["肉眼の同時観測記録は限定的"],
                         limits: "公開された解析範囲に基づく。"),
        ],
        missingInformation: [Fx.gap("mi1", "当時のレーダー生データの完全公開")],
        neededEvidence: [Fx.gap("ne1", "独立した第三者による再解析")],
        timeline: [Fx.timeline("t1", 2, "公的機関の再解析結果を要約して公開", status: .explained)],
        sources: [
            Fx.source("s1", "公的分析機関", .official, "過去観測記録の再解析レポート（公開版）", daysAgo: 2),
            Fx.source("s2", "科学系メディア", .press, "再解析の解説記事", role: .contextualizes, daysAgo: 2),
        ],
        currentAssessment: "公的資料に基づき、機器要因で説明できる。一次資料の要約であり、原本リンクを必ず参照できる。",
        shapeTags: ["赤外", "高速", "機器要因"], isDemo: true
    )
}
