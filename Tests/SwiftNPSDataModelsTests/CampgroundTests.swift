import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Campground models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct CampgroundTests {
  @Test("Constructed campgrounds decode with nulls and unknown fields")
  func constructedCampgroundsDecodeWithNullsAndUnknownFields() throws {
    // Constructed, not recorded: recorded campgrounds carry no nulls or multimedia entries.
    let json = Data(
      #"""
      {"id":"C1","name":"Example Campground","url":null,"parkCode":null,"description":null,
      "accessibility":{"rvAllowed":null,"accessRoads":null,"futureAccess":"1"},
      "amenities":{"showers":null,"laundry":null},"campsites":{"totalSites":null},
      "fees":[{"cost":null,"description":null,"title":null}],"regulationsurl":null,
      "isPassportStampLocation":null,"contacts":null,"relevanceScore":null,
      "futureField":{"nested":true},"multimedia":[{"id":"M1","title":"Tour","type":"video",
      "url":"https://www.nps.gov/media/video/view.htm?id=M1","extra":1},{"title":null}],
      "images":[{"url":"https://www.nps.gov/example.jpg","crops":null}],
      "passportStampImages":[{"title":"Stamp","crops":[{"aspectRatio":null,"url":null}]}]}
      """#.utf8)
    let campground = try JSONDecoder().decode(Campground.self, from: json)
    #expect(campground.id == "C1")
    #expect(campground.name == "Example Campground")
    #expect(campground.url == nil)
    #expect(campground.parkCode == nil)
    #expect(campground.description == nil)
    #expect(campground.accessibility?.rvAllowed == nil)
    #expect(campground.accessibility?.accessRoads == nil)
    #expect(campground.amenities?.showers == nil)
    #expect(campground.campsites?.totalSites == nil)
    #expect(campground.fees?.first?.cost == nil)
    #expect(campground.regulationsUrl == nil)
    #expect(campground.isPassportStampLocation == nil)
    #expect(campground.contacts == nil)
    #expect(campground.relevanceScore == nil)
    #expect(campground.addresses == nil)
    #expect(campground.operatingHours == nil)
    #expect(campground.reservationUrl == nil)
    let multimedia: [NPSMultimedia] = try #require(campground.multimedia)
    #expect(multimedia.count == 2)
    #expect(multimedia[0].id == "M1")
    #expect(multimedia[0].type == "video")
    #expect(multimedia[1].title == nil)
    #expect(campground.images?.first?.url == "https://www.nps.gov/example.jpg")
    #expect(campground.images?.first?.crops == nil)
    let crop = try #require(campground.passportStampImages?.first?.crops?.first)
    #expect(crop.aspectRatio == nil)
    #expect(crop.url == nil)
  }

  @Test("Missing identity or name fails to decode")
  func missingIdentityOrNameFailsToDecode() {
    // Constructed, not recorded: NPS campgrounds always carry an id and name.
    for body in [#"{"name":"Example Campground"}"#, #"{"id":"C1"}"#] {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(Campground.self, from: Data(body.utf8))
      }
    }
  }

  @Test("Parks, visitor centers, and campgrounds share detail types")
  func parksVisitorCentersAndCampgroundsShareDetailTypes() throws {
    let park = try #require(
      try JSONDecoder().decode(NPSCollection<Park>.self, from: Fixture.parksAcadia.data()).data
        .first)
    let center = try #require(
      try JSONDecoder().decode(
        NPSCollection<VisitorCenter>.self, from: Fixture.visitorCentersPageLast.data()
      ).data.first)
    let campground = try #require(try decode(.campgroundsPageLast).data.first)
    let fees: [[NPSFee]?] = [park.entranceFees, park.entrancePasses, campground.fees]
    let images: [[NPSImage]?] = [center.images, campground.images]
    let stamps: [[NPSPassportStampImage]?] = [
      center.passportStampImages, campground.passportStampImages,
    ]
    let addresses: [[NPSAddress]?] = [park.addresses, center.addresses, campground.addresses]
    #expect(fees.allSatisfy { $0?.isEmpty == false })
    #expect(images.allSatisfy { $0?.isEmpty == false })
    #expect(stamps.allSatisfy { $0?.isEmpty == false })
    #expect(addresses.allSatisfy { $0?.isEmpty == false })
    #expect(campground.fees?.first?.cost == "20.00")
    #expect(campground.fees?.first?.description == "Fee/per night\nmaximum number of people: 6")
    #expect(campground.images?.first?.credit == "Ashley L. Conti/Friends of Acadia")
    #expect(campground.passportStampImages?.first?.title == "Duck Harbor Stamp")
    #expect(campground.operatingHours == [])
    #expect(campground.weatherOverview == "")
  }

  @Test("Recorded campground pages decode with their envelopes")
  func recordedCampgroundPagesDecodeWithTheirEnvelopes() throws {
    let first = try decode(.campgroundsPageFirst)
    #expect(first.total == "4")
    #expect(first.limit == "1")
    #expect(first.start == "0")
    #expect(first.data.map(\.id) == ["6E127BF1-F2A9-4C59-90FA-C4BED53EA7F5"])
    #expect(first.data.map(\.name) == ["Blackwoods Campground"])
    let last = try decode(.campgroundsPageLast)
    #expect(last.start == "1")
    #expect(last.data.map(\.id) == ["C1388F86-68A9-4C1C-85C2-193CD4BD3EE1"])
    #expect(last.data.map(\.name) == ["Duck Harbor Campground"])
    let empty = try decode(.campgroundsEmpty)
    #expect(empty.total == "0")
    #expect(empty.data.isEmpty)
  }

  @Test("Recorded nested shapes preserve provider values")
  func recordedNestedShapesPreserveProviderValues() throws {
    let campground = try #require(try decode(.campgroundsPageFirst).data.first)
    #expect(campground.parkCode == "acad")
    #expect(campground.isPassportStampLocation == "1")
    #expect(campground.geometryPoiId == "")
    #expect(campground.latitude == "44.30894404258141")
    #expect(campground.latLong == "{lat:44.30894404258141, lng:-68.20988547018771}")
    #expect(campground.lastIndexedDate == "")
    #expect(campground.directionsUrl == "")
    #expect(campground.relevanceScore == 1.0)
    #expect(campground.multimedia == [])
    #expect(campground.numberOfSitesReservable == "281")
    #expect(campground.numberOfSitesFirstComeFirstServe == "0")
    #expect(campground.reservationUrl == "https://www.recreation.gov/camping/campgrounds/232508")
    #expect(campground.regulationsUrl == "https://www.recreation.gov/camping/campgrounds/232508")
    #expect(campground.regulationsOverview?.contains(#""Need to Know" section"#) == true)
    #expect(campground.directionsOverview?.contains("10'4\" or more") == true)

    let accessibility = try #require(campground.accessibility)
    #expect(accessibility.rvAllowed == "1")
    #expect(accessibility.rvMaxLength == "0")
    #expect(accessibility.trailerAllowed == "1")
    #expect(accessibility.internetInfo == "")
    #expect(accessibility.accessRoads == ["Paved Roads - All vehicles OK"])
    #expect(accessibility.classifications == ["Developed Campground"])

    let amenities = try #require(campground.amenities)
    #expect(amenities.amphitheater == "Yes - seasonal")
    #expect(amenities.campStore == "No")
    #expect(amenities.toilets == ["Flush Toilets - seasonal"])
    #expect(amenities.showers == ["None"])
    #expect(amenities.potableWater == ["Yes - seasonal"])

    let campsites = try #require(campground.campsites)
    #expect(campsites.totalSites == "281")
    #expect(campsites.group == "4")
    #expect(campsites.tentOnly == "221")
    #expect(campsites.rvOnly == "60")
    #expect(campsites.walkBoatTo == "0")

    let fees = try #require(campground.fees)
    #expect(fees.map(\.cost) == ["60.00", "30.00", "30.00"])
    #expect(fees.first?.title == "Group Tent Only Area - Non-electric")

    let physical = try #require(campground.addresses?.first)
    #expect(physical.city == "Otter Creek")
    #expect(physical.line1 == "155 Blackwoods Drive")
    #expect(physical.line2 == "")
    #expect(physical.postalCode == "04660")
    #expect(physical.type == "Physical")

    let contacts = try #require(campground.contacts)
    #expect(contacts.phoneNumbers?.map(\.phoneNumber) == ["207-288-3274"])
    #expect(contacts.phoneNumbers?.first?.extension == "")
    #expect(contacts.emailAddresses?.first?.emailAddress == "acadia_information@nps.gov")

    let hours = try #require(campground.operatingHours?.first)
    #expect(hours.name == "Blackwoods Campground")
    #expect(hours.standardHours?["monday"] == "All Day")
    let exception = try #require(hours.exceptions?.first)
    #expect(exception.name == "Off Season")
    #expect(exception.startDate == "2026-10-22")
    #expect(exception.endDate == "2027-05-02")
    #expect(exception.exceptionHours?["sunday"] == "Closed")

    let image = try #require(campground.images?.first)
    #expect(campground.images?.count == 3)
    #expect(image.title == "Blackwoods Campground Ranger Station")
    #expect(image.credit == "NPS Photo")
    #expect(image.caption == "")
    #expect(image.crops == [])

    let stamp = try #require(campground.passportStampImages?.first)
    #expect(stamp.title == "Blackwoods Campground Stamp")
    #expect(stamp.altText == "Text: Acadia National Park, Blackwoods Campground")
    #expect(stamp.credit == "")
    #expect(stamp.description == "")
    let crop = try #require(stamp.crops?.first)
    #expect(crop.aspectRatio == 1.0)
    #expect(
      crop.url
        == "https://www.nps.gov/common/uploads/passport_stamps/primary/"
        + "A2BAC13F-D52B-2CD7-2D0F9D14779DF060.jpeg")
  }

  @Test("Recorded search results preserve provider values")
  func recordedSearchResultsPreserveProviderValues() throws {
    let page = try decode(.campgroundsSearch)
    #expect(page.total == "26")
    #expect(page.limit == "2")
    #expect(page.data.count == 2)
    let afterbay = page.data[0]
    #expect(afterbay.id == "4F9ED6A5-3ED1-443D-9E4C-859D7988F199")
    #expect(afterbay.name == "Afterbay Campground")
    #expect(afterbay.parkCode == "bica")
    #expect(afterbay.isPassportStampLocation == "0")
    #expect(afterbay.relevanceScore == 2.3048844)
    #expect(afterbay.fees == [])
    #expect(afterbay.passportStampImages == [])
    #expect(afterbay.reservationUrl == "")
    #expect(afterbay.regulationsUrl == "")
    #expect(afterbay.audioDescription == "")
    #expect(afterbay.campsites?.electricalHookups == "22")
    #expect(afterbay.addresses?.first?.city == "Fort Smith")
    #expect(afterbay.addresses?.first?.stateCode == "MT")
    #expect(afterbay.addresses?.first?.line2 == "Rte 200")
    #expect(afterbay.contacts?.phoneNumbers?.map(\.type) == ["Voice", "Fax"])
    #expect(afterbay.operatingHours?.first?.exceptions == [])
    let barrys = page.data[1]
    #expect(barrys.id == "4EAF0F61-6361-4CAC-BB23-F93C5CF4A8E2")
    #expect(barrys.name == "Barry's Landing & Trail Creek Campground")
    #expect(barrys.relevanceScore == 1.0050298)
    #expect(barrys.numberOfSitesFirstComeFirstServe == "30")
    let campgroundsSearchJSON = try #require(
      JSONSerialization.jsonObject(with: Fixture.campgroundsSearch.data()) as? [String: Any])
    let campgroundsSearchEntries = try #require(campgroundsSearchJSON["data"] as? [[String: Any]])
    let barrysEntry = try #require(
      campgroundsSearchEntries.first { $0["id"] as? String == barrys.id }
    )
    let expectedReservationUrl = try #require(barrysEntry["reservationUrl"] as? String)
    #expect(barrys.reservationUrl == expectedReservationUrl)
    #expect(barrys.amenities?.potableWater == ["No water"])
    #expect(barrys.contacts?.phoneNumbers?.last?.type == "TTY")
  }

  private func decode(_ fixture: Fixture) throws -> NPSCollection<Campground> {
    try JSONDecoder().decode(NPSCollection<Campground>.self, from: fixture.data())
  }
}
