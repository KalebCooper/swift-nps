#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// The provider's checklist list record.
/// Text, HTML, identifiers, order, and missing optional values remain unchanged.
public struct SpeciesChecklistItem: Codable, Hashable, Sendable {
  /// The provider's Category value.
  public let category: String

  /// The provider's CommonNames value.
  public let commonNames: String?

  /// The provider's Family value.
  public let family: String?

  /// The provider's Id value.
  public let id: Int

  /// The provider's Occurrence value.
  public let occurrence: String?

  /// The provider's Order value.
  public let order: String?

  /// The provider's ScientificName value.
  public let scientificName: String

  /// The provider's ScientificNameFormatted value.
  public let scientificNameFormatted: String

  /// The provider's Synonyms value.
  public let synonyms: [SpeciesSynonym]

  /// The provider's TaxaCode value.
  public let taxaCode: String

  /// The provider's UnitCode value.
  public let unitCode: String

  private enum CodingKeys: String, CodingKey {
    case category = "Category"
    case commonNames = "CommonNames"
    case family = "Family"
    case id = "Id"
    case occurrence = "Occurrence"
    case order = "Order"
    case scientificName = "ScientificName"
    case scientificNameFormatted = "ScientificNameFormatted"
    case synonyms = "Synonyms"
    case taxaCode = "TaxaCode"
    case unitCode = "UnitCode"
  }
}
