import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates individual park fees and passes records, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Records in provider order, without deduplication, throwing ``NPSDataError``.
  public func parkFeesAndPasses(
    query: ParkFeesAndPassesQuery
  ) -> NPSItemSequence<ParkFeesAndPasses> {
    items(for: .parkFeesAndPasses(query: query))
  }

  /// Iterates complete fees and passes pages with filters, text search, sorting, and explicit
  /// pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func parkFeesAndPassesPages(
    query: ParkFeesAndPassesQuery
  ) -> NPSPageSequence<ParkFeesAndPasses> {
    pages(for: .parkFeesAndPasses(query: query))
  }
}
