/// Required credentials for requests to the NPS Data API.
///
/// Supply a private API key obtained from NPS. There is no default key and the library never
/// reads the environment. Store credentials outside source control and application bundles.
///
/// ```swift
/// let configuration = try NPSDataConfiguration(apiKey: apiKey)
/// ```
public struct NPSDataConfiguration: CustomDebugStringConvertible, CustomStringConvertible, Sendable
{
  /// A redacted representation suitable for debugging.
  public var debugDescription: String { description }

  /// A representation that omits the API key.
  public var description: String { "NPSDataConfiguration(apiKey: <redacted>)" }

  let apiKey: String

  /// Validates and stores the credential without contacting NPS.
  ///
  /// Local validation rejects empty values, whitespace, and non-ASCII header characters.
  /// The service remains responsible for deciding whether a key is valid.
  /// - Parameter apiKey: The exact private key to send in `X-Api-Key`, without normalization.
  /// - Throws: ``NPSDataError/invalidAPIKey`` when the key cannot be safely sent.
  public init(apiKey: String) throws(NPSDataError) {
    guard !apiKey.isEmpty, apiKey.utf8.allSatisfy({ (33...126).contains($0) }) else {
      throw .invalidAPIKey
    }
    self.apiKey = apiKey
  }
}
