/// An article returned by the NPS articles API.
///
/// Identity and title are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. ``latitude`` and ``longitude`` arrive
/// as JSON numbers or `null` and keep that type, while ``latLong`` keeps the provider's own text.
/// Most articles send no coordinates. Unknown JSON fields are ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<Article>.self, from: data)
/// for article in page.data {
///   print(article.title, article.url ?? "")
/// }
/// ```
public struct Article: Codable, Hashable, Sendable {
  /// The attribution, including an empty string; upstream rights still apply.
  public let credit: String?

  /// The provider's geometry point-of-interest identifier, including an empty string.
  public let geometryPoiId: String?

  /// The article identifier, preserved without UUID parsing.
  public let id: String

  /// The latitude as a JSON number, or nil when the provider sends `null`.
  public let latitude: Double?

  /// The provider's combined coordinate text, such as `"{lat:31.97, long:-104.75}"`, or an empty
  /// string, kept as sent without parsing.
  public let latLong: String?

  /// The provider's summary of the article, including an empty string.
  public let listingDescription: String?

  /// The image shown with the article in listings, with URL text kept as sent.
  public let listingImage: NPSImage?

  /// The longitude as a JSON number, or nil when the provider sends `null`.
  public let longitude: Double?

  /// Parks NPS links to the article, including an empty array.
  public let relatedParks: [NPSRelatedPark]?

  /// Provider tags in the order sent, including an empty array.
  public let tags: [String]?

  /// The article's display title.
  public let title: String

  /// The article's web page URL text, not an API endpoint.
  public let url: String?
}
