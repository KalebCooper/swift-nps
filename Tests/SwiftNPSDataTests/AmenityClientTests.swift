import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Amenities client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct AmenityClientTests {
  @Test("Amenity item iteration fetches the next page only when needed")
  func amenityItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.amenitiesPageFirst.data())),
        .success(.ok(json: Fixture.amenitiesPageLast.data())),
      ])
    let sequence = try makeClient(transport).amenities(query: AmenityQuery(limit: 1))
    let _: NPSItemSequence<Amenity> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.name == "ATM/Cash Machine")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.name == "Accessible Rooms")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/amenities?limit=1&start=0", "/api/v1/amenities?limit=1&start=1",
      ])
    assertAuthenticated(transport)
  }

  @Test("Amenity pages advance lazily through the recorded pages")
  func amenityPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.amenitiesPageFirst.data()
    let last = try Fixture.amenitiesPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).amenityPages(query: AmenityQuery(limit: 1))
    let _: NPSPageSequence<Amenity> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(
      try await iterator.next()
        == (try JSONDecoder().decode(NPSCollection<Amenity>.self, from: first)))
    #expect(transport.requests.count == 1)
    #expect(
      try await iterator.next()
        == (try JSONDecoder().decode(NPSCollection<Amenity>.self, from: last)))
    #expect(transport.requests.count == 2)
  }

  @Test(
    "Amenity park place pages keep groups and items flatten them in order",
    arguments: [false, true])
  func amenityParkPlacePagesKeepGroupsAndItemsFlattenThemInOrder(_ items: Bool) async throws {
    let first = try Fixture.amenityParkPlacesPageFirst.data()
    let last = try Fixture.amenityParkPlacesPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let client = try makeClient(transport)
    let query = try AmenityParkPlacesQuery(limit: 1, parkCodes: [ParkCode("acad")])
    if items {
      let sequence = client.amenityParkPlaces(query: query)
      let _: NPSFlattenedItemSequence<AmenityParkPlaces> = sequence
      var iterator = sequence.makeAsyncIterator()
      #expect(transport.requests.isEmpty)
      #expect(try await iterator.next()?.name == "Accessible Rooms")
      #expect(transport.requests.count == 1)
      let second = try await iterator.next()
      #expect(second?.id == "B509969B-F06A-4DCC-BBB3-134964D896E2")
      #expect(second?.parks?.first?.places?.map(\.title) == ["Schoodic Woods Campground"])
    } else {
      let sequence = client.amenityParkPlacePages(query: query)
      let _: NPSPageSequence<[AmenityParkPlaces]> = sequence
      var iterator = sequence.makeAsyncIterator()
      let decoder = JSONDecoder()
      #expect(
        try await iterator.next()
          == (try decoder.decode(NPSCollection<[AmenityParkPlaces]>.self, from: first)))
      #expect(transport.requests.count == 1)
      #expect(
        try await iterator.next()
          == (try decoder.decode(NPSCollection<[AmenityParkPlaces]>.self, from: last)))
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/amenities/parksplaces?limit=1&parkCode=acad&start=0",
        "/api/v1/amenities/parksplaces?limit=1&parkCode=acad&start=1",
      ])
    assertAuthenticated(transport)
  }

  @Test(
    "Amenity park visitor center pages keep groups and items flatten them in order",
    arguments: [false, true])
  func amenityParkVisitorCenterPagesKeepGroupsAndItemsFlattenThemInOrder(
    _ items: Bool
  ) async throws {
    let first = try Fixture.amenityParkVisitorCentersPageFirst.data()
    let last = try Fixture.amenityParkVisitorCentersPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let client = try makeClient(transport)
    let query = try AmenityParkVisitorCentersQuery(limit: 1, parkCodes: [ParkCode("acad")])
    if items {
      let sequence = client.amenityParkVisitorCenters(query: query)
      let _: NPSFlattenedItemSequence<AmenityParkVisitorCenters> = sequence
      var iterator = sequence.makeAsyncIterator()
      #expect(transport.requests.isEmpty)
      let firstAmenity = try await iterator.next()
      #expect(firstAmenity?.name == "Automated Entrance")
      #expect(
        firstAmenity?.parks?.first?.visitorCenters?.map(\.name) == ["Hulls Cove Visitor Center"])
      #expect(transport.requests.count == 1)
      #expect(try await iterator.next()?.name == "Beach/Water Access")
    } else {
      let sequence = client.amenityParkVisitorCenterPages(query: query)
      let _: NPSPageSequence<[AmenityParkVisitorCenters]> = sequence
      var iterator = sequence.makeAsyncIterator()
      let decoder = JSONDecoder()
      #expect(
        try await iterator.next()
          == (try decoder.decode(NPSCollection<[AmenityParkVisitorCenters]>.self, from: first)))
      #expect(transport.requests.count == 1)
      #expect(
        try await iterator.next()
          == (try decoder.decode(NPSCollection<[AmenityParkVisitorCenters]>.self, from: last)))
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/amenities/parksvisitorcenters?limit=1&parkCode=acad&start=0",
        "/api/v1/amenities/parksvisitorcenters?limit=1&parkCode=acad&start=1",
      ])
    assertAuthenticated(transport)
  }

  @Test("Empty amenity pages end iteration without another request", arguments: [false, true])
  func emptyAmenityPagesEndIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.amenitiesEmpty.data())),
        .success(.ok(json: Fixture.amenityParkPlacesEmpty.data())),
        .success(.ok(json: Fixture.amenityParkVisitorCentersEmpty.data())),
      ])
    let client = try makeClient(transport)
    let amenities = try AmenityQuery(limit: 1, searchText: "zzzzzz")
    let places = try AmenityParkPlacesQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    let centers = try AmenityParkVisitorCentersQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    var count = 0
    if items {
      for try await _ in client.amenities(query: amenities) { count += 1 }
      for try await _ in client.amenityParkPlaces(query: places) { count += 1 }
      for try await _ in client.amenityParkVisitorCenters(query: centers) { count += 1 }
      #expect(count == 0)
    } else {
      var totals: [String] = []
      for try await page in client.amenityPages(query: amenities) {
        totals.append(page.total)
        count += page.data.count
      }
      for try await page in client.amenityParkPlacePages(query: places) {
        totals.append(page.total)
        count += page.data.count
      }
      for try await page in client.amenityParkVisitorCenterPages(query: centers) {
        totals.append(page.total)
        count += page.data.count
      }
      #expect(totals == ["0", "0", "0"])
      #expect(count == 0)
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/amenities?limit=1&q=zzzzzz&start=0",
        "/api/v1/amenities/parksplaces?limit=1&parkCode=zzzz&start=0",
        "/api/v1/amenities/parksvisitorcenters?limit=1&parkCode=zzzz&start=0",
      ])
  }

  @Test("Reusable amenity requests return the same page as their endpoint")
  func reusableAmenityRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let search = try Fixture.amenitiesSearch.data()
    let places = try Fixture.amenityParkPlacesPageFirst.data()
    let centers = try Fixture.amenityParkVisitorCentersPageFirst.data()
    let transport = MockTransport(
      results: [search, search, places, places, centers, centers].map { .success(.ok(json: $0)) })
    let client = try makeClient(transport)
    let amenityQuery = try AmenityQuery(limit: 2, searchText: "restroom")
    let reusable = try await client.value(for: .amenities(query: amenityQuery))
    #expect(reusable == (try await client.send(.amenities(query: amenityQuery))))
    #expect(reusable.data.map(\.name) == ["Animal-Safe Food Storage", "Audio Description"])
    let placesQuery = try AmenityParkPlacesQuery(limit: 1, parkCodes: [ParkCode("acad")])
    let placesPage = try await client.value(for: .amenityParkPlaces(query: placesQuery))
    #expect(placesPage == (try await client.send(.amenityParkPlaces(query: placesQuery))))
    #expect(placesPage.data.first?.first?.name == "Accessible Rooms")
    let centersQuery = try AmenityParkVisitorCentersQuery(limit: 1, parkCodes: [ParkCode("acad")])
    let centersPage = try await client.value(
      for: .amenityParkVisitorCenters(query: centersQuery))
    #expect(
      centersPage == (try await client.send(.amenityParkVisitorCenters(query: centersQuery))))
    #expect(centersPage.data.first?.first?.name == "Automated Entrance")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/amenities?limit=2&q=restroom&start=0",
        "/api/v1/amenities?limit=2&q=restroom&start=0",
        "/api/v1/amenities/parksplaces?limit=1&parkCode=acad&start=0",
        "/api/v1/amenities/parksplaces?limit=1&parkCode=acad&start=0",
        "/api/v1/amenities/parksvisitorcenters?limit=1&parkCode=acad&start=0",
        "/api/v1/amenities/parksvisitorcenters?limit=1&parkCode=acad&start=0",
      ])
  }

  private func assertAuthenticated(_ transport: MockTransport) {
    guard let key = HTTPField.Name("X-Api-Key") else {
      Issue.record("The API key header name must be valid.")
      return
    }
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }
}
