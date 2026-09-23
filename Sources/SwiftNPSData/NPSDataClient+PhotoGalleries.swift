import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates individual photo galleries, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Galleries in provider order, without deduplication, throwing ``NPSDataError``.
  public func photoGalleries(query: PhotoGalleryQuery) -> NPSItemSequence<PhotoGallery> {
    items(for: .photoGalleries(query: query))
  }

  /// Iterates complete photo gallery pages with filters, text search, sorting, and explicit
  /// pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func photoGalleryPages(query: PhotoGalleryQuery) -> NPSPageSequence<PhotoGallery> {
    pages(for: .photoGalleries(query: query))
  }
}
