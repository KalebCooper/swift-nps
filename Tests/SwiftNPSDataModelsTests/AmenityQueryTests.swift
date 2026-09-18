import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Amenity queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct AmenityQueryTests {
  @Test("All documented amenities parameters preserve caller values")
  func allDocumentedAmenitiesParametersPreserveCallerValues() throws {
    let query = try AmenityQuery(
      identifiers: [
        NPSIdentifier("A1B0AD01-740C-41E7-8412-FBBEDD5F1443"), NPSIdentifier("future,id&x"),
      ],
      limit: 2, searchText: "a +&/#?é", start: 3)
    #expect(
      Endpoint.amenities(query: query).path
        == "/amenities?id=A1B0AD01-740C-41E7-8412-FBBEDD5F1443,future%2Cid%26x&limit=2"
        + "&q=a%20%2B%26%2F%23%3F%C3%A9&start=3")
    #expect(Endpoint.collection(query) == Endpoint.amenities(query: query))
  }

  @Test("All documented amenity park parameters preserve caller values")
  func allDocumentedAmenityParkParametersPreserveCallerValues() throws {
    let identifiers = [
      try NPSIdentifier("4E4D076A-6866-46C8-A28B-A129E2B8F3DB"), try NPSIdentifier("future,id&x"),
    ]
    let parkCodes = [try ParkCode("ACAD"), try ParkCode("yell")]
    let sort: [NPSSort] = [.ascending("name"), .descending("futureField")]
    let places = try AmenityParkPlacesQuery(
      identifiers: identifiers, limit: 2, parkCodes: parkCodes, searchText: "a +&/#?é",
      sort: sort, start: 3)
    let centers = try AmenityParkVisitorCentersQuery(
      identifiers: identifiers, limit: 2, parkCodes: parkCodes, searchText: "a +&/#?é",
      sort: sort, start: 3)
    let parameters =
      "?id=4E4D076A-6866-46C8-A28B-A129E2B8F3DB,future%2Cid%26x&limit=2&parkCode=ACAD,yell"
      + "&q=a%20%2B%26%2F%23%3F%C3%A9&sort=name,-futureField&start=3"
    #expect(Endpoint.amenityParkPlaces(query: places).path == "/amenities/parksplaces" + parameters)
    #expect(
      Endpoint.amenityParkVisitorCenters(query: centers).path
        == "/amenities/parksvisitorcenters" + parameters)
    #expect(Endpoint.collection(places) == Endpoint.amenityParkPlaces(query: places))
    #expect(Endpoint.collection(centers) == Endpoint.amenityParkVisitorCenters(query: centers))
  }

  @Test("Amenity requests resolve as collections of the same query")
  func amenityRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let amenities = try AmenityQuery(limit: 1, searchText: "restroom")
    let places = try AmenityParkPlacesQuery(limit: 1, parkCodes: [ParkCode("acad")])
    let centers = try AmenityParkVisitorCentersQuery(limit: 1, parkCodes: [ParkCode("acad")])
    let amenityRequest = NPSDataRequest.amenities(query: amenities)
    let placesRequest = NPSDataRequest.amenityParkPlaces(query: places)
    let centersRequest = NPSDataRequest.amenityParkVisitorCenters(query: centers)
    let _: NPSDataRequest<NPSCollection<Amenity>> = amenityRequest
    let _: NPSDataRequest<NPSCollection<[AmenityParkPlaces]>> = placesRequest
    let _: NPSDataRequest<NPSCollection<[AmenityParkVisitorCenters]>> = centersRequest
    #expect(amenityRequest.resolution == .collection(NPSCollectionResolution(amenities)))
    #expect(placesRequest.resolution == .collection(NPSCollectionResolution(places)))
    #expect(centersRequest.resolution == .collection(NPSCollectionResolution(centers)))
    #expect(Set([placesRequest, .amenityParkPlaces(query: places)]).count == 1)
    #expect(placesRequest != .amenityParkPlaces(query: try AmenityParkPlacesQuery(limit: 1)))
    guard case .collection(let resolution) = placesRequest.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.amenityParkPlaces(query: places))
    #expect(resolution.query as? AmenityParkPlacesQuery == places)
    guard case .collection(let centersResolution) = centersRequest.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(centersResolution.query as? AmenityParkVisitorCentersQuery == centers)
  }

  @Test("Default amenity queries explicitly request fifty results at zero")
  func defaultAmenityQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(try Endpoint.amenities(query: AmenityQuery()).path == "/amenities?limit=50&start=0")
    #expect(
      try Endpoint.amenities(query: AmenityQuery(searchText: "")).path
        == "/amenities?limit=50&q=&start=0")
    #expect(
      try Endpoint.amenityParkPlaces(query: AmenityParkPlacesQuery()).path
        == "/amenities/parksplaces?limit=50&start=0")
    #expect(
      try Endpoint.amenityParkVisitorCenters(query: AmenityParkVisitorCentersQuery()).path
        == "/amenities/parksvisitorcenters?limit=50&start=0")
  }

  @Test("Empty identifier, code, and sort arrays omit their parameters")
  func emptyIdentifierCodeAndSortArraysOmitTheirParameters() throws {
    let amenities = try AmenityQuery(identifiers: [], limit: 1)
    let places = try AmenityParkPlacesQuery(identifiers: [], limit: 1, parkCodes: [], sort: [])
    let centers = try AmenityParkVisitorCentersQuery(
      identifiers: [], limit: 1, parkCodes: [], sort: [])
    #expect(amenities.queryItems.map(\.name) == ["limit", "start"])
    #expect(places.queryItems.map(\.name) == ["limit", "start"])
    #expect(centers.queryItems.map(\.name) == ["limit", "start"])
    #expect(Endpoint.amenities(query: amenities).path == "/amenities?limit=1&start=0")
  }

  @Test("Invalid amenity query pagination is rejected")
  func invalidAmenityQueryPaginationIsRejected() {
    #expect(throws: AmenityQuery.ValidationError.invalidLimit) { try AmenityQuery(limit: 0) }
    #expect(throws: AmenityQuery.ValidationError.invalidStart) { try AmenityQuery(start: -1) }
    #expect(throws: AmenityParkPlacesQuery.ValidationError.invalidLimit) {
      try AmenityParkPlacesQuery(limit: -1)
    }
    #expect(throws: AmenityParkPlacesQuery.ValidationError.invalidStart) {
      try AmenityParkPlacesQuery(start: -1)
    }
    #expect(throws: AmenityParkVisitorCentersQuery.ValidationError.invalidLimit) {
      try AmenityParkVisitorCentersQuery(limit: 0)
    }
    #expect(throws: AmenityParkVisitorCentersQuery.ValidationError.invalidStart) {
      try AmenityParkVisitorCentersQuery(start: -1)
    }
  }

  @Test("The recorded requests match the amenity query paths")
  func theRecordedRequestsMatchTheAmenityQueryPaths() throws {
    #expect(
      try Endpoint.amenities(query: AmenityQuery(limit: 2, searchText: "restroom")).path
        == "/amenities?limit=2&q=restroom&start=0")
    let page = try AmenityQuery(limit: 1)
    #expect(Endpoint.amenities(query: page).path == "/amenities?limit=1&start=0")
    #expect(
      Endpoint.amenities(query: page.starting(at: 1)).path == "/amenities?limit=1&start=1")
    #expect(
      try Endpoint.amenities(query: AmenityQuery(limit: 1, searchText: "zzzzzz")).path
        == "/amenities?limit=1&q=zzzzzz&start=0")
    let places = try AmenityParkPlacesQuery(limit: 1, parkCodes: [ParkCode("acad")])
    #expect(
      Endpoint.amenityParkPlaces(query: places).path
        == "/amenities/parksplaces?limit=1&parkCode=acad&start=0")
    #expect(
      Endpoint.amenityParkPlaces(query: places.starting(at: 1)).path
        == "/amenities/parksplaces?limit=1&parkCode=acad&start=1")
    #expect(
      try Endpoint.amenityParkPlaces(
        query: AmenityParkPlacesQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
      ).path == "/amenities/parksplaces?limit=1&parkCode=zzzz&start=0")
    let centers = try AmenityParkVisitorCentersQuery(limit: 1, parkCodes: [ParkCode("acad")])
    #expect(
      Endpoint.amenityParkVisitorCenters(query: centers).path
        == "/amenities/parksvisitorcenters?limit=1&parkCode=acad&start=0")
    #expect(
      Endpoint.amenityParkVisitorCenters(query: centers.starting(at: 1)).path
        == "/amenities/parksvisitorcenters?limit=1&parkCode=acad&start=1")
    #expect(
      try Endpoint.amenityParkVisitorCenters(
        query: AmenityParkVisitorCentersQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
      ).path == "/amenities/parksvisitorcenters?limit=1&parkCode=zzzz&start=0")
  }
}
