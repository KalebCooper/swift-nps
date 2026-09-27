import SwiftNPSTaxonomyModels

extension NPSTaxonomyClient {
  /// Fetches taxonProfile as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input or original transport, HTTP, decoding and cancellation errors.
  public func taxonProfile(code: String, kind: TaxonCodeKind, deriveIfBroken: Bool = false)
    async throws(NPSTaxonomyError) -> NPSTaxonProfile
  {
    let request: NPSTaxonomyRequest<NPSTaxonProfile>
    do { request = try .taxonProfile(code: code, kind: kind, deriveIfBroken: deriveIfBroken) } catch
    { throw .invalidInput }
    return try await value(for: request)
  }
}

extension NPSTaxonomyClient {
  /// Fetches taxonProfilesResponse as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input or original transport, HTTP, decoding and cancellation errors.
  public func taxonProfilesResponse(query: TaxonProfileQuery) async throws(NPSTaxonomyError)
    -> [NPSTaxonProfile]
  {
    try await value(for: .taxonProfilesResponse(query: query))
  }
}

extension NPSTaxonomyClient {
  /// Fetches taxonSummariesResponse as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input or original transport, HTTP, decoding and cancellation errors.
  public func taxonSummariesResponse(query: TaxonSummaryQuery) async throws(NPSTaxonomyError)
    -> [NPSTaxonSummary]
  {
    try await value(for: .taxonSummariesResponse(query: query))
  }
}

extension NPSTaxonomyClient {
  /// Fetches taxonSummary as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input or original transport, HTTP, decoding and cancellation errors.
  public func taxonSummary(code: String, kind: TaxonCodeKind) async throws(NPSTaxonomyError)
    -> NPSTaxonSummary
  {
    let request: NPSTaxonomyRequest<NPSTaxonSummary>
    do { request = try .taxonSummary(code: code, kind: kind) } catch { throw .invalidInput }
    return try await value(for: request)
  }
}
