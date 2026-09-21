/// A GeoJSON geometry whose coordinates are kept as an open tree of any depth.
///
/// The type is an open string, so a geometry kind this package does not name still decodes with its
/// coordinates intact. ``lineString``, ``polygon`` and ``multiPolygon`` read the three kinds the
/// service sends as typed arrays, returning nil rather than trapping when the declared type or the
/// nesting depth does not match. Positions are GeoJSON `[longitude, latitude]` arrays, kept as sent.
///
/// ```swift
/// if let polygons = geometry.multiPolygon {
///   print(polygons.count, polygons.first?.first?.count ?? 0)
/// } else if let rings = geometry.polygon {
///   print(rings.first?.count ?? 0)
/// }
/// ```
public struct NPSGeometry: Codable, Hashable, Sendable {
  /// The coordinates as sent, at whatever depth the geometry type uses.
  public let coordinates: NPSCoordinateTree?

  /// The GeoJSON geometry type, such as `"Polygon"` or `"MultiPolygon"`, kept as an open string.
  public let type: String?

  /// The positions of a `LineString`, in the order sent.
  ///
  /// Non-nil only when ``type`` is exactly `"LineString"` and every branch of ``coordinates`` is two
  /// levels deep. An empty list of positions is accepted as it arrived.
  public var lineString: [[Double]]? {
    guard type == "LineString" else { return nil }
    return coordinates?.positions
  }

  /// The polygons of a `MultiPolygon`, each a list of rings of positions.
  ///
  /// Non-nil only when ``type`` is exactly `"MultiPolygon"` and every branch of ``coordinates`` is
  /// four levels deep. An empty list at any level above the positions is accepted as it arrived.
  public var multiPolygon: [[[[Double]]]]? {
    guard type == "MultiPolygon" else { return nil }
    return coordinates?.polygons
  }

  /// The rings of a `Polygon`, each a list of positions, with the outer ring first.
  ///
  /// Non-nil only when ``type`` is exactly `"Polygon"` and every branch of ``coordinates`` is three
  /// levels deep. An empty list at any level above the positions is accepted as it arrived.
  public var polygon: [[[Double]]]? {
    guard type == "Polygon" else { return nil }
    return coordinates?.rings
  }
}
