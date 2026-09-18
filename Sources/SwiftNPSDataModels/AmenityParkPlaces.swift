/// An amenity with the parks and places NPS lists as offering it.
///
/// Identity and name are required. Parks and places are optional, preserving missing or null
/// values, and keep the provider's order and text, including links. Unknown JSON fields are
/// ignored by Codable.
///
/// The `/amenities/parksplaces` endpoint wraps its results in an extra array: each element of a
/// page's `data` is the provider's group of these values for one amenity, observed so far with one
/// entry each. Pages therefore decode as `NPSCollection<[AmenityParkPlaces]>`.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<[AmenityParkPlaces]>.self, from: data)
/// for amenity in page.data.joined() {
///   print(amenity.name, amenity.parks?.first?.places?.first?.title ?? "")
/// }
/// ```
public struct AmenityParkPlaces: Codable, Hashable, Sendable {
  /// A place in a park where NPS lists the amenity.
  public struct Place: Codable, Hashable, Sendable {
    /// The provider's place identifier, preserved as sent.
    public let id: String?

    /// The place title, such as `"Jordan Pond House"`.
    public let title: String?

    /// The place's public web page URL text, not an API endpoint.
    public let url: String?
  }

  /// A park offering the amenity, as NPS summarizes it, with the places that offer it.
  public struct RelatedPark: Codable, Hashable, Sendable {
    /// The park designation, such as `"National Park"`.
    public let designation: String?

    /// The full park name, including its designation.
    public let fullName: String?

    /// The short park name.
    public let name: String?

    /// The park code text, including codes unknown to this package.
    public let parkCode: String?

    /// Places in the park offering the amenity, in provider order.
    public let places: [Place]?

    /// The comma-separated state text, without splitting or sorting.
    public let states: String?

    /// The park's public website URL text.
    public let url: String?
  }

  /// The provider's amenity identifier, preserved as sent.
  public let id: String

  /// The amenity name, such as `"Accessible Rooms"`.
  public let name: String

  /// Parks offering the amenity, in provider order.
  public let parks: [RelatedPark]?
}
