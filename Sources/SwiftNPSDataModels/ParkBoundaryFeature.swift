/// One boundary feature: a park's geometry and naming details.
///
/// ```swift
/// if let polygons = feature.geometry?.multiPolygon {
///   print(feature.properties?.name ?? "", polygons.count)
/// }
/// ```
public struct ParkBoundaryFeature: Codable, Hashable, Sendable {
  /// The boundary shape, usually a `MultiPolygon` and occasionally a `Polygon`.
  public let geometry: NPSGeometry?

  /// The feature's identifier as sent.
  ///
  /// In the recordings it matched the park's own identifier, also sent as each alias's
  /// ``ParkBoundaryDetails/Alias/parkId``. That is an observation, not a documented guarantee.
  public let id: String?

  /// The park's names, aliases, and designation.
  public let properties: ParkBoundaryDetails?

  /// The GeoJSON object type, such as `"Feature"`, kept as an open string.
  public let type: String?
}
