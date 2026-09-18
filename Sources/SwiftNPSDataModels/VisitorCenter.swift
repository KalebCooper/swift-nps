/// A visitor center returned by the NPS visitor centers API.
///
/// Identity and name are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. Coordinates, flags, links, and
/// timestamps retain their provider representation, including empty strings. Unknown JSON fields
/// are ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<VisitorCenter>.self, from: data)
/// for center in page.data {
///   print(center.parkCode ?? "", center.name)
/// }
/// ```
public struct VisitorCenter: Codable, Hashable, Sendable {
  /// An image reference with attribution, accessibility text, and published crops.
  public struct Image: Codable, Hashable, Sendable {
    /// The alternative text.
    public let altText: String?

    /// The original caption.
    public let caption: String?

    /// The attribution; upstream rights still apply.
    public let credit: String?

    /// Published crops, including an empty array, or nil when absent.
    public let crops: [ImageCrop]?

    /// The image title.
    public let title: String?

    /// The image URL text, not an API endpoint.
    public let url: String?
  }

  /// A published crop of an image.
  public struct ImageCrop: Codable, Hashable, Sendable {
    /// The width-to-height ratio as a number, when supplied.
    public let aspectRatio: Double?

    /// The cropped image URL text, not an API endpoint.
    public let url: String?
  }

  /// An image of the National Parks Passport stamp available at a visitor center.
  public struct PassportStampImage: Codable, Hashable, Sendable {
    /// The alternative text, which often transcribes the stamp.
    public let altText: String?

    /// The original caption, including an empty string.
    public let caption: String?

    /// The attribution, including an empty string; upstream rights still apply.
    public let credit: String?

    /// Published crops, including an empty array, or nil when absent.
    public let crops: [ImageCrop]?

    /// The provider's description, including an empty string.
    public let description: String?

    /// The stamp image title.
    public let title: String?

    /// The image URL text, not an API endpoint.
    public let url: String?
  }

  /// Physical and mailing addresses.
  public let addresses: [NPSAddress]?

  /// Amenity names as published, in provider order.
  public let amenities: [String]?

  /// The provider's audio description text, including an empty string.
  public let audioDescription: String?

  /// Published contact information.
  public let contacts: NPSContacts?

  /// The visitor center's description.
  public let description: String?

  /// The provider's directions text.
  public let directionsInfo: String?

  /// The original directions link, including an empty string.
  public let directionsUrl: String?

  /// The provider's geometry point-of-interest identifier, including an empty string.
  public let geometryPoiId: String?

  /// The visitor center identifier, preserved without UUID parsing.
  public let id: String

  /// Image references and attribution.
  public let images: [Image]?

  /// The passport stamp flag exactly as sent, such as `"0"` or `"1"`, without Boolean parsing.
  public let isPassportStampLocation: String?

  /// When NPS last indexed the record, as the provider's text, including an empty string.
  public let lastIndexedDate: String?

  /// The combined coordinate text without parsing.
  public let latLong: String?

  /// The latitude as supplied, with its original precision.
  public let latitude: String?

  /// The longitude as supplied, with its original precision.
  public let longitude: String?

  /// Published multimedia references.
  public let multimedia: [NPSMultimedia]?

  /// The visitor center's display name.
  public let name: String

  /// Descriptive hours; these are not a live open-or-closed status.
  public let operatingHours: [NPSOperatingHours]?

  /// The code of the park the visitor center belongs to, without validation.
  public let parkCode: String?

  /// Passport stamp images, including an empty array, or nil when absent.
  public let passportStampImages: [PassportStampImage]?

  /// The provider's passport stamp description, including an empty string.
  public let passportStampLocationDescription: String?

  /// The provider's numeric relevance score, when supplied.
  public let relevanceScore: Double?

  /// The visitor center's web page URL text, including an empty string.
  public let url: String?
}
