/// An activity and the parks that offer it, returned by the NPS activity parks API.
///
/// Identity and name are required. The provider's `parks` array is optional, preserving a missing
/// or null value, and keeps its entries and order as sent. A query's park codes narrow this array
/// to the requested parks as well as selecting which activities are returned. Unknown JSON fields
/// are ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<ActivityParks>.self, from: data)
/// for activity in page.data {
///   print(activity.name, activity.parks?.compactMap(\.parkCode) ?? [])
/// }
/// ```
public struct ActivityParks: Codable, Hashable, Sendable {
  /// The provider's activity identifier, preserved as sent.
  public let id: String

  /// The activity name, such as `"Guided Tours"`.
  public let name: String

  /// Parks offering this activity in provider order, or nil when absent.
  public let parks: [NPSRelatedPark]?
}
