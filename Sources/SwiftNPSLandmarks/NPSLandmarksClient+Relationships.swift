import SwiftNPSLandmarksModels

extension NPSLandmarksClient {
  /// LandmarkOwnerInformation returns the provider's rows without reordering or deduplication.
  /// - Throws: Original transport, HTTP, decoding, or cancellation failures.
  public func landmarkOwners(query: LandmarkOwnerQuery) async throws(NPSLandmarksError)
    -> [LandmarkOwner]
  {
    try await value(for: .landmarkOwners(query: query))
  }
}

extension NPSLandmarksClient {
  /// SiteCounties returns the provider's rows without reordering or deduplication.
  /// - Throws: Original transport, HTTP, decoding, or cancellation failures.
  public func landmarkSiteCounties(query: LandmarkQuery) async throws(NPSLandmarksError)
    -> [LandmarkCounty]
  {
    try await value(for: .landmarkSiteCounties(query: query))
  }
}

extension NPSLandmarksClient {
  /// StateCounty returns the provider's rows without reordering or deduplication.
  /// - Throws: Original transport, HTTP, decoding, or cancellation failures.
  public func landmarkStateCounties(query: LandmarkStateCountyQuery) async throws(NPSLandmarksError)
    -> [LandmarkStateCounty]
  {
    try await value(for: .landmarkStateCounties(query: query))
  }
}

extension NPSLandmarksClient {
  /// LandmarkInformationWithCounty returns the provider's rows without reordering or deduplication.
  /// - Throws: Original transport, HTTP, decoding, or cancellation failures.
  public func landmarksWithCounty(query: LandmarkQuery) async throws(NPSLandmarksError)
    -> [LandmarkWithCounty]
  {
    try await value(for: .landmarksWithCounty(query: query))
  }
}

extension NPSLandmarksClient {
  /// StatesAndLandmarks returns the provider's rows without reordering or deduplication.
  /// - Throws: Original transport, HTTP, decoding, or cancellation failures.
  public func statesAndLandmarks() async throws(NPSLandmarksError) -> [LandmarkStateGroup] {
    try await value(for: .statesAndLandmarks())
  }
}
