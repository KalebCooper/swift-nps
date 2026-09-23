import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates individual passport stamp locations, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Locations in provider order, without deduplication, throwing ``NPSDataError``.
  public func passportStampLocations(
    query: PassportStampLocationQuery
  ) -> NPSItemSequence<PassportStampLocation> {
    items(for: .passportStampLocations(query: query))
  }

  /// Iterates complete passport stamp locations pages with filters, text search, sorting, and
  /// explicit pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func passportStampLocationPages(
    query: PassportStampLocationQuery
  ) -> NPSPageSequence<PassportStampLocation> {
    pages(for: .passportStampLocations(query: query))
  }
}
