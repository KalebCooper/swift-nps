/// An alert returned by the NPS alerts API.
///
/// Identity and title are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. An empty `url` string is kept as
/// sent. Categories, codes, and timestamps retain their provider representation. Unknown JSON
/// fields are ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<ParkAlert>.self, from: data)
/// for alert in page.data {
///   print(alert.category ?? "", alert.title)
/// }
/// ```
public struct ParkAlert: Codable, Hashable, Sendable {
  /// A road event the provider links to an alert.
  public struct RelatedRoadEvent: Codable, Hashable, Sendable {
    /// The road event's unique identifier.
    public let id: String?

    /// The road event's title.
    public let title: String?

    /// The open related-item type, such as `roadevent`.
    public let type: String?

    /// A link to more information about the road event, as published.
    public let url: String?
  }

  /// The open alert category, such as Danger, Caution, Information, or Park Closure.
  ///
  /// NPS documents four categories, but other values decode unchanged.
  public let category: String?

  /// The alert's full description text.
  public let description: String?

  /// The unique identifier for the alert record.
  public let id: String

  /// When NPS last indexed the alert, as the provider's timestamp text.
  ///
  /// The value, such as `2026-09-16 00:00:00.0`, carries no time zone and is not parsed.
  public let lastIndexedDate: String?

  /// The code of the park the alert belongs to, without validation.
  public let parkCode: String?

  /// Road events linked to the alert, including an empty array, or nil when absent.
  public let relatedRoadEvents: [RelatedRoadEvent]?

  /// The alert's title.
  public let title: String

  /// A link to more information, as published, including an empty string.
  public let url: String?
}
