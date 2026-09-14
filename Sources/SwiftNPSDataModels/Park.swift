/// A park returned by the NPS parks API.
///
/// Identity and names are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. Codes, coordinates, costs, links,
/// and dates retain their provider representation. Unknown JSON fields are ignored by Codable.
public struct Park: Codable, Hashable, Sendable {
  /// A physical or mailing address with provider-defined address types.
  public struct Address: Codable, Hashable, Sendable {
    /// The city text.
    public let city: String?

    /// The country code, when supplied.
    public let countryCode: String?

    /// The first address line.
    public let line1: String?

    /// The second address line, including an empty string.
    public let line2: String?

    /// The third address line, including an empty string.
    public let line3: String?

    /// The postal code as text.
    public let postalCode: String?

    /// The province or territory code, when supplied.
    public let provinceTerritoryCode: String?

    /// The state code without interpretation.
    public let stateCode: String?

    /// The open address type, such as Physical or Mailing.
    public let type: String?
  }

  /// Contact information published by a park.
  public struct Contacts: Codable, Hashable, Sendable {
    /// Published email contacts, or nil when unavailable.
    public let emailAddresses: [EmailAddress]?

    /// Published phone contacts, or nil when unavailable.
    public let phoneNumbers: [PhoneNumber]?
  }

  /// A published email contact.
  public struct EmailAddress: Codable, Hashable, Sendable {
    /// The provider's explanatory text.
    public let description: String?

    /// The email address as published.
    public let emailAddress: String?
  }

  /// A published entrance fee or pass, without numeric or currency conversion.
  public struct EntranceFee: Codable, Hashable, Sendable {
    /// The exact cost string; no currency is inferred.
    public let cost: String?

    /// The provider's fee or pass description.
    public let description: String?

    /// The fee or pass title.
    public let title: String?
  }

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

  /// A reference to provider multimedia with an open content type.
  public struct Multimedia: Codable, Hashable, Sendable {
    /// The provider identifier.
    public let id: String?

    /// The multimedia title.
    public let title: String?

    /// The provider's open media type.
    public let type: String?

    /// The original media link text.
    public let url: String?
  }

  /// An activity or topic with a provider identifier.
  public struct NamedItem: Codable, Hashable, Sendable {
    /// The identifier, including values unknown to this package.
    public let id: String?

    /// The provider's display name.
    public let name: String?
  }

  /// The park's published hours and seasonal exceptions.
  public struct OperatingHours: Codable, Hashable, Sendable {
    /// The original description and caveats.
    public let description: String?

    /// Exceptions, preserving nil separately from an empty array.
    public let exceptions: [OperatingHoursException]?

    /// The facility or schedule name.
    public let name: String?

    /// Hours by provider weekday key; values remain descriptive text.
    public let standardHours: [String: String?]?
  }

  /// A dated exception to published operating hours.
  public struct OperatingHoursException: Codable, Hashable, Sendable {
    /// The end date or timestamp in its original provider representation.
    public let endDate: String?

    /// Hours by provider weekday key, retaining null values.
    public let exceptionHours: [String: String?]?

    /// The exception's display name.
    public let name: String?

    /// The start date or timestamp without timezone assumptions.
    public let startDate: String?
  }

  /// A published phone contact with an open phone type.
  public struct PhoneNumber: Codable, Hashable, Sendable {
    /// The provider's explanatory text.
    public let description: String?

    /// The telephone extension as text.
    public let `extension`: String?

    /// The phone number without formatting changes.
    public let phoneNumber: String?

    /// The open type, including Voice, Fax, TTY, and future values.
    public let type: String?
  }

  /// Activities identified by NPS.
  public let activities: [NamedItem]?

  /// Physical and mailing addresses.
  public let addresses: [Address]?

  /// Published contact information.
  public let contacts: Contacts?

  /// The introduction from the park homepage.
  public let description: String?

  /// The open designation, such as National Park.
  public let designation: String?

  /// The provider's directions text.
  public let directionsInfo: String?

  /// The original directions link, including an empty string.
  public let directionsUrl: String?

  /// Published entrance fees, without reservation availability.
  public let entranceFees: [EntranceFee]?

  /// Published entrance passes.
  public let entrancePasses: [EntranceFee]?

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
  public let multimedia: [Multimedia]?

  /// The short park name.
  public let name: String

  /// Descriptive hours; these are not a live open-or-closed status.
  public let operatingHours: [OperatingHours]?

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
