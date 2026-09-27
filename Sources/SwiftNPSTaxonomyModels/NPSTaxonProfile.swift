/// A detailed taxon with original hierarchy, classifications and optional related arrays.
public struct NPSTaxonProfile: Codable, Hashable, Sendable {
  /// The classification source and optional external record links.
  public struct ClassificationSource: Codable, Hashable, Sendable {
    /// External reference values; the SDK never follows these links automatically.
    public struct Detail: Codable, Hashable, Sendable {
      /// The provider's Code value, preserving original text and optionality.
      public let code: String
      /// The provider's DataLink value, preserving original text and optionality.
      public let dataLink: String?
      /// The provider's WebLink value, preserving original text and optionality.
      public let webLink: String?

      private enum CodingKeys: String, CodingKey {
        case code = "Code"
        case dataLink = "DataLink"
        case webLink = "WebLink"
      }
    }

    /// The provider's Code value, preserving original text and optionality.
    public let code: String
    /// The provider's CodeName value, preserving original text and optionality.
    public let codeName: String?
    /// The provider's Detail value, preserving original text and optionality.
    public let detail: Detail?
    /// The provider's Name value, preserving original text and optionality.
    public let name: String
    /// The provider's ResourceLink value, preserving original text and optionality.
    public let resourceLink: String

    private enum CodingKeys: String, CodingKey {
      case code = "Code"
      case codeName = "CodeName"
      case detail = "Detail"
      case name = "Name"
      case resourceLink = "ResourceLink"
    }
  }

  /// A related taxon using the measured ScientificName key; optional links may be absent.
  public struct RelatedTaxon: Codable, Hashable, Sendable {
    /// The provider's Rank value, preserving original text and optionality.
    public let rank: String
    /// The provider's ResourceLink value, preserving original text and optionality.
    public let resourceLink: String?
    /// The provider's ScientificName value, preserving original text and optionality.
    public let scientificName: String
    /// The provider's TaxonCode value, preserving original text and optionality.
    public let taxonCode: String

    private enum CodingKeys: String, CodingKey {
      case rank = "Rank"
      case resourceLink = "ResourceLink"
      case scientificName = "ScientificName"
      case taxonCode = "TaxonCode"
    }
  }

  /// The provider's AcceptedTaxa value, preserving original text and optionality.
  public let acceptedTaxa: [RelatedTaxon]?
  /// The provider's ClassificationSource value, preserving original text and optionality.
  public let classificationSource: ClassificationSource
  /// The provider's CommonNames value, preserving original text and optionality.
  public let commonNames: [String]?
  /// The provider's Crosswalks value, preserving original text and optionality.
  public let crosswalks: [RelatedTaxon]?
  /// The provider's DisplayCitation value, preserving original text and optionality.
  public let displayCitation: String
  /// The provider's LifecycleState value, preserving original text and optionality.
  public let lifecycleState: String
  /// The provider's NPSpeciesCategory value, preserving original text and optionality.
  public let npSpeciesCategory: String
  /// The provider's OrderedHierarchy value, preserving original text and optionality.
  public let orderedHierarchy: [RelatedTaxon]
  /// The provider's Rank value, preserving original text and optionality.
  public let rank: String
  /// The provider's ResourceLink value, preserving original text and optionality.
  public let resourceLink: String
  /// The provider's ScientificName value, preserving original text and optionality.
  public let scientificName: String
  /// The provider's ScientificNameWithAuthority value, preserving original text and optionality.
  public let scientificNameWithAuthority: String?
  /// The provider's Synonyms value, preserving original text and optionality.
  public let synonyms: [RelatedTaxon]?
  /// The provider's TaxonCode value, preserving original text and optionality.
  public let taxonCode: String
  /// The provider's Usage value, preserving original text and optionality.
  public let usage: String?

  private enum CodingKeys: String, CodingKey {
    case acceptedTaxa = "AcceptedTaxa"
    case classificationSource = "ClassificationSource"
    case commonNames = "CommonNames"
    case crosswalks = "Crosswalks"
    case displayCitation = "DisplayCitation"
    case lifecycleState = "LifecycleState"
    case npSpeciesCategory = "NPSpeciesCategory"
    case orderedHierarchy = "OrderedHierarchy"
    case rank = "Rank"
    case resourceLink = "ResourceLink"
    case scientificName = "ScientificName"
    case scientificNameWithAuthority = "ScientificNameWithAuthority"
    case synonyms = "Synonyms"
    case taxonCode = "TaxonCode"
    case usage = "Usage"
  }
}
