import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Park video models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkVideoTests {
  @Test("Constructed park videos decode with nulls and unknown fields")
  func constructedParkVideosDecodeWithNullsAndUnknownFields() throws {
    // Constructed, not recorded: recorded park videos send every key and no null text or flags.
    let json = Data(
      #"""
      {"id":"V1","title":"Example Video","permalinkUrl":null,"description":null,
      "splashImage":null,"relatedParks":[{"parkCode":null,"extra":1}],"tags":null,
      "latitude":null,"longitude":null,"audioDescription":null,"audioDescriptionUrl":null,
      "aslVideoUrl":null,"geometryPoiId":null,"durationMs":null,"credit":null,"transcript":null,
      "descriptiveTranscript":null,"callToAction":null,"callToActionUrl":null,
      "audioDescribedBuiltIn":null,"hasOpenCaptions":null,"isVideoOnly":null,"isBRoll":null,
      "captionFiles":[{"language":null,"fileType":null,"url":null,"extra":3}],
      "versions":[{"fileSizeKb":null,"fileType":null,"aspectRatio":null,"heightPixels":null,
      "url":null,"widthPixels":null,"extra":2}],
      "futureField":{"nested":true}}
      """#.utf8)
    let video = try JSONDecoder().decode(ParkVideo.self, from: json)
    #expect(video.id == "V1")
    #expect(video.title == "Example Video")
    #expect(video.aslVideoUrl == nil)
    #expect(video.audioDescribedBuiltIn == nil)
    #expect(video.audioDescription == nil)
    #expect(video.audioDescriptionUrl == nil)
    #expect(video.callToAction == nil)
    #expect(video.callToActionUrl == nil)
    #expect(video.credit == nil)
    #expect(video.description == nil)
    #expect(video.descriptiveTranscript == nil)
    #expect(video.durationMs == nil)
    #expect(video.geometryPoiId == nil)
    #expect(video.hasOpenCaptions == nil)
    #expect(video.isBRoll == nil)
    #expect(video.isVideoOnly == nil)
    #expect(video.latitude == nil)
    #expect(video.longitude == nil)
    #expect(video.permalinkUrl == nil)
    #expect(video.relatedParks?.first?.parkCode == nil)
    #expect(video.splashImage == nil)
    #expect(video.tags == nil)
    #expect(video.transcript == nil)
    let caption = try #require(video.captionFiles?.first)
    #expect(caption.fileType == nil)
    #expect(caption.language == nil)
    #expect(caption.url == nil)
    let version = try #require(video.versions?.first)
    #expect(version.aspectRatio == nil)
    #expect(version.fileSizeKb == nil)
    #expect(version.fileType == nil)
    #expect(version.heightPixels == nil)
    #expect(version.url == nil)
    #expect(version.widthPixels == nil)
  }

  @Test("Missing identity or title fails to decode")
  func missingIdentityOrTitleFailsToDecode() {
    // Constructed, not recorded: NPS park videos always carry an id and title.
    for body in [#"{"title":"Example Video"}"#, #"{"id":"V1"}"#] {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(ParkVideo.self, from: Data(body.utf8))
      }
    }
  }

  @Test("An empty versions array stays empty")
  func anEmptyVersionsArrayStaysEmpty() throws {
    // Constructed, not recorded: one of 500 scanned videos sends an empty versions array.
    let json = Data(#"{"id":"V1","title":"Example Video","captionFiles":[],"versions":[]}"#.utf8)
    let video = try JSONDecoder().decode(ParkVideo.self, from: json)
    #expect(video.versions == [])
    #expect(video.captionFiles == [])
  }

  @Test("Recorded park video pages decode with their envelopes")
  func recordedParkVideoPagesDecodeWithTheirEnvelopes() throws {
    let first = try decode(.parkVideosPageFirst)
    #expect(first.total == "25")
    #expect(first.limit == "1")
    #expect(first.start == "0")
    #expect(first.data.map(\.id) == ["00952400-2312-44F0-B72C-30C1C692BFF2"])
    let last = try decode(.parkVideosPageLast)
    #expect(last.total == "25")
    #expect(last.start == "1")
    #expect(last.data.map(\.id) == ["280ED23E-D17F-41C5-966E-3AB940B7AEA5"])
    let empty = try decode(.parkVideosEmpty)
    #expect(empty.total == "0")
    #expect(empty.data.isEmpty)
  }

  @Test("Recorded null file sizes, captions, flags, parks, and empty text are kept as sent")
  func recordedNullFileSizesCaptionsFlagsParksAndEmptyTextAreKeptAsSent() throws {
    let video = try #require(try decode(.parkVideosPageFirst).data.first)
    #expect(video.title == "Bats at Craters of the Moon")
    #expect(
      video.permalinkUrl
        == "https://www.nps.gov/media/video/view.htm?id=00952400-2312-44F0-B72C-30C1C692BFF2")
    #expect(
      video.description == "Learn about the diversity and threats to bats at Craters of the Moon.")
    #expect(video.credit == "NPS/ Michael Durham")
    #expect(video.durationMs == 379000)
    #expect(video.latitude == nil)
    #expect(video.longitude == nil)
    #expect(video.aslVideoUrl == "")
    #expect(video.audioDescription == "")
    #expect(video.audioDescriptionUrl == "")
    #expect(video.callToAction == "")
    #expect(video.callToActionUrl == "")
    #expect(video.descriptiveTranscript == "")
    #expect(video.geometryPoiId == "")
    #expect(video.transcript == "")
    #expect(video.tags == [])
    #expect(video.audioDescribedBuiltIn == false)
    #expect(video.hasOpenCaptions == false)
    #expect(video.isBRoll == false)
    #expect(video.isVideoOnly == false)
    #expect(video.splashImage?.url == "")
    let caption = try #require(video.captionFiles?.first)
    #expect(video.captionFiles?.count == 1)
    #expect(caption.fileType == "text/vtt")
    #expect(caption.language == "english")
    #expect(
      caption.url
        == "https://www.nps.gov/nps-audiovideo/legacy/closed-caption/pwr/avElement/"
        + "crmo-nri-captions62.vtt")
    #expect(video.versions?.count == 3)
    #expect(video.versions?.map(\.fileSizeKb) == [nil, nil, nil])
    #expect(video.versions?.map(\.heightPixels) == [360, 240, 480])
    #expect(video.versions?.map(\.widthPixels) == [640, 426, 854])
    let version = try #require(video.versions?.first)
    #expect(version.aspectRatio == 1.778)
    #expect(version.fileType == "video/mp4")
    #expect(
      version.url
        == "https://www.nps.gov/nps-audiovideo/legacy/crmo/F31865BD-932E-A5CE-6FD328916C48F9D0/"
        + "crmo-CRMOBatsCavesFinal-H264320X64011_640x360.mp4")
    let park = try #require(video.relatedParks?.first)
    #expect(video.relatedParks?.count == 1)
    #expect(park.designation == "National Monument & Preserve")
    #expect(park.fullName == "Craters Of The Moon National Monument & Preserve")
    #expect(park.name == "Craters Of The Moon")
    #expect(park.parkCode == "crmo")
    #expect(park.states == "ID")
    #expect(park.url == "https://www.nps.gov/crmo/index.htm")
  }

  @Test("Recorded file sizes, true flags, and an empty caption list are kept as sent")
  func recordedFileSizesTrueFlagsAndAnEmptyCaptionListAreKeptAsSent() throws {
    let video = try #require(try decode(.parkVideosPageLast).data.first)
    #expect(video.title.hasPrefix("Video 8. Nature Journaling on the Moon"))
    #expect(video.credit == "Karen Jacobsen and Mary Arnold")
    #expect(video.durationMs == 226226)
    #expect(video.audioDescribedBuiltIn == true)
    #expect(video.hasOpenCaptions == true)
    #expect(video.isBRoll == false)
    #expect(video.isVideoOnly == false)
    #expect(video.captionFiles == [])
    #expect(
      video.splashImage?.url
        == "https://www.nps.gov/nps-audiovideo/thumbnail/a512021e-8705-4a3e-872d-1a89ab63efa9.jpg")
    #expect(video.versions?.map(\.fileSizeKb) == [15976.0, 22093.0, 66471.0, 117113.0])
    #expect(video.versions?.map(\.heightPixels) == [360, 480, 720, 1080])
    #expect(video.versions?.map(\.widthPixels) == [640, 854, 1280, 1920])
  }

  @Test("Recorded search results keep audio description links, tags, and mixed file sizes")
  func recordedSearchResultsKeepAudioDescriptionLinksTagsAndMixedFileSizes() throws {
    let page = try decode(.parkVideosSearch)
    #expect(page.total == "17")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    #expect(
      page.data.map(\.id) == [
        "33487F25-F758-4F1C-8EAB-BA420B291C8C", "A16085D7-4810-4AD5-93FB-7DD3EC92F2F2",
      ])
    let burns = try #require(page.data.first)
    #expect(burns.title == "A Man Kidnapped! The Rendition of Anthony Burns")
    #expect(burns.audioDescription == "")
    #expect(
      burns.audioDescriptionUrl?.hasSuffix(
        "RenditionofAnthonyBurns-FULLFINALCUT-AUDIODESCRIBED_640x360.mp4") == true)
    #expect(burns.captionFiles?.map(\.language) == ["english"])
    #expect(burns.versions?.map(\.fileSizeKb) == [nil, nil, nil, nil])
    let marker = try #require(page.data.last)
    #expect(marker.title == "Boston's Middle Passage Port Marker Dedication Ceremony")
    #expect(marker.durationMs == 4273836)
    #expect(marker.credit == "NPS")
    #expect(marker.description?.contains("Balla Kouyat\u{E9};") == true)
    #expect(marker.tags?.count == 9)
    #expect(marker.tags?.first == "Boston")
    #expect(marker.tags?.last == "Enslaved People")
    #expect(
      marker.audioDescriptionUrl
        == "https://www.nps.gov/nps-audiovideo/audiovideo/1e71d1d4-f254-4a1c-ae96-e87c6405d20f.mp4")
    #expect(marker.versions?.map(\.fileSizeKb) == [102071.0, 127976.0])
    #expect(marker.relatedParks?.map(\.parkCode) == ["boaf"])
  }

  private func decode(_ fixture: Fixture) throws -> NPSCollection<ParkVideo> {
    try JSONDecoder().decode(NPSCollection<ParkVideo>.self, from: fixture.data())
  }
}
