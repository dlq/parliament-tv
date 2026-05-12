//
//  ChannelCatalog.swift
//  Parliaments
//
//  Created by Darcy Quesnel on 2026-05-12.
//

import Foundation

enum ChannelCatalog {
    static let channels: [Channel] = [
        cpac,
        newZealand,
        brazil,
        denmark,
        netherlands,
        spain
    ] + quebecChannels + ontarioChannels

    private static let cpac = directChannel(
        id: "cpac-ca",
        name: "CPAC Canada",
        shortName: "CPAC",
        jurisdictionLevel: .national,
        countryOrRegion: "Canada",
        legislature: "Parliament of Canada",
        language: "English / French",
        playbackURL: "https://cpac-ca-live.cdn.vustreams.com/groupa/live/f9809cea-1e07-47cd-a94d-2ddd3e1351db/live.isml/.m3u8",
        officialURL: "https://www.cpac.ca/en/",
        attributionText: "Official CPAC stream endpoint discovered from CPAC metadata.",
        legalReviewStatus: "Personal use only until reviewed",
        availability: .alwaysOn,
        metadataLevel: "Daily schedule target",
        currentEventTitle: "Live public affairs feed",
        currentEventTime: "Schedule integration pending",
        nextEventTitle: "Daily schedule metadata",
        nextEventTime: "Planned",
        confidence: "Medium"
    )

    private static let newZealand = directChannel(
        id: "new-zealand-parliament",
        name: "New Zealand Parliament TV",
        shortName: "NZ",
        jurisdictionLevel: .national,
        countryOrRegion: "New Zealand",
        legislature: "New Zealand Parliament",
        language: "English",
        playbackURL: "https://ptvlive.kordia.net.nz/out/v1/daf20b9a9ec5449dadd734e50ce52b74/index.m3u8",
        officialURL: "https://www.parliament.nz/en/watch-parliament/",
        attributionText: "Official Parliament TV HLS candidate; pair with sitting calendar.",
        legalReviewStatus: "Explicit reuse allowed with conditions",
        availability: .sittingOnly,
        metadataLevel: "Current and next event target",
        currentEventTitle: "Parliament TV",
        currentEventTime: "Live during House sittings",
        nextEventTitle: "Sitting calendar integration",
        nextEventTime: "Planned",
        confidence: "High"
    )

    private static let brazil = directChannel(
        id: "brazil-tv-camara",
        name: "Brazil TV Camara",
        shortName: "BR",
        jurisdictionLevel: .national,
        countryOrRegion: "Brazil",
        legislature: "Camara dos Deputados",
        language: "Portuguese",
        playbackURL: "https://stream3.camara.gov.br/tv1/manifest.m3u8",
        officialURL: "https://www.camara.leg.br/tv/",
        attributionText: "Official TV Camara stream; source attribution and watermark integrity matter.",
        legalReviewStatus: "Explicit reuse allowed with conditions",
        availability: .alwaysOn,
        metadataLevel: "Daily schedule target",
        currentEventTitle: "TV Camara live",
        currentEventTime: "Official live channel",
        nextEventTitle: "Official schedule integration",
        nextEventTime: "Planned",
        confidence: "High"
    )

    private static let denmark = directChannel(
        id: "denmark-folketinget",
        name: "Denmark Folketinget",
        shortName: "DK",
        jurisdictionLevel: .national,
        countryOrRegion: "Denmark",
        legislature: "Folketinget",
        language: "Danish",
        playbackURL: "https://cdnapi.kaltura.com/p/2158211/sp/327418300/playManifest/entryId/1_24gfa7qq/protocol/https/format/applehttp/a.m3u8",
        officialURL: "https://www.ft.dk/",
        attributionText: "Official player HLS candidate; terms still need deeper review.",
        legalReviewStatus: "Personal use only until reviewed",
        availability: .eventBased,
        metadataLevel: "Schedule target",
        currentEventTitle: "Folketinget live stream",
        currentEventTime: "Active around scheduled proceedings",
        nextEventTitle: "Official schedule integration",
        nextEventTime: "Planned",
        confidence: "Medium"
    )

    private static let netherlands = directChannel(
        id: "netherlands-tweede-kamer",
        name: "Netherlands Tweede Kamer",
        shortName: "NL",
        jurisdictionLevel: .national,
        countryOrRegion: "Netherlands",
        legislature: "Tweede Kamer",
        language: "Dutch",
        playbackURL: "https://livestreaming.b67buv2.tweedekamer.nl/live/plenairezaal/index.m3u8?hd=1&keyframes=1&subtitles=live",
        officialURL: "https://www.tweedekamer.nl/debat_en_vergadering/livedebat",
        attributionText: "Official Tweede Kamer live room stream.",
        legalReviewStatus: "Personal use only until reviewed",
        availability: .eventBased,
        metadataLevel: "Schedule target",
        currentEventTitle: "Plenary hall live stream",
        currentEventTime: "Active around scheduled proceedings",
        nextEventTitle: "Official schedule integration",
        nextEventTime: "Planned",
        confidence: "Medium"
    )

