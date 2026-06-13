import Foundation

enum NewZealandScheduleAdapter {
  nonisolated static let channelID = "new-zealand-parliament"
  nonisolated static let calendarURL = URL(string: "https://www3.parliament.nz/en/calendar/")!

  nonisolated static func request() -> URLRequest {
    var request = URLRequest(url: calendarURL)
    request.timeoutInterval = 8
    request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
    return request
  }

  nonisolated static func programMetadata(
    from html: String,
    checkedAt: Date = Date(),
    displayTimeZone: TimeZone = .current
  ) -> ProgramMetadata? {
    guard html.range(of: "House next meets", options: .caseInsensitive) != nil else {
      return nil
    }

    let body = ScheduleTextHelpers.cleanHTML(html)
    let nextText =
      ScheduleTextHelpers.firstMatch(
        in: body,
        pattern: #"The\s+House next meets\s+(?:on\s+)?([^\.]+\.?)"#
      )
      ?? ScheduleTextHelpers.firstMatch(
        in: body,
        pattern: #"House next meets\s+(?:on\s+)?([^\.]+\.?)"#
      )

    return ProgramMetadata(
      currentEventTitle: "House not currently listed live",
      currentEventTime:
        "Checked \(ScheduleTextHelpers.timeLabel(for: checkedAt, timeZone: displayTimeZone))",
      nextEventTitle: "House next meets",
      nextEventTime: nextText,
      confidence: "Official calendar"
    )
  }
}
