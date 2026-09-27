/// A concrete XML request, separate from generic JSON Species requests.
public struct SpeciesCategoriesRequest: Hashable, Sendable {
  /// The fixed category endpoint and representation.
  public let endpoint: SpeciesCategoriesEndpoint

  /// Creates an inspectable category request.
  /// - Parameter endpoint: The fixed category discovery endpoint.
  public init(endpoint: SpeciesCategoriesEndpoint = .init()) { self.endpoint = endpoint }
}
