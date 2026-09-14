#if canImport(Darwin)
import Foundation
import HTTPURLSession

extension NPSDataClient {
  /// Creates a client using the shared URL session and a required private API key.
  /// - Parameter apiKey: The key to send in the `X-Api-Key` header.
  /// - Throws: ``NPSDataError/invalidAPIKey`` for invalid local credential syntax.
  public init(apiKey: String) throws(NPSDataError) {
    self.init(configuration: try NPSDataConfiguration(apiKey: apiKey))
  }

  /// Creates a client using an Apple URL session.
  /// - Parameters:
  ///   - configuration: Required API-key configuration.
  ///   - session: The session used for requests; defaults to the shared session.
  public init(configuration: NPSDataConfiguration, session: URLSession = .shared) {
    self.init(configuration: configuration, transport: URLSessionTransport(session: session))
  }
}
#endif
