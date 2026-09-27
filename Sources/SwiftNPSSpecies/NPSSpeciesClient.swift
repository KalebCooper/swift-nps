#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import HTTPCore
import HTTPTypes
import SwiftNPSSpeciesModels

/// A key-free client for NPS species lists.
///
/// Requests return provider arrays without aggregation, retries, or redirect following.
public struct NPSSpeciesClient: Sendable {
  let client: HTTPClient

  /// Creates a client using a supplied transport on any supported platform.
  /// - Parameter transport: The transport used to execute service requests.
  public init(transport: any Transport) {
    guard let baseURL = URL(string: "https://irmaservices.nps.gov/NPSpecies/v3/rest") else {
      preconditionFailure("The Species base is a valid HTTPS URL.")
    }
    client = HTTPClient(baseURL: baseURL, redirectPolicy: .never, transport: transport)
  }

  /// Sends a typed endpoint and decodes one JSON response.
  /// - Parameter endpoint: An endpoint confined to the Species service.
  /// - Returns: The unmodified decoded response.
  /// - Throws: Transport failures, including HTTP, decoding, and cancellation errors.
  public func send<Value: Decodable & SendableMetatype>(
    _ endpoint: SpeciesEndpoint<Value>
  ) async throws(NPSSpeciesError) -> Value {
    guard !Task.isCancelled else { throw .transport(.cancelled) }
    do throws(TransportError) {
      let response: DecodedResponse<Value> = try await client.execute(
        Request(headers: [.accept: "application/json"], path: endpoint.path))
      guard !Task.isCancelled else { throw .cancelled }
      return response.value
    } catch { throw .transport(error) }
  }

  /// Fetches the provider's species whole list without local filtering or pagination.
  /// - Parameter query: Exact unit and optional categories.
  /// - Throws: Typed transport, decoding, HTTP, or cancellation failure.
  public func species(query: SpeciesQuery) async throws(NPSSpeciesError) -> [SpeciesItem] {
    try await value(for: .species(query: query))
  }

  /// Fetches the provider's speciesChecklist whole list without local filtering or pagination.
  /// - Parameter query: Exact unit and optional categories.
  /// - Throws: Typed transport, decoding, HTTP, or cancellation failure.
  public func speciesChecklist(query: SpeciesQuery) async throws(NPSSpeciesError)
    -> [SpeciesChecklistItem]
  {
    try await value(for: .speciesChecklist(query: query))
  }

  /// Fetches the provider's speciesDetails whole list without local filtering or pagination.
  /// - Parameter query: Exact unit and optional categories.
  /// - Throws: Typed transport, decoding, HTTP, or cancellation failure.
  public func speciesDetails(query: SpeciesQuery) async throws(NPSSpeciesError)
    -> [SpeciesDetailItem]
  {
    try await value(for: .speciesDetails(query: query))
  }

  /// Executes an inspectable reusable request as one response.
  /// - Parameter request: A request whose response type is determined by its endpoint.
  /// - Returns: The provider's decoded response.
  /// - Throws: The same failures as ``send(_:)->Value``.
  public func value<Value: Decodable & SendableMetatype>(
    for request: NPSSpeciesRequest<Value>
  ) async throws(NPSSpeciesError) -> Value {
    try await send(request.endpoint)
  }

}
