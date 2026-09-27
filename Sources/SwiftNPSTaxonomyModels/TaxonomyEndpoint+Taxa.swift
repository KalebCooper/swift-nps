extension TaxonomyEndpoint where Response == NPSTaxonProfile {
  /// Describes taxonProfile as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input before I/O.
  public static func taxonProfile(code: String, kind: TaxonCodeKind, deriveIfBroken: Bool = false)
    throws(TaxonomyValidationError) -> Self
  {
    return route(
      "/" + (try TaxonomyEncoding.code(code)) + "?codeType=" + kind.rawValue + "&deriveIfBroken="
        + (deriveIfBroken ? "true" : "false") + "&detail=profile&format=json")
  }
}

extension TaxonomyEndpoint where Response == [NPSTaxonProfile] {
  /// Describes taxonProfilesResponse as one response, preserving provider order and identifiers.
  public static func taxonProfilesResponse(query: TaxonProfileQuery) -> Self {
    route(query.path)
  }
}

extension TaxonomyEndpoint where Response == [NPSTaxonSummary] {
  /// Describes taxonSummariesResponse as one response, preserving provider order and identifiers.
  public static func taxonSummariesResponse(query: TaxonSummaryQuery) -> Self {
    route(query.path)
  }
}

extension TaxonomyEndpoint where Response == NPSTaxonSummary {
  /// Describes taxonSummary as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input before I/O.
  public static func taxonSummary(code: String, kind: TaxonCodeKind) throws(TaxonomyValidationError)
    -> Self
  {
    return route(
      "/" + (try TaxonomyEncoding.code(code)) + "?codeType=" + kind.rawValue
        + "&detail=basic&format=json")
  }
}
