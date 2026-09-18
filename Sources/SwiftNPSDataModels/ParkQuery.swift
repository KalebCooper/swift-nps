/// Filters and pagination settings for the NPS parks endpoint.
///
/// Empty code and sort arrays omit those parameters. Search text is preserved, including empty
/// text. The explicit defaults request 50 results starting at zero. No provider maximum is assumed.
///
/// ```swift
/// let query = try ParkQuery(searchText: "history", stateCodes: [StateCode("MA")])
/// let endpoint = Endpoint.parks(query: query)
/// ```
public struct ParkQuery: NPSCollectionQuery {
  /// Why a query cannot be constructed.
  public enum ValidationError: Error, Hashable, Sendable {
    /// The page limit must be positive.
    case invalidLimit
    /// The starting offset must be nonnegative.
    case invalidStart
    /// Relevance sorting must be the only sort criterion.
    case mixedRelevanceSort
  }

  /// Each page decodes as a collection of ``Park`` values.
  public typealias Item = Park

  /// The parks collection path.
  public static let path = "/parks"

  /// The requested maximum number of results per page.
  public let limit: Int
  /// Park codes in caller-supplied order; empty means no park-code filter.
  public let parkCodes: [ParkCode]
  /// The exact text sent as `q`, or nil to omit text search.
  public let searchText: String?
  /// Sort criteria in priority order; empty uses NPS's default of full name.
  ///
  /// NPS documents `fullName`, `parkCode`, and `relevanceScore` for parks, and requires
  /// `relevanceScore` to be the sole criterion when used.
  public let sort: [NPSSort]
  /// The zero-based starting offset.
  public let start: Int
  /// State codes in caller-supplied order; empty means no state filter.
  public let stateCodes: [StateCode]

  /// Validates a query without contacting NPS or normalizing caller values.
  /// - Parameters:
  ///   - limit: A positive page size, defaulting to 50.
  ///   - parkCodes: Zero or more validated park codes.
  ///   - searchText: Optional text to search for.
  ///   - sort: Ordered criteria; relevance cannot be combined with another criterion.
  ///   - start: A nonnegative starting offset, defaulting to zero.
  ///   - stateCodes: Zero or more validated state codes.
  /// - Throws: ``ValidationError`` for invalid pagination or mixed relevance sorting.
  public init(
    limit: Int = 50, parkCodes: [ParkCode] = [], searchText: String? = nil,
    sort: [NPSSort] = [], start: Int = 0, stateCodes: [StateCode] = []
  ) throws(ValidationError) {
    guard limit > 0 else { throw .invalidLimit }
    guard start >= 0 else { throw .invalidStart }
    guard sort.count <= 1 || !sort.contains(where: { $0.field == "relevanceScore" }) else {
      throw .mixedRelevanceSort
    }
    self.limit = limit
    self.parkCodes = parkCodes
    self.searchText = searchText
    self.sort = sort
    self.start = start
    self.stateCodes = stateCodes
  }

  private init(copy: Self, start: Int) {
    self.limit = copy.limit
    self.parkCodes = copy.parkCodes
    self.searchText = copy.searchText
    self.sort = copy.sort
    self.start = start
    self.stateCodes = copy.stateCodes
  }

  /// The parks parameters for this page, omitting empty code and sort arrays.
  public var queryItems: [NPSQueryItem] {
    var items = [NPSQueryItem(name: "limit", value: String(limit))]
    if !parkCodes.isEmpty {
      items.append(NPSQueryItem(name: "parkCode", values: parkCodes.map(\.rawValue)))
    }
    if let searchText { items.append(NPSQueryItem(name: "q", value: searchText)) }
    if !sort.isEmpty {
      items.append(NPSQueryItem(name: "sort", values: sort.map(\.queryValue)))
    }
    items.append(NPSQueryItem(name: "start", value: String(start)))
    if !stateCodes.isEmpty {
      items.append(NPSQueryItem(name: "stateCode", values: stateCodes.map(\.rawValue)))
    }
    return items
  }

  /// Returns this query at a different offset with every filter and sort criterion unchanged.
  /// - Parameter start: A nonnegative starting offset already validated by the caller.
  /// - Returns: The same query beginning at `start`.
  public func starting(at start: Int) -> Self {
    Self(copy: self, start: start)
  }
}
