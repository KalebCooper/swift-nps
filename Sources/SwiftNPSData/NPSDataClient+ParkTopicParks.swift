import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates complete topic parks pages with filters, text search, sorting, and explicit
  /// pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func parkTopicParkPages(query: ParkTopicParksQuery) -> NPSPageSequence<ParkTopicParks> {
    pages(for: .parkTopicParks(query: query))
  }

  /// Iterates individual topics with the parks associated with them, fetching the next page only
  /// when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Topics in provider order, without deduplication, throwing ``NPSDataError``.
  public func parkTopicParks(query: ParkTopicParksQuery) -> NPSItemSequence<ParkTopicParks> {
    items(for: .parkTopicParks(query: query))
  }
}
