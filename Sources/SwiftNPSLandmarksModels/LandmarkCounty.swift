/// A National Natural Landmark service record preserving provider identifiers and raw classifications.
/// A listing does not establish public access or NPS ownership.
public struct LandmarkCounty: Codable, Hashable, Sendable {
  /// The provider's Code value without inferred defaults.
  public let code: String
  /// The provider's CountyID value without inferred defaults.
  public let countyID: Int64
  /// The provider's DisplayLabel value without inferred defaults.
  public let displayLabel: String
  /// The provider's ID value without inferred defaults.
  public let id: Int64
  /// The provider's Label value without inferred defaults.
  public let label: String
  /// The provider's StateCode value without inferred defaults.
  public let stateCode: String

  private enum CodingKeys: String, CodingKey {
    case code = "Code"
    case countyID = "CountyID"
    case displayLabel = "DisplayLabel"
    case id = "ID"
    case label = "Label"
    case stateCode = "StateCode"
  }
}
