import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates complete tours pages with identifiers, filters, sorting, and pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func tourPages(query: TourQuery) -> NPSPageSequence<Tour> {
    pages(for: .tours(query: query))
  }

  /// Iterates individual tours, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Tours in provider order, without deduplication, throwing ``NPSDataError``.
  public func tours(query: TourQuery) -> NPSItemSequence<Tour> {
    items(for: .tours(query: query))
  }
}
