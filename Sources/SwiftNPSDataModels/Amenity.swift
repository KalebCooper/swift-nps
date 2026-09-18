/// An amenity type returned by the NPS amenities API.
///
/// Identity and name are required. The provider's `categories` array is optional, preserving a
/// missing or null value, and keeps its category text and order as sent. Unknown JSON fields are
/// ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<Amenity>.self, from: data)
/// for amenity in page.data {
///   print(amenity.name, amenity.categories ?? [])
/// }
/// ```
public struct Amenity: Codable, Hashable, Sendable {
  /// Category names in provider order, such as `"Accessibility"`, or nil when absent.
  ///
  /// The specification does not list this field; live responses send it.
  public let categories: [String]?

  /// The provider's amenity identifier, preserved as sent.
  public let id: String

  /// The amenity name, such as `"ATM/Cash Machine"`.
  public let name: String
}