    private static let spain = directChannel(
        id: "spain-canal-parlamento",
        name: "Spain Canal Parlamento",
        shortName: "ES",
        jurisdictionLevel: .national,
        countryOrRegion: "Spain",
        legislature: "Congreso de los Diputados",
        language: "Spanish",
        playbackURL: "https://congresodirecto.akamaized.net/hls/live/2037973/canalparlamento/master.m3u8",
        officialURL: "https://www.congreso.es/",
        attributionText: "Official Congreso/Canal Parlamento HLS candidate.",
        legalReviewStatus: "Personal use only until reviewed",
        availability: .eventBased,
        metadataLevel: "Schedule target",
        currentEventTitle: "Canal Parlamento",
        currentEventTime: "Active around scheduled proceedings",
        nextEventTitle: "Official schedule integration",
        nextEventTime: "Planned",
        confidence: "Medium"
    )

    private static let quebecChannels: [Channel] = (1...14).map { channelNumber in
        let channel = String(format: "%02d", channelNumber)
        return directChannel(
            id: "quebec-canal\(channel)",
            name: "Quebec National Assembly - Canal \(channel)",
            shortName: "QC \(channel)",
            jurisdictionLevel: .subnational,
            countryOrRegion: "Quebec",
            legislature: "Assemblee nationale du Quebec",
            language: "French",
            playbackURL: "https://cdn3.wowza.com/5/SVEySlNEQ0FOWXlS/diffusion/canal\(channel)/playlist.m3u8",
            officialURL: "https://www.assnat.qc.ca/fr/video-audio/en-direct-webdiffusion.html",
            attributionText: "Official-vendor HLS from the Assembly live-list flow.",
            legalReviewStatus: "Noncommercial/personal use until reviewed",
            availability: .eventBased,
            metadataLevel: "Current event target",
            currentEventTitle: channelNumber == 5 || channelNumber == 6 || channelNumber == 14 ? "Recently active Assembly webcast channel" : "Assembly webcast channel",
            currentEventTime: "Active when proceedings are scheduled",
            nextEventTitle: "Live-list API metadata",
            nextEventTime: "Planned",
            confidence: channelNumber == 5 || channelNumber == 6 || channelNumber == 14 ? "Medium" : "Low"
        )
    }

    private static let ontarioChannels: [Channel] = [
        ("house-en", "Ontario Legislative Assembly - House EN", "ON House", "House proceedings", "English"),
        ("house-en-cc", "Ontario Legislative Assembly - House EN CC", "ON CC", "House proceedings with captions", "English"),
        ("rm151-en", "Ontario Legislative Assembly - Room 151", "ON 151", "Room 151 proceedings", "English"),
        ("committee_1-en", "Ontario Legislative Assembly - Committee 1", "ON C1", "Committee room 1", "English"),
        ("committee_2-en", "Ontario Legislative Assembly - Committee 2", "ON C2", "Committee room 2", "English"),
        ("media-en", "Ontario Legislative Assembly - Media Studio", "ON Media", "Media studio feed", "English")
    ].map { streamName, name, shortName, currentTitle, language in
        directChannel(
            id: "ontario-\(streamName.replacingOccurrences(of: "_", with: "-"))",
            name: name,
            shortName: shortName,
            jurisdictionLevel: .subnational,
            countryOrRegion: "Ontario",
            legislature: "Legislative Assembly of Ontario",
            language: language,
            playbackURL: "https://origin-http-delivery.isilive.ca/live/_definst_/ontla/\(streamName)/playlist.m3u8",
            officialURL: "https://www.ola.org/en/legislative-business/video",
            attributionText: "Official-vendor HLS for the Legislative Assembly video service.",
            legalReviewStatus: "Noncommercial/personal use until reviewed",
            availability: streamName.contains("house") ? .sittingOnly : .eventBased,
            metadataLevel: "Current and next event target",
            currentEventTitle: currentTitle,
            currentEventTime: "Live during sittings or scheduled events",
            nextEventTitle: "OLA calendar integration",
            nextEventTime: "Planned",
            confidence: "Medium"
        )
    }

