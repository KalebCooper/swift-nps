extension Endpoint where Response == NPSCollection<PhotoGalleryAsset> {
  /// Describes one photo gallery asset page with filters, text search, sorting, and explicit
  /// pagination.
  ///
  /// ```swift
  /// let query = try PhotoGalleryAssetQuery(
  ///   galleryIdentifiers: [NPSIdentifier("1FFC7EF8-155D-4519-3ECC-B652E2E95E20")], limit: 2)
  /// print(Endpoint.photoGalleryAssets(query: query).path)
  /// // "/multimedia/galleries/assets?galleryId=1FFC7EF8-155D-4519-3ECC-B652E2E95E20&limit=2&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func photoGalleryAssets(query: PhotoGalleryAssetQuery) -> Self {
    collection(query)
  }
}
