extension NPSLandmarksRequest where Response == [LandmarkOwner] {
  /// LandmarkOwnerInformation returns the provider's rows without reordering or deduplication.
  public static func landmarkOwners(query: LandmarkOwnerQuery) -> Self {
    Self(endpoint: .landmarkOwners(query: query))
  }
}

extension NPSLandmarksRequest where Response == [LandmarkCounty] {
  /// SiteCounties returns the provider's rows without reordering or deduplication.
  public static func landmarkSiteCounties(query: LandmarkQuery) -> Self {
    Self(endpoint: .landmarkSiteCounties(query: query))
  }
}

extension NPSLandmarksRequest where Response == [LandmarkStateCounty] {
  /// StateCounty returns the provider's rows without reordering or deduplication.
  public static func landmarkStateCounties(query: LandmarkStateCountyQuery) -> Self {
    Self(endpoint: .landmarkStateCounties(query: query))
  }
}

extension NPSLandmarksRequest where Response == [LandmarkWithCounty] {
  /// LandmarkInformationWithCounty returns the provider's rows without reordering or deduplication.
  public static func landmarksWithCounty(query: LandmarkQuery) -> Self {
    Self(endpoint: .landmarksWithCounty(query: query))
  }
}

extension NPSLandmarksRequest where Response == [LandmarkStateGroup] {
  /// StatesAndLandmarks returns the provider's rows without reordering or deduplication.
  public static func statesAndLandmarks() -> Self {
    Self(endpoint: .statesAndLandmarks())
  }
}
