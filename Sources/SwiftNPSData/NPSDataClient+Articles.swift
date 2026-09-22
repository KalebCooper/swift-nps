import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates complete articles pages with filters, text search, and explicit pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func articlePages(query: ArticleQuery) -> NPSPageSequence<Article> {
    pages(for: .articles(query: query))
  }

  /// Iterates individual articles, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Articles in provider order, without deduplication, throwing ``NPSDataError``.
  public func articles(query: ArticleQuery) -> NPSItemSequence<Article> {
    items(for: .articles(query: query))
  }
}
