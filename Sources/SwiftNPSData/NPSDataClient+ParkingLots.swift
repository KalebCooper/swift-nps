import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates individual parking lots, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Parking lots in provider order, without deduplication, throwing ``NPSDataError``.
  public func parkingLots(query: ParkingLotQuery) -> NPSItemSequence<ParkingLot> {
    items(for: .parkingLots(query: query))
  }

  /// Iterates complete parking lot pages with filters, text search, sorting, and explicit
  /// pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func parkingLotPages(query: ParkingLotQuery) -> NPSPageSequence<ParkingLot> {
    pages(for: .parkingLots(query: query))
  }
}
