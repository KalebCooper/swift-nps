import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Models module", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ModuleTests {
  @Test("Fixture instructions are available from the resource bundle")
  func fixtureInstructionsAreAvailableFromTheResourceBundle() throws {
    let data = try Fixture.instructions.data()
    #expect(String(decoding: data, as: UTF8.self).hasPrefix("# Recorded responses\n"))
  }
}
