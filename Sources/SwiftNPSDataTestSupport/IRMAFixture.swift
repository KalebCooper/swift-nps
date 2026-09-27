import Foundation

/// Original public IRMA response bytes, recorded September 27, 2026.
package enum IRMAFixture: String, CaseIterable, Sendable {
  /// ACAD January and February 2025 from the visitation route.
  case visitationAcadiaMonths = "acadia-months.json"
  /// Unknown unit ZZZZ, returning an empty array.
  case visitationEmpty = "empty.json"
  /// Invalid months, preserving the original HTTP 500 HTML body.
  case visitationHTTPFailure = "http-failure.html"
  /// National monthly records for 2025, retaining null unit identifiers.
  case visitationNationalMonths = "national-months.json"
  /// November 2025 through February 2026, retaining only the two reported months.
  case visitationSparse = "sparse.json"

  /// Reads the exact resource extension and unmodified response body.
  package func data() throws -> Data {
    guard
      let url = Bundle.module.url(
        forResource: rawValue, withExtension: nil, subdirectory: "Fixtures/IRMA/Visitation")
    else { throw FixtureFailure.missing(name: rawValue) }
    return try Data(contentsOf: url)
  }
}
