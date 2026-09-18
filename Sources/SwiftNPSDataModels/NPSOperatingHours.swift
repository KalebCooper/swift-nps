/// Published hours and seasonal exceptions for a park or facility.
///
/// Hours are descriptive text by provider weekday key, not a live open-or-closed status. Null
/// weekday values are retained.
///
/// ```swift
/// for hours in park.operatingHours ?? [] {
///   print(hours.name ?? "", hours.description ?? "")
/// }
/// ```
public struct NPSOperatingHours: Codable, Hashable, Sendable {
  /// The original description and caveats.
  public let description: String?

  /// Exceptions, preserving nil separately from an empty array.
  public let exceptions: [NPSOperatingHoursException]?

  /// The facility or schedule name.
  public let name: String?

  /// Hours by provider weekday key; values remain descriptive text.
  public let standardHours: [String: String?]?
}
