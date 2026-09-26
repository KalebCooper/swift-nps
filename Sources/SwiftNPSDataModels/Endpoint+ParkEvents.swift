extension Endpoint where Response == ParkEventCollection {
  /// Describes one ordinary events page or one array of expanded occurrences.
  /// - Parameter query: Validated filters and page-number settings.
  /// - Returns: A safely encoded relative events endpoint, without credentials.
  public static func parkEvents(query: ParkEventQuery) -> Self {
    let items = query.queryItems.map(\.encoded).joined(separator: "&")
    guard let endpoint = Self(path: "/events?" + items) else {
      preconditionFailure("Validated event query values form a safe relative endpoint.")
    }
    return endpoint
  }
}
