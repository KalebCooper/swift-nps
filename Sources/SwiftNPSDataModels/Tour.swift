/// A self-guided tour returned by the NPS tours API.
///
/// Identity and title are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. A tour links one park through a
/// singular ``park`` rather than an array. Durations arrive as numeric text with a separate unit
/// code and stay text; nothing is converted to a duration. Stops keep the provider's order and
/// their string ``Stop/ordinal``. Unknown JSON fields are ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<Tour>.self, from: data)
/// for tour in page.data {
///   print(tour.title, tour.park?.parkCode ?? "", tour.stops?.count ?? 0)
/// }
/// ```
public struct Tour: Codable, Hashable, Sendable {
  /// One stop on a tour, linking a place, visitor center, or other NPS asset.
  ///
  /// Every field is optional and kept as sent, including empty strings. ``ordinal`` is the
  /// provider's position text, such as `"1"`, and is not parsed into a number. ``assetType`` names
  /// the collection ``assetId`` belongs to, such as `"places"` or `"visitorcenters"`, and stays an
  /// open string.
  ///
  /// ```swift
  /// for stop in tour.stops ?? [] {
  ///   print(stop.ordinal ?? "", stop.assetName ?? "", stop.assetType ?? "")
  /// }
  /// ```
  public struct Stop: Codable, Hashable, Sendable {
    /// The identifier of the linked asset, preserved without UUID parsing.
    public let assetId: String?

    /// The linked asset's display name.
    public let assetName: String?

    /// The collection the linked asset belongs to, such as `"places"`, kept as an open string.
    public let assetType: String?

    /// The audio file URL text, including an empty string, not an API endpoint.
    public let audioFileUrl: String?

    /// The transcript of the stop's audio, including an empty string.
    public let audioTranscript: String?

    /// Directions from this stop to the next, including an empty string.
    public let directionsToNextStop: String?

    /// The stop identifier, preserved without UUID parsing.
    public let id: String?

    /// The stop's position text exactly as sent, such as `"1"`, without numeric parsing.
    public let ordinal: String?

    /// Why the stop matters, including an empty string.
    public let significance: String?
  }

  /// Activities NPS associates with the tour, in provider order.
  public let activities: [NPSNamedItem]?

  /// The tour's description.
  public let description: String?

  /// The longest expected duration as numeric text, measured in ``durationUnit``.
  public let durationMax: String?

  /// The shortest expected duration as numeric text, measured in ``durationUnit``.
  public let durationMin: String?

  /// The unit code for both durations as sent, such as `"m"`, `"h"`, or `"d"`, kept open.
  public let durationUnit: String?

  /// The tour identifier, preserved without UUID parsing.
  public let id: String

  /// Image references and attribution, whose crop aspect ratios arrive as JSON numbers on this
  /// path.
  public let images: [NPSImage]?

  /// The one park the tour belongs to, sent as a single object rather than an array.
  public let park: NPSRelatedPark?

  /// The provider's numeric relevance score, when supplied.
  public let relevanceScore: Double?

  /// The tour's stops in the order sent.
  public let stops: [Stop]?

  /// Provider tags in the order sent, including an empty array.
  public let tags: [String]?

  /// Topics NPS associates with the tour, in provider order.
  public let topics: [NPSNamedItem]?

  /// The tour's display title.
  public let title: String

  /// The provider's tour type, such as `"Standard"`, kept as an open string.
  public let type: String?
}
