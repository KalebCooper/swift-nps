import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates complete visitor centers pages with filters, sorting, and explicit pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func visitorCenterPages(query: VisitorCenterQuery) -> NPSPageSequence<VisitorCenter> {
    pages(for: .visitorCenters(query: query))
  }

  /// Iterates individual visitor centers, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Visitor centers in provider order, without deduplication, throwing
  ///   ``NPSDataError``.
  public func visitorCenters(query: VisitorCenterQuery) -> NPSItemSequence<VisitorCenter> {
    items(for: .visitorCenters(query: query))
  }
}
