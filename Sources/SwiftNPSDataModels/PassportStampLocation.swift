/// A place to collect a National Park Passport stamp, returned by the NPS passport stamp locations
/// API.
///
/// Identity and label are required. The provider's `parks` array is optional, preserving a missing
/// or null value, and keeps its entries and order as sent; it can be empty. A query's park codes
/// select which locations are returned without narrowing this array. Unknown JSON fields are
/// ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<PassportStampLocation>.self, from: data)
/// for location in page.data {
///   print(location.label, location.type ?? "", location.parks?.compactMap(\.parkCode) ?? [])
/// }
/// ```
public struct PassportStampLocation: Codable, Hashable, Sendable {
  /// The provider's location identifier, preserved as sent.
  public let id: String

  /// The location's display name, such as `"Camp Misty Mount"`.
  public let label: String

  /// The parks associated with this location, in provider order.
  public let parks: [NPSRelatedPark]?

  /// The provider's kind of location, preserved as open text.
  ///
  /// Observed values are `"visitorcenters"`, `"places"`, and `"campgrounds"`; NPS documents no
  /// closed set, so other values pass through unchanged.
  public let type: String?
}
