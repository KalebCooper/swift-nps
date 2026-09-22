extension Endpoint where Response == NPSCollection<ParkFeesAndPasses> {
  /// Describes one fees and passes page with filters, text search, sorting, and explicit pagination.
  ///
  /// ```swift
  /// let query = try ParkFeesAndPassesQuery(
  ///   limit: 1, parkCodes: [ParkCode("hale"), ParkCode("havo")], sort: [.descending("parkCode")])
  /// print(Endpoint.parkFeesAndPasses(query: query).path)
  /// // "/feespasses?limit=1&parkCode=hale,havo&sort=-parkCode&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func parkFeesAndPasses(query: ParkFeesAndPassesQuery) -> Self {
    collection(query)
  }
}
