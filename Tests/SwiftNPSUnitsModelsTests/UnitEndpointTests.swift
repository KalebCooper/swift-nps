import Foundation
import SwiftNPSDataTestSupport
import SwiftNPSUnitsModels
import Testing

@Suite("Unit endpoints", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct UnitBoundaryTests {
  @Test(
    "Executable links remain inside the Unit service",
    arguments: [
      "http://irmaservices.nps.gov/Unit/v2/api/ACAD",
      "https://other.example/Unit/v2/api/ACAD",
      "https://irmaservices.nps.gov/Unit/v2/apituff/ACAD",
      "https://irmaservices.nps.gov/v3/rest/stats/total/2025",
      "https://user:pass@irmaservices.nps.gov/Unit/v2/api/ACAD",
      "https://irmaservices.nps.gov/Unit/v2/api/ACAD#fragment",
      "https://irmaservices.nps.gov/Unit/v2/api/%2e%2e/Unit",
      "https://irmaservices.nps.gov/Unit/v2/api/ACAD?api_key=secret",
    ])
  func executableLinksRemainInsideTheUnitService(_ text: String) throws {
    let url = try #require(URL(string: text))
    #expect(UnitEndpoint<[NPSUnit]>(link: url) == nil)
  }

  @Test(
    "Relative paths refuse traversal credentials and origin changes",
    arguments: [
      "https://example.com/x", "//example.com/x", "/../x", "/%2e%2e/x",
      "/%252e%252e/x", "/x%2f..%2fy", "/x\\y", "/x%5cy", "/x#f",
      "/x?api_key=a", "/x?API_KEY=a", "/x?%61pi_key=a", "/x?X-Api-Key=a",
      "/x\ny", "/x y", "/x?key=a", "/x%00",
    ])
  func relativePathsRefuseTraversalCredentialsAndOriginChanges(_ path: String) {
    #expect(UnitEndpoint<[NPSUnit]>(path: path) == nil)
  }

  @Test("Valid service links preserve encoded queries")
  func validServiceLinksPreserveEncodedQueries() throws {
    let url = try #require(
      URL(string: "https://irmaservices.nps.gov/Unit/v2/api/ACAD%2CYELL?format=json"))
    #expect(
      UnitEndpoint<[NPSUnit]>(link: url)?.path
        == "/ACAD%2CYELL?format=json")
  }
}

@Suite("Unit endpoints", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct UnitEndpointTests {
  @Test("Administrative codes and search text remain exact")
  func administrativeCodesAndSearchTextRemainExact() throws {
    #expect(try UnitEndpoint.units(matching: "ACAD,YELL").path == "/ACAD%2CYELL?format=json")
    #expect(
      try UnitEndpoint.units(matching: "Cañon & Park").path
        == "/Ca%C3%B1on%20%26%20Park?format=json")
    #expect(
      try UnitEndpoint.linkedUnits(unitCode: "NPS", kind: .logical).path
        == "/NPS/linked/logical?format=json")
    #expect(try NPSUnitsRequest.unitSubtype(code: "OP").endpoint.path == "/subtypes/OP?format=json")
  }

  @Test(
    "Unsafe components fail before constructing a route",
    arguments: ["", ".", "..", "ACAD/YELL", "A\\B", "A%2FB", "A\nB", " "])
  func unsafeComponentsFailBeforeConstructingARoute(_ value: String) {
    #expect(throws: UnitEndpoint<[NPSUnit]>.ValidationError.self) {
      try UnitEndpoint.units(matching: value)
    }
  }
}
