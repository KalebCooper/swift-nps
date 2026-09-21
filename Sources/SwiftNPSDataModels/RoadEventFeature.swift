/// One road event in a feed: a GeoJSON feature with a geometry and event details.
///
/// Every recorded feature is a `LineString`, read through ``NPSGeometry/lineString`` as
/// `[longitude, latitude]` positions in provider order. The geometry is the open ``NPSGeometry``
/// rather than a closed list of positions, so a feature sent at another depth still decodes with
/// its coordinates intact instead of failing the whole feed.
///
/// ```swift
/// for feature in feed.features ?? [] {
///   let points = feature.geometry?.lineString ?? []
///   print(feature.properties?.coreDetails?.eventType ?? "", points.count)
/// }
/// ```
public struct RoadEventFeature: Codable, Hashable, Sendable {
  /// Where the event applies along the road.
  public let geometry: NPSGeometry?

  /// The event's details, timing, and identifiers.
  public let properties: RoadEventDetails?

  /// The GeoJSON object type, such as `"Feature"`, kept as an open string.
  public let type: String?
}
