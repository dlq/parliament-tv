import XCTest
@testable import Parliaments

final class QuebecWebdiffusionAdapterTests: XCTestCase {
    func testLabelsUpcomingMetadataAsSourceLevelWhenNoLiveEventIsListed() throws {
        let liveJSON = #"{"d":[]}"#.data(using: .utf8)!
        let upcomingJSON = """
        {
          "d": [
            {
              "Titre": "Commission de l'aménagement du territoire<br/>Étude détaillée du projet de loi n° 4",
              "Date": "8 juin 2026",
              "Heure": "Début vers  12&nbsp;h&nbsp;30<br/>jusqu'à 18&nbsp;h",
              "Message": ""
            }
          ]
        }
        """.data(using: .utf8)!

        let metadata = try QuebecWebdiffusionAdapter.programMetadataByChannelID(
            liveData: liveJSON,
            upcomingData: upcomingJSON,
            checkedAt: ISO8601DateFormatter().date(from: "2026-06-07T21:31:00Z")!,
            displayTimeZone: TimeZone(identifier: "America/Toronto")!
        )

        let canal02 = try XCTUnwrap(metadata["quebec-canal02"])
        XCTAssertEqual(canal02.currentEventTitle, "No live webcast listed")
        XCTAssertEqual(canal02.currentEventTime, "Checked 5:31 PM ET")
        XCTAssertEqual(canal02.nextEventTitle, "Next listed Quebec webcast")
        XCTAssertEqual(canal02.nextEventTime, "8 juin 2026, Début vers 12 h 30 jusqu'à 18 h")
        XCTAssertEqual(canal02.confidence, "Official source schedule")
    }

    func testMapsLiveMetadataToChannelFromSignalURL() throws {
        let liveJSON = """
        {
          "d": [
            {
              "Titre": "Séance de l'Assemblée<br/>Période de questions",
              "UrlSignal": "https://cdn3.wowza.com/5/SVEySlNEQ0FOWXlS/diffusion/canal05/playlist.m3u8",
              "NomCanal": "Canal 5",
              "DiffusionDisponible": true
            }
          ]
        }
        """.data(using: .utf8)!
        let upcomingJSON = #"{"d":[]}"#.data(using: .utf8)!

        let metadata = try QuebecWebdiffusionAdapter.programMetadataByChannelID(
            liveData: liveJSON,
            upcomingData: upcomingJSON,
            checkedAt: ISO8601DateFormatter().date(from: "2026-06-07T21:31:00Z")!,
            displayTimeZone: TimeZone(identifier: "America/Toronto")!
        )

        let canal05 = try XCTUnwrap(metadata["quebec-canal05"])
        XCTAssertEqual(canal05.currentEventTitle, "Séance de l'Assemblée - Période de questions")
        XCTAssertEqual(canal05.currentEventTime, "Live now")
        XCTAssertNil(canal05.nextEventTitle)
        XCTAssertNil(canal05.nextEventTime)
        XCTAssertEqual(canal05.confidence, "Official live list")
    }
}
