#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A reusable, transport-independent single-response Landmark operation.
public struct NPSLandmarksRequest<Response: Decodable & SendableMetatype>: Hashable, Sendable {
  /// The typed endpoint for inspection or execution with a custom networking stack.
  public let endpoint: LandmarkEndpoint<Response>

  /// Creates a reusable request from a typed service endpoint without performing I/O.
  /// - Parameter endpoint: The service-relative GET operation.
  public init(endpoint: LandmarkEndpoint<Response>) {
    self.endpoint = endpoint
  }
}
