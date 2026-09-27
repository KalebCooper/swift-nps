/// A reusable profile search with explicit paging; no I/O occurs during construction.
public struct TaxonProfileQuery: Hashable, Sendable {
  /// Request the provider to derive a broken hierarchy. Defaults explicitly to false.
  public let deriveIfBroken: Bool
  /// All results or validated page parameters.
  public let paging: TaxonomyPaging
  /// The exact search and optional filters.
  public let search: TaxonSearch

  let path: String

  /// Validates the search and provider Int32 paging bounds without normalization.
  public init(deriveIfBroken: Bool = false, paging: TaxonomyPaging = .all, search: TaxonSearch)
    throws(TaxonomyValidationError)
  {
    try paging.validate()
    let components = try search.components()
    let parameters =
      components.parameters + [("detail", "profile"), ("format", "json")] + paging.parameters + [
        ("deriveIfBroken", deriveIfBroken ? "true" : "false")
      ]
    self.deriveIfBroken = deriveIfBroken
    self.paging = paging
    self.search = search
    path = components.path + "?" + TaxonomyEncoding.query(parameters)
  }
}
