import Foundation

enum JurisdictionLevel: String {
  case national
  case subnational
  case supranational

  var label: String {
    switch self {
    case .national: L10n.string("jurisdiction.national")
    case .subnational: L10n.string("jurisdiction.subnational")
    case .supranational: L10n.string("jurisdiction.supranational")
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
    case .directHLS: L10n.string("source.type.directHLS")
    case .directDASH: L10n.string("source.type.directDASH")
    case .officialPage: L10n.string("source.type.officialPage")
    case .youtube: L10n.string("source.type.youtube")
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
    case .alwaysOn: L10n.string("availability.alwaysOn")
    case .sittingOnly: L10n.string("availability.sittingOnly")
    case .eventBased: L10n.string("availability.eventBased")
    case .unknown: L10n.string("availability.unknown")
    }
  }
}

enum TechnicalStatus: String {
  case validated
  case linkOnly
  case needsReview

  var label: String {
    switch self {
    case .validated: L10n.string("metadata.technical.validated")
    case .linkOnly: L10n.string("metadata.technical.linkOnly")
    case .needsReview: L10n.string("metadata.technical.needsReview")
    }
  }
}

enum LegalReviewStatus: String {
  case personalUsePendingReview
  case explicitReuseWithConditions
  case noncommercialPendingReview
  case embedOnly

  var label: String {
    switch self {
    case .personalUsePendingReview: L10n.string("metadata.legal.personalUsePendingReview")
    case .explicitReuseWithConditions: L10n.string("metadata.legal.explicitReuseWithConditions")
    case .noncommercialPendingReview: L10n.string("metadata.legal.noncommercialPendingReview")
    case .embedOnly: L10n.string("metadata.legal.embedOnly")
    }
  }
}

enum MetadataLevel: String {
  case signalStateOnly
  case scheduleTarget
  case agendaTarget
  case dailyScheduleTarget
  case currentEventTarget
  case currentAndNextEventTarget
  case youtubeCurrentEventTarget

  var label: String {
    switch self {
    case .signalStateOnly: L10n.string("metadata.level.signalStateOnly")
    case .scheduleTarget: L10n.string("metadata.level.scheduleTarget")
    case .agendaTarget: L10n.string("metadata.level.agendaTarget")
    case .dailyScheduleTarget: L10n.string("metadata.level.dailyScheduleTarget")
    case .currentEventTarget: L10n.string("metadata.level.currentEventTarget")
    case .currentAndNextEventTarget: L10n.string("metadata.level.currentAndNextEventTarget")
    case .youtubeCurrentEventTarget: L10n.string("metadata.level.youtubeCurrentEventTarget")
    }
  }
}

enum ProgramConfidence: Hashable {
  case low
  case medium
  case high
  case signal
  case officialCalendar
  case officialWeeklySchedule
  case officialLiveList
  case officialSourceSchedule

  var label: String {
    switch self {
    case .low: L10n.string("metadata.confidence.low")
    case .medium: L10n.string("metadata.confidence.medium")
    case .high: L10n.string("metadata.confidence.high")
    case .signal: L10n.string("metadata.confidence.signal")
    case .officialCalendar: L10n.string("metadata.confidence.officialCalendar")
    case .officialWeeklySchedule: L10n.string("metadata.confidence.officialWeeklySchedule")
    case .officialLiveList: L10n.string("metadata.confidence.officialLiveList")
    case .officialSourceSchedule: L10n.string("metadata.confidence.officialSourceSchedule")
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
  let legalReviewStatus: LegalReviewStatus
  let technicalStatus: TechnicalStatus
  let availability: Availability
  let metadataLevel: MetadataLevel
  let previewAssetName: String?
  let program: ProgramMetadata
}

struct ProgramMetadata: Hashable {
  let currentEventTitle: String
  let currentEventTime: String
  let nextEventTitle: String?
  let nextEventTime: String?
  let confidence: ProgramConfidence
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
