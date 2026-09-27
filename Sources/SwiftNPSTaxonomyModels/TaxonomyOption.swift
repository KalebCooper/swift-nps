/// A provider taxonomy metadata record, without normalization or inferred defaults.
public struct TaxonomyOption: Codable, Hashable, Sendable {
  /// The provider's Description value, preserving original text and optionality.
  public let description: String
  /// The provider's Value value, preserving original text and optionality.
  public let value: String

  private enum CodingKeys: String, CodingKey {
    case description = "Description"
    case value = "Value"
  }
}
