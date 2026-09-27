/// A flat basic taxon record. Common names remain text; links are data, not requests.
public struct NPSTaxonSummary: Codable, Hashable, Sendable {
  /// The provider's CategoryName value, preserving original text and optionality.
  public let categoryName: String
  /// The provider's CommonNames value, preserving original text and optionality.
  public let commonNames: String?
  /// The provider's ExternalCode value, preserving original text and optionality.
  public let externalCode: String?
  /// The provider's ExternalCodeName value, preserving original text and optionality.
  public let externalCodeName: String?
  /// The provider's ExternalLink value, preserving original text and optionality.
  public let externalLink: String?
  /// The provider's Family value, preserving original text and optionality.
  public let family: String
  /// The provider's Kingdom value, preserving original text and optionality.
  public let kingdom: String
  /// The provider's LifecycleState value, preserving original text and optionality.
  public let lifecycleState: String
  /// The provider's Order value, preserving original text and optionality.
  public let order: String
  /// The provider's Rank value, preserving original text and optionality.
  public let rank: String
  /// The provider's ResourceLink value, preserving original text and optionality.
  public let resourceLink: String
  /// The provider's SciName value, preserving original text and optionality.
  public let scientificName: String
  /// The provider's SciNameFormatted value, preserving original text and optionality.
  public let scientificNameFormatted: String
  /// The provider's SciWAuthority value, preserving original text and optionality.
  public let scientificNameWithAuthority: String?
  /// The provider's SciWAuthorityFormatted value, preserving original text and optionality.
  public let scientificNameWithAuthorityFormatted: String?
  /// The provider's SourceName value, preserving original text and optionality.
  public let sourceName: String
  /// The provider's TaxonCode value, preserving original text and optionality.
  public let taxonCode: String

  private enum CodingKeys: String, CodingKey {
    case categoryName = "CategoryName"
    case commonNames = "CommonNames"
    case externalCode = "ExternalCode"
    case externalCodeName = "ExternalCodeName"
    case externalLink = "ExternalLink"
    case family = "Family"
    case kingdom = "Kingdom"
    case lifecycleState = "LifecycleState"
    case order = "Order"
    case rank = "Rank"
    case resourceLink = "ResourceLink"
    case scientificName = "SciName"
    case scientificNameFormatted = "SciNameFormatted"
    case scientificNameWithAuthority = "SciWAuthority"
    case scientificNameWithAuthorityFormatted = "SciWAuthorityFormatted"
    case sourceName = "SourceName"
    case taxonCode = "TaxonCode"
  }
}
