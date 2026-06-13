import XCTest

@testable import Parliaments

final class BrazilScheduleAdapterTests: XCTestCase {
  func testBuildsNowNextMetadataFromWeeklyProgrammingRows() throws {
    let html = """
      <div id="programacao-segunda">
          <table>
              <tbody>
                  <tr>
                      <td><span>13:00</span></td>
                      <td><span>Participação Popular: Os desafios das relações na Era Digital</span></td>
                  </tr>
                  <tr>
                      <td><span>14:00</span></td>
                      <td><span>Câmara Debate: Regulamentação da Inteligência Artificial</span></td>
                  </tr>
              </tbody>
          </table>
      </div>
      """
    let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-06-08T16:30:00Z"))
    let metadata = try XCTUnwrap(
      try BrazilScheduleAdapter.programMetadata(
        from: html,
        now: now,
        calendar: Calendar(identifier: .gregorian),
        sourceTimeZone: XCTUnwrap(TimeZone(identifier: "America/Sao_Paulo")),
        displayTimeZone: XCTUnwrap(TimeZone(identifier: "America/Toronto"))
      ))

    XCTAssertEqual(
      metadata.currentEventTitle, "Participação Popular: Os desafios das relações na Era Digital")
    XCTAssertEqual(metadata.currentEventTime, "12:00 PM - 1:00 PM ET")
    XCTAssertEqual(
      metadata.nextEventTitle, "Câmara Debate: Regulamentação da Inteligência Artificial")
    XCTAssertEqual(metadata.nextEventTime, "1:00 PM ET")
    XCTAssertEqual(metadata.confidence, .officialWeeklySchedule)
  }

  func testPrefersActiveDayTabWhenWeeklyPageContainsMultipleDays() throws {
    let html = """
      <div class="tab-pane fade" id="quinta_feira">
          <table>
              <tr><td><span>11:00</span></td><td><span>Previous day program</span></td></tr>
          </table>
      </div>
      <div class="tab-pane fade active in show" id="sexta_feira">
          <table>
              <tr><td><span>11:00</span></td><td><span>Active day program</span></td></tr>
              <tr><td><span>12:00</span></td><td><span>Active day next</span></td></tr>
          </table>
      </div>
      """
    let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-06-12T14:30:00Z"))
    let metadata = try XCTUnwrap(
      try BrazilScheduleAdapter.programMetadata(
        from: html,
        now: now,
        calendar: Calendar(identifier: .gregorian),
        sourceTimeZone: XCTUnwrap(TimeZone(identifier: "America/Sao_Paulo")),
        displayTimeZone: XCTUnwrap(TimeZone(identifier: "America/Toronto"))
      ))

    XCTAssertEqual(metadata.currentEventTitle, "Active day program")
    XCTAssertEqual(metadata.nextEventTitle, "Active day next")
  }
}
