/// The error envelope returned by the NPS API gateway.
///
/// Codes are open strings, including values introduced after this package was compiled.
public struct ServiceErrorResponse: Codable, Hashable, Sendable {
  /// The gateway's explanation of a failed request.
  public struct Detail: Codable, Hashable, Sendable {
    /// The provider code, such as `API_KEY_MISSING` or `OVER_RATE_LIMIT`.
    public let code: String

    /// The provider's original explanatory text.
    public let message: String
  }

  /// The error reported by the gateway.
  public let error: Detail
}
