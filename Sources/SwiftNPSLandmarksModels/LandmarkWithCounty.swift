/// A National Natural Landmark service record preserving provider identifiers and raw classifications.
/// A listing does not establish public access or NPS ownership.
public struct LandmarkWithCounty: Codable, Hashable, Sendable {
  /// The provider's Area_Acres value without inferred defaults.
  public let areaAcres: Double
  /// The provider's AuthoritativeURL value without inferred defaults.
  public let authoritativeURL: String?
  /// The provider's Code value without inferred defaults.
  public let code: String
  /// The provider's CountyID value without inferred defaults.
  public let countyID: Int64
  /// The provider's CountyLabel value without inferred defaults.
  public let countyLabel: String?
  /// The provider's DesignationYear value without inferred defaults.
  public let designationYear: Int
  /// The provider's ID value without inferred defaults.
  public let id: Int64
  /// The provider's SignificanceStatement value without inferred defaults.
  public let significanceStatement: String
  /// The provider's StateCode value without inferred defaults.
  public let stateCode: String?
  /// The provider's Title value without inferred defaults.
  public let title: String

  private enum CodingKeys: String, CodingKey {
    case areaAcres = "Area_Acres"
    case authoritativeURL = "AuthoritativeURL"
    case code = "Code"
    case countyID = "CountyID"
    case countyLabel = "CountyLabel"
    case designationYear = "DesignationYear"
    case id = "ID"
    case significanceStatement = "SignificanceStatement"
    case stateCode = "StateCode"
    case title = "Title"
  }
}
