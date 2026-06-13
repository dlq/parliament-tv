import XCTest

@testable import Parliaments

final class LocalizationTests: XCTestCase {
  private let expectedLocaleIDs = [
    "en",
    "fr",
    "pt",
    "da",
    "nl",
    "es",
    "el",
    "lb",
    "it",
    "hi",
    "th",
    "sk",
    "mn",
    "iu",
    "zh-Hans",
    "zh-Hant",
    "mi",
  ]

  func testRepresentativeLocalizationKeysResolveToEnglishValues() {
    XCTAssertEqual(L10n.string("app.title"), "Parliaments")
    XCTAssertEqual(L10n.string("guide.action.show"), "Show Guide")
    XCTAssertEqual(L10n.string("player.signal.noSignal"), "No signal")
  }

  func testRepresentativeKeysCoverStreamLanguages() throws {
    let localizations = try loadLocalizations()

    for key in [
      "app.title",
      "guide.action.show",
      "guide.group.national",
      "player.signal.noSignal",
      "web.action.openOnYouTube",
    ] {
      let availableLocaleIDs = try XCTUnwrap(localizations[key], "Missing key \(key)")
      XCTAssertEqual(
        Set(availableLocaleIDs), Set(expectedLocaleIDs), "\(key) should cover stream languages")
    }
  }

  private func loadLocalizations() throws -> [String: [String]] {
    let catalogURL = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appendingPathComponent("App/Localizable.xcstrings")
    let data = try Data(contentsOf: catalogURL)
    let catalog = try JSONDecoder().decode(StringCatalog.self, from: data)

    return catalog.strings.mapValues { Array($0.localizations.keys) }
  }
}

private struct StringCatalog: Decodable {
  let strings: [String: StringCatalogEntry]
}

private struct StringCatalogEntry: Decodable {
  let localizations: [String: StringLocalization]
}

private struct StringLocalization: Decodable {}
