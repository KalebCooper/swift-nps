extension LandmarkEndpoint where Response == LandmarkCounty {
  /// County returns one county relationship (including for an unfiltered request).
  /// - Throws: This operation performs no I/O.
  public static func landmarkCounty(query: LandmarkQuery) -> Self {
    let query = query.encodedQuery
    return route("/api/County" + (query.isEmpty ? "" : "?" + query))
  }
}

extension LandmarkEndpoint where Response == LandmarkState {
  /// State returns the provider's records.
  /// - Throws: Invalid input before I/O.
  public static func landmarkState(stateCode: String) throws(LandmarkQuery.ValidationError) -> Self
  {
    let query = try LandmarkQuery(stateCode: stateCode).encodedQuery
    return route("/api/State" + (query.isEmpty ? "" : "?" + query))
  }
}

extension LandmarkEndpoint where Response == [LandmarkState] {
  /// AllStates returns the provider's records.
  /// - Throws: This operation performs no I/O.
  public static func landmarkStates() -> Self {
    let query = ""
    return route("/api/AllStates" + (query.isEmpty ? "" : "?" + query))
  }
}

extension LandmarkEndpoint where Response == [LandmarkWithCounty] {
  /// LandmarkInformationPerCounty returns county-enriched records without deduplication.
  /// - Throws: Invalid input before I/O.
  public static func landmarks(countyID: Int64) throws(LandmarkQuery.ValidationError) -> Self {
    let query = try LandmarkQuery(countyID: countyID).encodedQuery
    return route("/api/LandmarkInformationPerCounty" + (query.isEmpty ? "" : "?" + query))
  }
}

extension LandmarkEndpoint where Response == [NPSLandmark] {
  /// LandmarkInformation returns the provider's records.
  /// - Throws: This operation performs no I/O.
  public static func landmarks(query: LandmarkQuery) -> Self {
    let query = query.encodedQuery
    return route("/api/LandmarkInformation" + (query.isEmpty ? "" : "?" + query))
  }
}

extension LandmarkEndpoint where Response == [NPSLandmark] {
  /// LandmarkInformationPerStateCode returns the provider's records.
  /// - Throws: Invalid input before I/O.
  public static func landmarks(stateCode: String) throws(LandmarkQuery.ValidationError) -> Self {
    let query = try LandmarkQuery(stateCode: stateCode).encodedQuery
    return route("/api/LandmarkInformationPerStateCode" + (query.isEmpty ? "" : "?" + query))
  }
}
