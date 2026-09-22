import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("News releases models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct NewsReleaseTests {
  @Test("Constructed news releases decode with nulls and unknown fields")
  func constructedNewsReleasesDecodeWithNullsAndUnknownFields() throws {
    // Constructed, not recorded: recorded news releases send every key and no null text.
    let json = Data(
      #"""
      {"id":"N1","title":"Example Release","url":null,"parkCode":null,"abstract":null,
      "image":null,"relatedParks":[{"parkCode":null,"extra":1}],"relatedOrganizations":null,
      "latitude":null,"longitude":null,"geometryPoiId":null,"releaseDate":null,"credit":null,
      "lastIndexedDate":null,"futureField":{"nested":true}}
      """#.utf8)
    let release = try JSONDecoder().decode(NewsRelease.self, from: json)
    #expect(release.id == "N1")
    #expect(release.title == "Example Release")
    #expect(release.abstract == nil)
    #expect(release.credit == nil)
    #expect(release.geometryPoiId == nil)
    #expect(release.image == nil)
    #expect(release.lastIndexedDate == nil)
    #expect(release.latitude == nil)
    #expect(release.longitude == nil)
    #expect(release.parkCode == nil)
    #expect(release.relatedOrganizations == nil)
    #expect(release.relatedParks?.first?.parkCode == nil)
    #expect(release.releaseDate == nil)
    #expect(release.url == nil)
  }

  @Test("Missing identity or title fails to decode")
  func missingIdentityOrTitleFailsToDecode() {
    // Constructed, not recorded: NPS news releases always carry an id and title.
    for body in [#"{"title":"Example Release"}"#, #"{"id":"N1"}"#] {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(NewsRelease.self, from: Data(body.utf8))
      }
    }
  }

  @Test("Recorded news release pages decode with their envelopes")
  func recordedNewsReleasePagesDecodeWithTheirEnvelopes() throws {
    let first = try decode(.newsReleasesPageFirst)
    #expect(first.total == "19")
    #expect(first.limit == "1")
    #expect(first.start == "0")
    #expect(first.data.map(\.id) == ["1E2E3378-3BB5-469F-B1F5-90187DC513A5"])
    let last = try decode(.newsReleasesPageLast)
    #expect(last.total == "19")
    #expect(last.start == "1")
    #expect(last.data.map(\.id) == ["5F507B4F-FFB9-4AA6-B608-712C4A3A1077"])
    #expect(
      last.data.map(\.title) == [
        "Yellowstone National Park reports August 2026 visitation statistics"
      ])
    let empty = try decode(.newsReleasesEmpty)
    #expect(empty.total == "0")
    #expect(empty.data.isEmpty)
  }

  @Test("Recorded timestamps, images, parks, and empty text are kept as sent")
  func recordedTimestampsImagesParksAndEmptyTextAreKeptAsSent() throws {
    let release = try #require(try decode(.newsReleasesPageFirst).data.first)
    #expect(release.url == "https://www.nps.gov/yell/learn/news/26023.htm")
    #expect(release.parkCode == "yell")
    #expect(release.releaseDate == "2026-09-17 15:34:00.0")
    #expect(release.lastIndexedDate == "2026-09-17 11:07:35.0")
    #expect(release.abstract?.hasPrefix("The National Park Service (NPS) signed a Finding") == true)
    #expect(release.latitude == nil)
    #expect(release.longitude == nil)
    #expect(release.geometryPoiId == "")
    #expect(release.credit == "")
    #expect(release.relatedOrganizations == [])
    let image = try #require(release.image)
    #expect(image.url == "https://www.nps.gov/yell/learn/news/images/52151724253_3cd4fc7475_k.jpg")
    #expect(image.credit == "NPS / Jacob W. Frank")
    #expect(image.altText == "Yellowstone flood event 2022: North Entrance Road washout")
    #expect(image.title == "North Entrance Road washout")
    #expect(image.description == "")
    #expect(
      image.caption == "Yellowstone flood event 2022: North Entrance Road, Gardiner to Mammoth")
    #expect(image.crops == nil)
    let park = try #require(release.relatedParks?.first)
    #expect(release.relatedParks?.count == 1)
    #expect(park.designation == "National Park")
    #expect(park.fullName == "Yellowstone National Park")
    #expect(park.name == "Yellowstone")
    #expect(park.parkCode == "yell")
    #expect(park.states == "ID,MT,WY")
    #expect(park.url == "https://www.nps.gov/yell/index.htm")
  }

  @Test("Recorded search results keep organizations, park code lists, and empty images")
  func recordedSearchResultsKeepOrganizationsParkCodeListsAndEmptyImages() throws {
    let page = try decode(.newsReleasesSearch)
    #expect(page.total == "2")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    #expect(
      page.data.map(\.id) == [
        "A4CA6BB5-F553-4F4B-8A5E-7C974DAC4FE8", "590F673C-4C2A-4E5D-85CF-8B5EAE0847DF",
      ])
    let fireworks = try #require(page.data.first)
    #expect(fireworks.title == "Traffic advisory for July 4 fireworks setup at Anacostia Park")
    #expect(fireworks.parkCode == "anac,nace")
    #expect(fireworks.relatedParks?.map(\.parkCode) == ["anac", "nace"])
    #expect(fireworks.relatedParks?.last?.designation == "")
    #expect(fireworks.releaseDate == "2026-06-18 10:39:00.0")
    #expect(fireworks.abstract?.contains("street closures \u{2013} some beginning") == true)
    let organization = try #require(fireworks.relatedOrganizations?.first)
    #expect(fireworks.relatedOrganizations?.count == 1)
    #expect(organization.id == "E33CCEA6-E7D0-4EC4-8C80-2CE6D20059C4")
    #expect(organization.name == "US Park Police")
    #expect(organization.url == "https://www.nps.gov/subjects/uspp/index.htm")
    let image = try #require(fireworks.image)
    #expect(image.url == "")
    #expect(image.altText == "")
    #expect(image.caption == "")
    #expect(image.credit == "")
    #expect(image.description == "")
    #expect(image.title == "")
    let closures = try #require(page.data.last)
    #expect(closures.parkCode == "anac")
    #expect(closures.relatedOrganizations?.map(\.name) == ["US Park Police"])
    #expect(closures.lastIndexedDate == "2026-07-01 12:01:22.0")
  }

  private func decode(_ fixture: Fixture) throws -> NPSCollection<NewsRelease> {
    try JSONDecoder().decode(NPSCollection<NewsRelease>.self, from: fixture.data())
  }
}
