#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A typed, inspectable operation confined to the NPS Taxonomy service.
///
/// Use a consumer-defined Decodable response to execute another operation below this service base.
public struct TaxonomyEndpoint<Response: Decodable & SendableMetatype>: Hashable, Sendable {
  /// JSON code-list bytes for explicit POST searches; nil for GET.
  public let body: Data?
  /// The explicit read-only submission method.
  public let method: TaxonomyMethod
  /// The encoded service-relative path and query, beginning with one slash.
  public let path: String

  /// Accepts an HTTPS link below the Taxonomy base without credentials or fragments.
  /// - Parameter link: An IRMA Taxonomy link, never a link to another IRMA service.
  public init?(link: URL) {
    guard let parts = URLComponents(url: link, resolvingAgainstBaseURL: false),
      parts.scheme?.lowercased() == "https", parts.host?.lowercased() == "irmaservices.nps.gov",
      parts.port == nil || parts.port == 443, parts.user == nil, parts.password == nil,
      parts.fragment == nil, parts.percentEncodedPath.lowercased().hasPrefix("/taxonomy/v2/rest/")
    else { return nil }
    self.init(
      path: String(parts.percentEncodedPath.dropFirst("/taxonomy/v2/rest".count))
        + (parts.percentEncodedQuery.map { "?" + $0 } ?? ""))
  }

  /// Accepts an encoded path relative to the fixed Taxonomy base.
  ///
  /// Rejects origin changes, traversal, controls, encoded separators, and API-key parameters.
  /// - Parameter path: A path such as `/sources?detail=basic&format=json`.
  public init?(path: String) {
    guard path.hasPrefix("/"), !path.hasPrefix("//"),
      path.utf8.allSatisfy({ (33...126).contains($0) }),
      let parts = URLComponents(string: path),
      parts.scheme == nil, parts.host == nil, parts.fragment == nil,
      parts.percentEncodedPath == String(path.split(separator: "?", maxSplits: 1)[0]),
      !parts.path.contains("\\"), !parts.path.hasPrefix("//"),
      !parts.path.unicodeScalars.contains(where: { $0.value < 32 || $0.value == 127 }),
      !parts.path.split(separator: "/").contains(where: { $0 == "." || $0 == ".." }),
      !["%25", "%2f", "%5c"].contains(where: { parts.percentEncodedPath.lowercased().contains($0) }
      ),
      !(parts.queryItems ?? []).contains(where: {
        ["api_key", "apikey", "key", "x-api-key"].contains($0.name.lowercased())
      })
    else { return nil }
    body = nil
    method = .get
    self.path = path
  }

  private init(body: Data?, method: TaxonomyMethod, validatedPath: String) {
    self.body = body
    self.method = method
    path = validatedPath
  }

  static func route(_ path: String, body: Data? = nil, method: TaxonomyMethod = .get) -> Self {
    guard let endpoint = Self(path: path) else {
      preconditionFailure("Validated components produce a service-relative path.")
    }
    return Self(body: body, method: method, validatedPath: endpoint.path)
  }
}
