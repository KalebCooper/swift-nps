/// The offset-paginated collection envelope returned by NPS Data API endpoints.
///
/// Pagination metadata stays in NPS's original string representation. A filter matching nothing
/// produces an empty ``data`` array with a total of `"0"`; that is a successful response.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<Park>.self, from: body)
/// print(page.data.count, page.total)
/// ```
public struct NPSCollection<Item: Codable & Hashable & Sendable>: Codable, Hashable, Sendable {
  /// Items on this page, in the provider's order.
  public let data: [Item]

  /// The provider's page limit, without conversion to an integer.
  public let limit: String

  /// The provider's starting offset, without conversion to an integer.
  public let start: String

  /// The provider's total matching count, without conversion to an integer.
  public let total: String
}
