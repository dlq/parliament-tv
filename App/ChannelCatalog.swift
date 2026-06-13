//
//  ChannelCatalog.swift
//  Parliaments
//
//  Created by Darcy Quesnel on 2026-05-12.
//

import Foundation

enum ChannelCatalog {
  static let channels: [Channel] = {
    var channels = [
      cpac,
      newZealand,
      brazil,
      denmark,
      netherlands,
      spain,
      france,
      portugal,
      greece,
      luxembourg,
      italySenate,
      indiaSansad1,
      indiaSansad2,
      thailand,
      slovakia,
    ]

    #if os(macOS)
      channels.append(mongolia)
    #endif

    return channels + quebecChannels + ontarioChannels + [nunavut]
  }()

  private static let cpac = directChannel(
    id: "cpac-ca",
    name: "CPAC Canada",
    shortName: "CPAC",
    jurisdictionLevel: .national,
    countryOrRegion: "Canada",
    legislature: "Parliament of Canada",
    language: "English / French",
    playbackURL:
      "https://cpac-ca-live.cdn.vustreams.com/groupa/live/f9809cea-1e07-47cd-a94d-2ddd3e1351db/live.isml/.m3u8",
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
    attributionText:
      "Official TV Camara stream; source attribution and watermark integrity matter.",
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
    playbackURL:
      "https://cdnapi.kaltura.com/p/2158211/sp/327418300/playManifest/entryId/1_24gfa7qq/protocol/https/format/applehttp/a.m3u8",
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
    playbackURL:
      "https://livestreaming.b67buv2.tweedekamer.nl/live/plenairezaal/index.m3u8?hd=1&keyframes=1&subtitles=live",
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
    playbackURL:
      "https://congresodirecto.akamaized.net/hls/live/2037973/canalparlamento/master.m3u8",
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

  private static let france = directChannel(
    id: "france-national-assembly",
    name: "France National Assembly",
    shortName: "FR",
    jurisdictionLevel: .national,
    countryOrRegion: "France",
    legislature: "Assemblee nationale",
    language: "French",
    playbackURL: "https://assemblee-nationale.akamaized.net/live/live36/stream36.m3u8",
    officialURL: "https://videos.assemblee-nationale.fr/direct.php",
    attributionText: "Official National Assembly video portal HLS stream.",
    legalReviewStatus: "Personal use only until reviewed",
    availability: .eventBased,
    metadataLevel: "Schedule target",
    currentEventTitle: "National Assembly live stream",
    currentEventTime: "Active around public sittings and meetings",
    nextEventTitle: "Official video portal schedule integration",
    nextEventTime: "Planned",
    confidence: "Medium"
  )

  private static let portugal = directChannel(
    id: "portugal-artv",
    name: "Portugal ARTV Canal Parlamento",
    shortName: "PT",
    jurisdictionLevel: .national,
    countryOrRegion: "Portugal",
    legislature: "Assembleia da Republica",
    language: "Portuguese",
    playbackURL:
      "https://playout172.livextend.cloud/liveiframe/_definst_/liveartvabr/playlist.m3u8",
    officialURL: "https://www.parlamento.pt/",
    attributionText: "Canal Parlamento HLS candidate; pair with official agenda metadata.",
    legalReviewStatus: "Personal use only until reviewed",
    availability: .eventBased,
    metadataLevel: "Agenda target",
    currentEventTitle: "ARTV Canal Parlamento",
    currentEventTime: "Active around scheduled proceedings",
    nextEventTitle: "Official agenda integration",
    nextEventTime: "Planned",
    confidence: "Medium"
  )

  private static let greece = directChannel(
    id: "greece-hellenic-parliament-tv",
    name: "Greece Hellenic Parliament TV",
    shortName: "GR",
    jurisdictionLevel: .national,
    countryOrRegion: "Greece",
    legislature: "Hellenic Parliament",
    language: "Greek",
    playbackURL: "https://ert-ucdn.broadpeak-aas.com/bpk-tv/VOULITV/default/index.m3u8",
    officialURL: "https://www.hellenicparliament.gr/",
    attributionText:
      "Hellenic Parliament TV HLS candidate distributed through public broadcaster infrastructure.",
    legalReviewStatus: "Personal use only until reviewed",
    availability: .alwaysOn,
    metadataLevel: "Schedule target",
    currentEventTitle: "Hellenic Parliament TV",
    currentEventTime: "Official parliamentary TV feed",
    nextEventTitle: "Official schedule integration",
    nextEventTime: "Planned",
    confidence: "Medium"
  )

  private static let luxembourg = directChannel(
    id: "luxembourg-chamber-tv",
    name: "Luxembourg Chamber TV",
    shortName: "LU",
    jurisdictionLevel: .national,
    countryOrRegion: "Luxembourg",
    legislature: "Chambre des Deputes",
    language: "French / Luxembourgish",
    playbackURL: "https://media02.webtvlive.eu/chd-edge/smil:chamber_tv_hd.smil/playlist.m3u8",
    officialURL: "https://www.chd.lu/",
    attributionText: "Chamber TV HLS candidate from official player infrastructure.",
    legalReviewStatus: "Personal use only until reviewed",
    availability: .eventBased,
    metadataLevel: "Schedule target",
    currentEventTitle: "Chamber TV",
    currentEventTime: "Active around scheduled proceedings",
    nextEventTitle: "Official schedule integration",
    nextEventTime: "Planned",
    confidence: "Medium"
  )

  private static let italySenate = directChannel(
    id: "italy-senate",
    name: "Italy Senate",
    shortName: "IT",
    jurisdictionLevel: .national,
    countryOrRegion: "Italy",
    legislature: "Senato della Repubblica",
    language: "Italian",
    playbackURL: "https://senato-live.morescreens.com/SENATO_1_001/playlist.m3u8",
    officialURL: "https://webtv.senato.it/",
    attributionText: "Senate live HLS candidate; official source and terms need deeper review.",
    legalReviewStatus: "Personal use only until reviewed",
    availability: .eventBased,
    metadataLevel: "Schedule target",
    currentEventTitle: "Senate live stream",
    currentEventTime: "Active around scheduled proceedings",
    nextEventTitle: "Official schedule integration",
    nextEventTime: "Planned",
    confidence: "Medium"
  )

  private static let indiaSansad1 = directChannel(
    id: "india-sansad-tv-1",
    name: "India Sansad TV 1",
    shortName: "IN 1",
    jurisdictionLevel: .national,
    countryOrRegion: "India",
    legislature: "Parliament of India",
    language: "Hindi / English",
    playbackURL:
      "https://d2lk5u59tns74c.cloudfront.net/out/v1/fff8f20221d5456e8922e689d71dedc3/index.m3u8",
    officialURL: "https://sansadtv.nic.in/",
    attributionText: "Sansad TV HLS candidate; terms and reliability require review.",
    legalReviewStatus: "Personal use only until reviewed",
    availability: .alwaysOn,
    metadataLevel: "Schedule target",
    currentEventTitle: "Sansad TV feed 1",
    currentEventTime: "Official parliamentary television feed",
    nextEventTitle: "Official schedule integration",
    nextEventTime: "Planned",
    confidence: "Medium"
  )

  private static let indiaSansad2 = directChannel(
    id: "india-sansad-tv-2",
    name: "India Sansad TV 2",
    shortName: "IN 2",
    jurisdictionLevel: .national,
    countryOrRegion: "India",
    legislature: "Parliament of India",
    language: "Hindi / English",
    playbackURL:
      "https://d2lk5u59tns74c.cloudfront.net/out/v1/e4182054dce340da9e0ff38b6b3658a4/index.m3u8",
    officialURL: "https://sansadtv.nic.in/",
    attributionText: "Sansad TV HLS candidate; terms and reliability require review.",
    legalReviewStatus: "Personal use only until reviewed",
    availability: .alwaysOn,
    metadataLevel: "Schedule target",
    currentEventTitle: "Sansad TV feed 2",
    currentEventTime: "Official parliamentary television feed",
    nextEventTitle: "Official schedule integration",
    nextEventTime: "Planned",
    confidence: "Medium"
  )

  private static let thailand = directChannel(
    id: "thailand-parliament-tv",
    name: "Thailand Parliament TV",
    shortName: "TH",
    jurisdictionLevel: .national,
    countryOrRegion: "Thailand",
    legislature: "National Assembly of Thailand",
    language: "Thai",
    playbackURL: "https://tv-live.tpchannel.org/live/tv.m3u8",
    officialURL: "https://tpchannel.org/",
    attributionText: "Thai Parliament TV HLS candidate; terms and reliability require review.",
    legalReviewStatus: "Personal use only until reviewed",
    availability: .alwaysOn,
    metadataLevel: "Schedule target",
    currentEventTitle: "Thai Parliament TV",
    currentEventTime: "Official parliamentary television feed",
    nextEventTitle: "Official schedule integration",
    nextEventTime: "Planned",
    confidence: "Medium"
  )

  private static let slovakia = directChannel(
    id: "slovakia-tv-nrsr",
    name: "Slovakia TV NRSR",
    shortName: "SK",
    jurisdictionLevel: .national,
    countryOrRegion: "Slovakia",
    legislature: "National Council of the Slovak Republic",
    language: "Slovak",
    playbackURL: "https://n11.stv.livebox.sk/stv-tv/stv4.stream/playlist.m3u8",
    officialURL: "https://www.nrsr.sk/",
    attributionText:
      "Parliamentary/public-broadcaster HLS candidate; source ownership needs review.",
    legalReviewStatus: "Personal use only until reviewed",
    availability: .eventBased,
    metadataLevel: "Schedule target",
    currentEventTitle: "TV NRSR",
    currentEventTime: "Active around scheduled proceedings",
    nextEventTitle: "Official schedule integration",
    nextEventTime: "Planned",
    confidence: "Low"
  )

  private static let mongolia = directDashChannel(
    id: "mongolia-parliament-tv",
    name: "Mongolia Parliament TV",
    shortName: "MN",
    jurisdictionLevel: .national,
    countryOrRegion: "Mongolia",
    legislature: "State Great Khural",
    language: "Mongolian",
    playbackURL: "https://cdn4.skygo.mn/live/disk1/Parlament/DASH-FTA/Parlament.mpd",
    officialURL: "https://www.parliament.mn/",
    attributionText:
      "SkyGo DASH distribution candidate for parliamentary television; ownership and terms need review.",
    legalReviewStatus: "Personal use only until reviewed",
    availability: .alwaysOn,
    metadataLevel: "Signal state only",
    currentEventTitle: "Parliament TV DASH stream",
    currentEventTime: "macOS playback experiment",
    nextEventTitle: "Official source review",
    nextEventTime: "Planned",
    confidence: "Low"
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
      playbackURL:
        "https://cdn3.wowza.com/5/SVEySlNEQ0FOWXlS/diffusion/canal\(channel)/playlist.m3u8",
      officialURL: "https://www.assnat.qc.ca/fr/video-audio/en-direct-webdiffusion.html",
      attributionText: "Official-vendor HLS from the Assembly live-list flow.",
      legalReviewStatus: "Noncommercial/personal use until reviewed",
      availability: .eventBased,
      metadataLevel: "Current event target",
      currentEventTitle: channelNumber == 5 || channelNumber == 6 || channelNumber == 14
        ? "Recently active Assembly webcast channel" : "Assembly webcast channel",
      currentEventTime: "Active when proceedings are scheduled",
      nextEventTitle: "Live-list API metadata",
      nextEventTime: "Planned",
      confidence: channelNumber == 5 || channelNumber == 6 || channelNumber == 14 ? "Medium" : "Low"
    )
  }

