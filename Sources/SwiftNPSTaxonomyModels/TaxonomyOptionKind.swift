/// An explicit query option catalog.
public enum TaxonomyOptionKind: String, CaseIterable, Codable, Hashable, Sendable {
  /// The provider's category selection.
  case category = "category"
  /// The provider's codeType selection.
  case codeType = "codeType"
  /// The provider's detail selection.
  case detail = "detail"
  /// The provider's paging selection.
  case paging = "paging"
  /// The provider's source selection.
  case source = "source"
}
