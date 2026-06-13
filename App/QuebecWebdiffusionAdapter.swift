import Foundation

enum QuebecWebdiffusionAdapter {
  static let liveURL = URL(
    string: "https://www.assnat.qc.ca/Gabarits/RefonteVA_Accueil.aspx/ObtenirListeEnDirect")!
  static let upcomingURL = URL(
    string: "https://www.assnat.qc.ca/Gabarits/RefonteVA_Accueil.aspx/ObtenirListeAVenir")!

  nonisolated static func programMetadataByChannelID(
    liveData: Data,
    upcomingData: Data,
    checkedAt: Date = Date(),
    displayTimeZone: TimeZone = .current
  ) throws -> [String: ProgramMetadata] {
    let liveItems = try JSONDecoder().decode(Response<LiveItem>.self, from: liveData).d
    let upcomingItems = try JSONDecoder().decode(Response<UpcomingItem>.self, from: upcomingData).d
    let next = upcomingItems.first.map(UpcomingProgram.init)
    var metadataByChannelID = sourceLevelUpcomingMetadata(
      next: next,
      checkedAt: checkedAt,
      displayTimeZone: displayTimeZone
    )

    for item in liveItems {
      guard
        item.diffusionDisponible != false,
        let channelID = item.channelID
      else {
        continue
      }

      metadataByChannelID[channelID] = ProgramMetadata(
        currentEventTitle: cleanText(item.titre),
        currentEventTime: "Live now",
        nextEventTitle: next?.title,
        nextEventTime: next?.time,
        confidence: .officialLiveList
      )
    }

    return metadataByChannelID
  }

  nonisolated static func request(for url: URL) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.timeoutInterval = 8
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
    request.httpBody = #"{"codeLangue":"fr"}"#.data(using: .utf8)
    return request
  }

  private nonisolated static func sourceLevelUpcomingMetadata(
    next: UpcomingProgram?,
    checkedAt: Date,
    displayTimeZone: TimeZone
  ) -> [String: ProgramMetadata] {
    let metadata = ProgramMetadata(
      currentEventTitle: "No live webcast listed",
      currentEventTime: "Checked \(timeLabel(for: checkedAt, timeZone: displayTimeZone))",
      nextEventTitle: next == nil ? nil : "Next listed Quebec webcast",
      nextEventTime: next?.time,
      confidence: next == nil ? .officialLiveList : .officialSourceSchedule
    )

    return Dictionary(
      uniqueKeysWithValues: (1...14).map { channelNumber in
        (String(format: "quebec-canal%02d", channelNumber), metadata)
      }
    )
  }

  private nonisolated static func cleanText(_ text: String) -> String {
    text
      .replacingOccurrences(
        of: #"<br\s*/?>"#, with: " - ", options: [.regularExpression, .caseInsensitive]
      )
      .cleanedHTML()
  }

  private nonisolated static func cleanTimeText(_ text: String) -> String {
    text
      .replacingOccurrences(
        of: #"<br\s*/?>"#, with: " ", options: [.regularExpression, .caseInsensitive]
      )
      .cleanedHTML()
  }

  private nonisolated static func timeLabel(for date: Date, timeZone: TimeZone) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_CA")
    formatter.timeZone = timeZone
    formatter.dateFormat = "h:mm a"
    return "\(formatter.string(from: date)) \(timeZone.shortDisplayName)"
  }

  private nonisolated struct Response<Item: Decodable>: Decodable {
    let d: [Item]
  }

  private nonisolated struct LiveItem: Decodable {
    let titre: String
    let urlSignal: String?
    let diffusionDisponible: Bool?

    nonisolated var channelID: String? {
      guard
        let urlSignal,
        let match = urlSignal.firstMatch(of: /canal(\d{2})/)
      else {
        return nil
      }

      return "quebec-canal\(match.1)"
    }

    enum CodingKeys: String, CodingKey {
      case titre = "Titre"
      case urlSignal = "UrlSignal"
      case diffusionDisponible = "DiffusionDisponible"
    }
  }

  private nonisolated struct UpcomingItem: Decodable {
    let titre: String
    let date: String
    let heure: String

    enum CodingKeys: String, CodingKey {
      case titre = "Titre"
      case date = "Date"
      case heure = "Heure"
    }
  }

  private nonisolated struct UpcomingProgram {
    let title: String
    let time: String

    nonisolated init(item: UpcomingItem) {
      title = cleanText(item.titre)
      time = "\(cleanTimeText(item.date)), \(cleanTimeText(item.heure))"
    }
  }
}

extension String {
  fileprivate nonisolated func cleanedHTML() -> String {
    replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
      .replacingOccurrences(of: "&nbsp;", with: " ")
      .replacingOccurrences(of: "&amp;", with: "&")
      .replacingOccurrences(of: "&quot;", with: "\"")
      .replacingOccurrences(of: "&#39;", with: "'")
      .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
      .replacingOccurrences(of: " -  - ", with: " - ")
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
