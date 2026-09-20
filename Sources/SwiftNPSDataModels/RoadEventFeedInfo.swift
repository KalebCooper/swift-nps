/// The metadata of a road events feed: publisher, license, contact, and data sources.
///
/// Timestamps are kept as the provider's text, such as `"2024-01-16T16:49:30.901071Z"`, without
/// date parsing. The feed update date can be older than the events it lists.
///
/// ```swift
/// if let info = feed.roadEventFeedInfo {
///   print(info.publisher ?? "", info.license ?? "")
/// }
/// ```
public struct RoadEventFeedInfo: Codable, Hashable, Sendable {
  /// The feed contact's email address, an organizational mailbox as sent.
  public let contactEmail: String?

  /// The feed contact's name, such as `"National Park Service"`.
  public let contactName: String?

  /// The organizations whose events the feed contains, including an empty array.
  public let dataSources: [RoadEventDataSource]?

  /// The feed identifier, preserved without UUID parsing.
  public let id: String?

  /// The URL text of the license covering the feed's data, such as a Creative Commons deed.
  public let license: String?

  /// The feed's publisher, such as `"National Park Service"`.
  public let publisher: String?

  /// The feed's last update time as the provider's text, without date parsing.
  public let updateDate: String?

  /// The provider's stated update frequency as a JSON number, such as `60`, without a unit.
  public let updateFrequency: Int?

  /// The WZDx specification version the feed declares, such as `"4.1"`.
  public let version: String?

  // The provider sends snake_case keys for multiword fields.
  private enum CodingKeys: String, CodingKey {
    case contactEmail = "contact_email"
    case contactName = "contact_name"
    case dataSources = "data_sources"
    case id
    case license
    case publisher
    case updateDate = "update_date"
    case updateFrequency = "update_frequency"
    case version
  }
}
