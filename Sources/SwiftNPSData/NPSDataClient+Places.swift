import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates complete places pages with filters, text search, and explicit pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func placePages(query: PlaceQuery) -> NPSPageSequence<Place> {
    pages(for: .places(query: query))
  }

  /// Iterates individual places, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Places in provider order, without deduplication, throwing ``NPSDataError``.
  public func places(query: PlaceQuery) -> NPSItemSequence<Place> {
    items(for: .places(query: query))
  }
}
