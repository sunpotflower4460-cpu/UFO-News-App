import Foundation

/// Derives V2 (Aether) presentation data from the existing Phase 1 `UAPCase`
/// fixtures, so every case gains assessment dimensions, What-Changed deltas,
/// confirmed facts, related cases, and a priority reason without rewriting the
/// fixture library. Production data will populate these fields directly later.
extension UAPCase {

    var v2Status: SkyCaseStatus { SkyCaseStatus(status) }

    /// Multi-axis assessment (never a single score).
    var assessmentDimensions: [AssessmentDimension] {
        func lvl(_ v: Int) -> AssessmentDimension.Level {
            switch v { case 75...: .strong; case 50...: .moderate; case 25...: .limited; default: .insufficient }
        }
        let independence: AssessmentDimension.Level =
            independentReportCount >= 4 ? .strong :
            independentReportCount == 3 ? .moderate :
            independentReportCount == 2 ? .limited : .insufficient
        let location: AssessmentDimension.Level = {
            switch locationPrecision {
            case .exact: .strong; case .approximate: .moderate; case .regionOnly: .limited; case .withheld: .insufficient
            }
        }()
        let official = sources.contains { $0.sourceType == .official } ? AssessmentDimension.Level.moderate : .limited
        return [
            .init(id: "\(id)_independence", kind: .sourceIndependence, level: independence,
                  basis: SkyStrings.t("assess.basis.independence", String(independentReportCount), String(sourceCount))),
            .init(id: "\(id)_time", kind: .timeConsistency, level: contradictions.isEmpty ? .moderate : .limited,
                  basis: contradictions.isEmpty ? SkyStrings.t("assess.basis.timeOk") : SkyStrings.t("assess.basis.timeConflict")),
            .init(id: "\(id)_location", kind: .locationPrecision, level: location,
                  basis: SkyStrings.t(locationPrecision.labelKey)),
            .init(id: "\(id)_media", kind: .mediaProvenance, level: lvl(scores.evidenceQuality),
                  basis: SkyStrings.t("assess.basis.media")),
            .init(id: "\(id)_official", kind: .officialCorroboration, level: official,
                  basis: SkyStrings.t("assess.basis.official")),
            .init(id: "\(id)_known", kind: .knownPhenomenonFit, level: lvl(scores.knownPhenomenaMatch),
                  basis: SkyStrings.t("assess.basis.known")),
            .init(id: "\(id)_contradiction", kind: .unresolvedContradictions,
                  level: contradictions.isEmpty ? .strong : (contradictions.count == 1 ? .moderate : .limited),
                  basis: SkyStrings.t("assess.basis.contradiction", String(contradictions.count))),
            .init(id: "\(id)_missing", kind: .missingInformation,
                  level: missingInformation.isEmpty ? .strong : (missingInformation.count <= 1 ? .moderate : .limited),
                  basis: SkyStrings.t("assess.basis.missing", String(missingInformation.count))),
        ]
    }

    /// What-Changed deltas, derived from timeline entries newer than publication.
    var whatChanged: [CaseChangeEntry] {
        timeline
            .filter { $0.date > publishedAt.addingTimeInterval(60) }
            .sorted { $0.date > $1.date }
            .map { entry in
                let kind: CaseChangeEntry.Kind = {
                    if entry.statusChange == .disputed { return .contradiction }
                    if entry.statusChange == .withdrawn { return .correction }
                    if entry.statusChange != nil { return .assessmentChanged }
                    if !entry.addedSourceIDs.isEmpty { return .newEvidence }
                    return .officialUpdate
                }()
                return CaseChangeEntry(id: "\(id)_chg_\(entry.id)", kind: kind,
                                       summary: entry.scoreChangeNote ?? entry.summary,
                                       timelineEntryID: entry.id, changedAt: entry.date)
            }
    }

    var confirmedFacts: [ConfirmedFact] {
        agreements.map { ConfirmedFact(id: "\(id)_fact_\($0.id)", text: $0.text, sourceIDs: $0.supportingSourceIDs) }
    }

    /// Evidence *records* (distinct from Sources/citations): the record-bearing
    /// sources reframed as evidence. See docs/DECISIONS.md D-V3-001.
    var evidenceItems: [EvidenceItem] {
        sources.compactMap { s in
            guard let kind = EvidenceKind(s.sourceType) else { return nil }
            return EvidenceItem(id: "\(id)_ev_\(s.id)", kind: kind, title: s.title,
                                capturedAt: s.publishedAt ?? s.retrievedAt, sourceID: s.id)
        }
    }

    /// Priority reason for Today's lead, derived from the latest meaningful change.
    var priorityReason: String? {
        guard let latest = whatChanged.first else { return nil }
        return SkyStrings.t(latest.kind.labelKey) + "：" + latest.summary
    }

    /// Related cases by shared shape tags (demo heuristic; explicit in production).
    func relatedRefs(in all: [UAPCase], limit: Int = 3) -> [RelatedCaseRef] {
        let tags = Set(shapeTags)
        return all
            .filter { $0.id != id && !tags.isDisjoint(with: Set($0.shapeTags)) }
            .prefix(limit)
            .map { RelatedCaseRef(id: $0.id, relation: .similarAppearance) }
    }
}
