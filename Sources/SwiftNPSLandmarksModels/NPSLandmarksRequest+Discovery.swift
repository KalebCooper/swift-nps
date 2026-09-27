extension NPSLandmarksRequest where Response == LandmarkCounty {
  /// County returns one county relationship (including for an unfiltered request).
  /// - Throws: This operation performs no I/O.
  public static func landmarkCounty(query: LandmarkQuery) -> Self {
    Self(endpoint: .landmarkCounty(query: query))
  }
}

extension NPSLandmarksRequest where Response == LandmarkState {
  /// State returns the provider's records.
  /// - Throws: Invalid input before I/O.
  public static func landmarkState(stateCode: String) throws(LandmarkQuery.ValidationError) -> Self
  {
    Self(endpoint: try .landmarkState(stateCode: stateCode))
  }
}

extension NPSLandmarksRequest where Response == [LandmarkState] {
  /// AllStates returns the provider's records.
  /// - Throws: This operation performs no I/O.
  public static func landmarkStates() -> Self {
    Self(endpoint: .landmarkStates())
  }
}

extension NPSLandmarksRequest where Response == [LandmarkWithCounty] {
  /// LandmarkInformationPerCounty returns county-enriched records without deduplication.
  /// - Throws: Invalid input before I/O.
  public static func landmarks(countyID: Int64) throws(LandmarkQuery.ValidationError) -> Self {
    Self(endpoint: try .landmarks(countyID: countyID))
  }
}

extension NPSLandmarksRequest where Response == [NPSLandmark] {
  /// LandmarkInformation returns the provider's records.
  /// - Throws: This operation performs no I/O.
  public static func landmarks(query: LandmarkQuery) -> Self {
    Self(endpoint: .landmarks(query: query))
  }
}

extension NPSLandmarksRequest where Response == [NPSLandmark] {
  /// LandmarkInformationPerStateCode returns the provider's records.
  /// - Throws: Invalid input before I/O.
  public static func landmarks(stateCode: String) throws(LandmarkQuery.ValidationError) -> Self {
    Self(endpoint: try .landmarks(stateCode: stateCode))
  }
}
