extension Endpoint where Response == NPSCollection<PhotoGallery> {
  /// Describes one photo gallery page with filters, text search, sorting, and explicit pagination.
  ///
  /// ```swift
  /// let query = try PhotoGalleryQuery(
  ///   limit: 1, parkCodes: [ParkCode("thrb")], sort: [.ascending("title")])
  /// print(Endpoint.photoGalleries(query: query).path)
  /// // "/multimedia/galleries?limit=1&parkCode=thrb&sort=title&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func photoGalleries(query: PhotoGalleryQuery) -> Self {
    collection(query)
  }
}
