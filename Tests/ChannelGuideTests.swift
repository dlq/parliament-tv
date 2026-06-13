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
    XCTAssertEqual(
      groups.first?.channels.map(\.id),
      [
        "cpac-ca",
        "quebec-canal05",
        "quebec-canal06",
        "quebec-canal14",
        "ontario-house-en",
        "nunavut-legislative-assembly-tv",
      ])

    let nationalGroup = groups.first { $0.id == "national" }
    XCTAssertTrue(nationalGroup?.channels.contains { $0.id == "cpac-ca" } == true)

    let regionsGroup = groups.first { $0.id == "regions" }
    XCTAssertEqual(regionsGroup?.channels.count, 21)
    XCTAssertTrue(
      regionsGroup?.channels.contains { $0.id == "nunavut-legislative-assembly-tv" } == true)
  }

  func testGuideGroupsUseCustomPinnedChannels() {
    let groups = GuideGroup.build(
      nativeChannels: ChannelCatalog.channels,
      externalChannels: ChannelCatalog.sourcesRequiringExternalPlayer,
      pinnedChannelIDs: ["cpac-ca", "france-national-assembly", "thailand-parliament-tv"]
    )

    XCTAssertEqual(groups.first?.id, GuideGroup.pinnedID)
    XCTAssertEqual(
      groups.first?.channels.map(\.id),
      [
        "cpac-ca",
        "france-national-assembly",
        "thailand-parliament-tv",
      ])
  }

  func testYouTubeSourcesAreSeparatedFromNativeSurfGroups() throws {
    let groups = GuideGroup.build(
      nativeChannels: ChannelCatalog.channels,
      externalChannels: ChannelCatalog.sourcesRequiringExternalPlayer,
      pinnedChannelIDs: Set(GuideGroup.defaultPinnedChannelIDs)
    )
    let youtubeGroup = try XCTUnwrap(groups.first { $0.id == GuideGroup.youtubeID })

    XCTAssertEqual(
      youtubeGroup.channels.map(\.id),
      [
        "uk-parliament-youtube",
        "australia-parliament-youtube",
        "taiwan-parliamentary-tv-youtube",
        "costa-rica-assembly-youtube",
      ])
    XCTAssertTrue(youtubeGroup.channels.allSatisfy { $0.sourceType == .youtube })
    XCTAssertTrue(youtubeGroup.channels.allSatisfy { $0.displayMode == .linkOut })
  }

  func testChannelCodesProvideStableGuidePositions() {
    let channelsByID = Dictionary(
      uniqueKeysWithValues: (ChannelCatalog.channels + ChannelCatalog.sourcesRequiringExternalPlayer)
        .map { ($0.id, $0) })

    XCTAssertEqual(channelsByID["cpac-ca"]?.channelCode, "001 CPAC")
    XCTAssertEqual(channelsByID["quebec-canal05"]?.channelCode, "005 QC")
    XCTAssertEqual(channelsByID["ontario-house-en"]?.channelCode, "020 ON")
    XCTAssertEqual(channelsByID["nunavut-legislative-assembly-tv"]?.channelCode, "030 NU")
    XCTAssertEqual(channelsByID["mongolia-parliament-tv"]?.channelCode, "115 MN")
    XCTAssertEqual(channelsByID["uk-parliament-youtube"]?.channelCode, "901 UK")
    XCTAssertEqual(channelsByID["costa-rica-assembly-youtube"]?.channelCode, "904 CR")
  }

  func testChannelDisplayLabelsMatchSourceAndAvailability() throws {
    let cpac = try XCTUnwrap(ChannelCatalog.channels.first { $0.id == "cpac-ca" })
    XCTAssertEqual(cpac.liveStateLabel, "Live")
    XCTAssertEqual(cpac.liveStateIcon, "dot.radiowaves.left.and.right")
    XCTAssertEqual(cpac.sourceQualityLabel, "Official HLS")

    let newZealand = try XCTUnwrap(
      ChannelCatalog.channels.first { $0.id == "new-zealand-parliament" })
    XCTAssertEqual(newZealand.liveStateLabel, "Sitting feed")
    XCTAssertEqual(newZealand.liveStateIcon, "calendar")

    let quebec = try XCTUnwrap(ChannelCatalog.channels.first { $0.id == "quebec-canal01" })
    XCTAssertEqual(quebec.liveStateLabel, "Event feed")
    XCTAssertEqual(quebec.liveStateIcon, "calendar.badge.clock")

    let youtube = try XCTUnwrap(
      ChannelCatalog.sourcesRequiringExternalPlayer.first { $0.id == "uk-parliament-youtube" })
    XCTAssertEqual(youtube.liveStateLabel, "YouTube")
    XCTAssertEqual(youtube.liveStateIcon, "arrow.up.forward.square")
    XCTAssertEqual(youtube.sourceQualityLabel, "YouTube")
  }

  func testCatalogueMetadataUsesTypedLabels() throws {
    let cpac = try XCTUnwrap(ChannelCatalog.channels.first { $0.id == "cpac-ca" })
    XCTAssertEqual(cpac.legalReviewStatus, .personalUsePendingReview)
    XCTAssertEqual(cpac.legalReviewStatus.label, "Personal use only until reviewed")
    XCTAssertEqual(cpac.metadataLevel, .dailyScheduleTarget)
    XCTAssertEqual(cpac.metadataLevel.label, "Daily schedule target")
    XCTAssertEqual(cpac.program.confidence, .medium)
    XCTAssertEqual(cpac.program.confidence.label, "Medium")

    let youtube = try XCTUnwrap(
      ChannelCatalog.sourcesRequiringExternalPlayer.first { $0.id == "uk-parliament-youtube" })
    XCTAssertEqual(youtube.legalReviewStatus, .embedOnly)
    XCTAssertEqual(youtube.metadataLevel, .youtubeCurrentEventTarget)
  }

  func testMacOSCatalogIncludesDashExperiment() throws {
    #if os(macOS)
      let channel = try XCTUnwrap(
        ChannelCatalog.channels.first { $0.id == "mongolia-parliament-tv" })
      XCTAssertEqual(channel.sourceType, .directDASH)
      XCTAssertEqual(channel.displayMode, .nativePlayer)
    #endif
  }
}
