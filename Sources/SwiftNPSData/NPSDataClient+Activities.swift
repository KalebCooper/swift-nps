import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates complete activities pages with filters, text search, sorting, and explicit
  /// pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func activityPages(query: ActivityQuery) -> NPSPageSequence<Activity> {
    pages(for: .activities(query: query))
  }

  /// Iterates individual activities, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Activities in provider order, without deduplication, throwing ``NPSDataError``.
  public func activities(query: ActivityQuery) -> NPSItemSequence<Activity> {
    items(for: .activities(query: query))
  }
}
