import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Photo gallery asset queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct PhotoGalleryAssetQueryTests {
  @Test("All documented photo gallery asset parameters preserve caller values")
  func allDocumentedPhotoGalleryAssetParametersPreserveCallerValues() throws {
    let query = try PhotoGalleryAssetQuery(
      galleryIdentifiers: [
        NPSIdentifier("1FFC7EF8-155D-4519-3ECC-B652E2E95E20"), NPSIdentifier("future,id&x"),
      ],
      identifiers: [NPSIdentifier("83ADD5BA-4D24-4DB9-BDC6-10506A4E86CA")], limit: 2,
      parkCodes: [ParkCode("COWP"), ParkCode("heho")], searchText: "a +&/#?é",
      sort: [.descending("title"), .ascending("ordinal")], start: 3,
      stateCodes: [StateCode("ny"), StateCode("IA")])
    #expect(
      Endpoint.photoGalleryAssets(query: query).path
        == "/multimedia/galleries/assets?galleryId=1FFC7EF8-155D-4519-3ECC-B652E2E95E20,"
        + "future%2Cid%26x&id=83ADD5BA-4D24-4DB9-BDC6-10506A4E86CA&limit=2&parkCode=COWP,heho"
        + "&q=a%20%2B%26%2F%23%3F%C3%A9&sort=-title,ordinal&start=3&stateCode=ny,IA")
    #expect(Endpoint.collection(query) == Endpoint.photoGalleryAssets(query: query))
  }

  @Test("Default photo gallery asset queries explicitly request fifty results at zero")
  func defaultPhotoGalleryAssetQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(
      try Endpoint.photoGalleryAssets(query: PhotoGalleryAssetQuery()).path
        == "/multimedia/galleries/assets?limit=50&start=0"
    )
    #expect(
      try Endpoint.photoGalleryAssets(query: PhotoGalleryAssetQuery(searchText: "")).path
        == "/multimedia/galleries/assets?limit=50&q=&start=0")
  }

  @Test("Empty identifier, code, and sort arrays omit their parameters")
  func emptyIdentifierCodeAndSortArraysOmitTheirParameters() throws {
    let query = try PhotoGalleryAssetQuery(
      galleryIdentifiers: [], identifiers: [], limit: 1, parkCodes: [], sort: [],
      stateCodes: [])
    #expect(
      Endpoint.photoGalleryAssets(query: query).path
        == "/multimedia/galleries/assets?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid photo gallery asset query pagination is rejected")
  func invalidPhotoGalleryAssetQueryPaginationIsRejected() {
    #expect(throws: PhotoGalleryAssetQuery.ValidationError.invalidLimit) {
      try PhotoGalleryAssetQuery(limit: 0)
    }
    #expect(throws: PhotoGalleryAssetQuery.ValidationError.invalidLimit) {
      try PhotoGalleryAssetQuery(limit: -1)
    }
    #expect(throws: PhotoGalleryAssetQuery.ValidationError.invalidStart) {
      try PhotoGalleryAssetQuery(start: -1)
    }
  }

  @Test("Sort fields are sent without validation or reordering")
  func sortFieldsAreSentWithoutValidationOrReordering() throws {
    // The live endpoint refuses relevanceScore with HTTP 400; the query still sends it as named.
    let query = try PhotoGalleryAssetQuery(
      limit: 1, sort: [.descending("relevanceScore"), .ascending("futureField")])
    #expect(
      Endpoint.photoGalleryAssets(query: query).path
        == "/multimedia/galleries/assets?limit=1&sort=-relevanceScore,futureField&start=0")
  }

  @Test("Gallery identifiers are sent as galleryId without case or format changes")
  func galleryIdentifiersAreSentAsGalleryIdWithoutCaseOrFormatChanges() throws {
    // The live endpoint matches galleryId case sensitively and ignores non-UUID values; the
    // query sends each value exactly as given.
    let query = try PhotoGalleryAssetQuery(
      galleryIdentifiers: [
        NPSIdentifier("1ffc7ef8-155d-4519-3ecc-b652e2e95e20"), NPSIdentifier("zzzz"),
      ],
      limit: 1)
    #expect(
      Endpoint.photoGalleryAssets(query: query).path
        == "/multimedia/galleries/assets?galleryId=1ffc7ef8-155d-4519-3ecc-b652e2e95e20,zzzz"
        + "&limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["galleryId", "limit", "start"])
  }

  @Test("Photo gallery asset requests resolve as collections of the same query")
  func photoGalleryAssetRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try PhotoGalleryAssetQuery(limit: 1, parkCodes: [ParkCode("cowp")])
    let request = NPSDataRequest.photoGalleryAssets(query: query)
    let _: NPSDataRequest<NPSCollection<PhotoGalleryAsset>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .photoGalleryAssets(query: query)]).count == 1)
    #expect(request != .photoGalleryAssets(query: try PhotoGalleryAssetQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.photoGalleryAssets(query: query))
    #expect(resolution.query as? PhotoGalleryAssetQuery == query)
  }

  @Test("The recorded requests match the photo gallery asset query paths")
  func theRecordedRequestsMatchThePhotoGalleryAssetQueryPaths() throws {
    let search = try PhotoGalleryAssetQuery(
      limit: 2, parkCodes: [ParkCode("heho")], searchText: "snow",
      sort: [.ascending("title")], stateCodes: [StateCode("IA")])
    #expect(
      Endpoint.photoGalleryAssets(query: search).path
        == "/multimedia/galleries/assets?limit=2&parkCode=heho&q=snow&sort=title&start=0"
        + "&stateCode=IA")
    let gallery = try PhotoGalleryAssetQuery(
      galleryIdentifiers: [NPSIdentifier("1FFC7EF8-155D-4519-3ECC-B652E2E95E20")], limit: 2)
    #expect(
      Endpoint.photoGalleryAssets(query: gallery).path
        == "/multimedia/galleries/assets?galleryId=1FFC7EF8-155D-4519-3ECC-B652E2E95E20&limit=2"
        + "&start=0")
    let page = try PhotoGalleryAssetQuery(limit: 1, parkCodes: [ParkCode("cowp")])
    #expect(
      Endpoint.photoGalleryAssets(query: page).path
        == "/multimedia/galleries/assets?limit=1&parkCode=cowp&start=0")
    #expect(
      Endpoint.photoGalleryAssets(query: page.starting(at: 1)).path
        == "/multimedia/galleries/assets?limit=1&parkCode=cowp&start=1")
    let empty = try PhotoGalleryAssetQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    #expect(
      Endpoint.photoGalleryAssets(query: empty).path
        == "/multimedia/galleries/assets?limit=1&parkCode=zzzz&start=0")
  }

  @Test("A photo gallery asset query advances by the returned item count and keeps its filters")
  func aPhotoGalleryAssetQueryAdvancesByTheReturnedItemCountAndKeepsItsFilters() throws {
    let query = try PhotoGalleryAssetQuery(
      galleryIdentifiers: [NPSIdentifier("1BBC09C6-5953-4AF1-8081-C4F1D68C6DA3")], limit: 1,
      parkCodes: [ParkCode("cowp")], sort: [.ascending("title")])
    let page = try JSONDecoder().decode(
      NPSCollection<PhotoGalleryAsset>.self, from: Fixture.photoGalleryAssetsPageFirst.data())
    let next = try #require(try query.next(after: page))
    #expect(next == query.starting(at: 1))
    #expect(
      Endpoint.photoGalleryAssets(query: next).path
        == "/multimedia/galleries/assets?galleryId=1BBC09C6-5953-4AF1-8081-C4F1D68C6DA3&limit=1"
        + "&parkCode=cowp&sort=title&start=1")
  }
}
