import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates complete webcams pages with identifiers, filters, and explicit pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func webcamPages(query: WebcamQuery) -> NPSPageSequence<Webcam> {
    pages(for: .webcams(query: query))
  }

  /// Iterates individual webcams, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Webcams in provider order, without deduplication, throwing ``NPSDataError``.
  public func webcams(query: WebcamQuery) -> NPSItemSequence<Webcam> {
    items(for: .webcams(query: query))
  }
}
