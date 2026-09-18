import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Visitor center models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct VisitorCenterTests {
  @Test("Constructed visitor centers decode with nulls and unknown fields")
  func constructedVisitorCentersDecodeWithNullsAndUnknownFields() throws {
    // Constructed, not recorded: recorded visitor centers carry no nulls or multimedia entries.
    let json = Data(
      #"""
      {"id":"V1","name":"Example Center","url":null,"parkCode":null,"description":null,
      "isPassportStampLocation":null,"amenities":null,"contacts":null,"relevanceScore":null,
      "futureField":{"nested":true},"multimedia":[{"id":"M1","title":"Tour","type":"video",
      "url":"https://www.nps.gov/media/video/view.htm?id=M1","extra":1},{"title":null}],
      "images":[{"url":"https://www.nps.gov/example.jpg","crops":null}],
      "passportStampImages":[{"title":"Stamp","crops":[{"aspectRatio":null,"url":null}]}]}
      """#.utf8)
    let center = try JSONDecoder().decode(VisitorCenter.self, from: json)
    #expect(center.id == "V1")
    #expect(center.name == "Example Center")
    #expect(center.url == nil)
    #expect(center.parkCode == nil)
    #expect(center.description == nil)
    #expect(center.isPassportStampLocation == nil)
    #expect(center.amenities == nil)
    #expect(center.contacts == nil)
    #expect(center.relevanceScore == nil)
    #expect(center.addresses == nil)
    #expect(center.operatingHours == nil)
    let multimedia: [NPSMultimedia] = try #require(center.multimedia)
    #expect(multimedia.count == 2)
    #expect(multimedia[0].id == "M1")
    #expect(multimedia[0].title == "Tour")
    #expect(multimedia[0].type == "video")
    #expect(multimedia[0].url == "https://www.nps.gov/media/video/view.htm?id=M1")
    #expect(multimedia[1].id == nil)
    #expect(multimedia[1].title == nil)
    #expect(center.images?.first?.url == "https://www.nps.gov/example.jpg")
    #expect(center.images?.first?.crops == nil)
    let crop = try #require(center.passportStampImages?.first?.crops?.first)
    #expect(crop.aspectRatio == nil)
    #expect(crop.url == nil)
  }

  @Test("Missing identity or name fails to decode")
  func missingIdentityOrNameFailsToDecode() {
    // Constructed, not recorded: NPS visitor centers always carry an id and name.
    for body in [#"{"name":"Example Center"}"#, #"{"id":"V1"}"#] {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(VisitorCenter.self, from: Data(body.utf8))
      }
    }
  }

  @Test("Recorded visitor center pages decode with their envelopes")
  func recordedVisitorCenterPagesDecodeWithTheirEnvelopes() throws {
    let first = try decode(.visitorCentersPageFirst)
    #expect(first.total == "6")
    #expect(first.limit == "1")
    #expect(first.start == "0")
    #expect(first.data.map(\.id) == ["99B33FA9-2579-415C-B2C7-2A29879744F8"])
    #expect(first.data.map(\.name) == ["Acadia Gateway Center"])
    let last = try decode(.visitorCentersPageLast)
    #expect(last.start == "1")
    #expect(last.data.map(\.id) == ["2DC6EAAC-3718-4438-9630-85E55A3DA496"])
    #expect(last.data.map(\.name) == ["Hulls Cove Visitor Center"])
    let empty = try decode(.visitorCentersEmpty)
    #expect(empty.total == "0")
    #expect(empty.data.isEmpty)
  }

  @Test("Recorded nested shapes preserve provider values")
  func recordedNestedShapesPreserveProviderValues() throws {
    let center = try #require(try decode(.visitorCentersPageLast).data.first)
    #expect(center.parkCode == "acad")
    #expect(center.isPassportStampLocation == "1")
    #expect(
      center.passportStampLocationDescription == "Text: Acadia National Park, Bar Harbor, Maine")
    #expect(center.geometryPoiId == "F96FB9D2-861E-5C17-A0A0-5C6A13ABC159")
    #expect(center.latitude == "44.4085418988")
    #expect(center.latLong == "{lat:44.4085418988, lng:-68.2461366995}")
    #expect(center.lastIndexedDate == "")
    #expect(center.audioDescription == "")
    #expect(center.relevanceScore == 1.0)
    #expect(center.multimedia == [])
    #expect(center.description?.contains("Acadia\u{2019}s main visitor contact station") == true)
    #expect(center.amenities?.count == 17)
    #expect(center.amenities?.first == "Automated Entrance")
    #expect(center.amenities?.last == "Wheelchair Accessible")

    let physical = try #require(center.addresses?.first)
    #expect(physical.city == "Bar Harbor")
    #expect(physical.countryCode == "US")
    #expect(physical.line1 == "25 Visitor Center Road")
    #expect(physical.line2 == "")
    #expect(physical.line3 == "")
    #expect(physical.postalCode == "04609")
    #expect(physical.provinceTerritoryCode == "")
    #expect(physical.stateCode == "ME")
    #expect(physical.type == "Physical")

    let contacts = try #require(center.contacts)
    #expect(contacts.phoneNumbers?.map(\.phoneNumber) == ["2072883338", "2072888800"])
    #expect(contacts.phoneNumbers?.map(\.type) == ["Voice", "TTY"])
    #expect(contacts.phoneNumbers?.first?.extension == "")
    #expect(contacts.emailAddresses?.first?.emailAddress == "acadia_information@nps.gov")
    #expect(
      contacts.emailAddresses?.first?.description == "This email is for general park inquiries.")

    let hours = try #require(center.operatingHours?.first)
    #expect(hours.name == "Hulls Cove Visitor Center")
    #expect(hours.standardHours?["monday"] == "8:30AM - 4:30PM")
    let exception = try #require(hours.exceptions?.first)
    #expect(exception.name == "Winter closure")
    #expect(exception.startDate == "2026-11-01")
    #expect(exception.endDate == "2027-04-30")
    #expect(exception.exceptionHours?["sunday"] == "Closed")

    let image = try #require(center.images?.first)
    #expect(image.title == "Information pavlion")
    #expect(image.credit == "NPS Photo")
    #expect(image.crops == [])
    #expect(
      image.url
        == "https://www.nps.gov/common/uploads/structured_data/74BB868B-FD73-480F-995ADD559080E7DD.jpg"
    )

    let stamp = try #require(center.passportStampImages?.first)
    #expect(stamp.title == "Bar Harbor Stamp")
    #expect(stamp.altText == "Text: Acadia National Park, Bar Harbor, Maine")
    #expect(stamp.credit == "")
    #expect(stamp.caption == "")
    #expect(stamp.description == "")
    #expect(
      stamp.url
        == "https://www.nps.gov/common/uploads/passport_stamps/A9AB785F-C6A1-6E84-86ABC93D2D3DB797.jpeg"
    )
    let crop = try #require(stamp.crops?.first)
    #expect(crop.aspectRatio == 1.0)
    #expect(
      crop.url
        == "https://www.nps.gov/common/uploads/passport_stamps/primary/"
        + "A9AB785F-C6A1-6E84-86ABC93D2D3DB797.jpeg")
  }

  @Test("Recorded search results preserve provider values")
  func recordedSearchResultsPreserveProviderValues() throws {
    let page = try decode(.visitorCentersSearch)
    #expect(page.total == "9")
    #expect(page.limit == "2")
    #expect(page.data.count == 2)
    let allagash = page.data[0]
    #expect(allagash.id == "88AB3CC6-6CC5-4C62-BAC7-452F632E9177")
    #expect(allagash.name == "Allagash Historical Society/Museum")
    #expect(allagash.parkCode == "maac")
    #expect(allagash.url == "")
    #expect(allagash.isPassportStampLocation == "0")
    #expect(allagash.relevanceScore == 12.067375)
    #expect(allagash.addresses == [])
    #expect(allagash.images == [])
    #expect(allagash.contacts?.phoneNumbers == [])
    #expect(allagash.contacts?.emailAddresses == [])
    #expect(allagash.operatingHours?.first?.exceptions == [])
    #expect(allagash.operatingHours?.first?.standardHours?["sunday"] == "12:00PM - 5:00PM")
    let montCarmel = page.data[1]
    #expect(montCarmel.id == "984C08FB-AF5E-4BD3-BE9A-7F7A8DAF5C1E")
    #expect(montCarmel.name == "Association Culturelle et Historique du Mont-Carmel")
    #expect(montCarmel.relevanceScore == 3.87362)
    #expect(montCarmel.description?.hasPrefix("Mus\u{E9}e Culturel du Mont-Carmel") == true)
    #expect(montCarmel.contacts?.phoneNumbers?.first?.phoneNumber == "207-895-3339")
    #expect(montCarmel.addresses?.map(\.type) == ["Physical", "Mailing"])
    #expect(montCarmel.addresses?.first?.city == "Grand Isle")
  }

  @Test("Parks and visitor centers share address, contact, and hours types")
  func parksAndVisitorCentersShareAddressContactAndHoursTypes() throws {
    let park = try #require(
      try JSONDecoder().decode(NPSCollection<Park>.self, from: Fixture.parksAcadia.data()).data
        .first)
    let center = try #require(try decode(.visitorCentersPageLast).data.first)
    let addresses: [[NPSAddress]?] = [park.addresses, center.addresses]
    let contacts: [NPSContacts?] = [park.contacts, center.contacts]
    let hours: [[NPSOperatingHours]?] = [park.operatingHours, center.operatingHours]
    #expect(addresses.allSatisfy { $0?.isEmpty == false })
    #expect(contacts.allSatisfy { $0?.phoneNumbers?.isEmpty == false })
    #expect(hours.allSatisfy { $0?.isEmpty == false })
    #expect(park.addresses?.first?.postalCode == center.addresses?.first?.postalCode)
  }

  private func decode(_ fixture: Fixture) throws -> NPSCollection<VisitorCenter> {
    try JSONDecoder().decode(NPSCollection<VisitorCenter>.self, from: fixture.data())
  }
}
