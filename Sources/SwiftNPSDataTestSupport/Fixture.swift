import Foundation

/// A bundled resource used to verify the test resource layout.
///
/// No NPS response has been recorded. Replace the instructions case with recorded JSON cases
/// when the first service operation is implemented, documenting each exact path and query.
package enum Fixture: String, CaseIterable, Sendable {
  /// The fixture recording instructions, not an API response.
  case instructions = "README"

  /// Reads the bundled resource.
  package func data() throws -> Data {
    guard
      let url = Bundle.module.url(
        forResource: rawValue, withExtension: "md", subdirectory: "Fixtures")
    else {
      throw FixtureFailure.missing(name: rawValue)
    }
    return try Data(contentsOf: url)
  }
}

/// Why a bundled resource could not be read.
package enum FixtureFailure: Error, Hashable, Sendable {
  /// The resource is absent from the bundle.
  case missing(name: String)
}
