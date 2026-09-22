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

extension Endpoint {
  /// Describes one page of any offset-paginated collection from its validated query.
  ///
  /// Parameters are serialized in name order, each value percent-encoded and list values joined
  /// with commas, so equal queries always produce identical paths.
  /// - Parameter query: A validated collection query, including its explicit limit and start.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope for the page.
  public static func collection<Query: NPSCollectionQuery>(
    _ query: Query
  ) -> Self where Response == NPSCollection<Query.Item> {
    let items = query.queryItems.sorted { $0.name < $1.name }.map(\.encoded)
    guard let endpoint = Self(path: Query.path + "?" + items.joined(separator: "&")) else {
      preconditionFailure(
        "Validated query values and percent-encoded parameters form a relative endpoint.")
    }
    return endpoint
  }
}
