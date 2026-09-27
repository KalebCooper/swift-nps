/// One flat state/landmark index row; repeated membership remains repeated.
public struct LandmarkStateGroup: Codable, Hashable, Sendable {
  /// The provider's SiteCode value, preserved without inferred defaults.
  public let siteCode: String
  /// The provider's StateCode value, preserved without inferred defaults.
  public let stateCode: String
  /// The provider's StateLabel value, preserved without inferred defaults.
  public let stateLabel: String
  /// The provider's Title value, preserved without inferred defaults.
  public let title: String

  private enum CodingKeys: String, CodingKey {
    case siteCode = "SiteCode"
    case stateCode = "StateCode"
    case stateLabel = "StateLabel"
    case title = "Title"
  }
}
