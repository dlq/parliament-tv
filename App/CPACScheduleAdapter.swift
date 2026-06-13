import Combine
import Foundation

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
      currentIndex =
        nextIndex == entries.startIndex
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
      confidence: .high
    )
  }

  private static func scheduleEntries(from html: String) -> [ScheduleEntry] {
    let pattern =
      #"data-airdate="([^"]+)"[\s\S]*?<button[^>]*class="[^"]*schedule-item-btn[^"]*"[^>]*>([\s\S]*?)</button>"#
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

    return
      "\(timeLabel(for: start, timeZone: timeZone, includesTimeZone: false)) - \(timeLabel(for: end, timeZone: timeZone))"
  }

  private static func timeLabel(for date: Date, timeZone: TimeZone, includesTimeZone: Bool = true)
    -> String
  {
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

  private var lastScheduleRefreshBySource: [String: Date] = [:]
  private let scheduleRefreshInterval: TimeInterval = 15 * 60

  func refresh(channels: [Channel], selectedChannel: Channel) async {
    await refreshHLSFallbacks(channels: channels)
    await refreshSchedule(for: selectedChannel)
  }

  func refreshSelectedChannel(_ channel: Channel) async {
    await refreshHLSFallback(channel: channel)
    await refreshSchedule(for: channel)
  }

  private func refreshHLSFallbacks(channels: [Channel]) async {
    await withTaskGroup(of: (String, ProgramMetadata)?.self) { group in
      for channel in channels where channel.sourceType == .directHLS {
        guard let playbackURL = channel.playbackURL else { continue }

        group.addTask {
          let checkedAt = Date()
          do {
            var request = URLRequest(url: playbackURL)
            request.timeoutInterval = 6
            request.setValue("bytes=0-2047", forHTTPHeaderField: "Range")
            let (data, response) = try await URLSession.shared.data(for: request)
            let status = HLSProgramMetadataAdapter.status(from: data, response: response)
            return (
              channel.id,
              HLSProgramMetadataAdapter.signalMetadata(
                for: channel,
                status: status,
                checkedAt: checkedAt
              )
            )
          } catch {
            return (
              channel.id,
              HLSProgramMetadataAdapter.signalMetadata(
                for: channel,
                status: .unavailable,
                checkedAt: checkedAt
              )
            )
          }
        }
      }

      for await result in group {
        guard let result else { continue }
        metadataByChannelID[result.0] = result.1
      }
    }
  }

  private func refreshHLSFallback(channel: Channel) async {
    guard channel.sourceType == .directHLS, let playbackURL = channel.playbackURL else { return }

    let checkedAt = Date()
    do {
      var request = URLRequest(url: playbackURL)
      request.timeoutInterval = 6
      request.setValue("bytes=0-2047", forHTTPHeaderField: "Range")
      let (data, response) = try await URLSession.shared.data(for: request)
      let status = HLSProgramMetadataAdapter.status(from: data, response: response)
      metadataByChannelID[channel.id] = HLSProgramMetadataAdapter.signalMetadata(
        for: channel,
        status: status,
        checkedAt: checkedAt
      )
    } catch {
      metadataByChannelID[channel.id] = HLSProgramMetadataAdapter.signalMetadata(
        for: channel,
        status: .unavailable,
        checkedAt: checkedAt
      )
    }
  }

  private func refreshSchedule(for channel: Channel) async {
    switch channel.id {
    case CPACScheduleAdapter.channelID:
      await refreshCPACIfNeeded()
    case BrazilScheduleAdapter.channelID:
      await refreshBrazilIfNeeded()
    case NewZealandScheduleAdapter.channelID:
      await refreshNewZealandIfNeeded()
    case let id where id.hasPrefix("quebec-canal"):
      await refreshQuebecIfNeeded()
    case let id where id.hasPrefix("ontario-"):
      await refreshOntarioIfNeeded()
    default:
      break
    }
  }

  private func shouldRefreshSchedule(sourceID: String, now: Date = Date()) -> Bool {
    guard let lastRefresh = lastScheduleRefreshBySource[sourceID] else { return true }
    return now.timeIntervalSince(lastRefresh) >= scheduleRefreshInterval
  }

  private func markScheduleRefreshed(sourceID: String, at date: Date = Date()) {
    lastScheduleRefreshBySource[sourceID] = date
  }

  private func refreshCPACIfNeeded() async {
    let sourceID = "cpac"
    guard shouldRefreshSchedule(sourceID: sourceID) else { return }
    if await refreshCPAC() {
      markScheduleRefreshed(sourceID: sourceID)
    }
  }

  private func refreshQuebecIfNeeded() async {
    let sourceID = "quebec"
    guard shouldRefreshSchedule(sourceID: sourceID) else { return }
    if await refreshQuebec() {
      markScheduleRefreshed(sourceID: sourceID)
    }
  }

  private func refreshBrazilIfNeeded() async {
    let sourceID = "brazil"
    guard shouldRefreshSchedule(sourceID: sourceID) else { return }
    do {
      let (data, _) = try await URLSession.shared.data(for: BrazilScheduleAdapter.request())
      guard let html = String(data: data, encoding: .utf8) else { return }
      guard let metadata = BrazilScheduleAdapter.programMetadata(from: html) else { return }
      metadataByChannelID[BrazilScheduleAdapter.channelID] = metadata
      markScheduleRefreshed(sourceID: sourceID)
    } catch {
      // Keep the HLS signal-state fallback if the schedule page is unavailable.
    }
  }

  private func refreshNewZealandIfNeeded() async {
    let sourceID = "new-zealand"
    guard shouldRefreshSchedule(sourceID: sourceID) else { return }
    do {
      let (data, _) = try await URLSession.shared.data(for: NewZealandScheduleAdapter.request())
      guard let html = String(data: data, encoding: .utf8) else { return }
      guard let metadata = NewZealandScheduleAdapter.programMetadata(from: html) else { return }
      metadataByChannelID[NewZealandScheduleAdapter.channelID] = metadata
      markScheduleRefreshed(sourceID: sourceID)
    } catch {
      // Keep the HLS signal-state fallback if the calendar page is unavailable.
    }
  }

  private func refreshOntarioIfNeeded() async {
    let sourceID = "ontario"
    guard shouldRefreshSchedule(sourceID: sourceID) else { return }
    do {
      let (data, _) = try await URLSession.shared.data(for: OntarioCalendarAdapter.request())
      guard let html = String(data: data, encoding: .utf8) else { return }
      let metadata = OntarioCalendarAdapter.programMetadataByChannelID(from: html)
      guard !metadata.isEmpty else { return }
      metadataByChannelID.merge(metadata) { _, new in new }
      markScheduleRefreshed(sourceID: sourceID)
    } catch {
      // Keep the HLS signal-state fallback if the calendar page is unavailable.
    }
  }

  private func refreshCPAC() async -> Bool {
    do {
      let (data, _) = try await URLSession.shared.data(from: CPACScheduleAdapter.scheduleURL)
      guard let html = String(data: data, encoding: .utf8) else { return false }
      guard let metadata = CPACScheduleAdapter.programMetadata(from: html) else { return false }
      metadataByChannelID[CPACScheduleAdapter.channelID] = metadata
      return true
    } catch {
      // Keep the static catalogue metadata if the schedule page is unavailable.
      return false
    }
  }

  private func refreshQuebec() async -> Bool {
    do {
      async let liveResult = URLSession.shared.data(
        for: QuebecWebdiffusionAdapter.request(for: QuebecWebdiffusionAdapter.liveURL))
      async let upcomingResult = URLSession.shared
        .data(for: QuebecWebdiffusionAdapter.request(for: QuebecWebdiffusionAdapter.upcomingURL))
      let (live, upcoming) = try await (liveResult, upcomingResult)
      let metadata = try QuebecWebdiffusionAdapter.programMetadataByChannelID(
        liveData: live.0,
        upcomingData: upcoming.0
      )
      guard !metadata.isEmpty else { return false }
      metadataByChannelID.merge(metadata) { _, new in new }
      return true
    } catch {
      // Keep signal-state metadata if the Quebec schedule API is unavailable.
      return false
    }
  }
}
