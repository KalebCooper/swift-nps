/// One road event in a feed: a GeoJSON feature with a geometry and event details.
///
/// ```swift
/// for feature in feed.features ?? [] {
///   let points = feature.geometry?.coordinates ?? []
///   print(feature.properties?.coreDetails?.eventType ?? "", points.count)
/// }
/// ```
public struct RoadEventFeature: Codable, Hashable, Sendable {
  /// The WZDx geometry of a road event, with coordinates kept as GeoJSON `[longitude, latitude]`.
  ///
  /// Every recorded feature is a `LineString` whose coordinates are an array of two-number
  /// positions. Positions are kept in provider order and longitude-first, without reordering or
  /// conversion to a coordinate type.
  public struct Geometry: Codable, Hashable, Sendable {
    /// The positions along the road, each a `[longitude, latitude]` array as sent.
    public let coordinates: [[Double]]?

    /// The GeoJSON geometry type, such as `"LineString"`, kept as an open string.
    public let type: String?
  }

  /// Where the event applies along the road.
  public let geometry: Geometry?

  /// The event's details, timing, and identifiers.
  public let properties: RoadEventDetails?

  /// The GeoJSON object type, such as `"Feature"`, kept as an open string.
  public let type: String?
}
