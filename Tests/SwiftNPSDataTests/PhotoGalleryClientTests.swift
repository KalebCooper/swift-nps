import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Photo gallery client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct PhotoGalleryClientTests {
  @Test(
    "An empty photo gallery page ends iteration without another request", arguments: [false, true])
  func anEmptyPhotoGalleryPageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(results: [
      .success(.ok(json: try Fixture.photoGalleriesEmpty.data()))
    ]
    )
    let client = try makeClient(transport)
    let query = try PhotoGalleryQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var galleries: [PhotoGallery] = []
      for try await gallery in client.photoGalleries(query: query) { galleries.append(gallery) }
      #expect(galleries.isEmpty)
    } else {
      var pages: [NPSCollection<PhotoGallery>] = []
      for try await page in client.photoGalleryPages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/multimedia/galleries?limit=1&parkCode=zzzz&start=0"
      ])
  }

  @Test("Photo gallery item iteration fetches the next page only when needed")
  func photoGalleryItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.photoGalleriesPageFirst.data())),
        .success(.ok(json: Fixture.photoGalleriesPageLast.data())),
      ])
    let sequence = try makeClient(transport).photoGalleries(query: makeQuery())
    let _: NPSItemSequence<PhotoGallery> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.id == "195A5808-155D-451F-67A6-897B29577270")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.id == "19A3CC98-155D-451F-67C2-E30B384719E7")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/multimedia/galleries?limit=1&parkCode=thrb&start=0",
        "/api/v1/multimedia/galleries?limit=1&parkCode=thrb&start=1",
      ])
  }

  @Test("Photo gallery pages advance lazily through the recorded pages")
  func photoGalleryPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.photoGalleriesPageFirst.data()
    let last = try Fixture.photoGalleriesPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).photoGalleryPages(query: makeQuery())
    let _: NPSPageSequence<PhotoGallery> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(firstPage == (try JSONDecoder().decode(NPSCollection<PhotoGallery>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<PhotoGallery>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/multimedia/galleries?limit=1&parkCode=thrb&start=0",
        "/api/v1/multimedia/galleries?limit=1&parkCode=thrb&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable photo gallery requests return the same page as their endpoint")
  func reusablePhotoGalleryRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.photoGalleriesSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try PhotoGalleryQuery(
      limit: 2, parkCodes: [ParkCode("heho")], searchText: "snow",
      sort: [.ascending("title")], stateCodes: [StateCode("IA")])
    let reusable = try await client.value(for: .photoGalleries(query: query))
    let endpoint = try await client.send(.photoGalleries(query: query))
    #expect(reusable == endpoint)
    #expect(
      reusable.data.map(\.id) == [
        "D2EB9B96-1DD8-B71B-0B4C-646D4E916D81", "2704673F-16D7-4E6F-90D0-98F3EAC93070",
      ])
    let path =
      "/api/v1/multimedia/galleries?limit=2&parkCode=heho&q=snow&sort=title&start=0&stateCode=IA"
    #expect(transport.requests.map(\.request.path) == [path, path])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> PhotoGalleryQuery {
    try PhotoGalleryQuery(limit: 1, parkCodes: [ParkCode("thrb")])
  }
}
