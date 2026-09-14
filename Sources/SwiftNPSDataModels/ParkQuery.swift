/// Filters and pagination settings for the NPS parks endpoint.
///
/// Empty code and sort arrays omit those parameters. Search text is preserved, including empty
/// text. The explicit defaults request 50 results starting at zero. No provider maximum is assumed.
///
/// ```swift
/// let query = try ParkQuery(searchText: "history", stateCodes: [StateCode("MA")])
/// let endpoint = Endpoint.parks(query: query)
/// ```
public struct ParkQuery: Hashable, Sendable {
  /// Why a query cannot be constructed.
  public enum ValidationError: Error, Hashable, Sendable {
    /// The page limit must be positive.
    case invalidLimit
    /// The starting offset must be nonnegative.
    case invalidStart
    /// Relevance sorting must be the only sort criterion.
    case mixedRelevanceSort
  }

  /// The requested maximum number of results per page.
  public let limit: Int
  /// Park codes in caller-supplied order; empty means no park-code filter.
  public let parkCodes: [ParkCode]
  /// The exact text sent as `q`, or nil to omit text search.
  public let searchText: String?
  /// Sort criteria in priority order; empty uses NPS's default of full name.
  public let sort: [ParkSort]
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
    sort: [ParkSort] = [], start: Int = 0, stateCodes: [StateCode] = []
  ) throws(ValidationError) {
    guard limit > 0 else { throw .invalidLimit }
    guard start >= 0 else { throw .invalidStart }
    guard sort.count <= 1 || !sort.contains(where: { $0.isRelevance }) else {
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

  /// Validates a received page and describes the following request, if any.
  ///
  /// Advances by the number of returned parks, preserving all other options. A page ends the
  /// traversal when its returned range reaches the reported total. An empty page is terminal only
  /// at or beyond that total. Results can change between requests; this is not a snapshot guarantee.
  /// - Parameter page: The response to this query's starting offset.
  /// - Returns: The next query, or nil for a terminal page.
  /// - Throws: ``ParkPaginationError`` for unusable metadata, inconsistent data, or overflow.
  public func next(after page: ParksResponse) throws(ParkPaginationError) -> Self? {
    let receivedLimit = try Self.integer(page.limit, field: "limit")
    let receivedStart = try Self.integer(page.start, field: "start")
    let total = try Self.integer(page.total, field: "total")
    guard receivedLimit > 0 else { throw .invalidMetadata(field: "limit", value: page.limit) }
    guard receivedStart == start else {
      throw .unexpectedStart(actual: receivedStart, expected: start)
    }
    guard page.data.count <= receivedLimit else { throw .inconsistentPage }
    if page.data.isEmpty {
      guard start >= total else { throw .inconsistentPage }
      return nil
    }
    let (following, overflow) = start.addingReportingOverflow(page.data.count)
    guard !overflow else { throw .offsetOverflow }
    guard following <= total else { throw .inconsistentPage }
    return following == total ? nil : Self(copy: self, start: following)
  }

  package func starting(at start: Int) -> Self {
    Self(copy: self, start: start)
  }

  private static func integer(_ value: String, field: String) throws(ParkPaginationError) -> Int {
    guard !value.isEmpty, value.utf8.allSatisfy({ (48...57).contains($0) }), let result = Int(value)
    else { throw .invalidMetadata(field: field, value: value) }
    return result
  }
}
