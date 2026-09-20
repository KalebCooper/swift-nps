import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Places models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct PlaceTests {
  @Test("Constructed places decode with nulls and unknown fields")
  func constructedPlacesDecodeWithNullsAndUnknownFields() throws {
    // Constructed, not recorded: recorded places carry no nulls and no related organizations.
    let json = Data(
      #"""
      {"id":"P1","title":"Example Place","url":null,"amenities":null,"bodyText":null,
      "isOpenToPublic":null,"latLong":null,"latitude":null,"longitude":null,"relevanceScore":null,
      "tags":null,"quickFacts":[{"id":null,"name":null,"value":null}],
      "relatedOrganizations":[{"name":"Friends"}],"relatedParks":[{"parkCode":null,"extra":1}],
      "multimedia":[{"type":"webcam"}],"passportStampImages":[{"url":null,"crops":null}],
      "images":[{"url":"https://www.nps.gov/example.jpg","crops":[{"aspectRatio":null}]}],
      "futureField":{"nested":true}}
      """#.utf8)
    let place = try JSONDecoder().decode(Place.self, from: json)
    #expect(place.id == "P1")
    #expect(place.title == "Example Place")
    #expect(place.url == nil)
    #expect(place.amenities == nil)
    #expect(place.bodyText == nil)
    #expect(place.isOpenToPublic == nil)
    #expect(place.latLong == nil)
    #expect(place.latitude == nil)
    #expect(place.longitude == nil)
    #expect(place.relevanceScore == nil)
    #expect(place.tags == nil)
    #expect(place.associatedIcon == nil)
    #expect(place.listingDescription == nil)
    #expect(place.npmapId == nil)
    #expect(place.quickFacts?.first?.id == nil)
    #expect(place.quickFacts?.first?.name == nil)
    #expect(place.quickFacts?.first?.value == nil)
    #expect(place.relatedOrganizations?.map(\.name) == ["Friends"])
    #expect(place.relatedParks?.first?.parkCode == nil)
    #expect(place.multimedia?.map(\.type) == ["webcam"])
    #expect(place.passportStampImages?.first?.crops == nil)
    let image = try #require(place.images?.first)
    #expect(image.url == "https://www.nps.gov/example.jpg")
    #expect(image.description == nil)
    #expect(image.crops?.first?.aspectRatio == nil)
  }

  @Test("Missing identity or title fails to decode")
  func missingIdentityOrTitleFailsToDecode() {
    // Constructed, not recorded: NPS places always carry an id and title.
    for body in [#"{"title":"Example Place"}"#, #"{"id":"P1"}"#] {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(Place.self, from: Data(body.utf8))
      }
    }
  }

  @Test("One response carries both crop aspect ratio forms")
  func oneResponseCarriesBothCropAspectRatioForms() throws {
    let place = try #require(try decode(.placesSearch).data.first)
    #expect(place.images?.first?.crops?.map(\.aspectRatio) == ["1.78", "1.33"])
    #expect(place.images?.first?.crops?.map(\.ratio) == [1.78, 1.33])
    let stamp = try #require(place.passportStampImages?.first)
    #expect(stamp.crops?.map(\.aspectRatio) == ["1.0"])
    #expect(stamp.crops?.map(\.ratio) == [1.0])
    #expect(
      stamp.crops?.first?.url
        == "https://www.nps.gov/common/uploads/passport_stamps/primary/"
        + "D7FC2A50-E9FB-CF18-6867C7A8B6F12130.jpg")
    #expect(stamp.altText == "Fort Barrancas Area ")
    #expect(stamp.title == "Fort Barrancas Area")
    #expect(stamp.caption == "")
    #expect(stamp.credit == "")
    #expect(stamp.description == "")
    #expect(
      stamp.url
        == "https://www.nps.gov/common/uploads/passport_stamps/"
        + "D7FC2A50-E9FB-CF18-6867C7A8B6F12130.jpg")
  }

  @Test("Recorded places pages decode with their envelopes")
  func recordedPlacesPagesDecodeWithTheirEnvelopes() throws {
    let first = try decode(.placesPageFirst)
    #expect(first.total == "181")
    #expect(first.limit == "1")
    #expect(first.start == "0")
    #expect(first.data.map(\.id) == ["C9F643CF-FC98-4E28-B36E-E1B3D3771DDF"])
    #expect(first.data.map(\.title) == ["Acadia Earthcache Course Stop Five: Champlain Mountain"])
    let last = try decode(.placesPageLast)
    #expect(last.total == "181")
    #expect(last.start == "1")
    #expect(last.data.map(\.id) == ["B24187C1-432C-4068-B97C-BB5F71DCAED4"])
    #expect(last.data.map(\.title) == ["Acadia Earthcache Course Stop Four: Gorham Mountain Trail"])
    let empty = try decode(.placesEmpty)
    #expect(empty.total == "0")
    #expect(empty.data.isEmpty)
  }

  @Test("Recorded place flags and coordinates keep their provider text")
  func recordedPlaceFlagsAndCoordinatesKeepTheirProviderText() throws {
    let acadia = try #require(try decode(.placesPageFirst).data.first)
    #expect(acadia.isManagedByNps == "1")
    #expect(acadia.isMapPinHidden == "0")
    #expect(acadia.isOpenToPublic == "1")
    #expect(acadia.isPassportStampLocation == "0")
    #expect(acadia.latLong == "")
    #expect(acadia.latitude == "")
    #expect(acadia.longitude == "")
    #expect(acadia.amenities == [])
    #expect(acadia.passportStampImages == [])
    #expect(acadia.relatedOrganizations == [])
    #expect(acadia.multimedia == [])

    let redoubt = try #require(try decode(.placesSearch).data.first)
    #expect(redoubt.isPassportStampLocation == "0")
    #expect(redoubt.passportStampImages?.count == 1)
    #expect(redoubt.latLong == "30.354663,-87.29756")
    #expect(redoubt.latitude == "30.354663")
    #expect(redoubt.longitude == "-87.29756")
    #expect(redoubt.relevanceScore == 16.06786)
  }

  @Test("Recorded place text and nested shapes preserve provider values")
  func recordedPlaceTextAndNestedShapesPreserveProviderValues() throws {
    let place = try #require(try decode(.placesPageFirst).data.first)
    #expect(place.url == "https://www.nps.gov/places/acadia-earthcache-stop-five.htm")
    #expect(place.listingDescription == "Stop five on the Acadia Geocache course.")
    #expect(place.bodyText?.hasPrefix("Stop five on the <a href=") == true)
    #expect(place.audioDescription?.hasPrefix("Standing on the road you are facing") == true)
    #expect(place.associatedIcon == "")
    #expect(place.credit == "")
    #expect(place.geometryPoiId == "")
    #expect(place.location == "")
    #expect(place.locationDescription == "")
    #expect(place.managedByOrg == "")
    #expect(place.managedByUrl == "")
    #expect(place.npmapId == "")
    #expect(place.passportStampLocationDescription == "")
    #expect(place.tags == ["geocache", "geocaching", "Glacial Polish"])
    #expect(place.relevanceScore == 1.0)

    let park = try #require(place.relatedParks?.first)
    #expect(place.relatedParks?.count == 1)
    #expect(park.designation == "National Park")
    #expect(park.fullName == "Acadia National Park")
    #expect(park.name == "Acadia")
    #expect(park.parkCode == "acad")
    #expect(park.states == "ME")
    #expect(park.url == "https://www.nps.gov/acad/index.htm")

    let image = try #require(place.images?.first)
    #expect(place.images?.count == 1)
    #expect(image.title == "Glacial Polish at Champlain Mountain")
    #expect(image.credit == "NPSPhoto.")
    #expect(image.altText == "dark rocks that are shiny and reflecting the sun")
    #expect(image.caption == "Glacial Polish is easy to spot once you can recognize it.")
    #expect(image.description == "")
    #expect(
      image.url
        == "https://www.nps.gov/common/uploads/cropped_image/"
        + "D9A3B83A-BDA9-A20A-6C78FD74410DC397.jpg")

    #expect(place.quickFacts?.map(\.name) == ["Location", "Significance"])
    #expect(
      place.quickFacts?.map(\.value)
        == ["Base of Champlain Mountain", "Final Stop on the Acadia Earthcache Course. "])
    #expect(
      place.quickFacts?.map(\.id)
        == ["5C252B96-2DEB-4EF4-91D1-B5D2B202FCD7", "208F1B3C-44DC-4CF5-9A61-9B26A364D701"])
  }

  @Test("Recorded search results preserve provider values")
  func recordedSearchResultsPreserveProviderValues() throws {
    let page = try decode(.placesSearch)
    #expect(page.total == "27")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    #expect(page.data.count == 2)
    let redoubt = page.data[0]
    #expect(redoubt.id == "80F024C5-27B0-48B7-8098-30E10EE5AB61")
    #expect(redoubt.title == "Advanced Redoubt")
    #expect(redoubt.url == "https://www.nps.gov/places/000/advanced-redoubt.htm")
    #expect(
      redoubt.managedByUrl
        == "https://www.nps.gov/guis/learn/historyculture/advanced-redoubt.htm")
    #expect(redoubt.bodyText?.hasPrefix("<p>The Advanced Redoubt was built") == true)
    #expect(
      redoubt.amenities == [
        "Benches/Seating", "Historical/Interpretive Information/Exhibits", "Parking - Auto",
        "Scenic View/Photo Spot", "Trailhead",
      ])
    #expect(redoubt.quickFacts?.map(\.name) == ["Location", "Significance"])
    #expect(redoubt.relatedParks?.map(\.parkCode) == ["guis"])
    #expect(redoubt.relatedParks?.map(\.states) == ["FL,MS"])
    let glacis = page.data[1]
    #expect(glacis.id == "02E85F7F-2454-4B71-9372-AD71813FA80B")
    #expect(glacis.title == "Advanced Redoubt Tour Stop 1: The Glacis")
    #expect(glacis.amenities == [])
    #expect(glacis.passportStampImages == [])
    #expect(glacis.relevanceScore == 10.787928)
  }

  private func decode(_ fixture: Fixture) throws -> NPSCollection<Place> {
    try JSONDecoder().decode(NPSCollection<Place>.self, from: fixture.data())
  }
}
