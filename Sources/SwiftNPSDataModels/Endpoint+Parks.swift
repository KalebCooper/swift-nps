extension Endpoint where Response == NPSCollection<Park> {
  /// Looks up one code using `/parks`, explicitly requesting one result starting at zero.
  ///
  /// The provider envelope is retained, including an empty data array for an unknown code.
  /// No subsequent page is fetched and no result is selected from the response.
  /// - Parameter parkCode: A validated single park code.
  /// - Returns: A transport-independent endpoint returning ``NPSCollection`` of ``Park``.
  public static func parks(parkCode: ParkCode) -> Self {
    guard let endpoint = Self(path: "/parks?parkCode=\(parkCode.rawValue)&limit=1&start=0") else {
      preconditionFailure("A validated park code produces a valid relative parks endpoint.")
    }
    return endpoint
  }

  /// Describes one parks page with filters, text search, sorting, and explicit pagination.
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func parks(query: ParkQuery) -> Self {
    collection(query)
  }
}
