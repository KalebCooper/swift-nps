/// One documented NPS parks sort criterion.
///
/// Query criteria retain their order. Relevance must be used alone; higher scores indicate
/// stronger matches, so `.relevanceScore(.descending)` is useful for text searches.
public enum ParkSort: Hashable, Sendable {
  /// A sort direction encoded using NPS's optional minus prefix.
  public enum Order: Hashable, Sendable {
    /// Ascending values, without a prefix.
    case ascending
    /// Descending values, with a minus prefix.
    case descending
  }

  /// Sort by the full park name.
  case fullName(Order)
  /// Sort by park code.
  case parkCode(Order)
  /// Sort by text-search relevance, without other criteria.
  case relevanceScore(Order)

  var isRelevance: Bool {
    if case .relevanceScore = self { return true }
    return false
  }

  var queryValue: String {
    let field: String
    let order: Order
    switch self {
    case .fullName(let direction): (field, order) = ("fullName", direction)
    case .parkCode(let direction): (field, order) = ("parkCode", direction)
    case .relevanceScore(let direction): (field, order) = ("relevanceScore", direction)
    }
    return (order == .descending ? "-" : "") + field
  }
}
