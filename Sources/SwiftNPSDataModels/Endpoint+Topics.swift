extension Endpoint where Response == NPSCollection<Topic> {
  /// Describes one topics page with filters, text search, sorting, and explicit pagination.
  ///
  /// ```swift
  /// let query = try TopicQuery(
  ///   limit: 1, parkCodes: [ParkCode("mamc")], sort: [.descending("name")])
  /// print(Endpoint.topics(query: query).path)
  /// // "/topics?limit=1&parkCode=mamc&sort=-name&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func topics(query: TopicQuery) -> Self {
    collection(query)
  }
}