  private static let ontarioChannels: [Channel] = [
    (
      "house-en", "Ontario Legislative Assembly - House EN", "ON House", "House proceedings",
      "English"
    ),
    (
      "house-en-cc", "Ontario Legislative Assembly - House EN CC", "ON CC",
      "House proceedings with captions", "English"
    ),
    (
      "rm151-en", "Ontario Legislative Assembly - Room 151", "ON 151", "Room 151 proceedings",
      "English"
    ),
    (
      "committee_1-en", "Ontario Legislative Assembly - Committee 1", "ON C1", "Committee room 1",
      "English"
    ),
    (
      "committee_2-en", "Ontario Legislative Assembly - Committee 2", "ON C2", "Committee room 2",
      "English"
    ),
    (
      "media-en", "Ontario Legislative Assembly - Media Studio", "ON Media", "Media studio feed",
      "English"
    ),
  ].map { streamName, name, shortName, currentTitle, language in
    directChannel(
      id: "ontario-\(streamName.replacingOccurrences(of: "_", with: "-"))",
      name: name,
      shortName: shortName,
      jurisdictionLevel: .subnational,
      countryOrRegion: "Ontario",
      legislature: "Legislative Assembly of Ontario",
      language: language,
      playbackURL:
        "https://origin-http-delivery.isilive.ca/live/_definst_/ontla/\(streamName)/playlist.m3u8",
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

  private static let nunavut = directChannel(
    id: "nunavut-legislative-assembly-tv",
    name: "Nunavut Legislative Assembly TV",
    shortName: "NU",
    jurisdictionLevel: .subnational,
    countryOrRegion: "Nunavut",
    legislature: "Legislative Assembly of Nunavut",
    language: "English / Inuktitut",
    playbackURL: "https://temp2.isilive.ca/live/nunavut/live-eng/index.m3u8",
    officialURL: "https://assembly.nu.ca/",
    attributionText: "iSi LIVE HLS candidate; official page and terms still need confirmation.",
    legalReviewStatus: "Personal use only until reviewed",
    availability: .eventBased,
    metadataLevel: "Signal state only",
    currentEventTitle: "Legislative Assembly TV",
    currentEventTime: "Active around scheduled proceedings",
    nextEventTitle: "Official source and schedule review",
    nextEventTime: "Planned",
    confidence: "Low"
  )

  static let sourcesRequiringExternalPlayer: [Channel] = [
    linkOutChannel(
      id: "uk-parliament-youtube",
      name: "UK Parliament YouTube",
      shortName: "UK",
      jurisdictionLevel: .national,
      countryOrRegion: "United Kingdom",
      legislature: "UK Parliament",
      language: "English",
      sourceType: .youtube,
      officialURL: "https://www.youtube.com/UKParliament",
      attributionText: "Selected live events and clips.",
      legalReviewStatus: "Embed only",
      technicalStatus: .linkOnly,
      metadataLevel: "YouTube current event target",
      currentEventTitle: "Channel page",
      currentEventTime: "Open for selected live streams",
      previewAssetName: "UKParliamentYouTubePreview",
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
      attributionText: "Live events hosted outside the native player.",
      legalReviewStatus: "Embed only",
      technicalStatus: .linkOnly,
      metadataLevel: "YouTube current event target",
      currentEventTitle: "Channel page",
      currentEventTime: "Open for active streams",
      previewAssetName: "AustraliaParliamentYouTubePreview",
      confidence: "Medium"
    ),
    linkOutChannel(
      id: "taiwan-parliamentary-tv-youtube",
      name: "Taiwan Parliamentary TV",
      shortName: "TW",
      jurisdictionLevel: .national,
      countryOrRegion: "Taiwan",
      legislature: "Legislative Yuan",
      language: "Mandarin",
      sourceType: .youtube,
      officialURL: "https://www.parliamentarytv.org.tw/",
      attributionText: "Live portal with channels and meeting playlists.",
      legalReviewStatus: "Embed only",
      technicalStatus: .linkOnly,
      metadataLevel: "YouTube current event target",
      currentEventTitle: "Live portal",
      currentEventTime: "Open for active streams",
      previewAssetName: "TaiwanParliamentaryTVPreview",
      confidence: "Medium"
    ),
    linkOutChannel(
      id: "costa-rica-assembly-youtube",
      name: "Costa Rica Assembly YouTube",
      shortName: "CR",
      jurisdictionLevel: .national,
      countryOrRegion: "Costa Rica",
      legislature: "Asamblea Legislativa",
      language: "Spanish",
      sourceType: .youtube,
      officialURL: "https://www.youtube.com/@AsambleaCRC",
      attributionText: "Live and recorded Assembly proceedings.",
      legalReviewStatus: "Embed only",
      technicalStatus: .linkOnly,
      metadataLevel: "YouTube current event target",
      currentEventTitle: "Channel page",
      currentEventTime: "Open for active streams",
      previewAssetName: "CostaRicaAssemblyYouTubePreview",
      confidence: "Medium"
    ),
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
      previewAssetName: nil,
      program: ProgramMetadata(
        currentEventTitle: currentEventTitle,
        currentEventTime: currentEventTime,
        nextEventTitle: nextEventTitle,
        nextEventTime: nextEventTime,
        confidence: confidence
      )
    )
  }

  private static func directDashChannel(
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
      sourceType: .directDASH,
      displayMode: .nativePlayer,
      playbackURL: URL(string: playbackURL),
      officialURL: URL(string: officialURL)!,
      attributionText: attributionText,
      legalReviewStatus: legalReviewStatus,
      technicalStatus: .needsReview,
      availability: availability,
      metadataLevel: metadataLevel,
      previewAssetName: nil,
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
    previewAssetName: String?,
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
      previewAssetName: previewAssetName,
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
