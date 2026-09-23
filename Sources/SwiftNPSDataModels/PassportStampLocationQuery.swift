/// Filters, sorting, and pagination settings for the NPS passport stamp locations endpoint.
///
/// Empty identifier, code, and sort arrays omit those parameters. Search text is preserved,
/// including empty text. The explicit defaults request 50 results starting at zero. No provider
/// maximum is assumed.
///
/// A recognized identifier selects that location, while the live endpoint ignores an identifier it
/// does not recognize and returns the unfiltered set rather than matching nothing. Park codes
/// select the locations related to those parks without narrowing each location's
/// ``PassportStampLocation/parks``.
///
/// ```swift
/// let query = try PassportStampLocationQuery(
///   parkCodes: [ParkCode("cato")], sort: [.descending("name")])
/// let endpoint = Endpoint.passportStampLocations(query: query)
/// ```
public struct PassportStampLocationQuery: NPSCollectionQuery {
  /// Why a query cannot be constructed.
  public enum ValidationError: Error, Hashable, Sendable {
    /// The page limit must be positive.
    case invalidLimit
    /// The starting offset must be nonnegative.
    case invalidStart
  }

  /// Each page decodes as a collection of ``PassportStampLocation`` values.
  public typealias Item = PassportStampLocation

  /// The passport stamp locations collection path.
  public static let path = "/passportstamplocations"

  /// Location identifiers in caller-supplied order; empty means no identifier filter.
  public let identifiers: [NPSIdentifier]
  /// The requested maximum number of results per page.
  public let limit: Int
  /// Park codes in caller-supplied order; empty means no park-code filter.
  public let parkCodes: [ParkCode]
  /// The exact text sent as `q`, or nil to omit text search.
  public let searchText: String?
  /// Sort criteria in priority order; empty uses the provider's default order, which matches
  /// `name` ascending.
  ///
  /// The live endpoint orders by label for `name`, ascending or descending. It accepts `parkCode`,
  /// ascending or descending, with no observed ordering. It answers HTTP 400 for `label`, `title`,
  /// `relevanceScore`, `fullName`, `type`, `id`, and unknown fields. Fields are sent without
  /// validation.
  public let sort: [NPSSort]
  /// The zero-based starting offset.
  public let start: Int
  /// State codes in caller-supplied order; empty means no state filter.
  public let stateCodes: [StateCode]

  /// Validates a query without contacting NPS or normalizing caller values.
  /// - Parameters:
  ///   - identifiers: Zero or more validated location identifiers, sent as `id`.
  ///   - limit: A positive page size, defaulting to 50.
  ///   - parkCodes: Zero or more validated park codes.
  ///   - searchText: Optional text to search for.
  ///   - sort: Ordered criteria naming provider sort fields, such as `name`.
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

  /// The passport stamp locations parameters for this page, omitting empty identifier, code, and sort arrays.
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
