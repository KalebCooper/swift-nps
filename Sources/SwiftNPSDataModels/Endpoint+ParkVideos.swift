extension Endpoint where Response == NPSCollection<ParkVideo> {
  /// Describes one park video page with filters, text search, sorting, and explicit pagination.
  ///
  /// ```swift
  /// let query = try ParkVideoQuery(
  ///   limit: 1, parkCodes: [ParkCode("crmo")], sort: [.ascending("title")])
  /// print(Endpoint.parkVideos(query: query).path)
  /// // "/multimedia/videos?limit=1&parkCode=crmo&sort=title&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func parkVideos(query: ParkVideoQuery) -> Self {
    collection(query)
  }
}
