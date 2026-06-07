//
//  Models.swift
//  Parliaments
//
//  Created by Darcy Quesnel on 2026-05-12.
//

import Foundation

enum JurisdictionLevel: String {
    case national
    case subnational
    case supranational

    var label: String {
        switch self {
        case .national: "National"
        case .subnational: "Subnational"
        case .supranational: "Supranational"
        }
    }
}

enum SourceType: String {
    case directHLS
    case directDASH
    case officialPage
    case youtube

    var label: String {
        switch self {
        case .directHLS: "Direct HLS"
        case .directDASH: "Direct DASH"
        case .officialPage: "Official page"
        case .youtube: "YouTube"
        }
    }
}

enum DisplayMode: String {
    case nativePlayer
    case linkOut
}

enum Availability: String {
    case alwaysOn
    case sittingOnly
    case eventBased
    case unknown

    var label: String {
        switch self {
        case .alwaysOn: "24/7"
        case .sittingOnly: "Sitting only"
        case .eventBased: "Event based"
        case .unknown: "Unknown"
        }
    }
}

enum TechnicalStatus: String {
    case validated
    case linkOnly
    case needsReview

    var label: String {
        switch self {
        case .validated: "Validated"
        case .linkOnly: "Link only"
        case .needsReview: "Needs review"
        }
    }
}

struct Channel: Identifiable, Hashable {
    let id: String
    let name: String
    let shortName: String
    let jurisdictionLevel: JurisdictionLevel
    let countryOrRegion: String
    let legislature: String
    let language: String
    let sourceType: SourceType
    let displayMode: DisplayMode
    let playbackURL: URL?
    let officialURL: URL
    let attributionText: String
    let legalReviewStatus: String
    let technicalStatus: TechnicalStatus
    let availability: Availability
    let metadataLevel: String
    let previewAssetName: String?
    let program: ProgramMetadata
}

struct ProgramMetadata: Hashable {
    let currentEventTitle: String
    let currentEventTime: String
    let nextEventTitle: String?
    let nextEventTime: String?
    let confidence: String
}

extension Channel {
    func replacingProgram(_ program: ProgramMetadata) -> Channel {
        Channel(
            id: id,
            name: name,
            shortName: shortName,
            jurisdictionLevel: jurisdictionLevel,
            countryOrRegion: countryOrRegion,
            legislature: legislature,
            language: language,
            sourceType: sourceType,
            displayMode: displayMode,
            playbackURL: playbackURL,
            officialURL: officialURL,
            attributionText: attributionText,
            legalReviewStatus: legalReviewStatus,
            technicalStatus: technicalStatus,
            availability: availability,
            metadataLevel: metadataLevel,
            previewAssetName: previewAssetName,
            program: program
        )
    }
}
