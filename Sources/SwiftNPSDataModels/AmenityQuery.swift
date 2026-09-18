/// Filters and pagination settings for the NPS amenities endpoint.
///
/// An empty identifier array omits that parameter. Search text is preserved, including empty text.
/// The explicit defaults request 50 results starting at zero. No provider maximum is assumed. NPS
/// documents no park, state, or sort parameter for `/amenities`, so this query has none.
///
/// ```swift
/// let query = try AmenityQuery(searchText: "restroom")
/// let endpoint = Endpoint.amenities(query: query)
/// ```
public struct AmenityQuery: NPSCollectionQuery {
  /// Why a query cannot be constructed.
  public enum ValidationError: Error, Hashable, Sendable {
    /// The page limit must be positive.
    case invalidLimit
    /// The starting offset must be nonnegative.
    case invalidStart
  }

  /// Each page decodes as a collection of ``Amenity`` values.
  public typealias Item = Amenity

  /// The amenities collection path.
  public static let path = "/amenities"

  /// Amenity identifiers in caller-supplied order; empty means no identifier filter.
  public let identifiers: [NPSIdentifier]
  /// The requested maximum number of results per page.
  public let limit: Int
  /// The exact text sent as `q`, or nil to omit text search.
  public let searchText: String?
  /// The zero-based starting offset.
  public let start: Int

  /// Validates a query without contacting NPS or normalizing caller values.
  /// - Parameters:
  ///   - identifiers: Zero or more validated amenity identifiers, sent as `id`.
  ///   - limit: A positive page size, defaulting to 50.
  ///   - searchText: Optional text to search for.
  ///   - start: A nonnegative starting offset, defaulting to zero.
  /// - Throws: ``ValidationError/invalidLimit`` or ``ValidationError/invalidStart``.
  public init(
    identifiers: [NPSIdentifier] = [], limit: Int = 50, searchText: String? = nil, start: Int = 0
  ) throws(ValidationError) {
    guard limit > 0 else { throw .invalidLimit }
    guard start >= 0 else { throw .invalidStart }
    self.identifiers = identifiers
    self.limit = limit
    self.searchText = searchText
    self.start = start
  }

  private init(copy: Self, start: Int) {
    self.identifiers = copy.identifiers
    self.limit = copy.limit
    self.searchText = copy.searchText
    self.start = start
  }

  /// The amenities parameters for this page, omitting an empty identifier array.
  public var queryItems: [NPSQueryItem] {
    var items: [NPSQueryItem] = []
    if !identifiers.isEmpty {
      items.append(NPSQueryItem(name: "id", values: identifiers.map(\.rawValue)))
    }
    items.append(NPSQueryItem(name: "limit", value: String(limit)))
    if let searchText { items.append(NPSQueryItem(name: "q", value: searchText)) }
    items.append(NPSQueryItem(name: "start", value: String(start)))
    return items
  }

  /// Returns this query at a different offset with every filter unchanged.
  /// - Parameter start: A nonnegative starting offset already validated by the caller.
  /// - Returns: The same query beginning at `start`.
  public func starting(at start: Int) -> Self {
    Self(copy: self, start: start)
  }
}
