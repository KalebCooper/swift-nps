/// A park returned by the NPS parks API.
///
/// Identity and names are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. Codes, coordinates, costs, links,
/// and dates retain their provider representation. Unknown JSON fields are ignored by Codable.
public struct Park: Codable, Hashable, Sendable {
  /// An image reference, including its attribution and accessibility text.
  public struct Image: Codable, Hashable, Sendable {
    /// The alternative text.
    public let altText: String?

    /// The original caption.
    public let caption: String?

    /// The attribution; upstream rights still apply.
    public let credit: String?

    /// The image title.
    public let title: String?

    /// The image URL text, not an API endpoint.
    public let url: String?
  }

  /// An activity or topic with a provider identifier.
  public struct NamedItem: Codable, Hashable, Sendable {
    /// The identifier, including values unknown to this package.
    public let id: String?

    /// The provider's display name.
    public let name: String?
  }

  /// Activities identified by NPS.
  public let activities: [NamedItem]?

  /// Physical and mailing addresses.
  public let addresses: [NPSAddress]?

  /// Published contact information.
  public let contacts: NPSContacts?

  /// The introduction from the park homepage.
  public let description: String?

  /// The open designation, such as National Park.
  public let designation: String?

  /// The provider's directions text.
  public let directionsInfo: String?

  /// The original directions link, including an empty string.
  public let directionsUrl: String?

  /// Published entrance fees, without reservation availability.
  public let entranceFees: [NPSFee]?

  /// Published entrance passes.
  public let entrancePasses: [NPSFee]?

  /// The full park name, including its designation.
  public let fullName: String

  /// The park identifier, preserved without UUID parsing.
  public let id: String

  /// Image references and attribution.
  public let images: [Image]?

  /// The combined coordinate text without parsing.
  public let latLong: String?

  /// The latitude as supplied, with its original precision.
  public let latitude: String?

  /// The longitude as supplied, with its original precision.
  public let longitude: String?

  /// Published multimedia references.
  public let multimedia: [NPSMultimedia]?

  /// The short park name.
  public let name: String

  /// Descriptive hours; these are not a live open-or-closed status.
  public let operatingHours: [NPSOperatingHours]?

  /// The response code as supplied, without request-code validation.
  public let parkCode: String

  /// The provider's numeric relevance score, when supplied.
  public let relevanceScore: Double?

  /// The comma-separated state text, without splitting or sorting.
  public let states: String?

  /// Topics identified by NPS.
  public let topics: [NamedItem]?

  /// The park's public website URL text.
  public let url: String?

  /// The park's general weather information, not a forecast.
  public let weatherInfo: String?
}
