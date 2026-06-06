import XCTest
@testable import Parliaments

final class ChannelGuideTests: XCTestCase {
    func testGuideGroupsPrioritizePinnedLocalSources() {
        let groups = GuideGroup.build(
            nativeChannels: ChannelCatalog.channels,
            externalChannels: ChannelCatalog.sourcesRequiringExternalPlayer
        )

        XCTAssertEqual(groups.map(\.id), ["pinned", "quebec", "ontario", "world", "link-out"])
        XCTAssertEqual(groups.first?.channels.map(\.id), [
            "cpac-ca",
            "quebec-canal05",
            "quebec-canal06",
            "quebec-canal14",
            "ontario-house-en"
        ])
    }

    func testLinkOutSourcesAreSeparatedFromNativeSurfGroups() throws {
        let groups = GuideGroup.build(
            nativeChannels: ChannelCatalog.channels,
            externalChannels: ChannelCatalog.sourcesRequiringExternalPlayer
        )
        let linkOutGroup = try XCTUnwrap(groups.first { $0.id == GuideGroup.linkOutID })

        XCTAssertEqual(linkOutGroup.channels.map(\.id), [
            "uk-parliament",
            "european-parliament",
            "australia-parliament-youtube"
        ])
        XCTAssertTrue(linkOutGroup.channels.allSatisfy { $0.displayMode == .linkOut })
    }

    func testChannelCodesProvideStableGuidePositions() {
        let channelsByID = Dictionary(uniqueKeysWithValues: (
            ChannelCatalog.channels + ChannelCatalog.sourcesRequiringExternalPlayer
        ).map { ($0.id, $0) })

        XCTAssertEqual(channelsByID["cpac-ca"]?.channelCode, "001 CPAC")
        XCTAssertEqual(channelsByID["quebec-canal05"]?.channelCode, "005 QC")
        XCTAssertEqual(channelsByID["ontario-house-en"]?.channelCode, "020 ON")
        XCTAssertEqual(channelsByID["uk-parliament"]?.channelCode, "901 UK")
    }
}
