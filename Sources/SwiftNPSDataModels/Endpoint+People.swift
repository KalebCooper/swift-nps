extension Endpoint where Response == NPSCollection<Person> {
  /// Describes one people page with filters, text search, and explicit pagination.
  ///
  /// ```swift
  /// let query = try PersonQuery(limit: 1, parkCodes: [ParkCode("yell")])
  /// print(Endpoint.people(query: query).path)
  /// // "/people?limit=1&parkCode=yell&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func people(query: PersonQuery) -> Self {
    collection(query)
  }
}
