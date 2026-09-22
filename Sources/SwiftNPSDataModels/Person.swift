/// A person profiled by the NPS people API.
///
/// Identity and title are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. ``latitude``, ``longitude``, and
/// ``latLong`` arrive as JSON strings and keep the provider's text: most people send empty
/// strings, and the rest send decimal text such as `"42.32527319611405"` (162 of 500 in a live
/// scan). Nothing is parsed into a number. ``bodyText`` is the provider's HTML, unmodified. Unknown
/// JSON fields are ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<Person>.self, from: data)
/// for person in page.data {
///   print(person.title, person.quickFacts?.first?.value ?? "")
/// }
/// ```
public struct Person: Codable, Hashable, Sendable {
  /// The provider's HTML profile, such as `"<p>...</p>"`, kept as sent without stripping markup.
  public let bodyText: String?

  /// The attribution, including an empty string; upstream rights still apply.
  public let credit: String?

  /// The person's first name, including an empty string.
  public let firstName: String?

  /// The provider's geometry point-of-interest identifier, including an empty string.
  public let geometryPoiId: String?

  /// The person identifier, preserved without UUID parsing.
  public let id: String

  /// Images of the person in provider order, with URL text and crop ratios kept as sent.
  public let images: [NPSImage]?

  /// The person's last name, including an empty string.
  public let lastName: String?

  /// The latitude text, either decimal text or an empty string, kept without parsing.
  public let latitude: String?

  /// The provider's combined coordinate text, such as
  /// `"{lat:42.32527319611405, long:-71.13226890563965}"`, or an empty string, kept as sent.
  public let latLong: String?

  /// The provider's summary of the person, including an empty string.
  public let listingDescription: String?

  /// The longitude text, either decimal text or an empty string, kept without parsing.
  public let longitude: String?

  /// The person's middle name, including an empty string.
  public let middleName: String?

  /// Labeled facts, such as a date or place of birth, in provider order. Values are text and are
  /// not parsed into dates.
  public let quickFacts: [NPSQuickFact]?

  /// Organizations NPS links to the person, including an empty array.
  public let relatedOrganizations: [NPSRelatedOrganization]?

  /// Parks NPS links to the person, including an empty array.
  public let relatedParks: [NPSRelatedPark]?

  /// Provider tags in the order sent, including an empty array.
  public let tags: [String]?

  /// The person's display title, usually the full name.
  public let title: String

  /// The person's web page URL text, not an API endpoint.
  public let url: String?
}
