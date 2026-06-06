import Foundation

struct GuideGroup: Identifiable, Hashable {
    static let pinnedID = "pinned"
    static let linkOutID = "link-out"

    let id: String
    let title: String
    let systemImage: String
    let channels: [Channel]

    var countLabel: String {
        "\(channels.count)"
    }

    static func build(nativeChannels: [Channel], externalChannels: [Channel]) -> [GuideGroup] {
        let channelByID = Dictionary(uniqueKeysWithValues: nativeChannels.map { ($0.id, $0) })
        let pinned = [
            channelByID["cpac-ca"],
            channelByID["quebec-canal05"],
            channelByID["quebec-canal06"],
            channelByID["quebec-canal14"],
            channelByID["ontario-house-en"]
        ].compactMap { $0 }

        let quebec = nativeChannels.filter { $0.countryOrRegion == "Quebec" }
        let ontario = nativeChannels.filter { $0.countryOrRegion == "Ontario" }
        let world = nativeChannels.filter { channel in
            channel.jurisdictionLevel != .subnational && channel.id != "cpac-ca"
        }

        return [
            GuideGroup(id: pinnedID, title: "Pinned", systemImage: "pin.fill", channels: pinned),
            GuideGroup(id: "quebec", title: "Quebec", systemImage: "building.columns.fill", channels: quebec),
            GuideGroup(id: "ontario", title: "Ontario", systemImage: "captions.bubble.fill", channels: ontario),
            GuideGroup(id: "world", title: "World", systemImage: "globe.americas.fill", channels: world),
            GuideGroup(id: linkOutID, title: "Link-out", systemImage: "arrow.up.forward.square.fill", channels: externalChannels)
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
        case "uk-parliament":
            "901 UK"
        case "european-parliament":
            "902 EP"
        case "australia-parliament-youtube":
            "903 AU"
        default:
            shortName
        }
    }

    var liveStateLabel: String {
        if displayMode == .linkOut {
            return "Link-out"
        }

        switch availability {
        case .alwaysOn:
            return "Live"
        case .sittingOnly:
            return "Next sitting"
        case .eventBased:
            return "Event based"
        case .unknown:
            return "Schedule unavailable"
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
            return "Official HLS"
        case .officialPage:
            return "Link out"
        case .youtube:
            return "Official YouTube"
        }
    }
}
