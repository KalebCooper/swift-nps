/// A provider taxonomy metadata record, without normalization or inferred defaults.
public struct TaxonomicSourceProfile: Codable, Hashable, Sendable {
  /// The provider's Code value, preserving original text and optionality.
  public let code: String
  /// The provider's CodeName value, preserving original text and optionality.
  public let codeName: String?
  /// The provider's ExternalLink value, preserving original text and optionality.
  public let externalLink: String?
  /// The provider's FullName value, preserving original text and optionality.
  public let fullName: String
  /// The provider's LifecycleState value, preserving original text and optionality.
  public let lifecycleState: String
  /// The provider's Name value, preserving original text and optionality.
  public let name: String
  /// The provider's ResourceLink value, preserving original text and optionality.
  public let resourceLink: String

  private enum CodingKeys: String, CodingKey {
    case code = "Code"
    case codeName = "CodeName"
    case externalLink = "ExternalLink"
    case fullName = "FullName"
    case lifecycleState = "LifecycleState"
    case name = "Name"
    case resourceLink = "ResourceLink"
  }
}
