extension NPSDataRequest where Response == ParkBoundary {
  /// Describes one park's boundary as a GeoJSON feature collection.
  ///
  /// The boundary is a single response, so the request resolves to one endpoint with no
  /// continuation. No request is sent during construction.
  /// - Parameter parkCode: The park whose boundary is described, sent as given.
  /// - Returns: A reusable request for ``ParkBoundary``, equivalent to
  ///   ``Endpoint/parkBoundary(parkCode:)``.
  public static func parkBoundary(parkCode: ParkCode) -> Self {
    Self(endpoint: .parkBoundary(parkCode: parkCode))
  }
}
