/// A park's boundary returned by the NPS park boundaries API, as a GeoJSON feature collection.
///
/// The provider sends a bare GeoJSON `FeatureCollection` rather than the paged NPS envelope, so
/// there is no total, limit, or start and no following page. Every recorded park returned exactly one
/// feature, most often a `MultiPolygon` and occasionally a `Polygon`. Coordinates are kept as sent
/// in GeoJSON `[longitude, latitude]` order. Unknown JSON fields are ignored by Codable.
///
/// Boundary geometry is published cartographic data, not a survey or a legal record.
///
/// ```swift
/// let boundary = try JSONDecoder().decode(ParkBoundary.self, from: data)
/// for feature in boundary.features ?? [] {
///   print(feature.properties?.fullName ?? "", feature.geometry?.type ?? "")
/// }
/// ```
public struct ParkBoundary: Codable, Hashable, Sendable {
  /// The boundary features in provider order; every recorded park returned one.
  public let features: [ParkBoundaryFeature]?

  /// The GeoJSON object type, such as `"FeatureCollection"`, kept as an open string.
  public let type: String?
}
