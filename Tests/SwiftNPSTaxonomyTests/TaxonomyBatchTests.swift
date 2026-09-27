import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSDataTestSupport
import SwiftNPSTaxonomy
import SwiftNPSTaxonomyModels
import Testing

@Suite("Taxonomy batches", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct TaxonomyBatchTests {
  @Test(
    "Profile GET and POST batches preserve namespace body and terminal pages",
    arguments: ["taxoncode", "tsn"], ["get", "post"])
  func profileBatches(_ namespace: String, _ submission: String) async throws {
    let codes =
      namespace == "taxoncode" ? ["81838", "719252", "719251"] : ["175590", "81838", "175310"]
    let kind: TaxonCodeKind = namespace == "taxoncode" ? .nps : .itis
    let search = TaxonSearch.codes(
      codes, kind: kind, submission: submission == "post" ? .post : .get)
    let prefix = "Taxonomy/batch-" + namespace + "-" + submission + "-profile-"
    let all = try #require(IRMAFixture(rawValue: prefix + "all.json")).data()
    var responses: [Result<Response, TransportError>] = Array(
      repeating: .success(.ok(json: all)), count: 3)
    for index in 0...3 {
      let fixture = try #require(IRMAFixture(rawValue: prefix + String(index) + ".json"))
      responses.append(.success(.ok(json: try fixture.data())))
    }
    let transport = MockTransport(results: responses)
    let client = NPSTaxonomyClient(transport: transport)
    let query = try TaxonProfileQuery(search: search)
    let request = NPSTaxonomyRequest.taxonProfilesResponse(query: query)
    let a = try await client.taxonProfilesResponse(query: query)
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonProfilesResponse(query: query))
    #expect(a == b && b == c && a.count == 3)
    var traversed: [NPSTaxonProfile] = []
    var counts: [Int] = []
    for try await page in client.taxonProfilePages(
      query: try TaxonProfileQuery(
        paging: .page(size: 1, startIndex: 0), search: search))
    {
      counts.append(page.count)
      traversed += page
    }
    #expect(counts == [1, 1, 1, 0])
    #expect(traversed == a)
    #expect(
      a.map(\.taxonCode)
        == (namespace == "taxoncode"
          ? ["81838", "719251", "719252"] : ["79519", "81838", "719252"]))
    #expect(transport.requests.count == 7)
    let body = Data(("[" + codes.map { "\"" + $0 + "\"" }.joined(separator: ",") + "]").utf8)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for (index, call) in transport.requests.enumerated() {
      #expect(call.request.method == (submission == "post" ? .post : .get))
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[.accept] == "application/json")
      #expect(call.request.headerFields[key] == nil)
      if submission == "post" {
        let original = try #require(
          IRMAFixture(
            rawValue:
              prefix + (index >= 3 ? String(index - 3) : "all") + ".request.json")
        ).data()
        #expect(original == body && call.body == .bytes(original))
        #expect(call.request.headerFields[.contentType] == "application/json")
      } else {
        #expect(call.body == .none)
      }
      var parameters = submission == "get" ? ["codes=" + codes.joined(separator: "%2C")] : []
      parameters.append("deriveIfBroken=false")
      parameters += ["detail=profile", "format=json"]
      if index >= 3 { parameters += ["pageSize=1", "startIndex=" + String(index - 3)] }
      #expect(
        call.request.path == "/taxonomy/v2/rest/searchByCodes/" + namespace + "?"
          + parameters.joined(separator: "&"))
    }
  }

  @Test(
    "Summary GET and POST batches preserve namespace body and terminal pages",
    arguments: ["taxoncode", "tsn"], ["get", "post"])
  func basicBatches(_ namespace: String, _ submission: String) async throws {
    let codes =
      namespace == "taxoncode" ? ["81838", "719252", "719251"] : ["175590", "81838", "175310"]
    let kind: TaxonCodeKind = namespace == "taxoncode" ? .nps : .itis
    let search = TaxonSearch.codes(
      codes, kind: kind, submission: submission == "post" ? .post : .get)
    let prefix = "Taxonomy/batch-" + namespace + "-" + submission + "-basic-"
    let all = try #require(IRMAFixture(rawValue: prefix + "all.json")).data()
    var responses: [Result<Response, TransportError>] = Array(
      repeating: .success(.ok(json: all)), count: 3)
    for index in 0...3 {
      let fixture = try #require(IRMAFixture(rawValue: prefix + String(index) + ".json"))
      responses.append(.success(.ok(json: try fixture.data())))
    }
    let transport = MockTransport(results: responses)
    let client = NPSTaxonomyClient(transport: transport)
    let query = try TaxonSummaryQuery(search: search)
    let request = NPSTaxonomyRequest.taxonSummariesResponse(query: query)
    let a = try await client.taxonSummariesResponse(query: query)
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonSummariesResponse(query: query))
    #expect(a == b && b == c && a.count == 3)
    var traversed: [NPSTaxonSummary] = []
    var counts: [Int] = []
    for try await page in client.taxonSummaryPages(
      query: try TaxonSummaryQuery(
        paging: .page(size: 1, startIndex: 0), search: search))
    {
      counts.append(page.count)
      traversed += page
    }
    #expect(counts == [1, 1, 1, 0])
    #expect(traversed == a)
    #expect(
      a.map(\.taxonCode)
        == (namespace == "taxoncode"
          ? ["81838", "719251", "719252"] : ["79519", "81838", "719252"]))
    #expect(transport.requests.count == 7)
    let body = Data(("[" + codes.map { "\"" + $0 + "\"" }.joined(separator: ",") + "]").utf8)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for (index, call) in transport.requests.enumerated() {
      #expect(call.request.method == (submission == "post" ? .post : .get))
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[.accept] == "application/json")
      #expect(call.request.headerFields[key] == nil)
      if submission == "post" {
        let original = try #require(
          IRMAFixture(
            rawValue:
              prefix + (index >= 3 ? String(index - 3) : "all") + ".request.json")
        ).data()
        #expect(original == body && call.body == .bytes(original))
        #expect(call.request.headerFields[.contentType] == "application/json")
      } else {
        #expect(call.body == .none)
      }
      var parameters = submission == "get" ? ["codes=" + codes.joined(separator: "%2C")] : []

      parameters += ["detail=basic", "format=json"]
      if index >= 3 { parameters += ["pageSize=1", "startIndex=" + String(index - 3)] }
      #expect(
        call.request.path == "/taxonomy/v2/rest/searchByCodes/" + namespace + "?"
          + parameters.joined(separator: "&"))
    }
  }

}
