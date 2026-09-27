#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// The provider's detail list record.
/// Text, HTML, identifiers, order, and missing optional values remain unchanged.
public struct SpeciesDetailItem: Codable, Hashable, Sendable {
  /// The provider's Abundance value.
  public let abundance: String?

  /// The provider's Category value.
  public let category: String

  /// The provider's CommonNames value.
  public let commonNames: String?

  /// The provider's DataStoreReferences value.
  public let dataStoreReferences: Int?

  /// The provider's Family value.
  public let family: String?

  /// The provider's GRank value.
  public let gRank: String?

  /// The provider's Id value.
  public let id: Int

  /// The provider's Nativeness value.
  public let nativeness: String?

  /// The provider's NativenessTags value.
  public let nativenessTags: String?

  /// The provider's NPSTags value.
  public let npsTags: String?

  /// The provider's Observations value.
  public let observations: Int?

  /// The provider's Occurrence value.
  public let occurrence: String?

  /// The provider's OccurrenceTags value.
  public let occurrenceTags: String?

  /// The provider's Order value.
  public let order: String?

  /// The provider's OzoneSensitiveStatus value.
  public let ozoneSensitiveStatus: String?

  /// The provider's RecordStatus value.
  public let recordStatus: String

  /// The provider's SRank value.
  public let sRank: String?

  /// The provider's ScientificName value.
  public let scientificName: String

  /// The provider's ScientificNameFormatted value.
  public let scientificNameFormatted: String

  /// The provider's StateStatus value.
  public let stateStatus: String?

  /// The provider's Synonyms value.
  public let synonyms: [SpeciesSynonym]

  /// The provider's TaxaCode value.
  public let taxaCode: String

  /// The provider's TEStatus value.
  public let teStatus: String?

  /// The provider's UnitCode value.
  public let unitCode: String

  /// The provider's Vouchers value.
  public let vouchers: Int?

  private enum CodingKeys: String, CodingKey {
    case abundance = "Abundance"
    case category = "Category"
    case commonNames = "CommonNames"
    case dataStoreReferences = "DataStoreReferences"
    case family = "Family"
    case gRank = "GRank"
    case id = "Id"
    case nativeness = "Nativeness"
    case nativenessTags = "NativenessTags"
    case npsTags = "NPSTags"
    case observations = "Observations"
    case occurrence = "Occurrence"
    case occurrenceTags = "OccurrenceTags"
    case order = "Order"
    case ozoneSensitiveStatus = "OzoneSensitiveStatus"
    case recordStatus = "RecordStatus"
    case sRank = "SRank"
    case scientificName = "ScientificName"
    case scientificNameFormatted = "ScientificNameFormatted"
    case stateStatus = "StateStatus"
    case synonyms = "Synonyms"
    case taxaCode = "TaxaCode"
    case teStatus = "TEStatus"
    case unitCode = "UnitCode"
    case vouchers = "Vouchers"
  }
}
