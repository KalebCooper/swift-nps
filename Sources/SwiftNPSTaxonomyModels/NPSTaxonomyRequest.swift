#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A reusable, transport-independent Taxonomy operation.
public struct NPSTaxonomyRequest<Response: Decodable & SendableMetatype>: Hashable, Sendable {
  /// The typed endpoint for inspection or execution with a custom networking stack.
  public let endpoint: TaxonomyEndpoint<Response>

  /// Search continuation, or nil for an endpoint-only single response.
  public let query: TaxonomySearchQuery?

  /// Creates a reusable request from a typed service endpoint without performing I/O.
  /// - Parameter endpoint: The service-relative operation.
  public init(endpoint: TaxonomyEndpoint<Response>) {
    self.endpoint = endpoint
    query = nil
  }

  init(endpoint: TaxonomyEndpoint<Response>, query: TaxonomySearchQuery) {
    self.endpoint = endpoint
    self.query = query
  }
}
