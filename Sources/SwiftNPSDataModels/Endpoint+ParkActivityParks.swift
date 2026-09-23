extension Endpoint where Response == NPSCollection<ParkActivityParks> {
  /// Describes one activity parks page with filters, text search, sorting, and explicit
  /// pagination.
  ///
  /// ```swift
  /// let query = try ParkActivityParksQuery(
  ///   limit: 1, parkCodes: [ParkCode("drto")], sort: [.descending("name")])
  /// print(Endpoint.parkActivityParks(query: query).path)
  /// // "/activities/parks?limit=1&parkCode=drto&sort=-name&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func parkActivityParks(query: ParkActivityParksQuery) -> Self {
    collection(query)
  }
}
