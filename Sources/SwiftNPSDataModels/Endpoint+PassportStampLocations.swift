extension Endpoint where Response == NPSCollection<PassportStampLocation> {
  /// Describes one passport stamp locations page with filters, text search, sorting, and explicit
  /// pagination.
  ///
  /// ```swift
  /// let query = try PassportStampLocationQuery(
  ///   limit: 1, parkCodes: [ParkCode("cato")], searchText: "center",
  ///   sort: [.descending("name")])
  /// print(Endpoint.passportStampLocations(query: query).path)
  /// // "/passportstamplocations?limit=1&parkCode=cato&q=center&sort=-name&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func passportStampLocations(query: PassportStampLocationQuery) -> Self {
    collection(query)
  }
}
