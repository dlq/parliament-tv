import XCTest

@testable import Parliaments

final class HLSProgramMetadataTests: XCTestCase {
  func testSignalFallbackReplacesPlannedCopyForEveryNativeHLSChannel() throws {
    let checkedAt = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-06-08T14:30:00Z"))
    let timeZone = try XCTUnwrap(TimeZone(identifier: "America/Toronto"))
    let hlsChannels = ChannelCatalog.channels.filter {
      $0.sourceType == .directHLS && $0.playbackURL != nil
    }

    XCTAssertFalse(hlsChannels.isEmpty)

    for channel in hlsChannels {
      let metadata = HLSProgramMetadataAdapter.signalMetadata(
        for: channel,
        status: .available,
        checkedAt: checkedAt,
        displayTimeZone: timeZone
      )

      XCTAssertEqual(metadata.currentEventTitle, "Signal available, program unknown", channel.id)
      XCTAssertEqual(metadata.currentEventTime, "Checked 10:30 AM ET", channel.id)
      XCTAssertNil(metadata.nextEventTitle, channel.id)
      XCTAssertNil(metadata.nextEventTime, channel.id)
      XCTAssertEqual(metadata.confidence, "Signal", channel.id)
    }
  }
}
