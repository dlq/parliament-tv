import Foundation

enum HLSSignalStatus {
    case available
    case unavailable
}

enum HLSProgramMetadataAdapter {
    nonisolated static func signalMetadata(
        for channel: Channel,
        status: HLSSignalStatus,
        checkedAt: Date = Date(),
        displayTimeZone: TimeZone = .current
    ) -> ProgramMetadata {
        switch status {
        case .available:
            ProgramMetadata(
                currentEventTitle: "Signal available, program unknown",
                currentEventTime: "Checked \(timeLabel(for: checkedAt, timeZone: displayTimeZone))",
                nextEventTitle: nil,
                nextEventTime: nil,
                confidence: "Signal"
            )
        case .unavailable:
            ProgramMetadata(
                currentEventTitle: "No signal",
                currentEventTime: "Checked \(timeLabel(for: checkedAt, timeZone: displayTimeZone))",
                nextEventTitle: nil,
                nextEventTime: nil,
                confidence: "Signal"
            )
        }
    }

    nonisolated static func status(from data: Data, response: URLResponse) -> HLSSignalStatus {
        guard
            let httpResponse = response as? HTTPURLResponse,
            (200..<300).contains(httpResponse.statusCode)
        else {
            return .unavailable
        }

        if data.isEmpty {
            return .available
        }

        guard let body = String(data: data, encoding: .utf8) else {
            return .available
        }

        return body.contains("#EXTM3U") ? .available : .unavailable
    }

    private nonisolated static func timeLabel(for date: Date, timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_CA")
        formatter.timeZone = timeZone
        formatter.dateFormat = "h:mm a"
        return "\(formatter.string(from: date)) \(timeZone.shortDisplayName)"
    }
}

extension TimeZone {
    nonisolated var shortDisplayName: String {
        if identifier == "America/Toronto" || identifier == "America/New_York" {
            return "ET"
        }

        return abbreviation() ?? identifier
    }
}
