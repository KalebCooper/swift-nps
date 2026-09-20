/// Filters, sorting, and pagination settings for the NPS tours endpoint.
///
/// Empty identifier, code, and sort arrays omit those parameters. Search text is preserved,
/// including empty text. The explicit defaults request 50 results starting at zero. No provider
/// maximum is assumed.
///
/// `relevanceScore` is the only sort field the live tours service accepts. It answers other fields,
/// such as `title`, with HTTP 400. Sort fields are sent without validation, so that failure
/// surfaces from NPS rather than from this query.
///
/// ```swift
/// let query = try TourQuery(
///   parkCodes: [ParkCode("yell")], searchText: "geyser", sort: [.descending("relevanceScore")])
/// let endpoint = Endpoint.tours(query: query)
/// ```
public struct TourQuery: NPSCollectionQuery {
  /// Why a query cannot be constructed.
  public enum ValidationError: Error, Hashable, Sendable {
    /// The page limit must be positive.
    case invalidLimit
    /// The starting offset must be nonnegative.
    case invalidStart
  }

  /// Each page decodes as a collection of ``Tour`` values.
  public typealias Item = Tour

  /// The tours collection path.
  public static let path = "/tours"

  /// Tour identifiers in caller-supplied order; empty means no identifier filter.
  public let identifiers: [NPSIdentifier]
  /// The requested maximum number of results per page.
  public let limit: Int
  /// Park codes in caller-supplied order; empty means no park-code filter.
  public let parkCodes: [ParkCode]
  /// The exact text sent as `q`, or nil to omit text search.
  public let searchText: String?
  /// Sort criteria in priority order; empty uses the provider's default order.
  ///
  /// The live tours service accepts only `relevanceScore` and answers other fields with HTTP 400.
  /// Fields are sent without validation.
  public let sort: [NPSSort]
  /// The zero-based starting offset.
  public let start: Int
  /// State codes in caller-supplied order; empty means no state filter.
  public let stateCodes: [StateCode]

  /// Validates a query without contacting NPS or normalizing caller values.
  /// - Parameters:
  ///   - identifiers: Zero or more validated tour identifiers, sent as `id`.
  ///   - limit: A positive page size, defaulting to 50.
  ///   - parkCodes: Zero or more validated park codes.
  ///   - searchText: Optional text to search for.
  ///   - sort: Ordered criteria; the live service accepts only `relevanceScore`.
  ///   - start: A nonnegative starting offset, defaulting to zero.
  ///   - stateCodes: Zero or more validated state codes.
  /// - Throws: ``ValidationError/invalidLimit`` or ``ValidationError/invalidStart``.
  public init(
    identifiers: [NPSIdentifier] = [], limit: Int = 50, parkCodes: [ParkCode] = [],
    searchText: String? = nil, sort: [NPSSort] = [], start: Int = 0,
    stateCodes: [StateCode] = []
  ) throws(ValidationError) {
    guard limit > 0 else { throw .invalidLimit }
    guard start >= 0 else { throw .invalidStart }
    self.identifiers = identifiers
    self.limit = limit
    self.parkCodes = parkCodes
    self.searchText = searchText
    self.sort = sort
    self.start = start
    self.stateCodes = stateCodes
  }

  private init(copy: Self, start: Int) {
    self.identifiers = copy.identifiers
    self.limit = copy.limit
    self.parkCodes = copy.parkCodes
    self.searchText = copy.searchText
    self.sort = copy.sort
    self.start = start
    self.stateCodes = copy.stateCodes
  }

  /// The tours parameters for this page, omitting empty identifier, code, and sort arrays.
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
