import Foundation

enum ScheduleTextHelpers {
    nonisolated static func cleanHTML(_ text: String) -> String {
        text
            .replacingOccurrences(of: #"<br\s*/?>"#, with: " ", options: [.regularExpression, .caseInsensitive])
            .replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&#039;", with: "'")
            .replacingOccurrences(of: "&rsquo;", with: "'")
            .replacingOccurrences(of: "&ldquo;", with: "\"")
            .replacingOccurrences(of: "&rdquo;", with: "\"")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    nonisolated static func timeLabel(
        for date: Date,
        timeZone: TimeZone,
        includesTimeZone: Bool = true
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_CA")
        formatter.timeZone = timeZone
        formatter.dateFormat = "h:mm a"
        if includesTimeZone {
            return "\(formatter.string(from: date)) \(timeZone.shortDisplayName)"
        }
        return formatter.string(from: date)
    }

    nonisolated static func timeRange(start: Date, end: Date?, timeZone: TimeZone) -> String {
        guard let end else {
            return timeLabel(for: start, timeZone: timeZone)
        }

        return "\(timeLabel(for: start, timeZone: timeZone, includesTimeZone: false)) - \(timeLabel(for: end, timeZone: timeZone))"
    }

    nonisolated static func firstMatch(in text: String, pattern: String) -> String? {
        guard
            let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
            let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..<text.endIndex, in: text)),
            match.numberOfRanges > 1,
            let range = Range(match.range(at: 1), in: text)
        else {
            return nil
        }

        return String(text[range])
    }
}
