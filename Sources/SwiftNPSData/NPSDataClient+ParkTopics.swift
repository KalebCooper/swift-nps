import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates complete topics pages with filters, text search, sorting, and explicit pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func parkTopicPages(query: ParkTopicQuery) -> NPSPageSequence<ParkTopic> {
    pages(for: .parkTopics(query: query))
  }

  /// Iterates individual topics, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Topics in provider order, without deduplication, throwing ``NPSDataError``.
  public func parkTopics(query: ParkTopicQuery) -> NPSItemSequence<ParkTopic> {
    items(for: .parkTopics(query: query))
  }
}
