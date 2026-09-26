/// An inspectable events query and its typed first endpoint.
///
/// Construction is available only for `ParkEventCollection`, preserving response inference
/// without transport closures or I/O. Custom executors inspect ``query`` and ``endpoint``.
public struct ParkEventResolution<Response>: Hashable, Sendable {
  /// The endpoint for this query's current page.
  public let endpoint: Endpoint<Response>
  /// The validated query, including every filter and recurrence setting.
  public let query: ParkEventQuery

  /// Describes an event operation whose response has the correct type.
  /// - Parameter query: The first-page query.
  public init(_ query: ParkEventQuery) where Response == ParkEventCollection {
    endpoint = .parkEvents(query: query)
    self.query = query
  }
}

extension ParkEventResolution where Response == ParkEventCollection {
  /// Validates a page and describes its successor without performing I/O.
  /// - Parameter page: The response to ``endpoint``; handle any reported errors first.
  /// - Returns: A following resolution, or nil at the reported end.
  /// - Throws: ``NPSPaginationError`` for expansion or invalid continuation metadata.
  public func next(after page: ParkEventCollection) throws(NPSPaginationError) -> Self? {
    guard let next = try query.next(after: page) else { return nil }
    return Self(next)
  }
}
