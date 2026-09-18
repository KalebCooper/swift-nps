import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Things to do models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ThingToDoTests {
  @Test("Constructed things to do decode with nulls and unknown fields")
  func constructedThingsToDoDecodeWithNullsAndUnknownFields() throws {
    // Constructed, not recorded: recorded things to do carry no nulls or populated organizations.
    let json = Data(
      #"""
      {"id":"T1","title":"Example Hike","url":null,"duration":null,"isReservationRequired":null,
      "relevanceScore":null,"tags":null,"season":null,"activities":[{"id":null,"name":null}],
      "relatedParks":[{"parkCode":null,"states":null,"extra":1}],
      "relatedOrganizations":[{"name":"Friends"}],"amenities":[{"id":"A1"}],
      "images":[{"url":"https://www.nps.gov/example.jpg","crops":[{"aspectRatio":null,"url":null}],
      "description":null}],"futureField":{"nested":true}}
      """#.utf8)
    let thing = try JSONDecoder().decode(ThingToDo.self, from: json)
    #expect(thing.id == "T1")
    #expect(thing.title == "Example Hike")
    #expect(thing.url == nil)
    #expect(thing.duration == nil)
    #expect(thing.isReservationRequired == nil)
    #expect(thing.relevanceScore == nil)
    #expect(thing.tags == nil)
    #expect(thing.season == nil)
    #expect(thing.timeOfDay == nil)
    #expect(thing.topics == nil)
    #expect(thing.activities?.count == 1)
    #expect(thing.activities?.first?.id == nil)
    #expect(thing.activities?.first?.name == nil)
    #expect(thing.relatedParks?.first?.parkCode == nil)
    #expect(thing.relatedParks?.first?.states == nil)
    let image = try #require(thing.images?.first)
    #expect(image.url == "https://www.nps.gov/example.jpg")
    #expect(image.description == nil)
    #expect(image.crops?.first?.aspectRatio == nil)
    #expect(image.crops?.first?.url == nil)
  }

  @Test("Missing identity or title fails to decode")
  func missingIdentityOrTitleFailsToDecode() {
    // Constructed, not recorded: NPS things to do always carry an id and title.
    for body in [#"{"title":"Example Hike"}"#, #"{"id":"T1"}"#] {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(ThingToDo.self, from: Data(body.utf8))
      }
    }
  }

  @Test("Parks and things to do share activity and topic types")
  func parksAndThingsToDoShareActivityAndTopicTypes() throws {
    let park = try #require(
      try JSONDecoder().decode(NPSCollection<Park>.self, from: Fixture.parksAcadia.data()).data
        .first)
    let thing = try #require(try decode(.thingsToDoPageFirst).data.first)
    let named: [[NPSNamedItem]?] = [park.activities, park.topics, thing.activities, thing.topics]
    #expect(named.allSatisfy { $0?.isEmpty == false })
    #expect(park.activities?.first?.id == "09DF0950-D319-4557-A57E-04CD2F63FF42")
    #expect(park.activities?.first?.name == "Arts and Culture")
    #expect(park.topics?.first?.name == "Arts")
    #expect(thing.activities?.map(\.id) == ["7CE6E935-F839-4FEC-A63E-052B1DEF39D2"])
    #expect(thing.activities?.map(\.name) == ["Biking"])
  }

  @Test("Recorded nested shapes preserve provider values")
  func recordedNestedShapesPreserveProviderValues() throws {
    let thing = try #require(try decode(.thingsToDoPageFirst).data.first)
    #expect(thing.url == "https://www.nps.gov/thingstodo/bike-carriage-roads.htm")
    #expect(
      thing.shortDescription
        == "Winding through the heart of the park, the\u{00A0}45 miles of historic carriage"
        + " roads\u{00A0}have crushed rock surfaces perfect for miles of bicycling.")
    #expect(thing.location == "Carriage Roads (throughout Acadia National Park)")
    #expect(thing.isReservationRequired == "false")
    #expect(thing.arePetsPermitted == "true")
    #expect(thing.arePetsPermittedWithRestrictions == "true")
    #expect(thing.doFeesApply == "false")
    #expect(thing.latitude == "")
    #expect(thing.longitude == "")
    #expect(thing.geometryPoiId == "")
    #expect(thing.duration == "")
    #expect(thing.credit == "")
    #expect(thing.reservationDescription == "")
    #expect(thing.relevanceScore == 1.0)
    #expect(thing.season == ["Winter", "Spring", "Summer", "Fall"])
    #expect(thing.timeOfDay == ["Day", "Dawn", "Dusk"])
    #expect(thing.tags?.first == "Acadia National Park")
    #expect(thing.tags?.count == 10)
    #expect(thing.longDescription?.contains("Rockefeller\u{2019}s teeth.\u{201D}") == true)
    #expect(
      thing.topics?.map(\.name) == ["Landscape Design", "Roads, Routes and Highways"])

    let park = try #require(thing.relatedParks?.first)
    #expect(thing.relatedParks?.count == 1)
    #expect(park.designation == "National Park")
    #expect(park.fullName == "Acadia National Park")
    #expect(park.name == "Acadia")
    #expect(park.parkCode == "acad")
    #expect(park.states == "ME")
    #expect(park.url == "https://www.nps.gov/acad/index.htm")

    let image = try #require(thing.images?.first)
    #expect(thing.images?.count == 1)
    #expect(image.title == "Duck Brook Carriage Road")
    #expect(image.credit == "NPS Photo/Kent Miller")
    #expect(image.altText == "Two people with bicycles looking over a ledge on a bridge")
    #expect(image.caption == "Bicyclists can enjoy 45 miles of carriage roads across the park")
    #expect(image.description == "")
    #expect(image.crops?.map(\.aspectRatio) == ["1.78", "1"])
    #expect(
      image.crops?.first?.url
        == "https://www.nps.gov/common/uploads/cropped_image/primary/"
        + "BAEBFEB5-9A86-4910-87CA94CA57BEB6C0.jpg")
  }

  @Test("Recorded search results preserve provider values")
  func recordedSearchResultsPreserveProviderValues() throws {
    let page = try decode(.thingsToDoSearch)
    #expect(page.total == "75")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    #expect(page.data.count == 2)
    let bubbles = page.data[0]
    #expect(bubbles.id == "51F69951-0A1B-4D54-AEAC-499B53C8A31F")
    #expect(bubbles.title == "Hike Bubbles")
    #expect(bubbles.relevanceScore == 13.626645)
    #expect(bubbles.duration == "60-90 Minutes")
    #expect(bubbles.location == "The Bubbles")
    #expect(bubbles.season == ["Spring", "Summer", "Fall"])
    #expect(bubbles.images?.first?.crops?.map(\.aspectRatio) == ["3", "1"])
    #expect(bubbles.images?.first?.title == "")
    let beachcroft = page.data[1]
    #expect(beachcroft.id == "E6CE83A1-421D-4B0C-9404-782FCD87228F")
    #expect(beachcroft.title == "Hike Beachcroft Path")
    #expect(beachcroft.relevanceScore == 12.141288)
    #expect(beachcroft.latitude == "44.3585023529493")
    #expect(beachcroft.longitude == "-68.2059851525353")
    #expect(beachcroft.duration == "1-2 Hours")
    #expect(beachcroft.activities?.map(\.id) == ["BFF8C027-7C8F-480B-A5F8-CD8CE490BFBA"])
    #expect(beachcroft.activities?.map(\.name) == ["Hiking"])
  }

  @Test("Recorded things to do pages decode with their envelopes")
  func recordedThingsToDoPagesDecodeWithTheirEnvelopes() throws {
    let first = try decode(.thingsToDoPageFirst)
    #expect(first.total == "89")
    #expect(first.limit == "1")
    #expect(first.start == "0")
    #expect(first.data.map(\.id) == ["C54D2783-6F50-4E03-9010-FCDA5C31EE91"])
    #expect(first.data.map(\.title) == ["Bike Carriage Roads"])
    let last = try decode(.thingsToDoPageLast)
    #expect(last.start == "1")
    #expect(last.data.map(\.id) == ["4B233E13-4DDF-4A74-B6F1-2F5FCBDE143C"])
    #expect(last.data.map(\.title) == [#"Birding "with" the Champlain Society"#])
    #expect(last.data.first?.activities?.map(\.name) == ["Birdwatching"])
    let empty = try decode(.thingsToDoEmpty)
    #expect(empty.total == "0")
    #expect(empty.data.isEmpty)
  }

  private func decode(_ fixture: Fixture) throws -> NPSCollection<ThingToDo> {
    try JSONDecoder().decode(NPSCollection<ThingToDo>.self, from: fixture.data())
  }
}
