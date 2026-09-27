/// The fixed category discovery operation, whose measured response is XML.
public struct SpeciesCategoriesEndpoint: Hashable, Sendable {
  /// The accepted representation for the raw-response execution path.
  public let accept = "application/xml"
  /// The original service-relative category route.
  public let path = "/urlOptions/categories?format=json"

  /// Creates the category discovery endpoint without performing I/O.
  public init() {}
}
