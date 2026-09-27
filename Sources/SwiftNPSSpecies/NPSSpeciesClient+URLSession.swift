#if canImport(Darwin)
import HTTPURLSession
extension NPSSpeciesClient {
  /// Creates a key-free client using URLSession on Apple platforms.
  public init() { self.init(transport: URLSessionTransport()) }
}
#endif
