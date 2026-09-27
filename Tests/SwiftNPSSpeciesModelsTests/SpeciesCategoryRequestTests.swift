import SwiftNPSDataTestSupport
import SwiftNPSSpeciesModels
import Testing

@Suite("Species category requests", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct SpeciesCategoryRequestTests {
  @Test("Category request retains an inspectable fixed XML endpoint")
  func categoryRequestRetainsAnInspectableFixedXMLEndpoint() {
    let request = SpeciesCategoriesRequest()
    #expect(request.endpoint == SpeciesCategoriesEndpoint())
    #expect(request.endpoint.path == "/urlOptions/categories?format=json")
    #expect(request.endpoint.accept == "application/xml")
  }
}
