import XCTest

@testable import Parliaments

final class NewZealandScheduleAdapterTests: XCTestCase {
  func testBuildsMetadataFromHouseNextMeetsText() throws {
    let html = """
      <main>
          <h2>House next meets</h2>
          <p>The House next meets on Tuesday, 16 June 2026 at 2:00 PM.</p>
      </main>
      """
    let checkedAt = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-06-12T17:00:00Z"))
    let metadata = try XCTUnwrap(
      try NewZealandScheduleAdapter.programMetadata(
        from: html,
        checkedAt: checkedAt,
        displayTimeZone: XCTUnwrap(TimeZone(identifier: "America/Toronto"))
      ))

    XCTAssertEqual(metadata.currentEventTitle, "House not currently listed live")
    XCTAssertEqual(metadata.currentEventTime, "Checked 1:00 PM ET")
    XCTAssertEqual(metadata.nextEventTitle, "House next meets")
    XCTAssertEqual(metadata.nextEventTime, "Tuesday, 16 June 2026 at 2:00 PM.")
    XCTAssertEqual(metadata.confidence, .officialCalendar)
  }
}
