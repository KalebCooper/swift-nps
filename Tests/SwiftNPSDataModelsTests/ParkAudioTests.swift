import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Park audio models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkAudioTests {
  @Test("Constructed park audio decodes with nulls and unknown fields")
  func constructedParkAudioDecodesWithNullsAndUnknownFields() throws {
    // Constructed, not recorded: recorded park audio sends every key and no null text.
    let json = Data(
      #"""
      {"id":"A1","title":"Example Audio","permalinkUrl":null,"description":null,
      "splashImage":null,"relatedParks":[{"parkCode":null,"extra":1}],"tags":null,
      "latitude":null,"longitude":null,"geometryPoiId":null,"durationMs":null,"credit":null,
      "transcript":null,"callToAction":null,"callToActionUrl":null,
      "versions":[{"fileSize":null,"fileType":null,"url":null,"extra":2}],
      "futureField":{"nested":true}}
      """#.utf8)
    let audio = try JSONDecoder().decode(ParkAudio.self, from: json)
    #expect(audio.id == "A1")
    #expect(audio.title == "Example Audio")
    #expect(audio.callToAction == nil)
    #expect(audio.callToActionUrl == nil)
    #expect(audio.credit == nil)
    #expect(audio.description == nil)
    #expect(audio.durationMs == nil)
    #expect(audio.geometryPoiId == nil)
    #expect(audio.latitude == nil)
    #expect(audio.longitude == nil)
    #expect(audio.permalinkUrl == nil)
    #expect(audio.relatedParks?.first?.parkCode == nil)
    #expect(audio.splashImage == nil)
    #expect(audio.tags == nil)
    #expect(audio.transcript == nil)
    let version = try #require(audio.versions?.first)
    #expect(version.fileSize == nil)
    #expect(version.fileType == nil)
    #expect(version.url == nil)
  }

  @Test("Missing identity or title fails to decode")
  func missingIdentityOrTitleFailsToDecode() {
    // Constructed, not recorded: NPS park audio always carries an id and title.
    for body in [#"{"title":"Example Audio"}"#, #"{"id":"A1"}"#] {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(ParkAudio.self, from: Data(body.utf8))
      }
    }
  }

  @Test("Recorded park audio pages decode with their envelopes")
  func recordedParkAudioPagesDecodeWithTheirEnvelopes() throws {
    let first = try decode(.parkAudioPageFirst)
    #expect(first.total == "13")
    #expect(first.limit == "1")
    #expect(first.start == "0")
    #expect(first.data.map(\.id) == ["84F895EE-31C4-4D17-BB01-5AF0AADE3F30"])
    let last = try decode(.parkAudioPageLast)
    #expect(last.total == "13")
    #expect(last.start == "1")
    #expect(last.data.map(\.id) == ["F9283688-390A-4B61-B0AE-55CC15A03B36"])
    #expect(last.data.map(\.title) == ["Sounds Along the Canal: Cars Under Key Bridge"])
    let empty = try decode(.parkAudioEmpty)
    #expect(empty.total == "0")
    #expect(empty.data.isEmpty)
  }

  @Test("Recorded versions, splash images, parks, and empty text are kept as sent")
  func recordedVersionsSplashImagesParksAndEmptyTextAreKeptAsSent() throws {
    let audio = try #require(try decode(.parkAudioPageFirst).data.first)
    #expect(audio.title == "Sounds Along the Canal: Rushing Water Near Lock 4")
    #expect(
      audio.permalinkUrl
        == "https://www.nps.gov/media/video/view.htm?id=84F895EE-31C4-4D17-BB01-5AF0AADE3F30")
    #expect(audio.description?.hasPrefix("Rushing water near a construction site") == true)
    #expect(audio.transcript?.hasSuffix("in Georgetown, Washington, DC.") == true)
    #expect(audio.durationMs == 16872)
    #expect(audio.latitude == nil)
    #expect(audio.longitude == nil)
    #expect(audio.geometryPoiId == "")
    #expect(audio.credit == "")
    #expect(audio.callToAction == "")
    #expect(audio.callToActionUrl == "")
    #expect(audio.tags == [])
    let splash = try #require(audio.splashImage)
    #expect(splash.url == "")
    #expect(splash.altText == nil)
    #expect(splash.crops == nil)
    let version = try #require(audio.versions?.first)
    #expect(audio.versions?.count == 1)
    #expect(version.fileSize == 170844.0)
    #expect(version.fileType == "audio/mp3")
    #expect(
      version.url
        == "https://www.nps.gov/nps-audiovideo/audiovideo/1cc21b67-8eff-46d3-8853-cfe3e7cab9ea.mp3")
    let park = try #require(audio.relatedParks?.first)
    #expect(audio.relatedParks?.count == 1)
    #expect(park.designation == "National Historical Park")
    #expect(park.fullName == "Chesapeake & Ohio Canal National Historical Park")
    #expect(park.name == "Chesapeake & Ohio Canal")
    #expect(park.parkCode == "choh")
    #expect(park.states == "DC,MD,WV")
    #expect(park.url == "https://www.nps.gov/choh/index.htm")
    let later = try #require(try decode(.parkAudioPageLast).data.first)
    #expect(
      later.splashImage?.url
        == "https://www.nps.gov/common/uploads/ncr/park/choh//3B9AE488-A03D-D8F8-7CE061F37C83AB3A"
        + "/3B9AE488-A03D-D8F8-7CE061F37C83AB3A-large.png")
    #expect(later.versions?.first?.fileSize == 150507.0)
  }

  @Test("Recorded search results keep empty transcripts, null durations, and zero file sizes")
  func recordedSearchResultsKeepEmptyTranscriptsNullDurationsAndZeroFileSizes() throws {
    let page = try decode(.parkAudioSearch)
    #expect(page.total == "6")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    #expect(
      page.data.map(\.id) == [
        "D9E5E229-63EB-4CB2-B7CB-7A93BA85BB44", "5EED7122-AADE-456E-954C-DDA4D0C43C3C",
      ])
    let alligator = try #require(page.data.first)
    #expect(alligator.title == "Alligator")
    #expect(alligator.credit == "NPS Natural Sounds Program")
    #expect(alligator.durationMs == nil)
    #expect(alligator.transcript == "")
    #expect(alligator.latitude == nil)
    #expect(alligator.splashImage?.url == "")
    #expect(alligator.relatedParks?.map(\.parkCode) == ["ever"])
    let chorus = try #require(page.data.last)
    #expect(chorus.title == "Alligator and Pig Frog")
    #expect(chorus.durationMs == nil)
    let version = try #require(chorus.versions?.first)
    #expect(version.fileSize == 0.0)
    #expect(version.fileType == "audio/mp3")
    #expect(
      version.url
        == "https://www.nps.gov/nps-audiovideo/legacy/mp3/ser/avElement/"
        + "ever-AlligatorAndPigFrogEVER.mp3")
  }

  private func decode(_ fixture: Fixture) throws -> NPSCollection<ParkAudio> {
    try JSONDecoder().decode(NPSCollection<ParkAudio>.self, from: fixture.data())
  }
}
