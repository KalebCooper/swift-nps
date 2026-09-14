#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import HTTPCore
import HTTPTypes
import SwiftNPSDataModels

/// A Sendable client for park lookups in the National Park Service Data API.
///
/// Use ``parks(parkCode:)`` for an everyday lookup, ``value(for:)`` for a reusable request,
/// or ``send(_:)`` for a typed endpoint. Every entry point uses the same authentication and errors.
/// No automatic retries, pagination, or redirects are performed.
public struct NPSDataClient: Sendable {
  /// The explicit credential configuration used by this client.
  public let configuration: NPSDataConfiguration

  private let client: HTTPClient

  /// Creates a client using a supplied transport on any supported platform.
  /// - Parameters:
  ///   - configuration: Required API-key configuration.
  ///   - transport: The transport that sends each request.
  public init(configuration: NPSDataConfiguration, transport: any Transport) {
    self.configuration = configuration
    self.client = HTTPClient(baseURL: Self.baseURL, redirectPolicy: .never, transport: transport)
  }

  /// Looks up one park code and retains the NPS collection envelope.
  /// - Parameter parkCode: A validated single park code.
  /// - Returns: One requested page, which can be empty; no first-result selection is performed.
  /// - Throws: The same ``NPSDataError`` as ``value(for:)``.
  public func parks(parkCode: ParkCode) async throws(NPSDataError) -> ParksResponse {
    try await value(for: .parks(parkCode: parkCode))
  }

  /// Sends one endpoint and decodes its body as the endpoint's response type.
  ///
  /// Cancellation is checked before sending. The API key is supplied only in a header.
  /// - Parameter endpoint: A validated relative NPS API endpoint.
  /// - Returns: The decoded body, including its provider envelope.
  /// - Throws: ``NPSDataError/service(_:response:)`` for gateway errors, or
  ///   ``NPSDataError/transport(_:)`` for HTTP, decoding, connection, and cancellation failures.
  public func send<Value: Decodable & SendableMetatype>(
    _ endpoint: Endpoint<Value>
  ) async throws(NPSDataError) -> Value {
    guard !Task.isCancelled else { throw .transport(.cancelled) }
    var headers = HTTPFields()
    headers[.accept] = "application/json"
    headers[Self.apiKeyField] = configuration.apiKey
    do {
      return try await client.execute(Request(headers: headers, path: endpoint.path))
    } catch {
      throw NPSDataError(error)
    }
  }

  /// Executes a reusable request without changing its response type.
  /// - Parameter request: The portable operation to execute.
  /// - Returns: The concrete response selected by its factory or consumer-defined endpoint.
  /// - Throws: The same ``NPSDataError`` as ``send(_:)``, including cancellation.
  public func value<Value: Decodable & SendableMetatype>(
    for request: ParkRequest<Value>
  ) async throws(NPSDataError) -> Value {
    switch request.resolution {
    case .endpoint(let endpoint):
      return try await send(endpoint)
    }
  }

  private static let apiKeyField: HTTPField.Name = {
    guard let name = HTTPField.Name("X-Api-Key") else {
      preconditionFailure("X-Api-Key is a valid HTTP field name.")
    }
    return name
  }()

  private static let baseURL: URL = {
    guard let url = URL(string: "https://developer.nps.gov/api/v1") else {
      preconditionFailure("The NPS API base is a valid HTTPS URL.")
    }
    return url
  }()
}
