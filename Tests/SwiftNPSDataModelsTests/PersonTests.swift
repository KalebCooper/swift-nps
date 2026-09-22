import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("People models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct PersonTests {
  @Test("Constructed people decode with nulls and unknown fields")
  func constructedPeopleDecodeWithNullsAndUnknownFields() throws {
    // Constructed, not recorded: recorded people send every key and no null text.
    let json = Data(
      #"""
      {"id":"P1","title":"Example Person","url":null,"listingDescription":null,"images":null,
      "relatedParks":[{"parkCode":null,"extra":1}],"relatedOrganizations":null,"tags":null,
      "latitude":null,"longitude":null,"latLong":null,"bodyText":null,"geometryPoiId":null,
      "firstName":null,"middleName":null,"lastName":null,"quickFacts":[{"id":null}],
      "credit":null,"futureField":{"nested":true}}
      """#.utf8)
    let person = try JSONDecoder().decode(Person.self, from: json)
    #expect(person.id == "P1")
    #expect(person.title == "Example Person")
    #expect(person.bodyText == nil)
    #expect(person.credit == nil)
    #expect(person.firstName == nil)
    #expect(person.geometryPoiId == nil)
    #expect(person.images == nil)
    #expect(person.lastName == nil)
    #expect(person.latitude == nil)
    #expect(person.latLong == nil)
    #expect(person.listingDescription == nil)
    #expect(person.longitude == nil)
    #expect(person.middleName == nil)
    #expect(person.quickFacts?.count == 1)
    #expect(person.quickFacts?.first?.id == nil)
    #expect(person.quickFacts?.first?.name == nil)
    #expect(person.quickFacts?.first?.value == nil)
    #expect(person.relatedOrganizations == nil)
    #expect(person.relatedParks?.first?.parkCode == nil)
    #expect(person.tags == nil)
    #expect(person.url == nil)
  }

  @Test("Missing identity or title fails to decode")
  func missingIdentityOrTitleFailsToDecode() {
    // Constructed, not recorded: NPS people always carry an id and title.
    for body in [#"{"title":"Example Person"}"#, #"{"id":"P1"}"#] {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(Person.self, from: Data(body.utf8))
      }
    }
  }

  @Test("Person coordinates keep their JSON string type")
  func personCoordinatesKeepTheirJSONStringType() {
    // Constructed, not recorded: the provider sends text, never a JSON number.
    for body in [
      #"{"id":"P1","title":"T","latitude":42.3}"#,
      #"{"id":"P1","title":"T","longitude":-71.1}"#,
    ] {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(Person.self, from: Data(body.utf8))
      }
    }
  }

  @Test("Recorded people pages decode with their envelopes")
  func recordedPeoplePagesDecodeWithTheirEnvelopes() throws {
    let first = try decode(.peoplePageFirst)
    #expect(first.total == "4")
    #expect(first.limit == "1")
    #expect(first.start == "0")
    #expect(first.data.map(\.id) == ["3F32B2C5-D4DB-43DA-93C6-E7D7F9419A3C"])
    #expect(first.data.map(\.title) == ["Thomas Moran"])
    let last = try decode(.peoplePageLast)
    #expect(last.total == "4")
    #expect(last.start == "1")
    #expect(last.data.map(\.id) == ["93643143-6594-4410-B0BF-0B15D85F4B59"])
    #expect(last.data.map(\.title) == ["Horace M. Albright"])
    let empty = try decode(.peopleEmpty)
    #expect(empty.total == "0")
    #expect(empty.data.isEmpty)
  }

  @Test("Recorded names, HTML, quick facts, and empty coordinates are kept as sent")
  func recordedNamesHTMLQuickFactsAndEmptyCoordinatesAreKeptAsSent() throws {
    let moran = try #require(try decode(.peoplePageFirst).data.first)
    #expect(moran.url == "https://www.nps.gov/people/thomas-moran.htm")
    #expect(moran.firstName == "Thomas")
    #expect(moran.middleName == "")
    #expect(moran.lastName == "Moran")
    #expect(moran.latitude == "")
    #expect(moran.longitude == "")
    #expect(moran.latLong == "")
    #expect(moran.geometryPoiId == "")
    #expect(moran.credit == "")
    #expect(moran.relatedOrganizations == [])
    #expect(moran.tags?.count == 8)
    #expect(moran.tags?.first == "Conservation")
    let body = try #require(moran.bodyText)
    #expect(body.hasPrefix("<p>Thomas Moran was born in Lancashire, England, to two hand"))
    #expect(body.hasSuffix("ted to New York, where he is buried.</p>"))
    #expect(body.unicodeScalars.count == 2609)
    #expect(moran.quickFacts?.count == 7)
    let fact = try #require(moran.quickFacts?.first)
    #expect(fact.id == "F7A67C96-173F-4675-B374-7E3D3A1818B2")
    #expect(fact.name == "Significance")
    #expect(fact.value == "Hudson River School painter, Hayden Geological Survey member")
    #expect(moran.quickFacts?.last?.name == "Cemetery Name")
    #expect(moran.quickFacts?.last?.value == "South End Cemetery")
    let image = try #require(moran.images?.first)
    #expect(moran.images?.count == 1)
    #expect(
      image.url
        == "https://www.nps.gov/common/uploads/people/nri/20180509/people/"
        + "C049E92F-1DD8-B71B-0BAF9958186F054C/C049E92F-1DD8-B71B-0BAF9958186F054C.jpg")
    #expect(
      image.credit == "Napoleon Sarony, photographer, ca 1890-96, from the Library of Congress")
    #expect(image.caption == "Thomas Moran")
    #expect(image.crops == [])
    #expect(image.description == "")
    #expect(image.title == "")
    let park = try #require(moran.relatedParks?.first)
    #expect(moran.relatedParks?.count == 1)
    #expect(park.designation == "National Park")
    #expect(park.fullName == "Yellowstone National Park")
    #expect(park.parkCode == "yell")
    #expect(park.states == "ID,MT,WY")
  }

  @Test("Recorded related organizations and middle names are kept as sent")
  func recordedRelatedOrganizationsAndMiddleNamesAreKeptAsSent() throws {
    let albright = try #require(try decode(.peoplePageLast).data.first)
    #expect(albright.firstName == "Horace")
    #expect(albright.middleName == "Marden")
    #expect(albright.lastName == "Albright")
    let organization = try #require(albright.relatedOrganizations?.first)
    #expect(albright.relatedOrganizations?.count == 1)
    #expect(organization.id == "C8DBBEFF-B534-4D31-8D1E-B49E65449EBB")
    #expect(organization.name == "Director")
    #expect(organization.url == "")
    #expect(albright.bodyText?.hasPrefix("<h3>At a Glance</h3> <ul> <li>") == true)
    // The provider's text omits a space after the comma; it is not reformatted.
    #expect(albright.quickFacts?.map(\.value).contains("January 6,1890") == true)
  }

  @Test("Recorded search results keep decimal coordinate text and string crop ratios")
  func recordedSearchResultsKeepDecimalCoordinateTextAndStringCropRatios() throws {
    let page = try decode(.peopleSearch)
    #expect(page.total == "30")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    #expect(page.data.map(\.title) == ["John Olmsted", "Marion Olmsted"])
    let john = try #require(page.data.first)
    #expect(john.latitude == "42.32527319611405")
    #expect(john.longitude == "-71.13226890563965")
    #expect(john.latLong == "{lat:42.32527319611405, long:-71.13226890563965}")
    #expect(john.relatedParks?.map(\.parkCode) == ["frla"])
    #expect(john.relatedParks?.map(\.states) == ["MA"])
    let crops = try #require(john.images?.first?.crops)
    #expect(crops.map(\.aspectRatio) == ["0.8", "1"])
    #expect(crops.map(\.ratio) == [0.8, 1])
    #expect(
      crops.first?.url
        == "https://www.nps.gov/common/uploads/cropped_image/primary/"
        + "8CC36779-99BD-DD8E-A6C199A26CF2AC68.jpg")
    let marion = try #require(page.data.last)
    #expect(marion.latitude == "42.32528906050197")
    #expect(marion.longitude == "-71.13230645656586")
    #expect(marion.quickFacts?.map(\.name) == ["Date of Birth", "Date of Death"])
    #expect(marion.quickFacts?.map(\.value) == ["October 28, 1861", "May 29, 1948"])
    #expect(marion.bodyText?.hasPrefix("Born October 28, 1861, Marion Olmsted was") == true)
  }

  private func decode(_ fixture: Fixture) throws -> NPSCollection<Person> {
    try JSONDecoder().decode(NPSCollection<Person>.self, from: fixture.data())
  }
}
