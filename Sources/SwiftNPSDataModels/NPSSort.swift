/// One sort criterion for an NPS collection query, naming a resource property.
///
/// NPS documents sortable fields as resource properties without enumerating them, so the field
/// is an open string preserved exactly. Criteria retain their order and serialize as the field
/// name with NPS's minus prefix for descending order.
///
/// ```swift
/// let query = try ParkQuery(sort: [.descending("fullName"), .ascending("parkCode")])
/// // sort=-fullName,parkCode
/// ```
public struct NPSSort: Hashable, Sendable {
  /// A sort direction encoded using NPS's optional minus prefix.
  public enum Direction: Hashable, Sendable {
    /// Ascending values, without a prefix.
    case ascending
    /// Descending values, with a minus prefix.
    case descending
  }

  /// The direction applied to ``field``.
  public let direction: Direction
  /// The provider property name, preserved without validation or case changes.
  public let field: String

  /// Creates a criterion for a provider property.
  /// - Parameters:
  ///   - field: A resource property name such as `fullName`.
  ///   - direction: The sort direction, ascending by default.
  public init(_ field: String, _ direction: Direction = .ascending) {
    self.direction = direction
    self.field = field
  }

  /// Creates an ascending criterion.
  /// - Parameter field: A resource property name.
  /// - Returns: The criterion serialized as the bare field name.
  public static func ascending(_ field: String) -> Self {
    Self(field, .ascending)
  }

  /// Creates a descending criterion.
  /// - Parameter field: A resource property name.
  /// - Returns: The criterion serialized with a leading minus.
  public static func descending(_ field: String) -> Self {
    Self(field, .descending)
  }

  var queryValue: String {
    (direction == .descending ? "-" : "") + field
  }
}
