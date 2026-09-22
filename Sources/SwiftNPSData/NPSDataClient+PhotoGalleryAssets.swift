import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates complete photo gallery asset pages with filters, text search, sorting, and explicit
  /// pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func photoGalleryAssetPages(
    query: PhotoGalleryAssetQuery
  ) -> NPSPageSequence<PhotoGalleryAsset> {
    pages(for: .photoGalleryAssets(query: query))
  }

  /// Iterates individual photo gallery assets, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Assets in provider order, without deduplication, throwing ``NPSDataError``.
  public func photoGalleryAssets(
    query: PhotoGalleryAssetQuery
  ) -> NPSItemSequence<PhotoGalleryAsset> {
    items(for: .photoGalleryAssets(query: query))
  }
}
