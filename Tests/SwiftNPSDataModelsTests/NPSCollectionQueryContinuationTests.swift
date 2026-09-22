import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Collection query continuation", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct NPSCollectionQueryContinuationTests {
  @Test(
    "Every collection query keeps its filters and sort and advances by the returned count",
    arguments: [
      ContinuationCase(
        try ActivityQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          sort: sort(), start: 3),
        page: .activitiesSearch,
        expected: try ActivityQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          sort: sort(), start: 4),
        items: [
          ("id", ["A1", "B2"]), ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("sort", ["name", "-title"]), ("start", ["4"]),
        ]),
      ContinuationCase(
        try ActivityParksQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          sort: sort(), start: 3),
        page: .activityParksSearch,
        expected: try ActivityParksQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          sort: sort(), start: 4),
        items: [
          ("id", ["A1", "B2"]), ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("sort", ["name", "-title"]), ("start", ["4"]),
        ]),
      ContinuationCase(
        try AlertQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", start: 3, stateCodes: states()),
        page: .alertsSearch,
        expected: try AlertQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", start: 5, stateCodes: states()),
        items: [
          ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]), ("start", ["5"]),
          ("stateCode", ["ME", "WY"]),
        ]),
      ContinuationCase(
        try AmenityParkPlacesQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          sort: sort(), start: 3),
        page: .amenityParkPlacesPageFirst,
        expected: try AmenityParkPlacesQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          sort: sort(), start: 4),
        items: [
          ("id", ["A1", "B2"]), ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("sort", ["name", "-title"]), ("start", ["4"]),
        ]),
      ContinuationCase(
        try AmenityParkVisitorCentersQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          sort: sort(), start: 3),
        page: .amenityParkVisitorCentersPageFirst,
        expected: try AmenityParkVisitorCentersQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          sort: sort(), start: 4),
        items: [
          ("id", ["A1", "B2"]), ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("sort", ["name", "-title"]), ("start", ["4"]),
        ]),
      ContinuationCase(
        try AmenityQuery(identifiers: identifiers(), limit: 7, searchText: "trail", start: 3),
        page: .amenitiesSearch,
        expected: try AmenityQuery(
          identifiers: identifiers(), limit: 7, searchText: "trail", start: 5),
        items: [("id", ["A1", "B2"]), ("limit", ["7"]), ("q", ["trail"]), ("start", ["5"])]),
      ContinuationCase(
        try ArticleQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", start: 3, stateCodes: states()),
        page: .articlesSearch,
        expected: try ArticleQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", start: 5, stateCodes: states()),
        items: [
          ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]), ("start", ["5"]),
          ("stateCode", ["ME", "WY"]),
        ]),
      ContinuationCase(
        try CampgroundQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 3,
          stateCodes: states()),
        page: .campgroundsSearch,
        expected: try CampgroundQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 5,
          stateCodes: states()),
        items: [
          ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("sort", ["name", "-title"]), ("start", ["5"]), ("stateCode", ["ME", "WY"]),
        ]),
      ContinuationCase(
        try LessonPlanQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          sort: sort(), start: 3, stateCodes: states()),
        page: .lessonPlansSearch,
        expected: try LessonPlanQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          sort: sort(), start: 5, stateCodes: states()),
        items: [
          ("id", ["A1", "B2"]), ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("sort", ["name", "-title"]), ("start", ["5"]), ("stateCode", ["ME", "WY"]),
        ]),
      ContinuationCase(
        try NewsReleaseQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 3,
          stateCodes: states()),
        page: .newsReleasesSearch,
        expected: try NewsReleaseQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 5,
          stateCodes: states()),
        items: [
          ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("sort", ["name", "-title"]), ("start", ["5"]), ("stateCode", ["ME", "WY"]),
        ]),
      ContinuationCase(
        try ParkAudioQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 3,
          stateCodes: states()),
        page: .parkAudioSearch,
        expected: try ParkAudioQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 5,
          stateCodes: states()),
        items: [
          ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("sort", ["name", "-title"]), ("start", ["5"]), ("stateCode", ["ME", "WY"]),
        ]),
      ContinuationCase(
        try ParkFeesAndPassesQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 3,
          stateCodes: states()),
        page: .parkFeesAndPassesSearch,
        expected: try ParkFeesAndPassesQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 5,
          stateCodes: states()),
        items: [
          ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("sort", ["name", "-title"]), ("start", ["5"]), ("stateCode", ["ME", "WY"]),
        ]),
      ContinuationCase(
        try ParkingLotQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 3,
          stateCodes: states()),
        page: .parkingLotsSearch,
        expected: try ParkingLotQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 5,
          stateCodes: states()),
        items: [
          ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("sort", ["name", "-title"]), ("start", ["5"]), ("stateCode", ["ME", "WY"]),
        ]),
      ContinuationCase(
        try ParkQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 3,
          stateCodes: states()),
        page: .parksSearch,
        expected: try ParkQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 5,
          stateCodes: states()),
        items: [
          ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("sort", ["name", "-title"]), ("start", ["5"]), ("stateCode", ["ME", "WY"]),
        ]),
      ContinuationCase(
        try ParkVideoQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 3,
          stateCodes: states()),
        page: .parkVideosSearch,
        expected: try ParkVideoQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 5,
          stateCodes: states()),
        items: [
          ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("sort", ["name", "-title"]), ("start", ["5"]), ("stateCode", ["ME", "WY"]),
        ]),
      ContinuationCase(
        try PersonQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", start: 3, stateCodes: states()),
        page: .peopleSearch,
        expected: try PersonQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", start: 5, stateCodes: states()),
        items: [
          ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]), ("start", ["5"]),
          ("stateCode", ["ME", "WY"]),
        ]),
      ContinuationCase(
        try PhotoGalleryAssetQuery(
          galleryIdentifiers: galleries(), identifiers: identifiers(), limit: 7,
          parkCodes: parks(), searchText: "trail", sort: sort(), start: 3, stateCodes: states()),
        page: .photoGalleryAssetsSearch,
        expected: try PhotoGalleryAssetQuery(
          galleryIdentifiers: galleries(), identifiers: identifiers(), limit: 7,
          parkCodes: parks(), searchText: "trail", sort: sort(), start: 5, stateCodes: states()),
        items: [
          ("galleryId", ["G1", "H2"]), ("id", ["A1", "B2"]), ("limit", ["7"]),
          ("parkCode", ["acad", "yell"]), ("q", ["trail"]), ("sort", ["name", "-title"]),
          ("start", ["5"]), ("stateCode", ["ME", "WY"]),
        ]),
      ContinuationCase(
        try PhotoGalleryQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 3,
          stateCodes: states()),
        page: .photoGalleriesSearch,
        expected: try PhotoGalleryQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 5,
          stateCodes: states()),
        items: [
          ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("sort", ["name", "-title"]), ("start", ["5"]), ("stateCode", ["ME", "WY"]),
        ]),
      ContinuationCase(
        try PlaceQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", start: 3, stateCodes: states()),
        page: .placesSearch,
        expected: try PlaceQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", start: 5, stateCodes: states()),
        items: [
          ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]), ("start", ["5"]),
          ("stateCode", ["ME", "WY"]),
        ]),
      ContinuationCase(
        try ThingToDoQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          sort: sort(), start: 3, stateCodes: states()),
        page: .thingsToDoSearch,
        expected: try ThingToDoQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          sort: sort(), start: 5, stateCodes: states()),
        items: [
          ("id", ["A1", "B2"]), ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("sort", ["name", "-title"]), ("start", ["5"]), ("stateCode", ["ME", "WY"]),
        ]),
      ContinuationCase(
        try TopicParksQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          sort: sort(), start: 3),
        page: .topicParksSearch,
        expected: try TopicParksQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          sort: sort(), start: 4),
        items: [
          ("id", ["A1", "B2"]), ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("sort", ["name", "-title"]), ("start", ["4"]),
        ]),
      ContinuationCase(
        try TourQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          sort: sort(), start: 3, stateCodes: states()),
        page: .toursPageFirst,
        expected: try TourQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          sort: sort(), start: 4, stateCodes: states()),
        items: [
          ("id", ["A1", "B2"]), ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("sort", ["name", "-title"]), ("start", ["4"]), ("stateCode", ["ME", "WY"]),
        ]),
      ContinuationCase(
        try VisitorCenterQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 3,
          stateCodes: states()),
        page: .visitorCentersSearch,
        expected: try VisitorCenterQuery(
          limit: 7, parkCodes: parks(), searchText: "trail", sort: sort(), start: 5,
          stateCodes: states()),
        items: [
          ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("sort", ["name", "-title"]), ("start", ["5"]), ("stateCode", ["ME", "WY"]),
        ]),
      ContinuationCase(
        try WebcamQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          start: 3, stateCodes: states()),
        page: .webcamsPageFirst,
        expected: try WebcamQuery(
          identifiers: identifiers(), limit: 7, parkCodes: parks(), searchText: "trail",
          start: 4, stateCodes: states()),
        items: [
          ("id", ["A1", "B2"]), ("limit", ["7"]), ("parkCode", ["acad", "yell"]), ("q", ["trail"]),
          ("start", ["4"]), ("stateCode", ["ME", "WY"]),
        ]),
    ])
  func everyCollectionQueryKeepsItsFiltersAndSortAndAdvancesByTheReturnedCount(
    _ continuation: ContinuationCase
  ) throws {
    let outcome = try continuation.check()
    #expect(outcome.items == continuation.items)
    #expect(outcome.matchesExpected)
  }
}

