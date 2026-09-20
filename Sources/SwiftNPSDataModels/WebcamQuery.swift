/// Filters and pagination settings for the NPS webcams endpoint.
///
/// Empty identifier and code arrays omit those parameters. Search text is preserved, including
/// empty text. The explicit defaults request 50 results starting at zero. No provider maximum is
/// assumed. The live endpoint answers HTTP 400 for any `sort` value, so this query has none.
///
/// ```swift
/// let query = try WebcamQuery(parkCodes: [ParkCode("yell")], searchText: "geyser")
/// let endpoint = Endpoint.webcams(query: query)
/// ```
public struct WebcamQuery: NPSCollectionQuery {
  /// Why a query cannot be constructed.
  public enum ValidationError: Error, Hashable, Sendable {
    /// The page limit must be positive.
    case invalidLimit
    /// The starting offset must be nonnegative.
    case invalidStart
  }

  /// Each page decodes as a collection of ``Webcam`` values.
  public typealias Item = Webcam

  /// The webcams collection path.
  public static let path = "/webcams"

  /// Webcam identifiers in caller-supplied order; empty means no identifier filter.
  public let identifiers: [NPSIdentifier]
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
  ///   - identifiers: Zero or more validated webcam identifiers, sent as `id`.
  ///   - limit: A positive page size, defaulting to 50.
  ///   - parkCodes: Zero or more validated park codes.
  ///   - searchText: Optional text to search for.
  ///   - start: A nonnegative starting offset, defaulting to zero.
  ///   - stateCodes: Zero or more validated state codes.
  /// - Throws: ``ValidationError/invalidLimit`` or ``ValidationError/invalidStart``.
  public init(
    identifiers: [NPSIdentifier] = [], limit: Int = 50, parkCodes: [ParkCode] = [],
    searchText: String? = nil, start: Int = 0, stateCodes: [StateCode] = []
  ) throws(ValidationError) {
    guard limit > 0 else { throw .invalidLimit }
    guard start >= 0 else { throw .invalidStart }
    self.identifiers = identifiers
    self.limit = limit
    self.parkCodes = parkCodes
    self.searchText = searchText
    self.start = start
    self.stateCodes = stateCodes
  }

  private init(copy: Self, start: Int) {
    self.identifiers = copy.identifiers
    self.limit = copy.limit
    self.parkCodes = copy.parkCodes
    self.searchText = copy.searchText
    self.start = start
    self.stateCodes = copy.stateCodes
  }

  /// The webcams parameters for this page, omitting empty identifier and code arrays.
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
