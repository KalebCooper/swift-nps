import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Webcams queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct WebcamQueryTests {
  @Test("All documented webcam parameters preserve caller values")
  func allDocumentedWebcamParametersPreserveCallerValues() throws {
    let query = try WebcamQuery(
      identifiers: [
        NPSIdentifier("9849DE2B-BC23-1110-33CED7C04E8AAF05"), NPSIdentifier("future,id&x"),
      ],
      limit: 2, parkCodes: [ParkCode("GUMO"), ParkCode("grte")], searchText: "a +&/#?é", start: 3,
      stateCodes: [StateCode("tx"), StateCode("WY")])
    #expect(
      Endpoint.webcams(query: query).path
        == "/webcams?id=9849DE2B-BC23-1110-33CED7C04E8AAF05,future%2Cid%26x&limit=2"
        + "&parkCode=GUMO,grte&q=a%20%2B%26%2F%23%3F%C3%A9&start=3&stateCode=tx,WY")
    #expect(Endpoint.collection(query) == Endpoint.webcams(query: query))
  }

  @Test("Default webcam queries explicitly request fifty results at zero")
  func defaultWebcamQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(try Endpoint.webcams(query: WebcamQuery()).path == "/webcams?limit=50&start=0")
    #expect(
      try Endpoint.webcams(query: WebcamQuery(searchText: "")).path
        == "/webcams?limit=50&q=&start=0")
  }

  @Test("Empty identifier and code arrays omit their parameters")
  func emptyIdentifierAndCodeArraysOmitTheirParameters() throws {
    let query = try WebcamQuery(identifiers: [], limit: 1, parkCodes: [], stateCodes: [])
    #expect(Endpoint.webcams(query: query).path == "/webcams?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid webcam query pagination is rejected")
  func invalidWebcamQueryPaginationIsRejected() {
    #expect(throws: WebcamQuery.ValidationError.invalidLimit) { try WebcamQuery(limit: 0) }
    #expect(throws: WebcamQuery.ValidationError.invalidLimit) { try WebcamQuery(limit: -1) }
    #expect(throws: WebcamQuery.ValidationError.invalidStart) { try WebcamQuery(start: -1) }
  }

  @Test("Webcam queries send no sort parameter")
  func webcamQueriesSendNoSortParameter() throws {
    // The live endpoint answers HTTP 400 for every sort value, so the query offers none.
    let query = try WebcamQuery(
      identifiers: [NPSIdentifier("9849DE2B-BC23-1110-33CED7C04E8AAF05")], limit: 2,
      parkCodes: [ParkCode("gumo")], searchText: "Capitan", start: 1,
      stateCodes: [StateCode("TX")])
    #expect(
      query.queryItems.map(\.name) == ["id", "limit", "parkCode", "q", "start", "stateCode"])
    #expect(Endpoint.webcams(query: query).path.contains("sort") == false)
  }

  @Test("Webcam requests resolve as collections of the same query")
  func webcamRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try WebcamQuery(limit: 1, parkCodes: [ParkCode("grte")])
    let request = NPSDataRequest.webcams(query: query)
    let _: NPSDataRequest<NPSCollection<Webcam>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .webcams(query: query)]).count == 1)
    #expect(request != .webcams(query: try WebcamQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.webcams(query: query))
    #expect(resolution.query as? WebcamQuery == query)
  }

  @Test("The recorded requests match the webcam query paths")
  func theRecordedRequestsMatchTheWebcamQueryPaths() throws {
    let search = try WebcamQuery(
      identifiers: [NPSIdentifier("9849DE2B-BC23-1110-33CED7C04E8AAF05")], limit: 2,
      parkCodes: [ParkCode("gumo")], searchText: "Capitan", stateCodes: [StateCode("TX")])
    #expect(
      Endpoint.webcams(query: search).path
        == "/webcams?id=9849DE2B-BC23-1110-33CED7C04E8AAF05&limit=2&parkCode=gumo&q=Capitan"
        + "&start=0&stateCode=TX")
    let page = try WebcamQuery(limit: 1, parkCodes: [ParkCode("grte")])
    #expect(Endpoint.webcams(query: page).path == "/webcams?limit=1&parkCode=grte&start=0")
    #expect(
      Endpoint.webcams(query: page.starting(at: 1)).path
        == "/webcams?limit=1&parkCode=grte&start=1")
    let empty = try WebcamQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    #expect(Endpoint.webcams(query: empty).path == "/webcams?limit=1&parkCode=zzzz&start=0")
  }
}
