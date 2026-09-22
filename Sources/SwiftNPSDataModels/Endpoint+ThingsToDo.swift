extension Endpoint where Response == NPSCollection<ThingToDo> {
  /// Describes one things to do page with identifiers, filters, text search, sorting, and pagination.
  ///
  /// ```swift
  /// let query = try ThingToDoQuery(
  ///   limit: 1, parkCodes: [ParkCode("acad")], sort: [.descending("relevanceScore")])
  /// print(Endpoint.thingsToDo(query: query).path)
  /// // "/thingstodo?limit=1&parkCode=acad&sort=-relevanceScore&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func thingsToDo(query: ThingToDoQuery) -> Self {
    collection(query)
  }
}
