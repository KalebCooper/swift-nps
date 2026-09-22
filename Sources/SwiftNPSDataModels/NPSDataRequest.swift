/// A reusable, typed NPS Data API operation that performs no I/O at construction.
///
/// Inspect ``resolution`` in a custom executor, or pass this value to `NPSDataClient.value(for:)`,
/// `pages(for:)`, or `items(for:)`. Constrained extensions can add application vocabulary without
/// erasing the response type.
///
/// ```swift
/// let request = NPSDataRequest.parks(parkCode: try ParkCode("acad"))
/// ```
public struct NPSDataRequest<Response>: Hashable, Sendable {
  /// The transport-independent operation required to obtain the response.
  public enum Resolution: Hashable, Sendable {
    /// Send a collection query; a paginating executor derives each following page from its response.
    case collection(NPSCollectionResolution<Response>)
    /// Send one endpoint and decode the response body as `Response`.
    case endpoint(Endpoint<Response>)
  }

  /// The operation a custom executor interprets.
  public let resolution: Resolution

  /// Creates a request for one endpoint, including a consumer-defined response.
  /// - Parameter endpoint: The endpoint whose body decodes directly as `Response`.
  public init(endpoint: Endpoint<Response>) {
    self.resolution = .endpoint(endpoint)
  }

  init(resolution: Resolution) {
    self.resolution = resolution
  }
}
