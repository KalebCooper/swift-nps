import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Tours models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct TourTests {
  @Test("Constructed tours decode with nulls and unknown fields")
  func constructedToursDecodeWithNullsAndUnknownFields() throws {
    // Constructed, not recorded: recorded tours carry no nulls.
    let json = Data(
      #"""
      {"id":"T1","title":"Example Tour","description":null,"park":null,"tags":null,"type":null,
      "activities":null,"topics":null,"durationMin":null,"durationMax":null,"durationUnit":null,
      "stops":[{"ordinal":null,"id":null,"extra":1},{}],"images":null,"relevanceScore":null,
      "futureField":{"nested":true}}
      """#.utf8)
    let tour = try JSONDecoder().decode(Tour.self, from: json)
    #expect(tour.id == "T1")
    #expect(tour.title == "Example Tour")
    #expect(tour.description == nil)
    #expect(tour.park == nil)
    #expect(tour.tags == nil)
    #expect(tour.type == nil)
    #expect(tour.activities == nil)
    #expect(tour.topics == nil)
    #expect(tour.durationMin == nil)
    #expect(tour.durationMax == nil)
    #expect(tour.durationUnit == nil)
    #expect(tour.images == nil)
    #expect(tour.relevanceScore == nil)
    #expect(tour.stops?.count == 2)
    let stop = try #require(tour.stops?.first)
    #expect(stop.ordinal == nil)
    #expect(stop.id == nil)
    #expect(stop.assetId == nil)
    #expect(stop.assetType == nil)
    #expect(tour.stops?.last?.assetName == nil)
  }

  @Test("Missing identity or title fails to decode")
  func missingIdentityOrTitleFailsToDecode() {
    // Constructed, not recorded: NPS tours always carry an id and title.
    for body in [#"{"title":"Example Tour"}"#, #"{"id":"T1"}"#] {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(Tour.self, from: Data(body.utf8))
      }
    }
  }

  @Test("Recorded tour crops decode their numeric aspect ratios")
  func recordedTourCropsDecodeTheirNumericAspectRatios() throws {
    // The tours body sends aspectRatio as the JSON numbers 1.78 and 1.0, while places sends text.
    let image = try #require(try decode(.toursSearch).data.first?.images?.first)
    #expect(image.crops?.map(\.aspectRatio) == ["1.78", "1.0"])
    #expect(image.crops?.map(\.ratio) == [1.78, 1.0])
    #expect(
      image.crops?.map(\.url) == [
        "https://www.nps.gov/common/uploads/tours/primary/7F5855D7-9A7D-2FBF-1D0F70B4AE3C590B.jpg",
        "https://www.nps.gov/common/uploads/tours/secondary/7F5855D7-9A7D-2FBF-1D0F70B4AE3C590B.jpg",
      ])
    #expect(image.credit == "NPS/USF")
    #expect(image.title == "Fort Matanzas Virtual Tour")
    #expect(image.altText == "Screenshot of virtual Fort Matanzas Tour")
    #expect(image.caption == "Screenshot of virtual Fort Matanzas Tour")
    #expect(image.description == nil)
    #expect(
      image.url
        == "https://www.nps.gov/common/uploads/tours/7F5855D7-9A7D-2FBF-1D0F70B4AE3C590B.jpg")
  }

  @Test("Recorded tours pages decode with their envelopes")
  func recordedToursPagesDecodeWithTheirEnvelopes() throws {
    let first = try decode(.toursPageFirst)
    #expect(first.total == "4")
    #expect(first.limit == "1")
    #expect(first.start == "0")
    #expect(first.data.map(\.id) == ["5E1E3F5E-BEE0-F773-443B2B7F25CE354E"])
    #expect(first.data.map(\.title) == ["Crater Rim Trail"])
    let last = try decode(.toursPageLast)
    #expect(last.total == "4")
    #expect(last.start == "1")
    #expect(last.data.map(\.id) == ["5CCCDD98-AAA5-3105-FC512D83E4B4E076"])
    #expect(last.data.map(\.title) == ["Crater Vent Trail"])
    let empty = try decode(.toursEmpty)
    #expect(empty.total == "0")
    #expect(empty.data.isEmpty)
  }

  @Test("A recorded tour links one park and keeps its duration text")
  func aRecordedTourLinksOneParkAndKeepsItsDurationText() throws {
    let tour = try #require(try decode(.toursPageFirst).data.first)
    let park = try #require(tour.park)
    #expect(park.designation == "National Monument")
    #expect(park.fullName == "Capulin Volcano National Monument")
    #expect(park.name == "Capulin Volcano")
    #expect(park.parkCode == "cavo")
    #expect(park.states == "NM")
    #expect(park.url == "https://www.nps.gov/cavo/index.htm")
    #expect(tour.durationMin == "30")
    #expect(tour.durationMax == "75")
    #expect(tour.durationUnit == "m")
    #expect(tour.type == "Standard")
    #expect(tour.relevanceScore == 1.0)
    #expect(tour.tags == ["scenic views", "volcanoes", "trail", "hiking"])
    #expect(
      tour.description?.hasPrefix("Come take a hike around the rim of Capulin Volcano!") == true)
    #expect(
      tour.activities?.map(\.name) == ["Hiking", "Front-Country Hiking", "Wildlife Watching"])
    #expect(tour.activities?.first?.id == "BFF8C027-7C8F-480B-A5F8-CD8CE490BFBA")
    #expect(tour.topics?.count == 8)
    #expect(tour.topics?.first?.name == "Animals")
    #expect(tour.topics?.first?.id == "0D00073E-18C3-46E5-8727-2F87B112DDC6")
  }

  @Test("Recorded stops keep their string ordinals and empty text")
  func recordedStopsKeepTheirStringOrdinalsAndEmptyText() throws {
    let tour = try #require(try decode(.toursPageFirst).data.first)
    let stops = try #require(tour.stops)
    #expect(stops.map(\.ordinal) == ["1", "2"])
    #expect(stops.map(\.assetName) == ["Volcano Road Parking", "Top of Capulin Volcano"])
    #expect(stops.map(\.assetType) == ["places", "places"])
    #expect(
      stops.map(\.assetId) == [
        "C872685F-BC9E-4480-A890-BBD9AE883330", "4E67E95B-CBBC-4CF2-A0D4-9417C42A187C",
      ])
    #expect(
      stops.map(\.id) == [
        "5E39F336-E93A-CF27-9367B418989B2845", "5E3C3703-DE8D-476F-E90146C657826FC9",
      ])
    for stop in stops {
      #expect(stop.significance == "")
      #expect(stop.directionsToNextStop == "")
      #expect(stop.audioTranscript == "")
      #expect(stop.audioFileUrl == "")
    }
  }

  @Test("Recorded search results preserve provider values")
  func recordedSearchResultsPreserveProviderValues() throws {
    let page = try decode(.toursSearch)
    #expect(page.total == "1")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    let tour = try #require(page.data.first)
    #expect(page.data.count == 1)
    #expect(tour.id == "7F1D5880-0FE9-5B95-492B8497DB1992A1")
    #expect(tour.title == "Virtual Tour")
    #expect(tour.park?.parkCode == "foma")
    #expect(tour.park?.states == "FL")
    #expect(tour.tags == [])
    #expect(tour.activities == [])
    #expect(tour.topics == [])
    #expect(tour.durationMin == "1")
    #expect(tour.durationMax == "30")
    #expect(tour.relevanceScore == 19.48063)
    let stop = try #require(tour.stops?.first)
    #expect(tour.stops?.count == 1)
    #expect(stop.ordinal == "1")
    #expect(stop.assetName == "Fort Matanzas Virtual Tour")
    #expect(
      stop.significance == "This is a website link to a virtual tour experience of Fort Matanzas")
    #expect(
      stop.audioTranscript
        == "This is a website link to a virtual tour experience of Fort Matanzas")
    #expect(stop.audioFileUrl == "")
  }

  private func decode(_ fixture: Fixture) throws -> NPSCollection<Tour> {
    try JSONDecoder().decode(NPSCollection<Tour>.self, from: fixture.data())
  }
}
