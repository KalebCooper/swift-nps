import Foundation
import SwiftNPSDataTestSupport
import SwiftNPSTaxonomyModels
import Testing

@Suite("Taxonomy confinement", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct TaxonomyEndpointTests {
  @Test("Only same-service HTTPS links become executable endpoints")
  func executableLinks() throws {
    for path in ["/taxonomy/v2/rest/", "/Taxonomy/v2/rest/"] {
      let url = try #require(
        URL(
          string: "https://irmaservices.nps.gov" + path + "81838?codeType=taxoncode&detail=profile")
      )
      #expect(
        TaxonomyEndpoint<NPSTaxonProfile>(link: url)?.path
          == "/81838?codeType=taxoncode&detail=profile")
    }
    for value in [
      "http://irmaservices.nps.gov/taxonomy/v2/rest/81838",
      "https://user:secret@irmaservices.nps.gov/taxonomy/v2/rest/81838",
      "https://example.org/taxonomy/v2/rest/81838",
      "https://www.itis.gov/servlet/SingleRpt/SingleRpt?search_value=81838",
      "https://irmaservices.nps.gov/Unit/v2/api/ACAD",
      "https://irmaservices.nps.gov:8443/taxonomy/v2/rest/81838",
      "https://irmaservices.nps.gov/taxonomy/v2/restful/81838",
      "https://irmaservices.nps.gov/taxonomy/v2/rest/81838#fragment",
    ] {
      #expect(TaxonomyEndpoint<NPSTaxonProfile>(link: try #require(URL(string: value))) == nil)
    }
  }

  @Test("Relative paths reject origin changes traversal and credentials")
  func relativePaths() {
    for path in [
      "//example.org", "/../sources", "/%2e%2e/sources", "/%252e%252e/sources", "/x%2Fy", "/x%5Cy",
      "/x?api_key=secret", "/x?X-Api-Key=secret", "/x#fragment",
    ] {
      #expect(TaxonomyEndpoint<NPSTaxonProfile>(path: path) == nil)
    }
  }
}
