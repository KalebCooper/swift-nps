/// Only the filters documented for LandmarkOwnerInformation.
/// Values retain exact spelling; identifiers must fit 1...Int32.max.
public struct LandmarkOwnerQuery: Hashable, Sendable {
  private let filters: LandmarkQuery

  /// The provider's code filter; nil omits it.
  public var code: String? { filters.code }
  /// The provider's id filter; nil omits it.
  public var id: Int64? { filters.id }

  /// Validates the documented filters without I/O.
  public init(code: String? = nil, id: Int64? = nil) throws(LandmarkQuery.ValidationError) {
    filters = try LandmarkQuery(code: code, id: id)
  }

  var encodedQuery: String { filters.encodedQuery }
}
