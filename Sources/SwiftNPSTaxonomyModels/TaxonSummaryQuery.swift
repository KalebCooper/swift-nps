/// A reusable basic search with explicit paging; no I/O occurs during construction.
public struct TaxonSummaryQuery: Hashable, Sendable {
  /// All results or validated page parameters.
  public let paging: TaxonomyPaging
  /// The exact search and optional filters.
  public let search: TaxonSearch

  let path: String

  /// Validates the search and provider Int32 paging bounds without normalization.
  public init(paging: TaxonomyPaging = .all, search: TaxonSearch) throws(TaxonomyValidationError) {
    try paging.validate()
    let components = try search.components()
    let parameters =
      components.parameters + [("detail", "basic"), ("format", "json")] + paging.parameters
    self.paging = paging
    self.search = search
    path = components.path + "?" + TaxonomyEncoding.query(parameters)
  }
}
