#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// One GET operation relative to `https://developer.nps.gov/api/v1`, with its response type.
///
/// Construction does no I/O. A custom executor sends ``path`` with `Accept: application/json`
/// and its own `X-Api-Key` header, then decodes `Response`. Credentials never belong in this value.
///
/// ```swift
/// let endpoint = Endpoint.parks(parkCode: try ParkCode("acad"))
/// print(endpoint.path) // "/parks?parkCode=acad&limit=1&start=0"
/// ```
public struct Endpoint<Response>: Hashable, Sendable {
  /// The encoded path and query relative to the API base, starting with one slash.
  public let path: String

  /// Accepts an absolute HTTPS NPS API link without credentials or a fragment.
  ///
  /// Only `developer.nps.gov`, port 443 or no port, and paths below `/api/v1/` are accepted.
  /// Public website and image links are not API endpoints. Encoded paths and queries are retained.
  /// - Parameter link: A provider link to interpret with a consumer-defined response type.
  public init?(link: URL) {
    guard let components = URLComponents(url: link, resolvingAgainstBaseURL: false),
      components.scheme?.lowercased() == "https",
      components.host?.lowercased() == "developer.nps.gov",
      components.port == nil || components.port == 443,
      components.user == nil, components.password == nil,
      components.fragment == nil,
      components.percentEncodedPath.hasPrefix("/api/v1/")
    else { return nil }
    let query = components.percentEncodedQuery.map { "?" + $0 } ?? ""
    self.init(path: String(components.percentEncodedPath.dropFirst("/api/v1".count)) + query)
  }

  /// Accepts an encoded relative API path for a consumer-defined response.
  ///
  /// Rejects absolute URLs, fragments, traversal segments, backslashes, whitespace, and
  /// `api_key` query parameters. The path cannot escape the configured API origin.
  /// - Parameter path: A path such as `/parks?parkCode=acad&limit=1&start=0`.
  public init?(path: String) {
    guard path.hasPrefix("/"), !path.hasPrefix("//"),
      path.utf8.allSatisfy({ (33...126).contains($0) }),
      let components = URLComponents(string: path),
      components.scheme == nil, components.host == nil,
      components.fragment == nil,
      components.percentEncodedPath == String(path.split(separator: "?", maxSplits: 1)[0]),
      !components.path.contains("\\"),
      !components.path.hasPrefix("//"),
      !components.path.split(separator: "/").contains(where: { $0 == "." || $0 == ".." }),
      !(components.queryItems ?? []).contains(where: { $0.name.lowercased() == "api_key" })
    else { return nil }
    self.path = path
  }
}

extension Endpoint where Response == ParksResponse {
  /// Looks up one code using `/parks`, explicitly requesting one result starting at zero.
  ///
  /// The provider envelope is retained, including an empty data array for an unknown code.
  /// No subsequent page is fetched and no result is selected from the response.
  /// - Parameter parkCode: A validated single park code.
  /// - Returns: A transport-independent endpoint returning ``ParksResponse``.
  public static func parks(parkCode: ParkCode) -> Self {
    guard let endpoint = Self(path: "/parks?parkCode=\(parkCode.rawValue)&limit=1&start=0") else {
      preconditionFailure("A validated park code produces a valid relative parks endpoint.")
    }
    return endpoint
  }

  /// Describes one parks page with filters, text search, sorting, and explicit pagination.
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``ParksResponse`` envelope.
  public static func parks(query: ParkQuery) -> Self {
    var items = ["limit=\(query.limit)"]
    if !query.parkCodes.isEmpty {
      items.append("parkCode=" + query.parkCodes.map(\.rawValue).joined(separator: ","))
    }
    if let text = query.searchText { items.append("q=" + encode(text)) }
    if !query.sort.isEmpty {
      items.append("sort=" + query.sort.map(\.queryValue).joined(separator: ","))
    }
    items.append("start=\(query.start)")
    if !query.stateCodes.isEmpty {
      items.append("stateCode=" + query.stateCodes.map(\.rawValue).joined(separator: ","))
    }
    guard let endpoint = Self(path: "/parks?" + items.joined(separator: "&")) else {
      preconditionFailure(
        "Validated query values and percent-encoded text form a relative endpoint.")
    }
    return endpoint
  }

  private static func encode(_ value: String) -> String {
    value.utf8.map { byte in
      if (48...57).contains(byte) || (65...90).contains(byte) || (97...122).contains(byte)
        || [45, 46, 95, 126].contains(byte)
      {
        return String(UnicodeScalar(byte))
      }
      let hex = String(byte, radix: 16, uppercase: true)
      return "%" + (hex.count == 1 ? "0" : "") + hex
    }.joined()
  }
}
