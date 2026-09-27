#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// The provider's synonym shared by the three measured list shapes.
/// Text, HTML, identifiers, order, and missing optional values remain unchanged.
public struct SpeciesSynonym: Codable, Hashable, Sendable {
  /// The provider's ScientificName value.
  public let scientificName: String

  /// The provider's ScientificNameFormatted value.
  public let scientificNameFormatted: String

  /// The provider's TaxaCode value.
  public let taxaCode: String

  private enum CodingKeys: String, CodingKey {
    case scientificName = "ScientificName"
    case scientificNameFormatted = "ScientificNameFormatted"
    case taxaCode = "TaxaCode"
  }
}
