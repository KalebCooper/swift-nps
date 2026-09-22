import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates complete topics pages with filters, text search, sorting, and explicit pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func topicPages(query: TopicQuery) -> NPSPageSequence<Topic> {
    pages(for: .topics(query: query))
  }

  /// Iterates individual topics, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Topics in provider order, without deduplication, throwing ``NPSDataError``.
  public func topics(query: TopicQuery) -> NPSItemSequence<Topic> {
    items(for: .topics(query: query))
  }
}
