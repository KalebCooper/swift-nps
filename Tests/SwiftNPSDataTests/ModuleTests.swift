import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("SDK dependencies", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ModuleTests {
  @Test("The HTTP test dependencies execute a request without network access")
  func theHTTPTestDependenciesExecuteARequestWithoutNetworkAccess() async throws {
    let transport = MockTransport(results: [.success(.ok(json: Data("42".utf8)))])
    let client = HTTPClient(
      baseURL: try #require(URL(string: "https://example.invalid")), transport: transport)

    let value: Int = try await client.execute(Request(path: "/resource"))

    #expect(value == 42)
    #expect(transport.requests.count == 1)
    #expect(transport.last?.request.path == "/resource")
  }
}
