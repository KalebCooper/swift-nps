import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Photo gallery queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct PhotoGalleryQueryTests {
  @Test("All documented photo gallery parameters preserve caller values")
  func allDocumentedPhotoGalleryParametersPreserveCallerValues() throws {
    let query = try PhotoGalleryQuery(
      limit: 2, parkCodes: [ParkCode("THRB"), ParkCode("heho")], searchText: "a +&/#?é",
      sort: [.descending("title"), .ascending("assetCount")], start: 3,
      stateCodes: [StateCode("ny"), StateCode("IA")])
    #expect(
      Endpoint.photoGalleries(query: query).path
        == "/multimedia/galleries?limit=2&parkCode=THRB,heho&q=a%20%2B%26%2F%23%3F%C3%A9"
        + "&sort=-title,assetCount&start=3&stateCode=ny,IA")
    #expect(Endpoint.collection(query) == Endpoint.photoGalleries(query: query))
  }

  @Test("Default photo gallery queries explicitly request fifty results at zero")
  func defaultPhotoGalleryQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(
      try Endpoint.photoGalleries(query: PhotoGalleryQuery()).path
        == "/multimedia/galleries?limit=50&start=0"
    )
    #expect(
      try Endpoint.photoGalleries(query: PhotoGalleryQuery(searchText: "")).path
        == "/multimedia/galleries?limit=50&q=&start=0")
  }

  @Test("Empty code and sort arrays omit their parameters")
  func emptyCodeAndSortArraysOmitTheirParameters() throws {
    let query = try PhotoGalleryQuery(limit: 1, parkCodes: [], sort: [], stateCodes: [])
    #expect(Endpoint.photoGalleries(query: query).path == "/multimedia/galleries?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid photo gallery query pagination is rejected")
  func invalidPhotoGalleryQueryPaginationIsRejected() {
    #expect(throws: PhotoGalleryQuery.ValidationError.invalidLimit) {
      try PhotoGalleryQuery(limit: 0)
    }
    #expect(throws: PhotoGalleryQuery.ValidationError.invalidLimit) {
      try PhotoGalleryQuery(limit: -1)
    }
    #expect(throws: PhotoGalleryQuery.ValidationError.invalidStart) {
      try PhotoGalleryQuery(start: -1)
    }
  }

  @Test("Sort fields are sent without validation or reordering")
  func sortFieldsAreSentWithoutValidationOrReordering() throws {
    // The live endpoint refuses relevanceScore with HTTP 400; the query still sends it as named.
    let query = try PhotoGalleryQuery(
      limit: 1, sort: [.descending("relevanceScore"), .ascending("futureField")])
    #expect(
      Endpoint.photoGalleries(query: query).path
        == "/multimedia/galleries?limit=1&sort=-relevanceScore,futureField&start=0")
  }

  @Test("Photo gallery requests resolve as collections of the same query")
  func photoGalleryRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try PhotoGalleryQuery(limit: 1, parkCodes: [ParkCode("thrb")])
    let request = NPSDataRequest.photoGalleries(query: query)
    let _: NPSDataRequest<NPSCollection<PhotoGallery>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .photoGalleries(query: query)]).count == 1)
    #expect(request != .photoGalleries(query: try PhotoGalleryQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.photoGalleries(query: query))
    #expect(resolution.query as? PhotoGalleryQuery == query)
  }

  @Test("The recorded requests match the photo gallery query paths")
  func theRecordedRequestsMatchThePhotoGalleryQueryPaths() throws {
    let search = try PhotoGalleryQuery(
      limit: 2, parkCodes: [ParkCode("heho")], searchText: "snow",
      sort: [.ascending("title")], stateCodes: [StateCode("IA")])
    #expect(
      Endpoint.photoGalleries(query: search).path
        == "/multimedia/galleries?limit=2&parkCode=heho&q=snow&sort=title&start=0&stateCode=IA")
    let page = try PhotoGalleryQuery(limit: 1, parkCodes: [ParkCode("thrb")])
    #expect(
      Endpoint.photoGalleries(query: page).path
        == "/multimedia/galleries?limit=1&parkCode=thrb&start=0")
    #expect(
      Endpoint.photoGalleries(query: page.starting(at: 1)).path
        == "/multimedia/galleries?limit=1&parkCode=thrb&start=1")
    let empty = try PhotoGalleryQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    #expect(
      Endpoint.photoGalleries(query: empty).path
        == "/multimedia/galleries?limit=1&parkCode=zzzz&start=0")
  }

  @Test("A photo gallery query advances by the returned item count and keeps its filters")
  func aPhotoGalleryQueryAdvancesByTheReturnedItemCountAndKeepsItsFilters() throws {
    let query = try PhotoGalleryQuery(
      limit: 1, parkCodes: [ParkCode("thrb")], sort: [.ascending("title")])
    let page = try JSONDecoder().decode(
      NPSCollection<PhotoGallery>.self, from: Fixture.photoGalleriesPageFirst.data())
    let next = try #require(try query.next(after: page))
    #expect(next == query.starting(at: 1))
    #expect(
      Endpoint.photoGalleries(query: next).path
        == "/multimedia/galleries?limit=1&parkCode=thrb&sort=title&start=1")
  }
}
