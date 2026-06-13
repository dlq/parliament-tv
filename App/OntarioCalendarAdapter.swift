import Foundation

enum OntarioCalendarAdapter {
  nonisolated static let calendarURL = URL(
    string: "https://www.ola.org/en/legislative-business/calendar")!

  nonisolated static func request() -> URLRequest {
    var request = URLRequest(url: calendarURL)
    request.timeoutInterval = 8
    request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
    return request
  }

  nonisolated static func programMetadataByChannelID(
    from html: String,
    now: Date = Date(),
    displayTimeZone: TimeZone = .current
  ) -> [String: ProgramMetadata] {
    let events = calendarEvents(from: html).sorted { $0.start < $1.start }
    guard !events.isEmpty else {
      if html.range(of: "There are no events today", options: .caseInsensitive) != nil {
        let metadata = ProgramMetadata(
          currentEventTitle: "No calendar events listed today",
          currentEventTime:
            "Checked \(ScheduleTextHelpers.timeLabel(for: now, timeZone: displayTimeZone))",
          nextEventTitle: nil,
          nextEventTime: nil,
          confidence: .officialCalendar
        )
        return Dictionary(uniqueKeysWithValues: channelIDs.map { ($0, metadata) })
      }
      return [:]
    }

    let nextIndex = events.firstIndex { $0.start > now }
    let currentIndex: Int
    if let nextIndex {
      currentIndex =
        nextIndex == events.startIndex ? events.startIndex : events.index(before: nextIndex)
    } else {
      currentIndex = events.index(before: events.endIndex)
    }

    let current = events[currentIndex]
    let next = events.indices.contains(currentIndex + 1) ? events[currentIndex + 1] : nil
    let metadata = ProgramMetadata(
      currentEventTitle: current.title,
      currentEventTime: ScheduleTextHelpers.timeLabel(
        for: current.start, timeZone: displayTimeZone),
      nextEventTitle: next?.title,
      nextEventTime: next.map {
        ScheduleTextHelpers.timeLabel(for: $0.start, timeZone: displayTimeZone)
      },
      confidence: .officialCalendar
    )

    return Dictionary(uniqueKeysWithValues: channelIDs.map { ($0, metadata) })
  }

  private nonisolated static let channelIDs = [
    "ontario-house-en",
    "ontario-house-en-cc",
    "ontario-rm151-en",
    "ontario-committee-1-en",
    "ontario-committee-2-en",
    "ontario-media-en",
  ]

  private nonisolated static func calendarEvents(from html: String) -> [CalendarEvent] {
    let pattern =
      #"<time[^>]*datetime="([^"]+)"[^>]*>[\s\S]*?</time>[\s\S]*?<h[1-6][^>]*>([\s\S]*?)</h[1-6]>"#
    guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
      return []
    }
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]

    return regex.matches(in: html, range: NSRange(html.startIndex..<html.endIndex, in: html))
      .compactMap { match in
        guard
          let dateRange = Range(match.range(at: 1), in: html),
          let titleRange = Range(match.range(at: 2), in: html),
          let start = formatter.date(from: String(html[dateRange]))
        else {
          return nil
        }

        let title = ScheduleTextHelpers.cleanHTML(String(html[titleRange]))
        guard !title.isEmpty else { return nil }
        return CalendarEvent(start: start, title: title)
      }
  }

  private struct CalendarEvent {
    let start: Date
    let title: String
  }
}
