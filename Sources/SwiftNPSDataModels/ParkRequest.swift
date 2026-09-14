/// A reusable, typed park lookup that performs no I/O at construction.
///
/// Inspect ``resolution`` in a custom executor, or pass this value to `NPSDataClient.value(for:)`.
/// Constrained extensions can add application vocabulary without erasing the response type.
///
/// ```swift
/// let request = ParkRequest.parks(parkCode: try ParkCode("acad"))
/// ```
public struct ParkRequest<Response>: Hashable, Sendable {
  /// The transport-independent operation required to obtain the response.
  public enum Resolution: Hashable, Sendable {
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
}

extension ParkRequest where Response == ParksResponse {
  /// Describes a lookup for one park code while retaining the provider envelope.
  /// - Parameter parkCode: A validated single park code.
  /// - Returns: A reusable request for ``ParksResponse``.
  public static func parks(parkCode: ParkCode) -> Self {
    Self(endpoint: .parks(parkCode: parkCode))
  }
}
