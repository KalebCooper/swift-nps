extension Endpoint where Response == NPSCollection<TopicParks> {
  /// Describes one topic parks page with filters, text search, sorting, and explicit pagination.
  ///
  /// ```swift
  /// let query = try TopicParksQuery(
  ///   limit: 1, parkCodes: [ParkCode("mamc")], sort: [.descending("name")])
  /// print(Endpoint.topicParks(query: query).path)
  /// // "/topics/parks?limit=1&parkCode=mamc&sort=-name&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func topicParks(query: TopicParksQuery) -> Self {
    collection(query)
  }
}
