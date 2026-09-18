/// A validated, immutable query for one offset-paginated NPS collection endpoint.
///
/// A conforming query names its collection path, exposes its page size and offset, lists every
/// parameter for one page, and produces the same query at another offset. The continuation math
/// in ``next(after:)`` is shared by every conformer. Construction performs no I/O.
///
/// ```swift
/// let query = try ParkQuery(limit: 20, searchText: "history")
/// let endpoint = Endpoint.collection(query)
/// ```
public protocol NPSCollectionQuery<Item>: Hashable, Sendable {
  /// The decoded element type of the collection's `data` array.
  associatedtype Item: Codable & Hashable & Sendable

  /// The collection path relative to the API base, such as `/parks`.
  static var path: String { get }

  /// The requested maximum number of results per page, always positive.
  var limit: Int { get }

  /// Every parameter for this page, including `limit` and `start`, unencoded.
  var queryItems: [NPSQueryItem] { get }

  /// The zero-based starting offset, never negative.
  var start: Int { get }

  /// Returns this query at a different offset with every other option unchanged.
  /// - Parameter start: A nonnegative starting offset already validated by the caller.
  /// - Returns: The same query beginning at `start`.
  func starting(at start: Int) -> Self
}

extension NPSCollectionQuery {
  /// Validates a received page and describes the following request, if any.
  ///
  /// Advances by the number of returned items, preserving all other options. A page ends the
  /// traversal when its returned range reaches the reported total. An empty page is terminal only
  /// at or beyond that total. Results can change between requests; this is not a snapshot guarantee.
  /// - Parameter page: The response to this query's starting offset.
  /// - Returns: The next query, or nil for a terminal page.
  /// - Throws: ``NPSPaginationError`` for unusable metadata, inconsistent data, or overflow.
  public func next(after page: NPSCollection<Item>) throws(NPSPaginationError) -> Self? {
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
    return following == total ? nil : starting(at: following)
  }

  private static func integer(_ value: String, field: String) throws(NPSPaginationError) -> Int {
    guard !value.isEmpty, value.utf8.allSatisfy({ (48...57).contains($0) }), let result = Int(value)
    else { throw .invalidMetadata(field: field, value: value) }
    return result
  }
}
