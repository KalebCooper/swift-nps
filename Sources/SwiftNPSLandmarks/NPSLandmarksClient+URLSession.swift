#if canImport(Darwin)
import HTTPURLSession

extension NPSLandmarksClient {
  /// Creates a key-free client using the default Apple URL session transport.
  public init() {
    self.init(transport: URLSessionTransport())
  }
}
#endif
