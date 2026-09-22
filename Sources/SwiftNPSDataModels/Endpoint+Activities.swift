extension Endpoint where Response == NPSCollection<Activity> {
  /// Describes one activities page with filters, text search, sorting, and explicit pagination.
  ///
  /// ```swift
  /// let query = try ActivityQuery(
  ///   limit: 1, parkCodes: [ParkCode("drto")], sort: [.descending("name")])
  /// print(Endpoint.activities(query: query).path)
  /// // "/activities?limit=1&parkCode=drto&sort=-name&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func activities(query: ActivityQuery) -> Self {
    collection(query)
  }
}
