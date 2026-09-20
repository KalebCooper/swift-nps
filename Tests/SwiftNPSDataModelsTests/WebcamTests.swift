import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Webcams models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct WebcamTests {
  @Test("Constructed webcams decode with nulls and unknown fields")
  func constructedWebcamsDecodeWithNullsAndUnknownFields() throws {
    // Constructed, not recorded: recorded webcams send every key and no null text.
    let json = Data(
      #"""
      {"id":"W1","title":"Example Webcam","url":null,"credit":null,"description":null,
      "geometryPoiId":null,"images":null,"isStreaming":null,"latitude":null,"longitude":null,
      "relatedParks":[{"parkCode":null,"extra":1}],"status":null,"statusMessage":null,
      "tags":null,"futureField":{"nested":true}}
      """#.utf8)
    let webcam = try JSONDecoder().decode(Webcam.self, from: json)
    #expect(webcam.id == "W1")
    #expect(webcam.title == "Example Webcam")
    #expect(webcam.url == nil)
    #expect(webcam.credit == nil)
    #expect(webcam.description == nil)
    #expect(webcam.geometryPoiId == nil)
    #expect(webcam.images == nil)
    #expect(webcam.isStreaming == nil)
    #expect(webcam.latitude == nil)
    #expect(webcam.longitude == nil)
    #expect(webcam.relatedParks?.first?.parkCode == nil)
    #expect(webcam.status == nil)
    #expect(webcam.statusMessage == nil)
    #expect(webcam.tags == nil)
  }

  @Test("Missing identity or title fails to decode")
  func missingIdentityOrTitleFailsToDecode() {
    // Constructed, not recorded: NPS webcams always carry an id and title.
    for body in [#"{"title":"Example Webcam"}"#, #"{"id":"W1"}"#] {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(Webcam.self, from: Data(body.utf8))
      }
    }
  }

  @Test("Streaming and coordinates keep their JSON types")
  func streamingAndCoordinatesKeepTheirJSONTypes() {
    // Constructed, not recorded: the provider sends a Boolean and numbers, never their text.
    for body in [
      #"{"id":"W1","title":"T","isStreaming":"true"}"#,
      #"{"id":"W1","title":"T","latitude":"1.5"}"#,
    ] {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(Webcam.self, from: Data(body.utf8))
      }
    }
  }

  @Test("Recorded webcam pages decode with their envelopes")
  func recordedWebcamPagesDecodeWithTheirEnvelopes() throws {
    let first = try decode(.webcamsPageFirst)
    #expect(first.total == "3")
    #expect(first.limit == "1")
    #expect(first.start == "0")
    #expect(first.data.map(\.id) == ["9603ED1D-F805-714D-AC4557683B558B00"])
    #expect(
      first.data.map(\.title) == [
        "Current view from the Craig Thomas Discovery & Visitor Center in Moose, WY"
      ])
    let last = try decode(.webcamsPageLast)
    #expect(last.total == "3")
    #expect(last.start == "1")
    #expect(last.data.map(\.id) == ["81B46A95-1DD8-B71B-0B8F152DC0EE9CB0"])
    #expect(last.data.map(\.title) == ["NPS Air Resources"])
    let empty = try decode(.webcamsEmpty)
    #expect(empty.total == "0")
    #expect(empty.data.isEmpty)
  }

  @Test("Recorded streaming flags, statuses, and null coordinates are kept as sent")
  func recordedStreamingFlagsStatusesAndNullCoordinatesAreKeptAsSent() throws {
    let moose = try #require(try decode(.webcamsPageFirst).data.first)
    #expect(moose.isStreaming == true)
    #expect(moose.status == "Active")
    #expect(moose.statusMessage == "")
    #expect(moose.latitude == nil)
    #expect(moose.longitude == nil)
    #expect(moose.images == [])
    #expect(moose.tags == [])
    #expect(moose.geometryPoiId == "")
    #expect(moose.credit == "")
    #expect(
      moose.url
        == "https://www.nps.gov/media/webcam/view.htm?id=9603ED1D-F805-714D-AC4557683B558B00")
    let park = try #require(moose.relatedParks?.first)
    #expect(moose.relatedParks?.count == 1)
    #expect(park.designation == "National Park")
    #expect(park.fullName == "Grand Teton National Park")
    #expect(park.name == "Grand Teton")
    #expect(park.parkCode == "grte")
    #expect(park.states == "WY")
    #expect(park.url == "https://www.nps.gov/grte/index.htm")

    let air = try #require(try decode(.webcamsPageLast).data.first)
    #expect(air.isStreaming == false)
    #expect(air.status == "Inactive")
    #expect(air.latitude == nil)
    #expect(air.longitude == nil)
    #expect(
      air.description
        == "The NPS Air Resources Division maintains a webcam on the east side of Grand Teton "
        + "National Park, near Teton Science Schools Kelly Campus.")
  }

  @Test("Recorded search results preserve provider values")
  func recordedSearchResultsPreserveProviderValues() throws {
    let page = try decode(.webcamsSearch)
    #expect(page.total == "1")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    let capitan = try #require(page.data.first)
    #expect(page.data.count == 1)
    #expect(capitan.id == "9849DE2B-BC23-1110-33CED7C04E8AAF05")
    #expect(capitan.title == "El Capitan View")
    #expect(
      capitan.description
        == "View from the Pine Springs area towards the southwest and the profile of El Capitan - "
        + "\"View Webcam\" link opens a larger picture that updates every 30 seconds.")
    #expect(capitan.isStreaming == false)
    #expect(capitan.status == "Active")
    #expect(capitan.latitude == 31.923355102539062)
    #expect(capitan.longitude == -104.87138366699219)
    #expect(capitan.tags == ["Texas", "Guadalupe Mountains"])
    #expect(capitan.relatedParks?.map(\.parkCode) == ["gumo"])
    #expect(capitan.relatedParks?.map(\.states) == ["TX"])
    let image = try #require(capitan.images?.first)
    #expect(capitan.images?.count == 1)
    #expect(
      image.url
        == "https://www.nps.govhttps://www.nps.gov/common/uploads/cropped_image/"
        + "357C0EB9-B5B4-D7E7-9AC756993AC6DD18.jpg")
    #expect(
      image.altText == "El Capitan View View from the Pine Springs area towards the southwest")
    #expect(image.caption == "")
    #expect(image.credit == "")
    #expect(image.crops == [])
    #expect(image.description == "")
    #expect(image.title == "")
  }

  private func decode(_ fixture: Fixture) throws -> NPSCollection<Webcam> {
    try JSONDecoder().decode(NPSCollection<Webcam>.self, from: fixture.data())
  }
}
