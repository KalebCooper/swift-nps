import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates complete park video pages with filters, text search, sorting, and explicit
  /// pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func parkVideoPages(query: ParkVideoQuery) -> NPSPageSequence<ParkVideo> {
    pages(for: .parkVideos(query: query))
  }

  /// Iterates individual park videos, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Videos in provider order, without deduplication, throwing ``NPSDataError``.
  public func parkVideos(query: ParkVideoQuery) -> NPSItemSequence<ParkVideo> {
    items(for: .parkVideos(query: query))
  }
}