/// One collection query, a recorded page for its item type, and the literal continuation it
/// must produce.
///
/// Every page's metadata is rewritten to `limit=7`, `start=3`, and `total=1000`, so a two-item
/// page continues at 5 and a one-item page at 4.
struct ContinuationCase: CustomTestStringConvertible, Sendable {
  let check: @Sendable () throws -> (items: [NPSQueryItem], matchesExpected: Bool)
  let items: [NPSQueryItem]
  let testDescription: String

  init<Query: NPSCollectionQuery>(
    _ query: @autoclosure @escaping @Sendable () throws -> Query, page fixture: Fixture,
    expected: @autoclosure @escaping @Sendable () throws -> Query,
    items: [(String, [String])]
  ) {
    self.check = {
      var object = try #require(
        JSONSerialization.jsonObject(with: fixture.data()) as? [String: Any])
      object.merge(["limit": "7", "start": "3", "total": "1000"]) { _, new in new }
      let page = try JSONDecoder().decode(
        NPSCollection<Query.Item>.self, from: JSONSerialization.data(withJSONObject: object))
      let following = try #require(try query().next(after: page))
      return (following.queryItems, following == (try expected()))
    }
    self.items = items.map { NPSQueryItem(name: $0.0, values: $0.1) }
    self.testDescription = String(describing: Query.self)
  }
}

private func galleries() throws -> [NPSIdentifier] {
  try [NPSIdentifier("G1"), NPSIdentifier("H2")]
}

private func identifiers() throws -> [NPSIdentifier] {
  try [NPSIdentifier("A1"), NPSIdentifier("B2")]
}

private func parks() throws -> [ParkCode] {
  try [ParkCode("acad"), ParkCode("yell")]
}

private func sort() -> [NPSSort] {
  [.ascending("name"), .descending("title")]
}

private func states() throws -> [StateCode] {
  try [StateCode("ME"), StateCode("WY")]
}
