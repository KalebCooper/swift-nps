import Foundation

/// A real NPS response recorded on September 13, 2026.
package enum Fixture: String, CaseIterable, Sendable {
  /// GET /api/v1/parks?parkCode=acad&limit=1&start=0 without authentication; HTTP 403.
  case apiKeyMissing = "api-key-missing"

  /// GET /api/v1/parks?parkCode=acad&limit=1&start=0; HTTP 200.
  case parksAcadia = "parks-acad"

  /// GET /api/v1/parks?parkCode=zzzz&limit=1&start=0; HTTP 200 with no matches.
  case parksEmpty = "parks-empty"

  /// GET /api/v1/parks?parkCode=yell&limit=1&start=0; HTTP 200.
  case parksYellowstone = "parks-yell"

  /// Reads the recorded JSON response; see Fixtures/README.md for lossless escaping.
  package func data() throws -> Data {
    guard
      let url = Bundle.module.url(
        forResource: rawValue, withExtension: "json", subdirectory: "Fixtures")
    else { throw FixtureFailure.missing(name: rawValue) }
    return try Data(contentsOf: url)
  }
}

/// Why a recorded response could not be read.
package enum FixtureFailure: Error, Hashable, Sendable {
  /// The named resource is absent from the bundle.
  case missing(name: String)
}
