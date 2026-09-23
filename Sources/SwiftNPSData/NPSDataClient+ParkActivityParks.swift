import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates complete activity parks pages with filters, text search, sorting, and explicit
  /// pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func parkActivityParkPages(query: ParkActivityParksQuery) -> NPSPageSequence<
    ParkActivityParks
  > {
    pages(for: .parkActivityParks(query: query))
  }

  /// Iterates individual activities with the parks offering them, fetching the next page only
  /// when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Activities in provider order, without deduplication, throwing ``NPSDataError``.
  public func parkActivityParks(query: ParkActivityParksQuery) -> NPSItemSequence<ParkActivityParks>
  {
    items(for: .parkActivityParks(query: query))
  }
}
