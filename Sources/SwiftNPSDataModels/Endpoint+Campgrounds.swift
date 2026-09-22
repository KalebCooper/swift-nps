extension Endpoint where Response == NPSCollection<Campground> {
  /// Describes one campgrounds page with filters, text search, sorting, and pagination.
  ///
  /// ```swift
  /// let query = try CampgroundQuery(
  ///   limit: 1, parkCodes: [ParkCode("acad")], sort: [.ascending("name")])
  /// print(Endpoint.campgrounds(query: query).path)
  /// // "/campgrounds?limit=1&parkCode=acad&sort=name&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func campgrounds(query: CampgroundQuery) -> Self {
    collection(query)
  }
}
