import SwiftNPSDataModels

extension NPSDataClient {
  /// Fetches the road events feed, optionally narrowed to one park and one event type.
  ///
  /// The feed is one response with no pagination, and most parks return an empty feed. The
  /// provider silently ignores a park code it does not recognize and returns every park's events.
  /// - Parameters:
  ///   - parkCode: One park code, or nil for every park.
  ///   - type: One event type sent in the provider's spelling, or nil for every type.
  /// - Returns: The complete WZDx feed, with its metadata and features kept as sent.
  /// - Throws: The same ``NPSDataError`` as ``value(for:)``.
  public func roadEvents(
    parkCode: ParkCode? = nil, type: RoadEventType? = nil
  ) async throws(NPSDataError) -> RoadEventFeed {
    try await value(for: .roadEvents(parkCode: parkCode, type: type))
  }
}
