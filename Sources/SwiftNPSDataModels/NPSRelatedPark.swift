/// A park summary NPS attaches to records from other endpoint groups.
///
/// Things to do list these under `relatedParks`, and the amenity park endpoints nest one inside
/// each park entry. Every field is optional and kept as sent, including empty strings; `states`
/// stays the provider's comma-joined text and is not split or validated.
///
/// ```swift
/// for park in thing.relatedParks ?? [] {
///   print(park.parkCode ?? "", park.fullName ?? "", park.states ?? "")
/// }
/// ```
public struct NPSRelatedPark: Codable, Hashable, Sendable {
  /// The park designation, such as `"National Park"`, including an empty string.
  public let designation: String?

  /// The full park name, including its designation.
  public let fullName: String?

  /// The short park name.
  public let name: String?

  /// The park code text, including codes unknown to this package.
  public let parkCode: String?

  /// The comma-joined state text as sent, without splitting, trimming, or sorting.
  public let states: String?

  /// The park's public website URL text, not an API endpoint.
  public let url: String?
}
