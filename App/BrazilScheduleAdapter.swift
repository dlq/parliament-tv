import Foundation

enum BrazilScheduleAdapter {
    nonisolated static let channelID = "brazil-tv-camara"
    nonisolated static let scheduleURL = URL(string: "https://www.camara.leg.br/tv/programacao-semanal")!

    nonisolated static func request() -> URLRequest {
        var request = URLRequest(url: scheduleURL)
        request.timeoutInterval = 8
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        return request
    }

    nonisolated static func programMetadata(
        from html: String,
        now: Date = Date(),
        calendar: Calendar = Calendar(identifier: .gregorian),
        sourceTimeZone: TimeZone = TimeZone(identifier: "America/Sao_Paulo")!,
        displayTimeZone: TimeZone = .current
    ) -> ProgramMetadata? {
        let entries = scheduleEntries(from: html, now: now, calendar: calendar, sourceTimeZone: sourceTimeZone)
        guard !entries.isEmpty else { return nil }

        let nextIndex = entries.firstIndex { $0.start > now }
        let currentIndex: Int
        if let nextIndex {
            currentIndex = nextIndex == entries.startIndex ? entries.startIndex : entries.index(before: nextIndex)
        } else {
            currentIndex = entries.index(before: entries.endIndex)
        }

        let current = entries[currentIndex]
        let next = entries.indices.contains(currentIndex + 1) ? entries[currentIndex + 1] : nil

        return ProgramMetadata(
            currentEventTitle: current.title,
            currentEventTime: ScheduleTextHelpers.timeRange(start: current.start, end: next?.start, timeZone: displayTimeZone),
            nextEventTitle: next?.title,
            nextEventTime: next.map { ScheduleTextHelpers.timeLabel(for: $0.start, timeZone: displayTimeZone) },
            confidence: "Official weekly schedule"
        )
    }

    private nonisolated static func scheduleEntries(
        from html: String,
        now: Date,
        calendar baseCalendar: Calendar,
        sourceTimeZone: TimeZone
    ) -> [ScheduleEntry] {
        let html = activeTabHTML(from: html) ?? html
        let pattern = #"<tr[^>]*>\s*<td[^>]*>\s*<span[^>]*>(\d{1,2}:\d{2})</span>\s*</td>\s*<td[^>]*>\s*<span[^>]*>([\s\S]*?)</span>\s*</td>\s*</tr>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }

        var calendar = baseCalendar
        calendar.timeZone = sourceTimeZone
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: now)

        return regex.matches(in: html, range: NSRange(html.startIndex..<html.endIndex, in: html)).compactMap { match in
            guard
                let timeRange = Range(match.range(at: 1), in: html),
                let titleRange = Range(match.range(at: 2), in: html)
            else {
                return nil
            }

            let timeParts = html[timeRange].split(separator: ":").compactMap { Int(String($0)) }
            guard timeParts.count == 2 else { return nil }

            var components = dayComponents
            components.hour = timeParts[0]
            components.minute = timeParts[1]
            guard let start = calendar.date(from: components) else { return nil }

            let title = ScheduleTextHelpers.cleanHTML(String(html[titleRange]))
            guard !title.isEmpty else { return nil }
            return ScheduleEntry(start: start, title: title)
        }
        .sorted { $0.start < $1.start }
    }

    private nonisolated static func activeTabHTML(from html: String) -> String? {
        let pattern = #"<div[^>]*class="[^"]*\btab-pane\b[^"]*\bactive\b[^"]*"[^>]*>([\s\S]*?)(?=<div[^>]*class="[^"]*\btab-pane\b|</div>\s*</div>\s*</div>)"#
        return ScheduleTextHelpers.firstMatch(in: html, pattern: pattern)
    }

    private struct ScheduleEntry {
        let start: Date
        let title: String
    }
}
