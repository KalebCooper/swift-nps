/// A topic associated with national parks, returned by the NPS topics API.
///
/// Identity and name are the only fields the provider sends. Unlike ``ParkTopicParks``, a page of
/// topics carries no nested parks; use ``ParkTopicParks`` to see which parks relate to a topic.
/// Unknown JSON fields are ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<ParkTopic>.self, from: data)
/// for topic in page.data {
///   print(topic.name)
/// }
/// ```
public struct ParkTopic: Codable, Hashable, Sendable {
  /// The provider's topic identifier, preserved as sent.
  public let id: String

  /// The topic name, such as `"Women's History"`.
  public let name: String
}
