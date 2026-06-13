import Foundation

struct GuideGroup: Identifiable, Hashable {
  static let pinnedID = "pinned"
  static let youtubeID = "youtube"
  static let defaultPinnedChannelIDs = [
    "cpac-ca",
    "quebec-canal05",
    "quebec-canal06",
    "quebec-canal14",
    "ontario-house-en",
    "nunavut-legislative-assembly-tv",
  ]

  let id: String
  let title: String
  let systemImage: String
  let channels: [Channel]

  var countLabel: String {
    "\(channels.count)"
  }

  static func build(
    nativeChannels: [Channel], externalChannels: [Channel], pinnedChannelIDs: Set<String>
  ) -> [GuideGroup] {
    let channelByID = Dictionary(uniqueKeysWithValues: nativeChannels.map { ($0.id, $0) })
    let pinned = nativeChannels.filter {
      pinnedChannelIDs.contains($0.id) && channelByID[$0.id] != nil
    }

    let regions = nativeChannels.filter { $0.jurisdictionLevel == .subnational }
    let national = nativeChannels.filter { $0.jurisdictionLevel != .subnational }

    return [
      GuideGroup(
        id: pinnedID, title: L10n.string("guide.group.pinned"), systemImage: "pin.fill",
        channels: pinned),
      GuideGroup(
        id: "national", title: L10n.string("guide.group.national"),
        systemImage: "globe.americas.fill", channels: national),
      GuideGroup(
        id: "regions", title: L10n.string("guide.group.regions"),
        systemImage: "building.columns.fill", channels: regions),
      GuideGroup(
        id: youtubeID, title: L10n.string("guide.group.youtube"),
        systemImage: "play.rectangle.fill",
        channels: externalChannels),
    ].filter { !$0.channels.isEmpty }
  }
}

extension Channel {
  var channelCode: String {
    switch id {
    case "cpac-ca":
      "001 CPAC"
    case "quebec-canal05":
      "005 QC"
    case "quebec-canal06":
      "006 QC"
    case "quebec-canal14":
      "014 QC"
    case "ontario-house-en":
      "020 ON"
    case "ontario-house-en-cc":
      "021 ON"
    case "ontario-rm151-en":
      "022 ON"
    case "ontario-committee-1-en":
      "023 ON"
    case "ontario-committee-2-en":
      "024 ON"
    case "ontario-media-en":
      "025 ON"
    case "nunavut-legislative-assembly-tv":
      "030 NU"
    case "new-zealand-parliament":
      "101 NZ"
    case "brazil-tv-camara":
      "102 BR"
    case "denmark-folketinget":
      "103 DK"
    case "netherlands-tweede-kamer":
      "104 NL"
    case "spain-canal-parlamento":
      "105 ES"
    case "france-national-assembly":
      "106 FR"
    case "portugal-artv":
      "107 PT"
    case "greece-hellenic-parliament-tv":
      "108 GR"
    case "luxembourg-chamber-tv":
      "109 LU"
    case "italy-senate":
      "110 IT"
    case "india-sansad-tv-1":
      "111 IN"
    case "india-sansad-tv-2":
      "112 IN"
    case "thailand-parliament-tv":
      "113 TH"
    case "slovakia-tv-nrsr":
      "114 SK"
    case "mongolia-parliament-tv":
      "115 MN"
    case "uk-parliament-youtube":
      "901 UK"
    case "australia-parliament-youtube":
      "902 AU"
    case "taiwan-parliamentary-tv-youtube":
      "903 TW"
    case "costa-rica-assembly-youtube":
      "904 CR"
    default:
      shortName
    }
  }

  var liveStateLabel: String {
    if displayMode == .linkOut {
      if sourceType == .youtube {
        return L10n.string("source.quality.youtube")
      }
      return L10n.string("source.linkOut")
    }

    switch availability {
    case .alwaysOn:
      return L10n.string("state.live")
    case .sittingOnly:
      return L10n.string("state.sittingFeed")
    case .eventBased:
      return L10n.string("state.eventFeed")
    case .unknown:
      return L10n.string("state.signalOnly")
    }
  }

  var liveStateIcon: String {
    if displayMode == .linkOut {
      return "arrow.up.forward.square"
    }

    switch availability {
    case .alwaysOn:
      return "dot.radiowaves.left.and.right"
    case .sittingOnly:
      return "calendar"
    case .eventBased:
      return "calendar.badge.clock"
    case .unknown:
      return "questionmark.circle"
    }
  }

  var sourceQualityLabel: String {
    switch sourceType {
    case .directHLS:
      return L10n.string("source.quality.officialHLS")
    case .directDASH:
      return L10n.string("source.quality.dash")
    case .officialPage:
      return L10n.string("source.quality.linkOut")
    case .youtube:
      return L10n.string("source.quality.youtube")
    }
  }
}
