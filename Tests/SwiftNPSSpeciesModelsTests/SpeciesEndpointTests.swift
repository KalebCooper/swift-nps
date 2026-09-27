import Foundation
import SwiftNPSDataTestSupport
import SwiftNPSSpeciesModels
import Testing

@Suite("Species endpoints", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct SpeciesEndpointTests {
  @Test(
    "Executable links remain inside the Species service",
    arguments: [
      "http://irmaservices.nps.gov/NPSpecies/v3/rest/fulllist/ACAD/birds",
      "https://other.example/NPSpecies/v3/rest/fulllist/ACAD/birds",
      "https://irmaservices.nps.gov/NPSpecies/v3/resttuff/fulllist/ACAD/birds",
      "https://irmaservices.nps.gov/Unit/v2/api/ACAD",
      "https://user:pass@irmaservices.nps.gov/NPSpecies/v3/rest/fulllist/ACAD/birds",
      "https://irmaservices.nps.gov/NPSpecies/v3/rest/fulllist/ACAD/birds#fragment",
      "https://irmaservices.nps.gov/NPSpecies/v3/rest/%2e%2e/Unit",
      "https://irmaservices.nps.gov/NPSpecies/v3/rest/fulllist/ACAD/birds?api_key=secret",
    ])
  func executableLinksRemainInsideTheSpeciesService(_ text: String) throws {
    let url = try #require(URL(string: text))
    #expect(SpeciesEndpoint<[SpeciesItem]>(link: url) == nil)
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
    #expect(SpeciesEndpoint<[SpeciesItem]>(path: path) == nil)
  }

  @Test("Valid service links preserve encoded queries")
  func validServiceLinksPreserveEncodedQueries() throws {
    let url = try #require(
      URL(
        string:
          "https://irmaservices.nps.gov/NPSpecies/v3/rest/fulllist/ACAD/birds%2Cmammals?format=json"
      )
    )
    #expect(
      SpeciesEndpoint<[SpeciesItem]>(link: url)?.path
        == "/fulllist/ACAD/birds%2Cmammals?format=json")
  }
}
