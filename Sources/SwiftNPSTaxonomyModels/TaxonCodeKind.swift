/// An explicit identifier namespace; numeric text alone does not identify a taxon.
public enum TaxonCodeKind: String, CaseIterable, Codable, Hashable, Sendable {
  /// The provider's tsn selection.
  case itis = "tsn"
  /// The provider's taxoncode selection.
  case nps = "taxoncode"
}
