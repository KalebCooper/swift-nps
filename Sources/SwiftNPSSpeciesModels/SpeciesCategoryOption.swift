/// The original Value and Description from one XML category option.
public struct SpeciesCategoryOption: Codable, Hashable, Sendable {
  /// Provider guidance for using this option.
  public let description: String
  /// Exact provider alias text; this is not a parsed category identifier.
  public let value: String

  /// Creates an option while preserving all text.
  /// - Parameters:
  ///   - description: Exact provider description.
  ///   - value: Exact provider value.
  public init(description: String, value: String) {
    self.description = description
    self.value = value
  }

  private enum CodingKeys: String, CodingKey {
    case description = "Description"
    case value = "Value"
  }
}
