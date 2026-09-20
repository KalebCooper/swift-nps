import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Amenity models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct AmenityTests {
  @Test("Constructed amenities decode with nulls and unknown fields")
  func constructedAmenitiesDecodeWithNullsAndUnknownFields() throws {
    // Constructed, not recorded: recorded amenities carry no nulls or unknown fields.
    let amenity = try JSONDecoder().decode(
      Amenity.self,
      from: Data(#"{"id":"A1","name":"Example","categories":null,"futureField":[1]}"#.utf8))
    #expect(amenity.id == "A1")
    #expect(amenity.name == "Example")
    #expect(amenity.categories == nil)
    let places = try JSONDecoder().decode(
      AmenityParkPlaces.self,
      from: Data(
        #"""
        {"id":"A1","name":"Example","extra":true,"parks":[{"parkCode":null,"states":null,
        "places":[{"id":null,"title":null,"url":null,"extra":1}],"extra":{}}]}
        """#.utf8))
    let park = try #require(places.parks?.first)
    #expect(park.park.parkCode == nil)
    #expect(park.park.states == nil)
    #expect(park.park.fullName == nil)
    #expect(park.places?.first?.id == nil)
    #expect(park.places?.first?.title == nil)
    let centers = try JSONDecoder().decode(
      AmenityParkVisitorCenters.self,
      from: Data(
        #"""
        {"id":"A1","name":"Example","parks":[{"visitorcenters":[{"id":null,"name":null,"url":null}],
        "designation":null}]}
        """#.utf8))
    let centerPark = try #require(centers.parks?.first)
    #expect(centerPark.park.designation == nil)
    #expect(centerPark.visitorCenters?.count == 1)
    #expect(centerPark.visitorCenters?.first?.name == nil)
    let absent = try JSONDecoder().decode(
      AmenityParkPlaces.self, from: Data(#"{"id":"A1","name":"Example"}"#.utf8))
    #expect(absent.parks == nil)
  }

  @Test("Constructed amenity groups keep every entry in provider order")
  func constructedAmenityGroupsKeepEveryEntryInProviderOrder() throws {
    // Constructed, not recorded: every recorded group holds exactly one amenity.
    let body = Data(
      #"""
      {"total":"3","limit":"2","start":"0","data":[[{"id":"A1","name":"First"},
      {"id":"A2","name":"Second"}],[]]}
      """#.utf8)
    let page = try JSONDecoder().decode(NPSCollection<[AmenityParkPlaces]>.self, from: body)
    #expect(page.data.map(\.count) == [2, 0])
    #expect(page.data.first?.map(\.id) == ["A1", "A2"])
  }

  @Test("Missing identity or name fails to decode")
  func missingIdentityOrNameFailsToDecode() {
    // Constructed, not recorded: NPS amenities always carry an id and name.
    for body in [#"{"name":"Example"}"#, #"{"id":"A1"}"#] {
      let data = Data(body.utf8)
      #expect(throws: DecodingError.self) { try JSONDecoder().decode(Amenity.self, from: data) }
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(AmenityParkPlaces.self, from: data)
      }
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(AmenityParkVisitorCenters.self, from: data)
      }
    }
  }

  @Test("Recorded amenities preserve identity, names, and categories")
  func recordedAmenitiesPreserveIdentityNamesAndCategories() throws {
    let search = try JSONDecoder().decode(
      NPSCollection<Amenity>.self, from: Fixture.amenitiesSearch.data())
    #expect(search.total == "30")
    #expect(search.limit == "2")
    #expect(search.start == "0")
    #expect(
      search.data.map(\.id) == [
        "89397A1A-3517-4941-8D30-037856E9D063", "7DC6C690-2BC3-4344-9691-EF9FCFB6E506",
      ])
    #expect(search.data.map(\.name) == ["Animal-Safe Food Storage", "Audio Description"])
    #expect(search.data.map(\.categories) == [["Safety"], ["Accessibility"]])
    let first = try JSONDecoder().decode(
      NPSCollection<Amenity>.self, from: Fixture.amenitiesPageFirst.data())
    let amenity = try #require(first.data.first)
    #expect(amenity.id == "A1B0AD01-740C-41E7-8412-FBBEDD5F1443")
    #expect(amenity.name == "ATM/Cash Machine")
    #expect(amenity.categories == ["Convenience", "Souvenirs and Supplies"])
    let empty = try JSONDecoder().decode(
      NPSCollection<Amenity>.self, from: Fixture.amenitiesEmpty.data())
    #expect(empty.total == "0")
    #expect(empty.data.isEmpty)
  }

  @Test("Recorded amenity park places preserve groups, parks, and places")
  func recordedAmenityParkPlacesPreserveGroupsParksAndPlaces() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<[AmenityParkPlaces]>.self, from: Fixture.amenityParkPlacesPageFirst.data())
    #expect(page.total == "59")
    #expect(page.data.map(\.count) == [1])
    let amenity = try #require(page.data.first?.first)
    #expect(amenity.id == "4E4D076A-6866-46C8-A28B-A129E2B8F3DB")
    #expect(amenity.name == "Accessible Rooms")
    let park = try #require(amenity.parks?.first)
    #expect(amenity.parks?.count == 1)
    #expect(park.park.designation == "National Park")
    #expect(park.park.fullName == "Acadia National Park")
    #expect(park.park.name == "Acadia")
    #expect(park.park.parkCode == "acad")
    #expect(park.park.states == "ME")
    #expect(park.park.url == "http://www.nps.gov/acad/")
    #expect(park.places?.map(\.title) == ["Jordan Pond House", "Moore Auditorium"])
    let place = try #require(park.places?.first)
    #expect(place.id == "73CD84BA-F5B5-491E-A3B4-B5B6743668AC")
    #expect(place.url == "https://www.nps.gov/places/jordan-pond-house.htm")
    let empty = try JSONDecoder().decode(
      NPSCollection<[AmenityParkPlaces]>.self, from: Fixture.amenityParkPlacesEmpty.data())
    #expect(empty.total == "0")
    #expect(empty.data.isEmpty)
  }

  @Test("Recorded amenity park visitor centers preserve groups, parks, and centers")
  func recordedAmenityParkVisitorCentersPreserveGroupsParksAndCenters() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<[AmenityParkVisitorCenters]>.self,
      from: Fixture.amenityParkVisitorCentersPageLast.data())
    #expect(page.total == "27")
    #expect(page.start == "1")
    #expect(page.data.map(\.count) == [1])
    let amenity = try #require(page.data.first?.first)
    #expect(amenity.id == "63734D6E-3330-4EED-B916-52B3F625A091")
    #expect(amenity.name == "Beach/Water Access")
    let park = try #require(amenity.parks?.first)
    #expect(park.park.parkCode == "acad")
    #expect(park.park.fullName == "Acadia National Park")
    let center = try #require(park.visitorCenters?.first)
    #expect(park.visitorCenters?.count == 1)
    #expect(center.id == "109BDB6B-C627-4C8D-87DA-A4F687E81BCE")
    #expect(center.name == "Islesford Historical Museum")
    #expect(center.url == "http://www.nps.gov/acad/planyourvisit/hours.htm")
    let empty = try JSONDecoder().decode(
      NPSCollection<[AmenityParkVisitorCenters]>.self,
      from: Fixture.amenityParkVisitorCentersEmpty.data())
    #expect(empty.total == "0")
    #expect(empty.data.isEmpty)
  }
}
