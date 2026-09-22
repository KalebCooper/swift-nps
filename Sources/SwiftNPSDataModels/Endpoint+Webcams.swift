extension Endpoint where Response == NPSCollection<Webcam> {
  /// Describes one webcams page with identifiers, filters, text search, and explicit pagination.
  ///
  /// ```swift
  /// let query = try WebcamQuery(limit: 1, parkCodes: [ParkCode("grte")])
  /// print(Endpoint.webcams(query: query).path)
  /// // "/webcams?limit=1&parkCode=grte&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func webcams(query: WebcamQuery) -> Self {
    collection(query)
  }
}
