import Foundation

/// Derives V2 (Aether) presentation data from the existing Phase 1 `UAPCase`
/// fixtures, so every case gains assessment dimensions, What-Changed deltas,
/// verified facts, related cases, and a priority reason without rewriting the
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
        let officialCount = sources.filter { $0.sourceType == .official }.count
        let official: AssessmentDimension.Level =
            officialCount >= 2 ? .strong : officialCount == 1 ? .moderate : .insufficient

        // Time consistency must not be inferred from unrelated contradictions
        // such as colour, direction, or object count. With the legacy model we can
        // safely assess only whether the recorded observation interval is valid.
        let time: AssessmentDimension.Level = {
            guard let start = occurredAtStart else { return .insufficient }
            guard let end = occurredAtEnd else { return .moderate }
            return end >= start ? .strong : .insufficient
        }()
        let timeBasis = time == .insufficient
            ? SkyStrings.t("assess.basis.timeConflict")
            : SkyStrings.t("assess.basis.timeOk")

        // These two dimensions describe the amount of adverse evidence. Zero is
        // therefore the lowest level, not "strong". Their colour semantics are
        // inverted in AssessmentDimension.signal.
        let contradictionLevel: AssessmentDimension.Level = {
            switch contradictions.count {
            case 0: .insufficient
            case 1: .limited
            case 2: .moderate
            default: .strong
            }
        }()
        let missingLevel: AssessmentDimension.Level = {
            switch missingInformation.count {
            case 0: .insufficient
            case 1: .limited
            case 2: .moderate
            default: .strong
            }
        }()

        return [
            .init(id: "\(id)_independence", kind: .sourceIndependence, level: independence,
                  basis: SkyStrings.t("assess.basis.independence", String(independentReportCount), String(sourceCount))),
            .init(id: "\(id)_time", kind: .timeConsistency, level: time, basis: timeBasis),
            .init(id: "\(id)_location", kind: .locationPrecision, level: location,
                  basis: SkyStrings.t(locationPrecision.labelKey)),
            .init(id: "\(id)_media", kind: .mediaProvenance, level: lvl(scores.evidenceQuality),
                  basis: SkyStrings.t("assess.basis.media")),
            .init(id: "\(id)_official", kind: .officialCorroboration, level: official,
                  basis: SkyStrings.t("assess.basis.official")),
            .init(id: "\(id)_known", kind: .knownPhenomenonFit, level: lvl(scores.knownPhenomenaMatch),
                  basis: SkyStrings.t("assess.basis.known")),
            .init(id: "\(id)_contradiction", kind: .unresolvedContradictions,
                  level: contradictionLevel,
                  basis: SkyStrings.t("assess.basis.contradiction", String(contradictions.count))),
            .init(id: "\(id)_missing", kind: .missingInformation,
                  level: missingLevel,
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
                    if !entry.addedSourceIDs.isEmpty {
                        let addedOfficial = sources.contains {
                            entry.addedSourceIDs.contains($0.id) && $0.sourceType == .official
                        }
                        return addedOfficial ? .officialUpdate : .newEvidence
                    }
                    // A generic timeline note is not automatically an official
                    // update. Without an official source it is an assessment edit.
                    return .assessmentChanged
                }()
                return CaseChangeEntry(id: "\(id)_chg_\(entry.id)", kind: kind,
                                       summary: entry.scoreChangeNote ?? entry.summary,
                                       timelineEntryID: entry.id, changedAt: entry.date)
            }
    }

    /// Only promote an agreement to a "confirmed fact" when it has at least two
    /// independently grouped supporting sources and one official/scientific
    /// source. Mere repetition across reports remains an agreement elsewhere.
    var confirmedFacts: [ConfirmedFact] {
        agreements.compactMap { agreement in
            let supporting = sources.filter { agreement.supportingSourceIDs.contains($0.id) }
            let independentGroups = Set(supporting.compactMap(\.independenceGroupID))
            let hasAuthoritativeSource = supporting.contains {
                $0.sourceType == .official || $0.sourceType == .scientific
            }
            guard supporting.count >= 2,
                  independentGroups.count >= 2,
                  hasAuthoritativeSource else { return nil }
            return ConfirmedFact(id: "\(id)_fact_\(agreement.id)", text: agreement.text,
                                 sourceIDs: supporting.map(\.id))
        }
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

    /// The "現時点" snapshot shown at the top of Case Detail: where the case
    /// stands now, the leading known explanation (if any), and the main open
    /// point. Short — orients before the deep sections (V3 §5.1).
    var executiveSnapshot: CaseExecutiveSnapshot {
        let leading = explanationCandidates
            .filter { $0.matchScore > 0 }
            .max(by: { $0.matchScore < $1.matchScore })?.label
        let open = missingInformation.first?.text ?? contradictions.first?.text
        return CaseExecutiveSnapshot(currentState: currentAssessment,
                                     leadingExplanation: leading, openPoint: open)
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
