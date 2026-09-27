/// A National Natural Landmark service record preserving provider identifiers and raw classifications.
/// A listing does not establish public access or NPS ownership.
public struct NPSLandmark: Codable, Hashable, Sendable {
  /// The provider's Area_Acres value without inferred defaults.
  public let areaAcres: Double
  /// The provider's AuthoritativeURL value without inferred defaults.
  public let authoritativeURL: String?
  /// The provider's Code value without inferred defaults.
  public let code: String
  /// The provider's DesignationYear value without inferred defaults.
  public let designationYear: Int
  /// The provider's ID value without inferred defaults.
  public let id: Int64
  /// The provider's PrimaryState value without inferred defaults.
  public let primaryState: String
  /// The provider's SecondaryState value without inferred defaults.
  public let secondaryState: String?
  /// The provider's SignificanceStatement value without inferred defaults.
  public let significanceStatement: String
  /// The provider's Title value without inferred defaults.
  public let title: String

  private enum CodingKeys: String, CodingKey {
    case areaAcres = "Area_Acres"
    case authoritativeURL = "AuthoritativeURL"
    case code = "Code"
    case designationYear = "DesignationYear"
    case id = "ID"
    case primaryState = "PrimaryState"
    case secondaryState = "SecondaryState"
    case significanceStatement = "SignificanceStatement"
    case title = "Title"
  }
}
