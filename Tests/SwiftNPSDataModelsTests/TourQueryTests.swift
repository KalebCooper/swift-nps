import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Tours queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct TourQueryTests {
  @Test("All documented tour parameters preserve caller values")
  func allDocumentedTourParametersPreserveCallerValues() throws {
    let query = try TourQuery(
      identifiers: [
        NPSIdentifier("7F1D5880-0FE9-5B95-492B8497DB1992A1"), NPSIdentifier("future,id&x"),
      ],
      limit: 2, parkCodes: [ParkCode("FOMA"), ParkCode("cavo")], searchText: "a +&/#?é",
      sort: [.descending("relevanceScore"), .ascending("title")], start: 3,
      stateCodes: [StateCode("fl"), StateCode("NM")])
    #expect(
      Endpoint.tours(query: query).path
        == "/tours?id=7F1D5880-0FE9-5B95-492B8497DB1992A1,future%2Cid%26x&limit=2"
        + "&parkCode=FOMA,cavo&q=a%20%2B%26%2F%23%3F%C3%A9&sort=-relevanceScore,title&start=3"
        + "&stateCode=fl,NM")
    #expect(Endpoint.collection(query) == Endpoint.tours(query: query))
  }

  @Test("Default tour queries explicitly request fifty results at zero")
  func defaultTourQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(try Endpoint.tours(query: TourQuery()).path == "/tours?limit=50&start=0")
    #expect(
      try Endpoint.tours(query: TourQuery(searchText: "")).path == "/tours?limit=50&q=&start=0")
  }

  @Test("Empty identifier, code, and sort arrays omit their parameters")
  func emptyIdentifierCodeAndSortArraysOmitTheirParameters() throws {
    let query = try TourQuery(identifiers: [], limit: 1, parkCodes: [], sort: [], stateCodes: [])
    #expect(Endpoint.tours(query: query).path == "/tours?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid tour query pagination is rejected")
  func invalidTourQueryPaginationIsRejected() {
    #expect(throws: TourQuery.ValidationError.invalidLimit) { try TourQuery(limit: 0) }
    #expect(throws: TourQuery.ValidationError.invalidLimit) { try TourQuery(limit: -1) }
    #expect(throws: TourQuery.ValidationError.invalidStart) { try TourQuery(start: -1) }
  }

  @Test("Tour sort fields are sent without validation or reordering")
  func tourSortFieldsAreSentWithoutValidationOrReordering() throws {
    // The live service accepts only relevanceScore and answers title with HTTP 400; the query
    // does not decide.
    let query = try TourQuery(limit: 1, sort: [.ascending("title"), .descending("futureField")])
    #expect(Endpoint.tours(query: query).path == "/tours?limit=1&sort=title,-futureField&start=0")
  }

  @Test("The recorded requests match the tour query paths")
  func theRecordedRequestsMatchTheTourQueryPaths() throws {
    let search = try TourQuery(
      identifiers: [NPSIdentifier("7F1D5880-0FE9-5B95-492B8497DB1992A1")], limit: 2,
      parkCodes: [ParkCode("foma")], searchText: "Virtual", sort: [.descending("relevanceScore")],
      stateCodes: [StateCode("FL")])
    #expect(
      Endpoint.tours(query: search).path
        == "/tours?id=7F1D5880-0FE9-5B95-492B8497DB1992A1&limit=2&parkCode=foma&q=Virtual"
        + "&sort=-relevanceScore&start=0&stateCode=FL")
    let page = try TourQuery(limit: 1, parkCodes: [ParkCode("cavo")])
    #expect(Endpoint.tours(query: page).path == "/tours?limit=1&parkCode=cavo&start=0")
    #expect(
      Endpoint.tours(query: page.starting(at: 1)).path == "/tours?limit=1&parkCode=cavo&start=1")
    #expect(
      try Endpoint.tours(query: TourQuery(limit: 1, parkCodes: [ParkCode("zzzz")])).path
        == "/tours?limit=1&parkCode=zzzz&start=0")
  }

  @Test("Tour requests resolve as collections of the same query")
  func tourRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try TourQuery(
      identifiers: [NPSIdentifier("7F1D5880-0FE9-5B95-492B8497DB1992A1")], limit: 1)
    let request = NPSDataRequest.tours(query: query)
    let _: NPSDataRequest<NPSCollection<Tour>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .tours(query: query)]).count == 1)
    #expect(request != .tours(query: try TourQuery(limit: 1)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.tours(query: query))
    #expect(resolution.query as? TourQuery == query)
  }
}
