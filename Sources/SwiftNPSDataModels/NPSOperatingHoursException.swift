/// A dated exception to published operating hours.
///
/// Dates keep their original provider representation without time zone assumptions.
///
/// ```swift
/// for exception in hours.exceptions ?? [] {
///   print(exception.name ?? "", exception.startDate ?? "", exception.endDate ?? "")
/// }
/// ```
public struct NPSOperatingHoursException: Codable, Hashable, Sendable {
  /// The end date or timestamp in its original provider representation.
  public let endDate: String?

  /// Hours by provider weekday key, retaining null values.
  public let exceptionHours: [String: String?]?

  /// The exception's display name.
  public let name: String?

  /// The start date or timestamp without timezone assumptions.
  public let startDate: String?
}
