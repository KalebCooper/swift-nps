/// A paginating collection operation whose concrete query type has been erased.
///
/// The value exists only for `Response == NPSCollection<Item>`: its sole initializer requires a
/// query whose `Item` matches, so every stored query decodes the same page type. It holds the
/// first-page ``endpoint`` and the ``query`` itself, with no closures, so a request containing it
/// remains a plain `Hashable` value. A custom executor sends ``endpoint``, decodes the page, and
/// calls ``next(after:)`` while more pages are wanted, or matches ``query`` against a concrete type.
///
/// ```swift
/// if case .collection(let resolution) = request.resolution,
///   let query = resolution.query as? ParkQuery
/// {
///   print(query.parkCodes)
/// }
/// ```
public struct NPSCollectionResolution<Response>: Hashable, Sendable {
  /// The endpoint for the page at the query's current offset.
  public let endpoint: Endpoint<Response>

  /// The validated query, whose concrete type a custom executor can match.
  public let query: any NPSCollectionQuery

  /// Erases a validated query whose pages decode as `Response`.
  /// - Parameter query: The query for the first page.
  public init<Query: NPSCollectionQuery>(
    _ query: Query
  ) where Response == NPSCollection<Query.Item> {
    self.endpoint = .collection(query)
    self.query = query
  }

  /// Validates a received page and describes the following request, if any.
  ///
  /// Delegates to ``NPSCollectionQuery/next(after:)`` on the erased query, so the continuation
  /// rules are those of the query's protocol extension.
  /// - Parameter page: The response to ``endpoint``.
  /// - Returns: The resolution for the next page, or nil for a terminal page.
  /// - Throws: ``NPSPaginationError`` for unusable metadata, inconsistent data, or overflow.
  public func next(after page: Response) throws(NPSPaginationError) -> Self? {
    try Self.advance(query, after: page)
  }

  /// Compares the endpoints and the concrete queries.
  /// - Parameters:
  ///   - lhs: A resolution.
  ///   - rhs: Another resolution.
  /// - Returns: Whether both erase equal queries of the same concrete type.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.endpoint == rhs.endpoint && AnyHashable(lhs.query) == AnyHashable(rhs.query)
  }

  /// Hashes the endpoint and the concrete query.
  /// - Parameter hasher: The hasher to feed.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(endpoint)
    hasher.combine(AnyHashable(query))
  }

  package func starting(at start: Int) -> Self {
    Self.restart(query, at: start)
  }

  private static func advance<Query: NPSCollectionQuery>(
    _ query: Query, after page: Response
  ) throws(NPSPaginationError) -> Self? {
    guard let page = page as? NPSCollection<Query.Item> else {
      preconditionFailure("The initializer requires the query's item to match the response.")
    }
    guard let next = try query.next(after: page) else { return nil }
    return Self.erase(next)
  }

  private static func erase<Query: NPSCollectionQuery>(_ query: Query) -> Self {
    guard let erased = NPSCollectionResolution<NPSCollection<Query.Item>>(query) as? Self else {
      preconditionFailure("The initializer requires the query's item to match the response.")
    }
    return erased
  }

  private static func restart<Query: NPSCollectionQuery>(_ query: Query, at start: Int) -> Self {
    erase(query.starting(at: start))
  }
}
