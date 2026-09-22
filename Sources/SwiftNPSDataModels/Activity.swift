/// An activity offered across national parks, returned by the NPS activities API.
///
/// Identity and name are the only fields the provider sends. Unlike ``ActivityParks``, a page of
/// activities carries no nested parks; use ``ActivityParks`` to see which parks offer an
/// activity. Unknown JSON fields are ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<Activity>.self, from: data)
/// for activity in page.data {
///   print(activity.name)
/// }
/// ```
public struct Activity: Codable, Hashable, Sendable {
  /// The provider's activity identifier, preserved as sent.
  public let id: String

  /// The activity name, such as `"Hiking"`.
  public let name: String
}
