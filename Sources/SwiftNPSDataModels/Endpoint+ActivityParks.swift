extension Endpoint where Response == NPSCollection<ActivityParks> {
  /// Describes one activity parks page with filters, text search, sorting, and explicit
  /// pagination.
  ///
  /// ```swift
  /// let query = try ActivityParksQuery(
  ///   limit: 1, parkCodes: [ParkCode("drto")], sort: [.descending("name")])
  /// print(Endpoint.activityParks(query: query).path)
  /// // "/activities/parks?limit=1&parkCode=drto&sort=-name&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func activityParks(query: ActivityParksQuery) -> Self {
    collection(query)
  }
}
