extension Endpoint where Response == RoadEventFeed {
  /// Describes the road events feed, optionally narrowed to one park and one event type.
  ///
  /// The feed is one response with no pagination. Omitted parameters are not sent, so passing
  /// neither describes `/roadevents`, the feed for every park. The provider silently ignores a park
  /// code it does not recognize and returns every park's events, while a recognized code with no
  /// events returns an empty feed.
  ///
  /// ```swift
  /// let endpoint = Endpoint.roadEvents(parkCode: try ParkCode("yell"), type: .workZone)
  /// print(endpoint.path) // "/roadevents?parkCode=yell&type=WorkZone"
  /// ```
  /// - Parameters:
  ///   - parkCode: One park code, or nil for every park.
  ///   - type: One event type sent in the provider's spelling, or nil for every type.
  /// - Returns: One endpoint returning the complete ``RoadEventFeed``.
  public static func roadEvents(parkCode: ParkCode? = nil, type: RoadEventType? = nil) -> Self {
    var items: [String] = []
    if let parkCode { items.append("parkCode=" + parkCode.rawValue) }
    if let type { items.append("type=" + type.rawValue) }
    let query = items.isEmpty ? "" : "?" + items.joined(separator: "&")
    guard let endpoint = Self(path: "/roadevents" + query) else {
      preconditionFailure("A validated park code and a known event type form a relative endpoint.")
    }
    return endpoint
  }
}
