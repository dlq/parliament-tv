import Foundation
import Combine

enum CPACScheduleAdapter {
    static let channelID = "cpac-ca"
    static let scheduleURL = URL(string: "https://www.cpac.ca/schedule/")!

    static func programMetadata(
        from html: String,
        now: Date = Date(),
        displayTimeZone: TimeZone = .current
    ) -> ProgramMetadata? {
        let entries = scheduleEntries(from: html)
        guard !entries.isEmpty else { return nil }

        let nextIndex = entries.firstIndex { $0.start > now }
        let currentIndex: Int
        if let nextIndex {
            currentIndex = nextIndex == entries.startIndex
                ? entries.startIndex
                : entries.index(before: nextIndex)
        } else {
            currentIndex = entries.index(before: entries.endIndex)
        }

        let current = entries[currentIndex]
        let next = entries.indices.contains(currentIndex + 1) ? entries[currentIndex + 1] : nil
        let currentEnd = next?.start

        return ProgramMetadata(
            currentEventTitle: current.title,
            currentEventTime: timeRange(start: current.start, end: currentEnd, timeZone: displayTimeZone),
            nextEventTitle: next?.title,
            nextEventTime: next.map { timeLabel(for: $0.start, timeZone: displayTimeZone) },
            confidence: "High"
        )
    }

    private static func scheduleEntries(from html: String) -> [ScheduleEntry] {
        let pattern = #"data-airdate="([^"]+)"[\s\S]*?<button[^>]*class="[^"]*schedule-item-btn[^"]*"[^>]*>([\s\S]*?)</button>"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let fullRange = NSRange(html.startIndex..<html.endIndex, in: html)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return regex.matches(in: html, range: fullRange).compactMap { match in
            guard
                let dateRange = Range(match.range(at: 1), in: html),
                let titleRange = Range(match.range(at: 2), in: html),
                let start = formatter.date(from: String(html[dateRange]))
            else {
                return nil
            }

            let title = decodeHTMLText(String(html[titleRange]))
            guard !title.isEmpty else { return nil }
            return ScheduleEntry(start: start, title: title)
        }
        .sorted { $0.start < $1.start }
    }

    private static func timeRange(start: Date, end: Date?, timeZone: TimeZone) -> String {
        guard let end else {
            return timeLabel(for: start, timeZone: timeZone)
        }

        return "\(timeLabel(for: start, timeZone: timeZone, includesTimeZone: false)) - \(timeLabel(for: end, timeZone: timeZone))"
    }

    private static func timeLabel(for date: Date, timeZone: TimeZone, includesTimeZone: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_CA")
        formatter.timeZone = timeZone
        formatter.dateFormat = "h:mm a"
        if includesTimeZone {
            return "\(formatter.string(from: date)) \(timeZone.shortDisplayName)"
        }
        return formatter.string(from: date)
    }

    private static func decodeHTMLText(_ text: String) -> String {
        text
            .replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private struct ScheduleEntry {
        let start: Date
        let title: String
    }
}

@MainActor
final class ProgramMetadataStore: ObservableObject {
    @Published private(set) var metadataByChannelID: [String: ProgramMetadata] = [:]

    func refreshCPAC() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: CPACScheduleAdapter.scheduleURL)
            guard let html = String(data: data, encoding: .utf8) else { return }
            if let metadata = CPACScheduleAdapter.programMetadata(from: html) {
                metadataByChannelID[CPACScheduleAdapter.channelID] = metadata
            }
        } catch {
            // Keep the static catalogue metadata if the schedule page is unavailable.
        }
    }
}

private extension TimeZone {
    var shortDisplayName: String {
        if identifier == "America/Toronto" || identifier == "America/New_York" {
            return "ET"
        }

        return abbreviation() ?? identifier
    }
}
