import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Collection continuation", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct NPSCollectionQueryTests {
  @Test(
    "Invalid pagination metadata fails explicitly",
    arguments: [
      ("limit", "0"), ("limit", "-1"), ("start", "+0"), ("total", ""),
      ("total", "1.5"), ("total", " 2"), ("total", "999999999999999999999999999"),
    ])
  func invalidPaginationMetadataFailsExplicitly(_ field: String, _ value: String) throws {
    let page = try modifiedPage([field: value])
    #expect(throws: NPSPaginationError.invalidMetadata(field: field, value: value)) {
      try ParkQuery(limit: 1).next(after: page)
    }
  }

  @Test("Offset overflow is reported without wrapping")
  func offsetOverflowIsReportedWithoutWrapping() throws {
    let page = try modifiedPage(["start": String(Int.max), "total": String(Int.max)])
    #expect(throws: NPSPaginationError.offsetOverflow) {
      try ParkQuery(start: Int.max).next(after: page)
    }
  }

  @Test("Recorded alert pages advance without changing query options")
  func recordedAlertPagesAdvanceWithoutChangingQueryOptions() throws {
    let first = try JSONDecoder().decode(
      NPSCollection<ParkAlert>.self, from: Fixture.alertsPageFirst.data())
    let last = try JSONDecoder().decode(
      NPSCollection<ParkAlert>.self, from: Fixture.alertsPageLast.data())
    let empty = try JSONDecoder().decode(
      NPSCollection<ParkAlert>.self, from: Fixture.alertsEmpty.data())
    let query = try AlertQuery(
      limit: 1, parkCodes: [ParkCode("acad")], searchText: "closure", stateCodes: [StateCode("ME")])
    let following = try #require(try query.next(after: first))
    #expect(following.start == 1)
    #expect(following.limit == 1)
    #expect(following.parkCodes == query.parkCodes)
    #expect(following.searchText == "closure")
    #expect(following.stateCodes == query.stateCodes)
    #expect(try following.next(after: last)?.start == 2)
    #expect(try AlertQuery(limit: 1).next(after: empty) == nil)
  }

  @Test("Recorded amenity pages advance without changing query options")
  func recordedAmenityPagesAdvanceWithoutChangingQueryOptions() throws {
    let decoder = JSONDecoder()
    let first = try decoder.decode(
      NPSCollection<Amenity>.self, from: Fixture.amenitiesPageFirst.data())
    let last = try decoder.decode(
      NPSCollection<Amenity>.self, from: Fixture.amenitiesPageLast.data())
    let empty = try decoder.decode(
      NPSCollection<Amenity>.self, from: Fixture.amenitiesEmpty.data())
    let query = try AmenityQuery(
      identifiers: [NPSIdentifier("A1B0AD01-740C-41E7-8412-FBBEDD5F1443")], limit: 1,
      searchText: "atm")
    let following = try #require(try query.next(after: first))
    #expect(following.start == 1)
    #expect(following.limit == 1)
    #expect(following.identifiers == query.identifiers)
    #expect(following.searchText == "atm")
    #expect(try following.next(after: last)?.start == 2)
    #expect(try AmenityQuery(limit: 1).next(after: empty) == nil)
  }

  @Test("Recorded amenity park groups advance by group count without changing query options")
  func recordedAmenityParkGroupsAdvanceByGroupCountWithoutChangingQueryOptions() throws {
    let decoder = JSONDecoder()
    let placesFirst = try decoder.decode(
      NPSCollection<[AmenityParkPlaces]>.self, from: Fixture.amenityParkPlacesPageFirst.data())
    let placesLast = try decoder.decode(
      NPSCollection<[AmenityParkPlaces]>.self, from: Fixture.amenityParkPlacesPageLast.data())
    let placesEmpty = try decoder.decode(
      NPSCollection<[AmenityParkPlaces]>.self, from: Fixture.amenityParkPlacesEmpty.data())
    let places = try AmenityParkPlacesQuery(
      identifiers: [NPSIdentifier("4E4D076A-6866-46C8-A28B-A129E2B8F3DB")], limit: 1,
      parkCodes: [ParkCode("acad")], searchText: "rooms", sort: [.ascending("name")])
    let nextPlaces = try #require(try places.next(after: placesFirst))
    #expect(nextPlaces.start == 1)
    #expect(nextPlaces.identifiers == places.identifiers)
    #expect(nextPlaces.parkCodes == places.parkCodes)
    #expect(nextPlaces.searchText == "rooms")
    #expect(nextPlaces.sort == [.ascending("name")])
    #expect(try nextPlaces.next(after: placesLast)?.start == 2)
    #expect(try AmenityParkPlacesQuery(limit: 1).next(after: placesEmpty) == nil)
    let centersFirst = try decoder.decode(
      NPSCollection<[AmenityParkVisitorCenters]>.self,
      from: Fixture.amenityParkVisitorCentersPageFirst.data())
    let centersLast = try decoder.decode(
      NPSCollection<[AmenityParkVisitorCenters]>.self,
      from: Fixture.amenityParkVisitorCentersPageLast.data())
    let centersEmpty = try decoder.decode(
      NPSCollection<[AmenityParkVisitorCenters]>.self,
      from: Fixture.amenityParkVisitorCentersEmpty.data())
    let centers = try AmenityParkVisitorCentersQuery(
      limit: 1, parkCodes: [ParkCode("acad")], sort: [.descending("name")])
    let nextCenters = try #require(try centers.next(after: centersFirst))
    #expect(nextCenters.start == 1)
    #expect(nextCenters.parkCodes == centers.parkCodes)
    #expect(nextCenters.sort == [.descending("name")])
    #expect(try nextCenters.next(after: centersLast)?.start == 2)
    #expect(try AmenityParkVisitorCentersQuery(limit: 1).next(after: centersEmpty) == nil)
  }

  @Test("Recorded campground pages advance without changing query options")
  func recordedCampgroundPagesAdvanceWithoutChangingQueryOptions() throws {
    let first = try JSONDecoder().decode(
      NPSCollection<Campground>.self, from: Fixture.campgroundsPageFirst.data())
    let last = try JSONDecoder().decode(
      NPSCollection<Campground>.self, from: Fixture.campgroundsPageLast.data())
    let empty = try JSONDecoder().decode(
      NPSCollection<Campground>.self, from: Fixture.campgroundsEmpty.data())
    let query = try CampgroundQuery(
      limit: 1, parkCodes: [ParkCode("acad")], searchText: "lake", sort: [.ascending("name")],
      stateCodes: [StateCode("ME")])
    let following = try #require(try query.next(after: first))
    #expect(following.start == 1)
    #expect(following.limit == 1)
    #expect(following.parkCodes == query.parkCodes)
    #expect(following.searchText == "lake")
    #expect(following.sort == [.ascending("name")])
    #expect(following.stateCodes == query.stateCodes)
    #expect(try following.next(after: last)?.start == 2)
    #expect(try CampgroundQuery(limit: 1).next(after: empty) == nil)
  }

  @Test("Recorded pages advance without changing query options")
  func recordedPagesAdvanceWithoutChangingQueryOptions() throws {
    let first = try JSONDecoder().decode(
      NPSCollection<Park>.self, from: Fixture.parksPageFirst.data())
    let last = try JSONDecoder().decode(
      NPSCollection<Park>.self, from: Fixture.parksPageLast.data())
    let query = try ParkQuery(
      limit: 1, parkCodes: [ParkCode("acad"), ParkCode("yell")], searchText: "park",
      sort: [.ascending("parkCode")], stateCodes: [StateCode("ME"), StateCode("WY")])
    let following = try #require(try query.next(after: first))
    #expect(following.start == 1)
    #expect(following.limit == 1)
    #expect(following.parkCodes == query.parkCodes)
    #expect(following.searchText == "park")
    #expect(following.sort == [.ascending("parkCode")])
    #expect(following.stateCodes == query.stateCodes)
    #expect(try following.next(after: last) == nil)
    let beyond = try JSONDecoder().decode(
      NPSCollection<Park>.self, from: Fixture.parksBeyond.data())
    #expect(try ParkQuery(start: 2).next(after: beyond) == nil)
  }

  @Test("Recorded things to do pages advance without changing query options")
  func recordedThingsToDoPagesAdvanceWithoutChangingQueryOptions() throws {
    let first = try JSONDecoder().decode(
      NPSCollection<ThingToDo>.self, from: Fixture.thingsToDoPageFirst.data())
    let last = try JSONDecoder().decode(
      NPSCollection<ThingToDo>.self, from: Fixture.thingsToDoPageLast.data())
    let empty = try JSONDecoder().decode(
      NPSCollection<ThingToDo>.self, from: Fixture.thingsToDoEmpty.data())
    let query = try ThingToDoQuery(
      identifiers: [NPSIdentifier("C54D2783-6F50-4E03-9010-FCDA5C31EE91")], limit: 1,
      parkCodes: [ParkCode("acad")], searchText: "bike", sort: [.descending("relevanceScore")],
      stateCodes: [StateCode("ME")])
    let following = try #require(try query.next(after: first))
    #expect(following.start == 1)
    #expect(following.limit == 1)
    #expect(following.identifiers == query.identifiers)
    #expect(following.parkCodes == query.parkCodes)
    #expect(following.searchText == "bike")
    #expect(following.sort == [.descending("relevanceScore")])
    #expect(following.stateCodes == query.stateCodes)
    #expect(try following.next(after: last)?.start == 2)
    #expect(try ThingToDoQuery(limit: 1).next(after: empty) == nil)
  }

  @Test("Recorded visitor center pages advance without changing query options")
  func recordedVisitorCenterPagesAdvanceWithoutChangingQueryOptions() throws {
    let first = try JSONDecoder().decode(
      NPSCollection<VisitorCenter>.self, from: Fixture.visitorCentersPageFirst.data())
    let last = try JSONDecoder().decode(
      NPSCollection<VisitorCenter>.self, from: Fixture.visitorCentersPageLast.data())
    let empty = try JSONDecoder().decode(
      NPSCollection<VisitorCenter>.self, from: Fixture.visitorCentersEmpty.data())
    let query = try VisitorCenterQuery(
      limit: 1, parkCodes: [ParkCode("acad")], searchText: "center", sort: [.ascending("name")],
      stateCodes: [StateCode("ME")])
    let following = try #require(try query.next(after: first))
    #expect(following.start == 1)
    #expect(following.limit == 1)
    #expect(following.parkCodes == query.parkCodes)
    #expect(following.searchText == "center")
    #expect(following.sort == [.ascending("name")])
    #expect(following.stateCodes == query.stateCodes)
    #expect(try following.next(after: last)?.start == 2)
    #expect(try VisitorCenterQuery(limit: 1).next(after: empty) == nil)
  }

  @Test("Short pages advance by returned count without skipping records")
  func shortPagesAdvanceByReturnedCountWithoutSkippingRecords() throws {
    let page = try modifiedPage(["limit": "50", "total": "3"])
    #expect(try ParkQuery().next(after: page)?.start == 1)
  }

  @Test("Unexpected offsets and contradictory counts cannot imply completion")
  func unexpectedOffsetsAndContradictoryCountsCannotImplyCompletion() throws {
    let repeated = try modifiedPage([:])
    #expect(throws: NPSPaginationError.unexpectedStart(actual: 0, expected: 1)) {
      try ParkQuery(start: 1).next(after: repeated)
    }
    let premature = try modifiedPage(["data": []])
    #expect(throws: NPSPaginationError.inconsistentPage) { try ParkQuery().next(after: premature) }
    let contradictory = try modifiedPage(["total": "0"])
    #expect(throws: NPSPaginationError.inconsistentPage) {
      try ParkQuery().next(after: contradictory)
    }
  }

  private func modifiedPage(_ changes: [String: Any]) throws -> NPSCollection<Park> {
    // Constructed metadata cases are deliberately separate from the recorded response bodies.
    var object = try #require(
      JSONSerialization.jsonObject(with: Fixture.parksPageFirst.data()) as? [String: Any])
    object.merge(changes) { _, new in new }
    return try JSONDecoder().decode(
      NPSCollection<Park>.self, from: JSONSerialization.data(withJSONObject: object))
  }
}
