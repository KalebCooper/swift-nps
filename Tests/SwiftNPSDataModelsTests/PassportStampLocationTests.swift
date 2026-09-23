import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Passport stamp locations", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct PassportStampLocationTests {
  @Test("The recorded search page decodes every location and park field as sent")
  func theRecordedSearchPageDecodesEveryLocationAndParkFieldAsSent() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<PassportStampLocation>.self, from: Fixture.passportStampLocationsSearch.data())
    #expect(page.total == "3")
    #expect(page.limit == "3")
    #expect(page.start == "0")
    #expect(page.data.count == 3)
    let bethune = try #require(page.data.first)
    #expect(bethune.id == "37139FC2-8292-4A60-95E7-26178E03C2D2")
    #expect(bethune.label == "Mary McLeod Bethune Council House National Historic Site")
    #expect(bethune.type == "visitorcenters")
    let bethunePark = try #require(bethune.parks?.first)
    #expect(bethune.parks?.count == 1)
    #expect(bethunePark.designation == "National Historic Site\r\n")
    #expect(bethunePark.fullName == "Mary McLeod Bethune Council House National Historic Site")
    #expect(bethunePark.name == "Mary McLeod Bethune Council House")
    #expect(bethunePark.parkCode == "mamc")
    #expect(bethunePark.states == "DC")
    #expect(bethunePark.url == "https://www.nps.gov/mamc/index.htm")
    let ruins = try #require(page.data.last)
    #expect(ruins.id == "44D6BE84-330B-493C-A1F6-A592497ACA6E")
    #expect(ruins.label == "Casa Grande Ruins")
    #expect(ruins.type == "places")
    let parks = try #require(ruins.parks)
    #expect(parks.map(\.parkCode) == ["cagr", "juba"])
    let trail = try #require(parks.last)
    #expect(trail.designation == "National Historic Trail")
    #expect(trail.fullName == "Juan Bautista de Anza National Historic Trail")
    #expect(trail.name == "Juan Bautista de Anza")
    #expect(trail.states == "AZ,CA")
    #expect(trail.url == "https://www.nps.gov/juba/index.htm")
  }

  @Test("The recorded pages decode one location each in descending label order")
  func theRecordedPagesDecodeOneLocationEachInDescendingLabelOrder() throws {
    let first = try JSONDecoder().decode(
      NPSCollection<PassportStampLocation>.self,
      from: Fixture.passportStampLocationsPageFirst.data())
    let last = try JSONDecoder().decode(
      NPSCollection<PassportStampLocation>.self,
      from: Fixture.passportStampLocationsPageLast.data())
    #expect(first.total == "2")
    #expect(first.start == "0")
    #expect(last.start == "1")
    #expect(first.data.map(\.label) == ["Visitor Center"])
    #expect(first.data.map(\.type) == ["visitorcenters"])
    #expect(last.data.map(\.label) == ["Camp Misty Mount"])
    #expect(last.data.map(\.type) == ["campgrounds"])
    #expect(last.data.first?.id == "9EE76DDC-80AB-4283-BCE9-F85952ED03E1")
    for location in first.data + last.data {
      #expect(location.parks?.map(\.parkCode) == ["cato"])
    }
  }

  @Test("The recorded empty page decodes with no locations")
  func theRecordedEmptyPageDecodesWithNoLocations() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<PassportStampLocation>.self, from: Fixture.passportStampLocationsEmpty.data())
    #expect(page.total == "0")
    #expect(page.data.isEmpty)
  }

  @Test("An empty parks array stays empty and an unknown type passes through")
  func anEmptyParksArrayStaysEmptyAndAnUnknownTypePassesThrough() throws {
    let json = #"{"id":"A1","label":"Thurmond","parks":[],"type":"futureKind"}"#
    let location = try JSONDecoder().decode(PassportStampLocation.self, from: Data(json.utf8))
    #expect(location.parks == [])
    #expect(location.type == "futureKind")
  }

  @Test(
    "Missing or null parks and type decode as nil",
    arguments: [
      #"{"id":"A1","label":"Thurmond"}"#,
      #"{"id":"A1","label":"Thurmond","parks":null,"type":null}"#,
    ])
  func missingOrNullParksAndTypeDecodeAsNil(_ json: String) throws {
    let location = try JSONDecoder().decode(PassportStampLocation.self, from: Data(json.utf8))
    #expect(location.id == "A1")
    #expect(location.label == "Thurmond")
    #expect(location.parks == nil)
    #expect(location.type == nil)
  }
}
