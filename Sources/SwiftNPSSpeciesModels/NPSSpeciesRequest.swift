/// An inspectable single-response Species request with no execution or transport dependency.
public struct NPSSpeciesRequest<Response: Decodable & SendableMetatype>: Hashable, Sendable {
  /// The typed endpoint defining the expected response.
  public let endpoint: SpeciesEndpoint<Response>
  /// Creates a request for a provider or consumer-defined response.
  /// - Parameter endpoint: A confined Species endpoint.
  public init(endpoint: SpeciesEndpoint<Response>) { self.endpoint = endpoint }
}
