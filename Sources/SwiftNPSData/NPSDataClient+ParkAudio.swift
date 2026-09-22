import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates individual park audio recordings, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Recordings in provider order, without deduplication, throwing ``NPSDataError``.
  public func parkAudio(query: ParkAudioQuery) -> NPSItemSequence<ParkAudio> {
    items(for: .parkAudio(query: query))
  }

  /// Iterates complete park audio pages with filters, text search, sorting, and explicit
  /// pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func parkAudioPages(query: ParkAudioQuery) -> NPSPageSequence<ParkAudio> {
    pages(for: .parkAudio(query: query))
  }
}
