import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates complete news releases pages with filters, text search, sorting, and explicit
  /// pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func newsReleasePages(query: NewsReleaseQuery) -> NPSPageSequence<NewsRelease> {
    pages(for: .newsReleases(query: query))
  }

  /// Iterates individual news releases, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: News releases in provider order, without deduplication, throwing
  ///   ``NPSDataError``.
  public func newsReleases(query: NewsReleaseQuery) -> NPSItemSequence<NewsRelease> {
    items(for: .newsReleases(query: query))
  }
}
