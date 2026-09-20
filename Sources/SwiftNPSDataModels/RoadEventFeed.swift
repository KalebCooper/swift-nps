/// A road events feed returned by the NPS road events API, in WZDx 4.1 GeoJSON form.
///
/// The provider sends a GeoJSON `FeatureCollection` rather than the paged NPS envelope, so there
/// is no total, limit, or start and no following page. Keys are remapped from the provider's
/// snake_case; values, timestamps, and GeoJSON `[longitude, latitude]` pairs are kept as sent.
/// Most parks return an empty ``features`` array. Unknown JSON fields are ignored by Codable.
///
/// The data is published by the National Park Service under the license URL in
/// ``RoadEventFeedInfo/license``, which this package's license does not cover. It is not an
/// authoritative live closure service.
///
/// ```swift
/// let feed = try JSONDecoder().decode(RoadEventFeed.self, from: data)
/// for feature in feed.features ?? [] {
///   print(feature.properties?.coreDetails?.name ?? "", feature.properties?.startDate ?? "")
/// }
/// ```
public struct RoadEventFeed: Codable, Hashable, Sendable {
  /// Road events in provider order, including an empty array when no events match.
  public let features: [RoadEventFeature]?

  /// The feed's publisher, license, contact, and data source metadata.
  public let roadEventFeedInfo: RoadEventFeedInfo?

  /// The GeoJSON object type, such as `"FeatureCollection"`, kept as an open string.
  public let type: String?

  // The provider sends `road_event_feed_info` in snake_case; every other key matches its property.
  private enum CodingKeys: String, CodingKey {
    case features
    case roadEventFeedInfo = "road_event_feed_info"
    case type
  }
}
