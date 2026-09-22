/// A news release returned by the NPS news releases API.
///
/// Identity and title are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. ``releaseDate`` and
/// ``lastIndexedDate`` keep the provider's text, such as `"2026-09-17 15:34:00.0"`, which is not
/// ISO 8601 and names no time zone, so no `Date` is derived. ``parkCode`` keeps the provider's
/// text, which can be empty or list several comma-separated codes. Unknown JSON fields are ignored
/// by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<NewsRelease>.self, from: data)
/// for release in page.data {
///   print(release.releaseDate ?? "", release.title)
/// }
/// ```
public struct NewsRelease: Codable, Hashable, Sendable {
  /// The provider's summary of the release, including an empty string.
  public let abstract: String?

  /// The attribution, including an empty string; upstream rights still apply.
  public let credit: String?

  /// The provider's geometry point-of-interest identifier, including an empty string.
  public let geometryPoiId: String?

  /// The news release identifier, preserved without UUID parsing.
  public let id: String

  /// The image shown with the release, with every text field kept as sent, including empty text.
  public let image: NPSImage?

  /// When NPS last indexed the release, as the provider's text such as
  /// `"2026-09-17 11:07:35.0"`, without a time zone or parsing.
  public let lastIndexedDate: String?

  /// The latitude as a JSON number, or nil when the provider sends `null`.
  public let latitude: Double?

  /// The longitude as a JSON number, or nil when the provider sends `null`.
  public let longitude: Double?

  /// The provider's park code text, such as `"yell"`, `"anac,nace"`, or an empty string, kept
  /// without splitting or validation.
  public let parkCode: String?

  /// Organizations NPS links to the release, including an empty array.
  public let relatedOrganizations: [NPSRelatedOrganization]?

  /// Parks NPS links to the release, including an empty array.
  public let relatedParks: [NPSRelatedPark]?

  /// When the release was published, as the provider's text such as `"2026-09-17 15:34:00.0"`,
  /// without a time zone or parsing.
  public let releaseDate: String?

  /// The release's display title.
  public let title: String

  /// The release's web page URL text, not an API endpoint.
  public let url: String?
}
