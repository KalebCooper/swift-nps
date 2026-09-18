import Foundation

/// A real NPS response body; each case names its exact request and recording date.
package enum Fixture: String, CaseIterable, Sendable {
  /// GET /api/v1/alerts?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 17, 2026.
  case alertsEmpty = "alerts-empty"

  /// GET /api/v1/alerts?limit=1&parkCode=acad&start=0; HTTP 200. Recorded September 17, 2026.
  case alertsPageFirst = "alerts-page-first"

  /// GET /api/v1/alerts?limit=1&parkCode=acad&start=1; HTTP 200. Recorded September 17, 2026.
  case alertsPageLast = "alerts-page-last"

  /// GET /api/v1/alerts?limit=2&parkCode=acad,yell&start=0; HTTP 200. Recorded September 17, 2026.
  case alertsSearch = "alerts-search"

  /// GET /api/v1/parks?parkCode=acad&limit=1&start=0 without authentication; HTTP 403.
  /// Recorded September 13, 2026.
  case apiKeyMissing = "api-key-missing"

  /// GET /api/v1/parks?parkCode=acad&limit=1&start=0; HTTP 200.
  /// Recorded September 13, 2026.
  case parksAcadia = "parks-acad"

  /// GET /api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=2; HTTP 200.
  /// Recorded September 13, 2026.
  case parksBeyond = "parks-beyond"

  /// GET /api/v1/parks?parkCode=zzzz&limit=1&start=0; HTTP 200 with no matches.
  /// Recorded September 13, 2026.
  case parksEmpty = "parks-empty"

  /// GET /api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=0; HTTP 200.
  /// Recorded September 13, 2026.
  case parksPageFirst = "parks-page-first"

  /// GET /api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=1; HTTP 200.
  /// Recorded September 13, 2026.
  case parksPageLast = "parks-page-last"

  /// GET /api/v1/parks?limit=2&q=history&sort=-relevanceScore&start=0&stateCode=ME,MA; HTTP 200.
  /// Recorded September 13, 2026.
  case parksSearch = "parks-search"

  /// GET /api/v1/parks?parkCode=yell&limit=1&start=0; HTTP 200.
  /// Recorded September 13, 2026.
  case parksYellowstone = "parks-yell"

  /// GET /api/v1/visitorcenters?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 17, 2026.
  case visitorCentersEmpty = "visitorcenters-empty"

  /// GET /api/v1/visitorcenters?limit=1&parkCode=acad&sort=name&start=0; HTTP 200.
  /// Recorded September 17, 2026.
  case visitorCentersPageFirst = "visitorcenters-page-first"

  /// GET /api/v1/visitorcenters?limit=1&parkCode=acad&sort=name&start=1; HTTP 200.
  /// Recorded September 17, 2026.
  case visitorCentersPageLast = "visitorcenters-page-last"

  /// GET /api/v1/visitorcenters?limit=2&q=museum&sort=name&start=0&stateCode=ME,MA; HTTP 200.
  /// Recorded September 17, 2026.
  case visitorCentersSearch = "visitorcenters-search"

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
