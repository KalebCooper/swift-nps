/// A road event type accepted by the road events `type` parameter.
///
/// The provider accepts exactly these four values and answers any other with HTTP 400, so the
/// parameter is a closed set. Each raw value is the provider's own spelling. The provider rejects
/// the WZDx spelling `work-zone` and accepts `WorkZone`, which ``workZone`` sends. A valid type
/// with no matching events returns an empty feed rather than an error.
///
/// Responses describe an event's type through ``RoadEventDetails/CoreDetails/eventType``, an open
/// string in WZDx spelling, which this request type does not decode.
///
/// ```swift
/// let endpoint = Endpoint.roadEvents(parkCode: try ParkCode("yell"), type: .workZone)
/// print(endpoint.path) // "/roadevents?parkCode=yell&type=WorkZone"
/// ```
public enum RoadEventType: String, CaseIterable, Hashable, Sendable {
  /// Detours, sent as `Detour`.
  case detour = "Detour"

  /// Incidents such as crashes or closures, sent as `Incident`.
  case incident = "Incident"

  /// Restrictions on vehicles or lanes, sent as `Restriction`.
  case restriction = "Restriction"

  /// Work zones, sent as `WorkZone`.
  case workZone = "WorkZone"
}
