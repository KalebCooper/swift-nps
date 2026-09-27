import Foundation

/// Original public IRMA response bytes, recorded September 27, 2026.
package enum IRMAFixture: String, CaseIterable, Sendable {
  /// Recorded Species acad-checklist.json response.
  case speciesAcadiaChecklist = "Species/acad-checklist.json"
  /// Recorded Species acad-details.json response.
  case speciesAcadiaDetails = "Species/acad-details.json"
  /// Recorded Species acad-full.json response.
  case speciesAcadiaFull = "Species/acad-full.json"
  /// Recorded Species empty.json response.
  case speciesEmpty = "Species/empty.json"
  /// Fort Point full list with category segment omitted.
  case speciesFortPointAll = "Species/fopo-all.json"
  /// Fort Point full list with birds,mammals in supplied order.
  case speciesFortPointBirdsMammals = "Species/fopo-birds-mammals.json"
  /// Recorded Species http-failure.html response.
  case speciesHTTPFailure = "Species/http-failure.html"
  /// Recorded Species yell-checklist.json response.
  case speciesYellowstoneChecklist = "Species/yell-checklist.json"
  /// Recorded Species yell-details.json response.
  case speciesYellowstoneDetails = "Species/yell-details.json"
  /// Recorded Species yell-full.json response.
  case speciesYellowstoneFull = "Species/yell-full.json"
  /// ACAD January and February 2025 from the visitation route.
  case visitationAcadiaMonths = "Visitation/acadia-months.json"
  /// Unknown unit ZZZZ, returning an empty array.
  case visitationEmpty = "Visitation/empty.json"
  /// Invalid months, preserving the original HTTP 500 HTML body.
  case visitationHTTPFailure = "Visitation/http-failure.html"
  /// National monthly records for 2025, retaining null unit identifiers.
  case visitationNationalMonths = "Visitation/national-months.json"
  /// November 2025 through February 2026, retaining only the two reported months.
  case visitationSparse = "Visitation/sparse.json"

  /// Reads the exact resource extension and unmodified response body.
  package func data() throws -> Data {
    guard
      let url = Bundle.module.url(
        forResource: rawValue, withExtension: nil, subdirectory: "Fixtures/IRMA")
    else { throw FixtureFailure.missing(name: rawValue) }
    return try Data(contentsOf: url)
  }
}
