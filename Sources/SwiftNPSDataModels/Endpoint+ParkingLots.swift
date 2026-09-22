extension Endpoint where Response == NPSCollection<ParkingLot> {
  /// Describes one parking lot page with filters, text search, sorting, and explicit pagination.
  ///
  /// ```swift
  /// let query = try ParkingLotQuery(
  ///   limit: 1, parkCodes: [ParkCode("chsc")], sort: [.descending("name")])
  /// print(Endpoint.parkingLots(query: query).path)
  /// // "/parkinglots?limit=1&parkCode=chsc&sort=-name&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func parkingLots(query: ParkingLotQuery) -> Self {
    collection(query)
  }
}
