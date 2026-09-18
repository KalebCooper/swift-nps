#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import HTTPCore
import HTTPTypes
import SwiftNPSDataModels

/// A Sendable client for collection lookups in the National Park Service Data API.
///
/// Use ``parks(parkCode:)`` for an everyday lookup, ``value(for:)`` for a reusable request,
/// or ``send(_:)`` for a typed endpoint. Every entry point uses the same authentication and errors.
/// Use ``alertPages(query:)``, ``alerts(query:)``, ``parkPages(query:)``, ``parks(query:)``,
/// ``visitorCenterPages(query:)``, or ``visitorCenters(query:)`` for lazy pagination of one
/// group, or ``pages(for:)`` and ``items(for:)`` for any collection request. No retries or
/// redirects are performed automatically.
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

  /// Iterates individual items from a reusable first-page collection request.
  /// - Parameter request: An inspectable collection operation.
  /// - Returns: Items flattened lazily from ``pages(for:)``, with the same typed failures.
  public func items<Item>(
    for request: NPSDataRequest<NPSCollection<Item>>
  ) -> NPSItemSequence<Item> {
    NPSItemSequence(pages: pages(for: request))
  }

  /// Iterates pages from an inspectable collection request without sending during construction.
  ///
  /// Collection requests advance using validated NPS metadata. A consumer-defined endpoint or
  /// legacy single-code request yields just its one page, because it declares no continuation.
  /// - Parameter request: The first-page operation and, for a query, its continuation settings.
  /// - Returns: Independent lazy page iterators whose failures are ``NPSDataError``.
  public func pages<Item>(
    for request: NPSDataRequest<NPSCollection<Item>>
  ) -> NPSPageSequence<Item> {
    let endpoint: Endpoint<NPSCollection<Item>>
    let resolution: NPSCollectionResolution<NPSCollection<Item>>?
    switch request.resolution {
    case .collection(let value):
      endpoint = value.endpoint
      resolution = value
    case .endpoint(let value):
      endpoint = value
      resolution = nil
    }
    let pages = client.pages(self.request(for: endpoint), as: NPSCollection<Item>.self) {
      page, sent in
      // The iterator reports validation failures before yielding this page. The nonthrowing
      // continuation callback must not schedule another request when metadata is unusable.
      guard let resolution, let start = Int(page.value.start),
        let next = try? resolution.starting(at: start).next(after: page.value)
      else { return nil }
      var following = sent
      following.path = next.endpoint.path
      return .request(following)
    }
    return NPSPageSequence(base: pages, resolution: resolution)
  }

  /// Iterates complete alerts pages with filters and explicit pagination settings.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func alertPages(query: AlertQuery) -> NPSPageSequence<ParkAlert> {
    pages(for: .alerts(query: query))
  }

  /// Iterates individual alerts, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Alerts in provider order, without deduplication, throwing ``NPSDataError``.
  public func alerts(query: AlertQuery) -> NPSItemSequence<ParkAlert> {
    items(for: .alerts(query: query))
  }

  /// Iterates pages from an inspectable parks request without sending during construction.
  /// - Parameter request: The first-page operation and, for a query, its continuation settings.
  /// - Returns: The same lazy page iterators as ``pages(for:)``.
  public func parkPages(for request: NPSDataRequest<NPSCollection<Park>>) -> NPSPageSequence<Park> {
    pages(for: request)
  }

  /// Iterates complete parks pages with filters, sorting, and explicit pagination settings.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func parkPages(query: ParkQuery) -> NPSPageSequence<Park> {
    pages(for: .parks(query: query))
  }

  /// Iterates individual parks from a reusable first-page request.
  /// - Parameter request: An inspectable parks operation.
  /// - Returns: The same lazy item iterators as ``items(for:)``.
  public func parks(for request: NPSDataRequest<NPSCollection<Park>>) -> NPSItemSequence<Park> {
    items(for: request)
  }

  /// Looks up one park code and retains the NPS collection envelope.
  /// - Parameter parkCode: A validated single park code.
  /// - Returns: One requested page, which can be empty; no first-result selection is performed.
  /// - Throws: The same ``NPSDataError`` as ``value(for:)``.
  public func parks(parkCode: ParkCode) async throws(NPSDataError) -> NPSCollection<Park> {
    try await value(for: .parks(parkCode: parkCode))
  }

  /// Iterates individual parks, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Parks in provider order, without deduplication, throwing ``NPSDataError``.
  public func parks(query: ParkQuery) -> NPSItemSequence<Park> {
    items(for: .parks(query: query))
  }

  /// Iterates complete visitor centers pages with filters, sorting, and explicit pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func visitorCenterPages(query: VisitorCenterQuery) -> NPSPageSequence<VisitorCenter> {
    pages(for: .visitorCenters(query: query))
  }

  /// Iterates individual visitor centers, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Visitor centers in provider order, without deduplication, throwing
  ///   ``NPSDataError``.
  public func visitorCenters(query: VisitorCenterQuery) -> NPSItemSequence<VisitorCenter> {
    items(for: .visitorCenters(query: query))
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
  ///
  /// A collection request sends only its first page; use ``pages(for:)`` to continue.
  /// - Parameter request: The portable operation to execute.
  /// - Returns: The concrete response selected by its factory or consumer-defined endpoint.
  /// - Throws: The same ``NPSDataError`` as ``send(_:)``, including cancellation.
  public func value<Value: Decodable & SendableMetatype>(
    for request: NPSDataRequest<Value>
  ) async throws(NPSDataError) -> Value {
    switch request.resolution {
    case .collection(let resolution):
      return try await send(resolution.endpoint)
    case .endpoint(let endpoint):
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
