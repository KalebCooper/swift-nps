extension Endpoint where Response == NPSCollection<ParkTopic> {
  /// Describes one topics page with filters, text search, sorting, and explicit pagination.
  ///
  /// ```swift
  /// let query = try ParkTopicQuery(
  ///   limit: 1, parkCodes: [ParkCode("mamc")], sort: [.descending("name")])
  /// print(Endpoint.parkTopics(query: query).path)
  /// // "/topics?limit=1&parkCode=mamc&sort=-name&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func parkTopics(query: ParkTopicQuery) -> Self {
    collection(query)
  }
}
