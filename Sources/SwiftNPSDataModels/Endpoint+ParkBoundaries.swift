extension Endpoint where Response == ParkBoundary {
  /// Describes one park's boundary as a GeoJSON feature collection.
  ///
  /// The park code is a path segment and the operation takes no query parameters. The response is
  /// one value with no pagination. The provider matched codes case-insensitively in the recordings,
  /// and an unknown code returns HTTP 404 with an `application/problem+json` body rather than the
  /// NPS error envelope.
  ///
  /// ```swift
  /// let endpoint = Endpoint.parkBoundary(parkCode: try ParkCode("drto"))
  /// print(endpoint.path) // "/mapdata/parkboundaries/drto"
  /// ```
  /// - Parameter parkCode: The park whose boundary is described, sent as given.
  /// - Returns: One endpoint returning the complete ``ParkBoundary``.
  public static func parkBoundary(parkCode: ParkCode) -> Self {
    guard let endpoint = Self(path: "/mapdata/parkboundaries/" + parkCode.rawValue) else {
      preconditionFailure("A validated park code forms a relative endpoint path segment.")
    }
    return endpoint
  }
}
