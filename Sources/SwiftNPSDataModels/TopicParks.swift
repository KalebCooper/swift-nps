/// A topic and the parks associated with it, returned by the NPS topic parks API.
///
/// Identity and name are required. The provider's `parks` array is optional, preserving a missing
/// or null value, and keeps its entries and order as sent. A query's park codes narrow this array
/// to the requested parks as well as selecting which topics are returned. Unknown JSON fields are
/// ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<TopicParks>.self, from: data)
/// for topic in page.data {
///   print(topic.name, topic.parks?.compactMap(\.parkCode) ?? [])
/// }
/// ```
public struct TopicParks: Codable, Hashable, Sendable {
  /// The provider's topic identifier, preserved as sent.
  public let id: String

  /// The topic name, such as `"Women's History"`.
  public let name: String

  /// Parks associated with this topic in provider order, or nil when absent.
  public let parks: [NPSRelatedPark]?
}
