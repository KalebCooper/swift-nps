/// GeoJSON coordinates of any nesting depth, kept exactly as sent.
///
/// A position is an array of numbers, such as `[longitude, latitude]` or
/// `[longitude, latitude, altitude]`; every level above it is an array of trees. A `Polygon` nests
/// three levels deep and a `MultiPolygon` four, but the tree decodes any depth, so geometry kinds this
/// package does not name still round trip without losing coordinates. Numbers are not reordered,
/// rounded, or counted against a required length. ``NPSGeometry`` offers typed accessors for the
/// depths callers read today.
///
/// An empty JSON array `[]` decodes as `.nested([])`: GeoJSON positions always hold numbers, so an
/// empty array is an empty list, such as a polygon without rings. A JSON array mixing numbers and
/// arrays, or any value that is not an array, fails to decode with a `DecodingError`.
///
/// ```swift
/// let tree = try JSONDecoder().decode(NPSCoordinateTree.self, from: Data("[[1.5, 2.5]]".utf8))
/// print(tree == .nested([.position([1.5, 2.5])])) // true
/// ```
public enum NPSCoordinateTree: Codable, Hashable, Sendable {
  /// A list of trees one level deeper, such as the rings of a polygon or the positions of a ring.
  case nested([NPSCoordinateTree])

  /// One position's numbers in provider order, such as `[longitude, latitude]`.
  ///
  /// A position decodes only from a non-empty array of numbers. `.position([])` encodes as `[]`,
  /// which decodes back as `.nested([])`, so that one constructed value does not round trip.
  case position([Double])

  /// Decodes a position from a non-empty array of numbers and a nested list from any other array.
  /// - Parameter decoder: The decoder positioned at a JSON array.
  /// - Throws: `DecodingError` when the value is not an array, or when an array mixes numbers with
  ///   other values.
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    // Trying numbers first costs one failed attempt per list level rather than one per position.
    if let numbers = try? container.decode([Double].self), !numbers.isEmpty {
      self = .position(numbers)
    } else {
      self = .nested(try container.decode([NPSCoordinateTree].self))
    }
  }

  /// Encodes the tree as the same nesting of JSON arrays and numbers.
  /// - Parameter encoder: The encoder receiving one JSON array.
  /// - Throws: Any error the encoder reports.
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .nested(let children): try container.encode(children)
    case .position(let numbers): try container.encode(numbers)
    }
  }
}

extension NPSCoordinateTree {
  /// The polygons of a four-level tree, or nil when any level has a different depth.
  var polygons: [[[[Double]]]]? { list(\.rings) }

  /// The positions of a two-level tree, or nil when any child is not a position.
  var positions: [[Double]]? {
    list { child in
      guard case .position(let numbers) = child else { return nil }
      return numbers
    }
  }

  /// The rings of a three-level tree, or nil when any level has a different depth.
  var rings: [[[Double]]]? { list(\.positions) }

  /// Maps every child of a nested list, or returns nil when this is a position or any child fails.
  private func list<Element>(_ transform: (NPSCoordinateTree) -> Element?) -> [Element]? {
    guard case .nested(let children) = self else { return nil }
    var elements: [Element] = []
    elements.reserveCapacity(children.count)
    for child in children {
      guard let element = transform(child) else { return nil }
      elements.append(element)
    }
    return elements
  }
}
