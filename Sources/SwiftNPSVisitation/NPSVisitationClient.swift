#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import HTTPCore
import HTTPTypes
import SwiftNPSVisitationModels

/// A key-free client for NPS historical monthly visitation statistics.
///
/// Requests return provider arrays without aggregation, retries, or redirect following.
public struct NPSVisitationClient: Sendable {
  private let client: HTTPClient

  /// Creates a client using a supplied transport on any supported platform.
  /// - Parameter transport: The transport used to execute service requests.
  public init(transport: any Transport) {
    guard let baseURL = URL(string: "https://irmaservices.nps.gov/v3/rest/stats") else {
      preconditionFailure("The statistics base is a valid HTTPS URL.")
    }
    client = HTTPClient(baseURL: baseURL, redirectPolicy: .never, transport: transport)
  }

  /// Fetches national monthly records without computing an annual sum.
  /// - Parameter year: A positive year.
  /// - Throws: An invalid-year or transport failure.
  public func nationalVisitation(year: Int) async throws(NPSVisitationError)
    -> [NPSVisitationRecord]
  {
    guard year > 0 else { throw .invalidYear }
    let request: NPSVisitationRequest<[NPSVisitationRecord]>
    do { request = try .nationalVisitation(year: year) } catch { throw .invalidYear }
    return try await value(for: request)
  }

  /// Sends a typed endpoint and decodes one JSON response.
  /// - Parameter endpoint: An endpoint confined to the statistics service.
  /// - Returns: The unmodified decoded response.
  /// - Throws: Transport failures, including HTTP, decoding, and cancellation errors.
  public func send<Value: Decodable & SendableMetatype>(
    _ endpoint: VisitationEndpoint<Value>
  ) async throws(NPSVisitationError) -> Value {
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
    for request: NPSVisitationRequest<Value>
  ) async throws(NPSVisitationError) -> Value {
    try await send(request.endpoint)
  }

  /// Fetches recorded months for the requested units and inclusive range.
  /// - Parameter query: Validated unit codes and months.
  /// - Returns: Provider records, preserving order, missing months, and identifiers.
  /// - Throws: Transport failures, including cancellation.
  public func visitation(query: VisitationQuery) async throws(NPSVisitationError)
    -> [NPSVisitationRecord]
  {
    try await value(for: .visitation(query: query))
  }
}
