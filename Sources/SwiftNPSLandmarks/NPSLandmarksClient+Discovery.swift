import SwiftNPSLandmarksModels

extension NPSLandmarksClient {
  /// County returns one county relationship (including for an unfiltered request).
  /// - Throws: Invalid input or the original transport, HTTP, decoding or cancellation failure.
  public func landmarkCounty(query: LandmarkQuery) async throws(NPSLandmarksError) -> LandmarkCounty
  {
    try await value(for: .landmarkCounty(query: query))
  }
}

extension NPSLandmarksClient {
  /// State returns the provider's records.
  /// - Throws: Invalid input or the original transport, HTTP, decoding or cancellation failure.
  public func landmarkState(stateCode: String) async throws(NPSLandmarksError) -> LandmarkState {
    let request: NPSLandmarksRequest<LandmarkState>
    do { request = try .landmarkState(stateCode: stateCode) } catch { throw .invalidInput }
    return try await value(for: request)
  }
}

extension NPSLandmarksClient {
  /// AllStates returns the provider's records.
  /// - Throws: Invalid input or the original transport, HTTP, decoding or cancellation failure.
  public func landmarkStates() async throws(NPSLandmarksError) -> [LandmarkState] {
    try await value(for: .landmarkStates())
  }
}

extension NPSLandmarksClient {
  /// LandmarkInformationPerCounty returns county-enriched records without deduplication.
  /// - Throws: Invalid input or the original transport, HTTP, decoding or cancellation failure.
  public func landmarks(countyID: Int64) async throws(NPSLandmarksError) -> [LandmarkWithCounty] {
    let request: NPSLandmarksRequest<[LandmarkWithCounty]>
    do { request = try .landmarks(countyID: countyID) } catch { throw .invalidInput }
    return try await value(for: request)
  }
}

extension NPSLandmarksClient {
  /// LandmarkInformation returns the provider's records.
  /// - Throws: Invalid input or the original transport, HTTP, decoding or cancellation failure.
  public func landmarks(query: LandmarkQuery) async throws(NPSLandmarksError) -> [NPSLandmark] {
    try await value(for: .landmarks(query: query))
  }
}

extension NPSLandmarksClient {
  /// LandmarkInformationPerStateCode returns the provider's records.
  /// - Throws: Invalid input or the original transport, HTTP, decoding or cancellation failure.
  public func landmarks(stateCode: String) async throws(NPSLandmarksError) -> [NPSLandmark] {
    let request: NPSLandmarksRequest<[NPSLandmark]>
    do { request = try .landmarks(stateCode: stateCode) } catch { throw .invalidInput }
    return try await value(for: request)
  }
}
