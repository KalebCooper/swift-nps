/// An activity offered across national parks, returned by the NPS activities API.
///
/// Identity and name are the only fields the provider sends. Unlike ``ParkActivityParks``, a page
/// of activities carries no nested parks; use ``ParkActivityParks`` to see which parks offer an
/// activity. Unknown JSON fields are ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<ParkActivity>.self, from: data)
/// for activity in page.data {
///   print(activity.name)
/// }
/// ```
public struct ParkActivity: Codable, Hashable, Sendable {
  /// The provider's activity identifier, preserved as sent.
  public let id: String

  /// The activity name, such as `"Hiking"`.
  public let name: String
}
