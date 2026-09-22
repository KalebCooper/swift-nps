extension Endpoint where Response == NPSCollection<Tour> {
  /// Describes one tours page with identifiers, filters, text search, sorting, and pagination.
  ///
  /// ```swift
  /// let query = try TourQuery(
  ///   limit: 1, parkCodes: [ParkCode("cavo")], sort: [.descending("relevanceScore")])
  /// print(Endpoint.tours(query: query).path)
  /// // "/tours?limit=1&parkCode=cavo&sort=-relevanceScore&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func tours(query: TourQuery) -> Self {
    collection(query)
  }
}
