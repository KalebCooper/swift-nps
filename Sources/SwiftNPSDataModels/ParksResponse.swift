/// The collection envelope returned by a parks lookup.
///
/// Pagination metadata stays in NPS's original string representation. An unknown code can
/// produce an empty ``data`` array with a total of `"0"`; that is a successful response.
public struct ParksResponse: Codable, Hashable, Sendable {
  /// Parks on this page, in the provider's order.
  public let data: [Park]

  /// The provider's page limit, without conversion to an integer.
  public let limit: String

  /// The provider's starting offset, without conversion to an integer.
  public let start: String

  /// The provider's total matching count, without conversion to an integer.
  public let total: String
}
