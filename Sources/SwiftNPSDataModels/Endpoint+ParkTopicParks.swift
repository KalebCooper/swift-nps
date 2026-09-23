extension Endpoint where Response == NPSCollection<ParkTopicParks> {
  /// Describes one topic parks page with filters, text search, sorting, and explicit pagination.
  ///
  /// ```swift
  /// let query = try ParkTopicParksQuery(
  ///   limit: 1, parkCodes: [ParkCode("mamc")], sort: [.descending("name")])
  /// print(Endpoint.parkTopicParks(query: query).path)
  /// // "/topics/parks?limit=1&parkCode=mamc&sort=-name&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func parkTopicParks(query: ParkTopicParksQuery) -> Self {
    collection(query)
  }
}
