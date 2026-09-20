/// A place returned by the NPS places API.
///
/// Identity and title are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. Flags arrive as `"0"` and `"1"` text
/// and stay text. The provider publishes three separate coordinate representations, `latitude`,
/// `longitude`, and `latLong`, and each is kept as sent without parsing or cross-checking.
/// `bodyText` and `audioDescription` carry HTML. Unknown JSON fields are ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<Place>.self, from: data)
/// for place in page.data {
///   print(place.title, place.latLong ?? "", place.amenities?.count ?? 0)
/// }
/// ```
public struct Place: Codable, Hashable, Sendable {
  /// Published amenity names, in provider order, including an empty array.
  public let amenities: [String]?

  /// The provider's associated icon text, including an empty string.
  public let associatedIcon: String?

  /// The provider's audio description, which can contain HTML, including an empty string.
  public let audioDescription: String?

  /// The place's main text, which contains HTML.
  public let bodyText: String?

  /// The attribution, including an empty string; upstream rights still apply.
  public let credit: String?

  /// The provider's geometry point-of-interest identifier, including an empty string.
  public let geometryPoiId: String?

  /// The place identifier, preserved without UUID parsing.
  public let id: String

  /// Image references and attribution, whose crop aspect ratios arrive as text on this path.
  public let images: [NPSImage]?

  /// The NPS management flag exactly as sent, such as `"0"` or `"1"`, without Boolean parsing.
  public let isManagedByNps: String?

  /// The hidden map pin flag exactly as sent, such as `"0"` or `"1"`, without Boolean parsing.
  public let isMapPinHidden: String?

  /// The public access flag exactly as sent, such as `"0"` or `"1"`, without Boolean parsing.
  public let isOpenToPublic: String?

  /// The passport stamp flag exactly as sent, such as `"0"` or `"1"`, without Boolean parsing.
  ///
  /// A place can publish ``passportStampImages`` while sending `"0"` here, so the two are
  /// independent provider values rather than one derived from the other.
  public let isPassportStampLocation: String?

  /// The combined coordinate text without parsing, including an empty string.
  public let latLong: String?

  /// The latitude as supplied, with its original precision, including an empty string.
  public let latitude: String?

  /// The summary text NPS shows in listings, including an empty string.
  public let listingDescription: String?

  /// The provider's location text, including an empty string.
  public let location: String?

  /// The provider's location description, including an empty string.
  public let locationDescription: String?

  /// The longitude as supplied, with its original precision, including an empty string.
  public let longitude: String?

  /// The managing organization's name, including an empty string.
  public let managedByOrg: String?

  /// The managing organization's URL text, including an empty string, not an API endpoint.
  public let managedByUrl: String?

  /// Published multimedia references, including an empty array.
  public let multimedia: [NPSMultimedia]?

  /// The provider's NPMap identifier, including an empty string.
  public let npmapId: String?

  /// Passport stamp images, including an empty array, whose crop aspect ratios arrive as JSON
  /// numbers on this path while ``images`` crops arrive as text in the same response.
  public let passportStampImages: [NPSImage]?

  /// The provider's passport stamp description, including an empty string.
  public let passportStampLocationDescription: String?

  /// Labeled facts NPS publishes about the place, in provider order.
  public let quickFacts: [NPSQuickFact]?

  /// Organizations NPS links to the place, including an empty array.
  public let relatedOrganizations: [NPSRelatedOrganization]?

  /// Parks NPS links to the place, including an empty array.
  public let relatedParks: [NPSRelatedPark]?

  /// The provider's numeric relevance score, when supplied.
  public let relevanceScore: Double?

  /// Provider tags in the order sent, including an empty array.
  public let tags: [String]?

  /// The place's display title.
  public let title: String

  /// The place's web page URL text, not an API endpoint.
  public let url: String?
}
