extension NPSDataRequest where Response == RoadEventFeed {
  /// Describes the road events feed, optionally narrowed to one park and one event type.
  ///
  /// The feed is a single response, so the request resolves to one endpoint with no continuation.
  /// No request is sent during construction.
  /// - Parameters:
  ///   - parkCode: One park code, or nil for every park.
  ///   - type: One event type sent in the provider's spelling, or nil for every type.
  /// - Returns: A reusable request for ``RoadEventFeed``, equivalent to
  ///   ``Endpoint/roadEvents(parkCode:type:)``.
  public static func roadEvents(parkCode: ParkCode? = nil, type: RoadEventType? = nil) -> Self {
    Self(endpoint: .roadEvents(parkCode: parkCode, type: type))
  }
}
