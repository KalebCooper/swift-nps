/// Filters, sorting, and pagination settings for the NPS activity parks endpoint.
///
/// Empty identifier, code, and sort arrays omit those parameters. Search text is preserved,
/// including empty text. The explicit defaults request 50 results starting at zero. No provider
/// maximum is assumed. The live endpoint ignores `stateCode`, so this query has none.
///
/// Park codes select the activities offered at those parks and also narrow each activity's
/// ``ActivityParks/parks`` to the requested parks. The live endpoint ignores an identifier it does
/// not recognize rather than matching nothing.
///
/// ```swift
/// let query = try ActivityParksQuery(parkCodes: [ParkCode("drto")], sort: [.descending("name")])
/// let endpoint = Endpoint.activityParks(query: query)
/// ```
public struct ActivityParksQuery: NPSCollectionQuery {
  /// Why a query cannot be constructed.
  public enum ValidationError: Error, Hashable, Sendable {
    /// The page limit must be positive.
    case invalidLimit
    /// The starting offset must be nonnegative.
    case invalidStart
  }

  /// Each page decodes as a collection of ``ActivityParks`` values.
  public typealias Item = ActivityParks

  /// The activity parks collection path.
  public static let path = "/activities/parks"

  /// Activity identifiers in caller-supplied order; empty means no identifier filter.
  public let identifiers: [NPSIdentifier]
  /// The requested maximum number of results per page.
  public let limit: Int
  /// Park codes in caller-supplied order; empty means no park-code filter.
  public let parkCodes: [ParkCode]
  /// The exact text sent as `q`, or nil to omit text search.
  public let searchText: String?
  /// Sort criteria in priority order; empty uses the provider's default order.
  ///
  /// The live endpoint sorts by `name`, ascending or descending, and answers HTTP 400 for other
  /// fields such as `fullName`, `id`, `parkCode`, and `relevanceScore`. Fields are sent without
  /// validation.
  public let sort: [NPSSort]
  /// The zero-based starting offset.
  public let start: Int

  /// Validates a query without contacting NPS or normalizing caller values.
  /// - Parameters:
  ///   - identifiers: Zero or more validated activity identifiers, sent as `id`.
  ///   - limit: A positive page size, defaulting to 50.
  ///   - parkCodes: Zero or more validated park codes.
  ///   - searchText: Optional text to search for.
  ///   - sort: Ordered criteria naming activity properties, such as `name`.
  ///   - start: A nonnegative starting offset, defaulting to zero.
  /// - Throws: ``ValidationError/invalidLimit`` or ``ValidationError/invalidStart``.
  public init(
    identifiers: [NPSIdentifier] = [], limit: Int = 50, parkCodes: [ParkCode] = [],
    searchText: String? = nil, sort: [NPSSort] = [], start: Int = 0
  ) throws(ValidationError) {
    guard limit > 0 else { throw .invalidLimit }
    guard start >= 0 else { throw .invalidStart }
    self.identifiers = identifiers
    self.limit = limit
    self.parkCodes = parkCodes
    self.searchText = searchText
    self.sort = sort
    self.start = start
  }

  private init(copy: Self, start: Int) {
    self.identifiers = copy.identifiers
    self.limit = copy.limit
    self.parkCodes = copy.parkCodes
    self.searchText = copy.searchText
    self.sort = copy.sort
    self.start = start
  }

  /// The activity parks parameters for this page, omitting empty identifier, code, and sort
  /// arrays.
  public var queryItems: [NPSQueryItem] {
    var items: [NPSQueryItem] = []
    if !identifiers.isEmpty {
      items.append(NPSQueryItem(name: "id", values: identifiers.map(\.rawValue)))
    }
    items.append(NPSQueryItem(name: "limit", value: String(limit)))
    if !parkCodes.isEmpty {
      items.append(NPSQueryItem(name: "parkCode", values: parkCodes.map(\.rawValue)))
    }
    if let searchText { items.append(NPSQueryItem(name: "q", value: searchText)) }
    if !sort.isEmpty {
      items.append(NPSQueryItem(name: "sort", values: sort.map(\.queryValue)))
    }
    items.append(NPSQueryItem(name: "start", value: String(start)))
    return items
  }

  /// Returns this query at a different offset with every filter and sort criterion unchanged.
  /// - Parameter start: A nonnegative starting offset already validated by the caller.
  /// - Returns: The same query beginning at `start`.
  public func starting(at start: Int) -> Self {
    Self(copy: self, start: start)
  }
}
