/// A National Natural Landmark service record preserving provider identifiers and raw classifications.
/// A listing does not establish public access or NPS ownership.
public struct LandmarkState: Codable, Hashable, Sendable {
  /// The provider's Label value without inferred defaults.
  public let label: String
  /// The provider's StateCode value without inferred defaults.
  public let stateCode: String

  private enum CodingKeys: String, CodingKey {
    case label = "Label"
    case stateCode = "StateCode"
  }
}
