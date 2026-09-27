import Foundation
import SwiftNPSDataTestSupport
import SwiftNPSLandmarksModels
import Testing

@Suite("Landmark requests", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct LandmarkQueryTests {
  @Test("Endpoint confinement rejects credentials traversal foreign services and keys")
  func endpointConfinement() throws {
    for path in [
      "//evil.test", "/../api", "/%2e%2e/api", "/api/%2f", "/api/%5c", "/api/%252e",
      "/api#fragment", "/api?API_KEY=x",
    ] {
      #expect(LandmarkEndpoint<[NPSLandmark]>(path: path) == nil)
    }
    #expect(
      LandmarkEndpoint<[NPSLandmark]>(
        link: try #require(URL(string: "https://irmaservices.nps.gov/Unit/v2/api/"))) == nil)
    for address in [
      "https://user:password@irmaservices.nps.gov/NNLApi/v1/api/AllStates",
      "https://example.org/NNLApi/v1/api/AllStates",
      "http://irmaservices.nps.gov/NNLApi/v1/api/AllStates",
      "https://irmaservices.nps.gov:8443/NNLApi/v1/api/AllStates",
    ] {
      #expect(LandmarkEndpoint<[NPSLandmark]>(link: try #require(URL(string: address))) == nil)
    }
    let link = try #require(
      URL(string: "https://irmaservices.nps.gov/NNLApi/v1/api/LandmarkInformation?ID=212"))
    #expect(LandmarkEndpoint<[NPSLandmark]>(link: link)?.path == "/api/LandmarkInformation?ID=212")
  }

  @Test("Invalid filters never silently broaden searches")
  func invalidFilters() {
    for id: Int64 in [0, -1, .min, .max, Int64(Int32.max) + 1] {
      #expect(throws: LandmarkQuery.ValidationError.invalidIdentifier) {
        try LandmarkQuery(countyID: id)
      }
      #expect(throws: LandmarkQuery.ValidationError.invalidIdentifier) {
        try LandmarkQuery(id: id)
      }
    }
    for value in ["", " ", "\u{0}", "ME\n"] {
      #expect(throws: LandmarkQuery.ValidationError.invalidText) { try LandmarkQuery(code: value) }
      #expect(throws: LandmarkQuery.ValidationError.invalidText) {
        try LandmarkQuery(stateCode: value)
      }
    }
  }

  @Test("Query values retain bytes and distinct identifiers in stable order")
  func queryEncodingAndOrder() throws {
    let query = try LandmarkQuery(code: "A/B &?%=é", countyID: 4347, id: 212, stateCode: "--")
    let request = NPSLandmarksRequest.landmarks(query: query)
    #expect(
      request.endpoint.path
        == "/api/LandmarkInformation?Code=A%2FB%20%26%3F%25%3D%C3%A9&CountyID=4347&ID=212&StateCode=--"
    )
    #expect(
      try LandmarkEndpoint.landmarks(countyID: Int64(Int32.max)).path
        == "/api/LandmarkInformationPerCounty?CountyID=2147483647")
    #expect(LandmarkEndpoint.landmarkCounty(query: try LandmarkQuery()).path == "/api/County")
  }
}
