import XCTest

@testable import Parliaments

final class CPACScheduleAdapterTests: XCTestCase {
  func testBuildsNowNextMetadataFromScheduleRows() throws {
    let html = """
      <div class="schedule-list-wrapper">
          <h2 class="schedule-date hidden" itemprop="startDate" data-airdate="2026-06-08T14:00:00.000Z"></h2>
          <button class="schedule-item-btn">House of Commons Proceedings</button>
      </div>
      <div class="schedule-list-wrapper">
          <h2 class="schedule-date hidden" itemprop="startDate" data-airdate="2026-06-08T15:00:00.000Z"></h2>
          <button class="schedule-item-btn">Question Period</button>
      </div>
      """

    let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-06-08T14:30:00Z"))
    let metadata = try XCTUnwrap(
      try CPACScheduleAdapter.programMetadata(
        from: html,
        now: now,
        displayTimeZone: XCTUnwrap(TimeZone(identifier: "America/Toronto"))
      ))

    XCTAssertEqual(metadata.currentEventTitle, "House of Commons Proceedings")
    XCTAssertEqual(metadata.currentEventTime, "10:00 AM - 11:00 AM ET")
    XCTAssertEqual(metadata.nextEventTitle, "Question Period")
    XCTAssertEqual(metadata.nextEventTime, "11:00 AM ET")
    XCTAssertEqual(metadata.confidence, .high)
  }
}
