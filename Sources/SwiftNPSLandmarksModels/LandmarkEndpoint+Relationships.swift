extension LandmarkEndpoint where Response == [LandmarkOwner] {
  /// LandmarkOwnerInformation returns the provider's rows without reordering or deduplication.
  public static func landmarkOwners(query: LandmarkOwnerQuery) -> Self {
    let encoded = query.encodedQuery
    return route("/api/LandmarkOwnerInformation" + (encoded.isEmpty ? "" : "?" + encoded))
  }
}

extension LandmarkEndpoint where Response == [LandmarkCounty] {
  /// SiteCounties returns the provider's rows without reordering or deduplication.
  public static func landmarkSiteCounties(query: LandmarkQuery) -> Self {
    let encoded = query.encodedQuery
    return route("/api/SiteCounties" + (encoded.isEmpty ? "" : "?" + encoded))
  }
}

extension LandmarkEndpoint where Response == [LandmarkStateCounty] {
  /// StateCounty returns the provider's rows without reordering or deduplication.
  public static func landmarkStateCounties(query: LandmarkStateCountyQuery) -> Self {
    let encoded = query.encodedQuery
    return route("/api/StateCounty" + (encoded.isEmpty ? "" : "?" + encoded))
  }
}

extension LandmarkEndpoint where Response == [LandmarkWithCounty] {
  /// LandmarkInformationWithCounty returns the provider's rows without reordering or deduplication.
  public static func landmarksWithCounty(query: LandmarkQuery) -> Self {
    let encoded = query.encodedQuery
    return route("/api/LandmarkInformationWithCounty" + (encoded.isEmpty ? "" : "?" + encoded))
  }
}

extension LandmarkEndpoint where Response == [LandmarkStateGroup] {
  /// StatesAndLandmarks returns the provider's rows without reordering or deduplication.
  public static func statesAndLandmarks() -> Self {
    route("/api/StatesAndLandmarks")
  }
}
