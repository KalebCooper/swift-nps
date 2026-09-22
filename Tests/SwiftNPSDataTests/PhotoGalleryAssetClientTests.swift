import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Photo gallery asset client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct PhotoGalleryAssetClientTests {
  @Test(
    "An empty photo gallery asset page ends iteration without another request",
    arguments: [false, true])
  func anEmptyPhotoGalleryAssetPageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(results: [
      .success(.ok(json: try Fixture.photoGalleryAssetsEmpty.data()))
    ]
    )
    let client = try makeClient(transport)
    let query = try PhotoGalleryAssetQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var assets: [PhotoGalleryAsset] = []
      for try await asset in client.photoGalleryAssets(query: query) { assets.append(asset) }
      #expect(assets.isEmpty)
    } else {
      var pages: [NPSCollection<PhotoGalleryAsset>] = []
      for try await page in client.photoGalleryAssetPages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/multimedia/galleries/assets?limit=1&parkCode=zzzz&start=0"
      ])
  }

  @Test("Photo gallery asset item iteration fetches the next page only when needed")
  func photoGalleryAssetItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.photoGalleryAssetsPageFirst.data())),
        .success(.ok(json: Fixture.photoGalleryAssetsPageLast.data())),
      ])
    let sequence = try makeClient(transport).photoGalleryAssets(query: makeQuery())
    let _: NPSItemSequence<PhotoGalleryAsset> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.id == "83ADD5BA-4D24-4DB9-BDC6-10506A4E86CA")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.id == "C432E255-D179-4812-9EB0-55EA4E17B07E")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/multimedia/galleries/assets?limit=1&parkCode=cowp&start=0",
        "/api/v1/multimedia/galleries/assets?limit=1&parkCode=cowp&start=1",
      ])
  }

  @Test("Photo gallery asset pages advance lazily through the recorded pages")
  func photoGalleryAssetPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.photoGalleryAssetsPageFirst.data()
    let last = try Fixture.photoGalleryAssetsPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).photoGalleryAssetPages(query: makeQuery())
    let _: NPSPageSequence<PhotoGalleryAsset> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(
      firstPage == (try JSONDecoder().decode(NPSCollection<PhotoGalleryAsset>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(
      lastPage == (try JSONDecoder().decode(NPSCollection<PhotoGalleryAsset>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/multimedia/galleries/assets?limit=1&parkCode=cowp&start=0",
        "/api/v1/multimedia/galleries/assets?limit=1&parkCode=cowp&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable photo gallery asset requests return the same page as their endpoint")
  func reusablePhotoGalleryAssetRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.photoGalleryAssetsSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try PhotoGalleryAssetQuery(
      limit: 2, parkCodes: [ParkCode("heho")], searchText: "snow",
      sort: [.ascending("title")], stateCodes: [StateCode("IA")])
    let reusable = try await client.value(for: .photoGalleryAssets(query: query))
    let endpoint = try await client.send(.photoGalleryAssets(query: query))
    #expect(reusable == endpoint)
    #expect(reusable.data.map(\.ordinal) == [3, 85])
    let path =
      "/api/v1/multimedia/galleries/assets?limit=2&parkCode=heho&q=snow&sort=title&start=0"
      + "&stateCode=IA"
    #expect(transport.requests.map(\.request.path) == [path, path])
  }

  @Test("A gallery filter sends galleryId and ends at the recorded total")
  func aGalleryFilterSendsGalleryIdAndEndsAtTheRecordedTotal() async throws {
    let transport = MockTransport(results: [
      .success(.ok(json: try Fixture.photoGalleryAssetsGallery.data()))
    ]
    )
    let query = try PhotoGalleryAssetQuery(
      galleryIdentifiers: [NPSIdentifier("1FFC7EF8-155D-4519-3ECC-B652E2E95E20")], limit: 2)
    var titles: [String] = []
    for try await asset in try makeClient(transport).photoGalleryAssets(query: query) {
      titles.append(asset.title)
    }
    #expect(titles == ["Chaplain Offers Prayer", "Colors"])
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/multimedia/galleries/assets?galleryId=1FFC7EF8-155D-4519-3ECC-B652E2E95E20"
          + "&limit=2&start=0"
      ])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> PhotoGalleryAssetQuery {
    try PhotoGalleryAssetQuery(limit: 1, parkCodes: [ParkCode("cowp")])
  }
}
