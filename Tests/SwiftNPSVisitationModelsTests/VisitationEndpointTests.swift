import Foundation
import SwiftNPSDataTestSupport
import SwiftNPSVisitationModels
import Testing

@Suite("Visitation endpoints", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct VisitationEndpointTests {
  @Test(
    "Executable links remain inside the statistics service",
    arguments: [
      "http://irmaservices.nps.gov/v3/rest/stats/total/2025",
      "https://other.example/v3/rest/stats/total/2025",
      "https://irmaservices.nps.gov/v3/rest/statstuff/total/2025",
      "https://irmaservices.nps.gov/Unit/v2/api/ACAD",
      "https://user:pass@irmaservices.nps.gov/v3/rest/stats/total/2025",
      "https://irmaservices.nps.gov/v3/rest/stats/total/2025#fragment",
      "https://irmaservices.nps.gov/v3/rest/stats/%2e%2e/Unit",
      "https://irmaservices.nps.gov/v3/rest/stats/total/2025?api_key=secret",
    ])
  func executableLinksRemainInsideTheStatisticsService(_ text: String) throws {
    let url = try #require(URL(string: text))
    #expect(VisitationEndpoint<[NPSVisitationRecord]>(link: url) == nil)
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
    #expect(VisitationEndpoint<[NPSVisitationRecord]>(path: path) == nil)
  }

  @Test("Valid service links preserve encoded queries")
  func validServiceLinksPreserveEncodedQueries() throws {
    let url = try #require(
      URL(string: "https://irmaservices.nps.gov/v3/rest/stats/visitation?unitCodes=ACAD%2CYELL"))
    #expect(
      VisitationEndpoint<[NPSVisitationRecord]>(link: url)?.path
        == "/visitation?unitCodes=ACAD%2CYELL")
  }
}
