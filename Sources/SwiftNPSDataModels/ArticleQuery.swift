/// Filters and pagination settings for the NPS articles endpoint.
///
/// Empty code arrays omit those parameters. Search text is preserved, including empty text. The
/// explicit defaults request 50 results starting at zero. No provider maximum is assumed. The live
/// endpoint answers `sort=title` with HTTP 400, so this query has no sort parameter.
///
/// ```swift
/// let query = try ArticleQuery(parkCodes: [ParkCode("arch")], searchText: "geology")
/// let endpoint = Endpoint.articles(query: query)
/// ```
public struct ArticleQuery: NPSCollectionQuery {
  /// Why a query cannot be constructed.
  public enum ValidationError: Error, Hashable, Sendable {
    /// The page limit must be positive.
    case invalidLimit
    /// The starting offset must be nonnegative.
    case invalidStart
  }

  /// Each page decodes as a collection of ``Article`` values.
  public typealias Item = Article

  /// The articles collection path.
  public static let path = "/articles"

  /// The requested maximum number of results per page.
  public let limit: Int
  /// Park codes in caller-supplied order; empty means no park-code filter.
  public let parkCodes: [ParkCode]
  /// The exact text sent as `q`, or nil to omit text search.
  public let searchText: String?
  /// The zero-based starting offset.
  public let start: Int
  /// State codes in caller-supplied order; empty means no state filter.
  public let stateCodes: [StateCode]

  /// Validates a query without contacting NPS or normalizing caller values.
  /// - Parameters:
  ///   - limit: A positive page size, defaulting to 50.
  ///   - parkCodes: Zero or more validated park codes.
  ///   - searchText: Optional text to search for.
  ///   - start: A nonnegative starting offset, defaulting to zero.
  ///   - stateCodes: Zero or more validated state codes.
  /// - Throws: ``ValidationError/invalidLimit`` or ``ValidationError/invalidStart``.
  public init(
    limit: Int = 50, parkCodes: [ParkCode] = [], searchText: String? = nil, start: Int = 0,
    stateCodes: [StateCode] = []
  ) throws(ValidationError) {
    guard limit > 0 else { throw .invalidLimit }
    guard start >= 0 else { throw .invalidStart }
    self.limit = limit
    self.parkCodes = parkCodes
    self.searchText = searchText
    self.start = start
    self.stateCodes = stateCodes
  }

  private init(copy: Self, start: Int) {
    self.limit = copy.limit
    self.parkCodes = copy.parkCodes
    self.searchText = copy.searchText
    self.start = start
    self.stateCodes = copy.stateCodes
  }

  /// The articles parameters for this page, omitting empty code arrays.
  public var queryItems: [NPSQueryItem] {
    var items = [NPSQueryItem(name: "limit", value: String(limit))]
    if !parkCodes.isEmpty {
      items.append(NPSQueryItem(name: "parkCode", values: parkCodes.map(\.rawValue)))
    }
    if let searchText { items.append(NPSQueryItem(name: "q", value: searchText)) }
    items.append(NPSQueryItem(name: "start", value: String(start)))
    if !stateCodes.isEmpty {
      items.append(NPSQueryItem(name: "stateCode", values: stateCodes.map(\.rawValue)))
    }
    return items
  }

  /// Returns this query at a different offset with every filter unchanged.
  /// - Parameter start: A nonnegative starting offset already validated by the caller.
  /// - Returns: The same query beginning at `start`.
  public func starting(at start: Int) -> Self {
    Self(copy: self, start: start)
  }
}
