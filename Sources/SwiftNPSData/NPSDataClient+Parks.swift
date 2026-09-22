import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates pages from an inspectable parks request without sending during construction.
  /// - Parameter request: The first-page operation and, for a query, its continuation settings.
  /// - Returns: The same lazy page iterators as ``pages(for:)``.
  public func parkPages(for request: NPSDataRequest<NPSCollection<Park>>) -> NPSPageSequence<Park> {
    pages(for: request)
  }

  /// Iterates complete parks pages with filters, sorting, and explicit pagination settings.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func parkPages(query: ParkQuery) -> NPSPageSequence<Park> {
    pages(for: .parks(query: query))
  }

  /// Iterates individual parks from a reusable first-page request.
  /// - Parameter request: An inspectable parks operation.
  /// - Returns: The same lazy item iterators as ``items(for:)``.
  public func parks(for request: NPSDataRequest<NPSCollection<Park>>) -> NPSItemSequence<Park> {
    items(for: request)
  }

  /// Looks up one park code and retains the NPS collection envelope.
  /// - Parameter parkCode: A validated single park code.
  /// - Returns: One requested page, which can be empty; no first-result selection is performed.
  /// - Throws: The same ``NPSDataError`` as ``value(for:)``.
  public func parks(parkCode: ParkCode) async throws(NPSDataError) -> NPSCollection<Park> {
    try await value(for: .parks(parkCode: parkCode))
  }

  /// Iterates individual parks, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Parks in provider order, without deduplication, throwing ``NPSDataError``.
  public func parks(query: ParkQuery) -> NPSItemSequence<Park> {
    items(for: .parks(query: query))
  }
}
