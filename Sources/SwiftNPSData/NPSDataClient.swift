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
/// Use ``parkPages(query:)`` or ``parks(query:)`` for lazy pagination. No retries or redirects
/// are performed automatically.
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

  /// Iterates pages from an inspectable parks request without sending during construction.
  ///
  /// Query requests advance using validated NPS metadata. A consumer-defined endpoint or legacy
  /// single-code request yields just its one page, because it declares no continuation query.
  /// - Parameter request: The first-page operation and, for a query, its continuation settings.
  /// - Returns: Independent lazy page iterators whose failures are ``NPSDataError``.
  public func parkPages(for request: ParkRequest<ParksResponse>) -> ParkPageSequence {
    let endpoint: Endpoint<ParksResponse>
    let query: ParkQuery?
    switch request.resolution {
    case .endpoint(let value):
      endpoint = value
      query = nil
    case .parks(let value):
      endpoint = .parks(query: value)
      query = value
    }
    let pages = client.pages(self.request(for: endpoint), as: ParksResponse.self) { page, sent in
      // The iterator reports validation failures before yielding this page. The nonthrowing
      // continuation callback must not schedule another request when metadata is unusable.
      guard let query, let start = Int(page.value.start),
        let next = try? query.starting(at: start).next(after: page.value)
      else { return nil }
      var following = sent
      following.path = Endpoint.parks(query: next).path
      return .request(following)
    }
    return ParkPageSequence(base: pages, query: query)
  }

  /// Iterates complete parks pages with filters, sorting, and explicit pagination settings.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func parkPages(query: ParkQuery) -> ParkPageSequence {
    parkPages(for: .parks(query: query))
  }

  /// Iterates individual parks from a reusable first-page request.
  /// - Parameter request: An inspectable parks operation.
  /// - Returns: Parks flattened lazily from ``parkPages(for:)``, with the same typed failures.
  public func parks(for request: ParkRequest<ParksResponse>) -> ParkSequence {
    ParkSequence(pages: parkPages(for: request))
  }

  /// Looks up one park code and retains the NPS collection envelope.
  /// - Parameter parkCode: A validated single park code.
  /// - Returns: One requested page, which can be empty; no first-result selection is performed.
  /// - Throws: The same ``NPSDataError`` as ``value(for:)``.
  public func parks(parkCode: ParkCode) async throws(NPSDataError) -> ParksResponse {
    try await value(for: .parks(parkCode: parkCode))
  }

  /// Iterates individual parks, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Parks in provider order, without deduplication, throwing ``NPSDataError``.
  public func parks(query: ParkQuery) -> ParkSequence {
    parks(for: .parks(query: query))
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
    do {
      return try await client.execute(request(for: endpoint))
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
    case .parks(let query):
      guard let endpoint = Endpoint<Value>(path: Endpoint.parks(query: query).path) else {
        preconditionFailure("The parks query factory produces a validated endpoint path.")
      }
      return try await send(endpoint)
    }
  }

  private func request<Value>(for endpoint: Endpoint<Value>) -> Request {
    var headers = HTTPFields()
    headers[.accept] = "application/json"
    headers[Self.apiKeyField] = configuration.apiKey
    return Request(headers: headers, path: endpoint.path)
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
