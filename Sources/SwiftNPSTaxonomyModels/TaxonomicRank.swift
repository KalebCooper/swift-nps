/// A provider taxonomy metadata record, without normalization or inferred defaults.
public struct TaxonomicRank: Codable, Hashable, Sendable {
  /// The provider's Code value, preserving original text and optionality.
  public let code: String
  /// The provider's DisplayOrder value, preserving original text and optionality.
  public let displayOrder: Int
  /// The provider's Name value, preserving original text and optionality.
  public let name: String
  /// The provider's ResourceLink value, preserving original text and optionality.
  public let resourceLink: String

  private enum CodingKeys: String, CodingKey {
    case code = "Code"
    case displayOrder = "DisplayOrder"
    case name = "Name"
    case resourceLink = "ResourceLink"
  }
}