    static let sourcesRequiringExternalPlayer: [Channel] = [
        linkOutChannel(
            id: "uk-parliament",
            name: "UK Parliament Live",
            shortName: "UK",
            jurisdictionLevel: .national,
            countryOrRegion: "United Kingdom",
            legislature: "UK Parliament",
            language: "English",
            sourceType: .officialPage,
            officialURL: "https://www.parliamentlive.tv/",
            attributionText: "Official Parliamentlive.tv player; direct HLS not validated.",
            legalReviewStatus: "Link only",
            technicalStatus: .linkOnly,
            metadataLevel: "Daily schedule target",
            currentEventTitle: "Official player required",
            currentEventTime: "Open source page for live and archived events",
            confidence: "High"
        ),
        linkOutChannel(
            id: "european-parliament",
            name: "European Parliament",
            shortName: "EP",
            jurisdictionLevel: .supranational,
            countryOrRegion: "European Union",
            legislature: "European Parliament",
            language: "Multilingual",
            sourceType: .officialPage,
            officialURL: "https://multimedia.europarl.europa.eu/en/webstreaming",
            attributionText: "Official Multimedia Centre source; native stream path pending.",
            legalReviewStatus: "Link only",
            technicalStatus: .needsReview,
            metadataLevel: "Daily schedule target",
            currentEventTitle: "Official webstreaming portal",
            currentEventTime: "Open source page for active streams",
            confidence: "High"
        ),
        linkOutChannel(
            id: "australia-parliament-youtube",
            name: "Australia Parliament Live",
            shortName: "AU",
            jurisdictionLevel: .national,
            countryOrRegion: "Australia",
            legislature: "Parliament of Australia",
            language: "English",
            sourceType: .youtube,
            officialURL: "https://www.youtube.com/@AUSParliamentLive",
            attributionText: "Official YouTube channel; in-app support is intentionally second class.",
            legalReviewStatus: "Embed only",
            technicalStatus: .linkOnly,
            metadataLevel: "YouTube current event target",
            currentEventTitle: "Official YouTube live source",
            currentEventTime: "Open channel for active streams",
            confidence: "Medium"
        )
    ]

    private static func directChannel(
        id: String,
        name: String,
        shortName: String,
        jurisdictionLevel: JurisdictionLevel,
        countryOrRegion: String,
        legislature: String,
        language: String,
        playbackURL: String,
        officialURL: String,
        attributionText: String,
        legalReviewStatus: String,
        availability: Availability,
        metadataLevel: String,
        currentEventTitle: String,
        currentEventTime: String,
        nextEventTitle: String?,
        nextEventTime: String?,
        confidence: String
    ) -> Channel {
        Channel(
            id: id,
            name: name,
            shortName: shortName,
            jurisdictionLevel: jurisdictionLevel,
            countryOrRegion: countryOrRegion,
            legislature: legislature,
            language: language,
            sourceType: .directHLS,
            displayMode: .nativePlayer,
            playbackURL: URL(string: playbackURL),
            officialURL: URL(string: officialURL)!,
            attributionText: attributionText,
            legalReviewStatus: legalReviewStatus,
            technicalStatus: .validated,
            availability: availability,
            metadataLevel: metadataLevel,
            program: ProgramMetadata(
                currentEventTitle: currentEventTitle,
                currentEventTime: currentEventTime,
                nextEventTitle: nextEventTitle,
                nextEventTime: nextEventTime,
                confidence: confidence
            )
        )
    }

    private static func linkOutChannel(
        id: String,
        name: String,
        shortName: String,
        jurisdictionLevel: JurisdictionLevel,
        countryOrRegion: String,
        legislature: String,
        language: String,
        sourceType: SourceType,
        officialURL: String,
        attributionText: String,
        legalReviewStatus: String,
        technicalStatus: TechnicalStatus,
        metadataLevel: String,
        currentEventTitle: String,
        currentEventTime: String,
        confidence: String
    ) -> Channel {
        Channel(
            id: id,
            name: name,
            shortName: shortName,
            jurisdictionLevel: jurisdictionLevel,
            countryOrRegion: countryOrRegion,
            legislature: legislature,
            language: language,
            sourceType: sourceType,
            displayMode: .linkOut,
            playbackURL: nil,
            officialURL: URL(string: officialURL)!,
            attributionText: attributionText,
            legalReviewStatus: legalReviewStatus,
            technicalStatus: technicalStatus,
            availability: .eventBased,
            metadataLevel: metadataLevel,
            program: ProgramMetadata(
                currentEventTitle: currentEventTitle,
                currentEventTime: currentEventTime,
                nextEventTitle: "Schedule metadata",
                nextEventTime: "Planned",
                confidence: confidence
            )
        )
    }
}
