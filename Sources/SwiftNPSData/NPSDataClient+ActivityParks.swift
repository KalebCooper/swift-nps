import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates complete activity parks pages with filters, text search, sorting, and explicit
  /// pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func activityParkPages(query: ActivityParksQuery) -> NPSPageSequence<ActivityParks> {
    pages(for: .activityParks(query: query))
  }

  /// Iterates individual activities with the parks offering them, fetching the next page only
  /// when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Activities in provider order, without deduplication, throwing ``NPSDataError``.
  public func activityParks(query: ActivityParksQuery) -> NPSItemSequence<ActivityParks> {
    items(for: .activityParks(query: query))
  }
}
