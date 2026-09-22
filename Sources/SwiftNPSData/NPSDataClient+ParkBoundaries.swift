import SwiftNPSDataModels

extension NPSDataClient {
  /// Fetches one park's boundary as a GeoJSON feature collection.
  ///
  /// The boundary is one response with no pagination. An unknown park code fails with HTTP 404 and
  /// an `application/problem+json` body, which is not the NPS error envelope, so it surfaces as
  /// ``NPSDataError/transport(_:)`` holding the HTTP status failure.
  /// - Parameter parkCode: The park whose boundary is fetched, sent as given.
  /// - Returns: The complete feature collection, with coordinates kept as sent.
  /// - Throws: The same ``NPSDataError`` as ``value(for:)``.
  public func parkBoundary(parkCode: ParkCode) async throws(NPSDataError) -> ParkBoundary {
    try await value(for: .parkBoundary(parkCode: parkCode))
  }
}
