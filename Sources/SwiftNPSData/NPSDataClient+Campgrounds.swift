import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates complete campgrounds pages with filters, sorting, and explicit pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func campgroundPages(query: CampgroundQuery) -> NPSPageSequence<Campground> {
    pages(for: .campgrounds(query: query))
  }

  /// Iterates individual campgrounds, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Campgrounds in provider order, without deduplication, throwing ``NPSDataError``.
  public func campgrounds(query: CampgroundQuery) -> NPSItemSequence<Campground> {
    items(for: .campgrounds(query: query))
  }
}
