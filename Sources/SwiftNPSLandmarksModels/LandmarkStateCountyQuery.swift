/// Only the filters documented for StateCounty.
/// Values retain exact spelling; identifiers must fit 1...Int32.max.
public struct LandmarkStateCountyQuery: Hashable, Sendable {
  private let filters: LandmarkQuery

  /// The provider's countyID filter; nil omits it.
  public var countyID: Int64? { filters.countyID }
  /// The provider's stateCode filter; nil omits it.
  public var stateCode: String? { filters.stateCode }

  /// Validates the documented filters without I/O.
  public init(countyID: Int64? = nil, stateCode: String? = nil) throws(LandmarkQuery
    .ValidationError)
  {
    filters = try LandmarkQuery(countyID: countyID, stateCode: stateCode)
  }

  var encodedQuery: String { filters.encodedQuery }
}
