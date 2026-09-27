#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import HTTPCore
import HTTPTypes
import SwiftNPSUnitsModels

/// A key-free client for NPS administrative units.
///
/// Requests preserve provider response shapes without retries or redirect following.
public struct NPSUnitsClient: Sendable {
  private let client: HTTPClient

  /// Creates a client using a supplied transport on any supported platform.
  /// - Parameter transport: The transport used to execute service requests.
  public init(transport: any Transport) {
    guard let baseURL = URL(string: "https://irmaservices.nps.gov/Unit/v2/api") else {
      preconditionFailure("The Unit base is a valid HTTPS URL.")
    }
    client = HTTPClient(baseURL: baseURL, redirectPolicy: .never, transport: transport)
  }

  /// Sends a typed endpoint and decodes one JSON response.
  /// - Parameter endpoint: An endpoint confined to the Unit service.
  /// - Returns: The unmodified decoded response.
  /// - Throws: Transport failures, including HTTP, decoding, and cancellation errors.
  public func send<Value: Decodable & SendableMetatype>(
    _ endpoint: UnitEndpoint<Value>
  ) async throws(NPSUnitsError) -> Value {
    guard !Task.isCancelled else { throw .transport(.cancelled) }
    do throws(TransportError) {
      let response: DecodedResponse<Value> = try await client.execute(
        Request(headers: [.accept: "application/json"], path: endpoint.path))
      guard !Task.isCancelled else { throw .cancelled }
      return response.value
    } catch { throw .transport(error) }
  }

  /// Executes an inspectable reusable request as one response.
  /// - Parameter request: A request whose response type is determined by its endpoint.
  /// - Returns: The provider's decoded response.
  /// - Throws: The same failures as ``send(_:)``.
  public func value<Value: Decodable & SendableMetatype>(
    for request: NPSUnitsRequest<Value>
  ) async throws(NPSUnitsError) -> Value {
    try await send(request.endpoint)
  }

}
