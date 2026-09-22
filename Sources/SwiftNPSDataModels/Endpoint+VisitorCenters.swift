extension Endpoint where Response == NPSCollection<VisitorCenter> {
  /// Describes one visitor centers page with filters, text search, sorting, and pagination.
  ///
  /// ```swift
  /// let query = try VisitorCenterQuery(
  ///   limit: 1, parkCodes: [ParkCode("acad")], sort: [.ascending("name")])
  /// print(Endpoint.visitorCenters(query: query).path)
  /// // "/visitorcenters?limit=1&parkCode=acad&sort=name&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func visitorCenters(query: VisitorCenterQuery) -> Self {
    collection(query)
  }
}
