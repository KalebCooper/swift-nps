extension Endpoint where Response == NPSCollection<ParkAlert> {
  /// Describes one alerts page with filters, text search, and explicit pagination.
  ///
  /// ```swift
  /// let endpoint = Endpoint.parkAlerts(
  ///   query: try ParkAlertQuery(limit: 2, parkCodes: [ParkCode("acad")]))
  /// print(endpoint.path) // "/alerts?limit=2&parkCode=acad&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func parkAlerts(query: ParkAlertQuery) -> Self {
    collection(query)
  }
}
