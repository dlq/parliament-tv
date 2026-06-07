import XCTest
@testable import Parliaments

final class ChannelGuideTests: XCTestCase {
    func testGuideGroupsPrioritizePinnedLocalSources() {
        let groups = GuideGroup.build(
            nativeChannels: ChannelCatalog.channels,
            externalChannels: ChannelCatalog.sourcesRequiringExternalPlayer,
            pinnedChannelIDs: Set(GuideGroup.defaultPinnedChannelIDs)
        )

        XCTAssertEqual(groups.map(\.id), ["pinned", "national", "regions", "youtube"])
        XCTAssertEqual(groups.first?.channels.map(\.id), [
            "cpac-ca",
            "quebec-canal05",
            "quebec-canal06",
            "quebec-canal14",
            "ontario-house-en",
            "nunavut-legislative-assembly-tv"
        ])

        let nationalGroup = groups.first { $0.id == "national" }
        XCTAssertTrue(nationalGroup?.channels.contains { $0.id == "cpac-ca" } == true)

        let regionsGroup = groups.first { $0.id == "regions" }
        XCTAssertEqual(regionsGroup?.channels.count, 21)
        XCTAssertTrue(regionsGroup?.channels.contains { $0.id == "nunavut-legislative-assembly-tv" } == true)
    }

    func testGuideGroupsUseCustomPinnedChannels() {
        let groups = GuideGroup.build(
            nativeChannels: ChannelCatalog.channels,
            externalChannels: ChannelCatalog.sourcesRequiringExternalPlayer,
            pinnedChannelIDs: ["cpac-ca", "france-national-assembly", "thailand-parliament-tv"]
        )

        XCTAssertEqual(groups.first?.id, GuideGroup.pinnedID)
        XCTAssertEqual(groups.first?.channels.map(\.id), [
            "cpac-ca",
            "france-national-assembly",
            "thailand-parliament-tv"
        ])
    }

    func testYouTubeSourcesAreSeparatedFromNativeSurfGroups() throws {
        let groups = GuideGroup.build(
            nativeChannels: ChannelCatalog.channels,
            externalChannels: ChannelCatalog.sourcesRequiringExternalPlayer,
            pinnedChannelIDs: Set(GuideGroup.defaultPinnedChannelIDs)
        )
        let youtubeGroup = try XCTUnwrap(groups.first { $0.id == GuideGroup.youtubeID })

        XCTAssertEqual(youtubeGroup.channels.map(\.id), [
            "uk-parliament-youtube",
            "australia-parliament-youtube",
            "taiwan-parliamentary-tv-youtube",
            "costa-rica-assembly-youtube"
        ])
        XCTAssertTrue(youtubeGroup.channels.allSatisfy { $0.sourceType == .youtube })
        XCTAssertTrue(youtubeGroup.channels.allSatisfy { $0.displayMode == .linkOut })
    }

    func testChannelCodesProvideStableGuidePositions() {
        let channelsByID = Dictionary(uniqueKeysWithValues: (
            ChannelCatalog.channels + ChannelCatalog.sourcesRequiringExternalPlayer
        ).map { ($0.id, $0) })

        XCTAssertEqual(channelsByID["cpac-ca"]?.channelCode, "001 CPAC")
        XCTAssertEqual(channelsByID["quebec-canal05"]?.channelCode, "005 QC")
        XCTAssertEqual(channelsByID["ontario-house-en"]?.channelCode, "020 ON")
        XCTAssertEqual(channelsByID["nunavut-legislative-assembly-tv"]?.channelCode, "030 NU")
        XCTAssertEqual(channelsByID["mongolia-parliament-tv"]?.channelCode, "115 MN")
        XCTAssertEqual(channelsByID["uk-parliament-youtube"]?.channelCode, "901 UK")
        XCTAssertEqual(channelsByID["costa-rica-assembly-youtube"]?.channelCode, "904 CR")
    }

    func testMacOSCatalogIncludesDashExperiment() throws {
        #if os(macOS)
        let channel = try XCTUnwrap(ChannelCatalog.channels.first { $0.id == "mongolia-parliament-tv" })
        XCTAssertEqual(channel.sourceType, .directDASH)
        XCTAssertEqual(channel.displayMode, .nativePlayer)
        #endif
    }
}
