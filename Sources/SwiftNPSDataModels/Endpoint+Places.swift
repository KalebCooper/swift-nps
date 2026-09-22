extension Endpoint where Response == NPSCollection<Place> {
  /// Describes one places page with filters, text search, and explicit pagination.
  ///
  /// ```swift
  /// let query = try PlaceQuery(limit: 1, parkCodes: [ParkCode("acad")])
  /// print(Endpoint.places(query: query).path)
  /// // "/places?limit=1&parkCode=acad&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func places(query: PlaceQuery) -> Self {
    collection(query)
  }
}
