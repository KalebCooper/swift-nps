/// An activity or topic with a provider identifier.
///
/// Parks and things to do use this shape for their activities and topics. Identifiers and names
/// are kept as sent, including values unknown to this package.
///
/// ```swift
/// for activity in park.activities ?? [] {
///   print(activity.id ?? "", activity.name ?? "")
/// }
/// ```
public struct NPSNamedItem: Codable, Hashable, Sendable {
  /// The identifier, including values unknown to this package.
  public let id: String?

  /// The provider's display name.
  public let name: String?
}
