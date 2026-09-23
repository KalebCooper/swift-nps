import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates complete alerts pages with filters and explicit pagination settings.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func parkAlertPages(query: ParkAlertQuery) -> NPSPageSequence<ParkAlert> {
    pages(for: .parkAlerts(query: query))
  }

  /// Iterates individual alerts, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Alerts in provider order, without deduplication, throwing ``NPSDataError``.
  public func parkAlerts(query: ParkAlertQuery) -> NPSItemSequence<ParkAlert> {
    items(for: .parkAlerts(query: query))
  }
}
