/// An amenity with the parks and visitor centers NPS lists as offering it.
///
/// Identity and name are required. Parks and visitor centers are optional, preserving missing or
/// null values, and keep the provider's order and text, including links. Unknown JSON fields are
/// ignored by Codable.
///
/// The `/amenities/parksvisitorcenters` endpoint wraps its results in an extra array: each element
/// of a page's `data` is the provider's group of these values for one amenity, observed so far with
/// one entry each. Pages therefore decode as `NPSCollection<[AmenityParkVisitorCenters]>`.
///
/// ```swift
/// let page = try JSONDecoder().decode(
///   NPSCollection<[AmenityParkVisitorCenters]>.self, from: data)
/// for amenity in page.data.joined() {
///   print(amenity.name, amenity.parks?.first?.visitorCenters?.first?.name ?? "")
/// }
/// ```
public struct AmenityParkVisitorCenters: Codable, Hashable, Sendable {
  /// A park offering the amenity, as NPS summarizes it, with the visitor centers that offer it.
  public struct RelatedPark: Codable, Hashable, Sendable {
    private enum CodingKeys: String, CodingKey {
      case designation
      case fullName
      case name
      case parkCode
      case states
      case url
      case visitorCenters = "visitorcenters"
    }

    /// The park designation, such as `"National Park"`.
    public let designation: String?

    /// The full park name, including its designation.
    public let fullName: String?

    /// The short park name.
    public let name: String?

    /// The park code text, including codes unknown to this package.
    public let parkCode: String?

    /// The comma-separated state text, without splitting or sorting.
    public let states: String?

    /// The park's public website URL text.
    public let url: String?

    /// Visitor centers in the park offering the amenity, in provider order, from the lowercase
    /// `visitorcenters` key.
    public let visitorCenters: [VisitorCenterSummary]?
  }

  /// A visitor center where NPS lists the amenity, as NPS summarizes it.
  ///
  /// This is a summary, not the full ``VisitorCenter`` from the visitor centers endpoint.
  public struct VisitorCenterSummary: Codable, Hashable, Sendable {
    /// The provider's visitor center identifier, preserved as sent.
    public let id: String?

    /// The visitor center name, such as `"Hulls Cove Visitor Center"`.
    public let name: String?

    /// The web page URL text the provider links, not an API endpoint.
    public let url: String?
  }

  /// The provider's amenity identifier, preserved as sent.
  public let id: String

  /// The amenity name, such as `"Automated Entrance"`.
  public let name: String

  /// Parks offering the amenity, in provider order.
  public let parks: [RelatedPark]?
}
