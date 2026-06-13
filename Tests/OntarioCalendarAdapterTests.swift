import XCTest

@testable import Parliaments

final class OntarioCalendarAdapterTests: XCTestCase {
  func testMapsHouseAndCommitteeCalendarEventsToOntarioChannels() throws {
    let html = """
      <article class="calendar-event">
          <time datetime="2026-06-12T10:30:00-04:00">10:30 a.m.</time>
          <h3>House proceedings</h3>
      </article>
      <article class="calendar-event">
          <time datetime="2026-06-12T13:00:00-04:00">1:00 p.m.</time>
          <h3>Standing Committee on Finance and Economic Affairs - Room 151</h3>
      </article>
      """
    let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-06-12T15:00:00Z"))
    let metadata = try OntarioCalendarAdapter.programMetadataByChannelID(
      from: html,
      now: now,
      displayTimeZone: XCTUnwrap(TimeZone(identifier: "America/Toronto"))
    )

    let house = try XCTUnwrap(metadata["ontario-house-en"])
    XCTAssertEqual(house.currentEventTitle, "House proceedings")
    XCTAssertEqual(house.currentEventTime, "10:30 AM ET")
    XCTAssertEqual(
      house.nextEventTitle, "Standing Committee on Finance and Economic Affairs - Room 151")
    XCTAssertEqual(house.nextEventTime, "1:00 PM ET")
    XCTAssertEqual(house.confidence, .officialCalendar)

    let room151 = try XCTUnwrap(metadata["ontario-rm151-en"])
    XCTAssertEqual(room151.currentEventTitle, "House proceedings")
    XCTAssertEqual(
      room151.nextEventTitle, "Standing Committee on Finance and Economic Affairs - Room 151")
  }

  func testMapsNoEventsMessageToOntarioChannels() throws {
    let checkedAt = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-06-12T17:30:00Z"))
    let metadata = try OntarioCalendarAdapter.programMetadataByChannelID(
      from: #"<div class="calendar-view-day__no-event">There are no events today</div>"#,
      now: checkedAt,
      displayTimeZone: XCTUnwrap(TimeZone(identifier: "America/Toronto"))
    )

    let house = try XCTUnwrap(metadata["ontario-house-en"])
    XCTAssertEqual(house.currentEventTitle, "No calendar events listed today")
    XCTAssertEqual(house.currentEventTime, "Checked 1:30 PM ET")
    XCTAssertNil(house.nextEventTitle)
    XCTAssertNil(house.nextEventTime)
    XCTAssertEqual(house.confidence, .officialCalendar)
  }
}
