import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates individual people, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: People in provider order, without deduplication, throwing ``NPSDataError``.
  public func people(query: PersonQuery) -> NPSItemSequence<Person> {
    items(for: .people(query: query))
  }

  /// Iterates complete people pages with filters, text search, and explicit pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func personPages(query: PersonQuery) -> NPSPageSequence<Person> {
    pages(for: .people(query: query))
  }
}
