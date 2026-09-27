/// A county and state relationship without a landmark identifier.
public struct LandmarkStateCounty: Codable, Hashable, Sendable {
  /// The provider's CountyID value, preserved without inferred defaults.
  public let countyID: Int64
  /// The provider's CountyLabel value, preserved without inferred defaults.
  public let countyLabel: String
  /// The provider's DisplayLabel value, preserved without inferred defaults.
  public let displayLabel: String
  /// The provider's StateCode value, preserved without inferred defaults.
  public let stateCode: String
  /// The provider's StateLabel value, preserved without inferred defaults.
  public let stateLabel: String

  private enum CodingKeys: String, CodingKey {
    case countyID = "CountyID"
    case countyLabel = "CountyLabel"
    case displayLabel = "DisplayLabel"
    case stateCode = "StateCode"
    case stateLabel = "StateLabel"
  }
}
