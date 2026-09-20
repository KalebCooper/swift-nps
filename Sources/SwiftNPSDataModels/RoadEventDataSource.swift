/// An organization contributing events to a road events feed, usually one park.
///
/// A feature names its source through ``RoadEventDetails/CoreDetails/dataSourceId``.
///
/// ```swift
/// for source in feed.roadEventFeedInfo?.dataSources ?? [] {
///   print(source.organizationName ?? "", source.updateDate ?? "")
/// }
/// ```
public struct RoadEventDataSource: Codable, Hashable, Sendable {
  /// The source contact's email address, an organizational mailbox as sent.
  public let contactEmail: String?

  /// The source contact's name, such as `"Yellowstone National Park"`.
  public let contactName: String?

  /// The data source identifier, preserved without UUID parsing.
  public let dataSourceId: String?

  /// The contributing organization's name.
  public let organizationName: String?

  /// The source's last update time as the provider's text, without date parsing.
  public let updateDate: String?

  // The provider sends snake_case keys.
  private enum CodingKeys: String, CodingKey {
    case contactEmail = "contact_email"
    case contactName = "contact_name"
    case dataSourceId = "data_source_id"
    case organizationName = "organization_name"
    case updateDate = "update_date"
  }
}
