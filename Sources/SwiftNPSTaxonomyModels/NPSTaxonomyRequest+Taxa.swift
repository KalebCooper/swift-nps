extension NPSTaxonomyRequest where Response == NPSTaxonProfile {
  /// Describes taxonProfile as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input before I/O.
  public static func taxonProfile(code: String, kind: TaxonCodeKind, deriveIfBroken: Bool = false)
    throws(TaxonomyValidationError) -> Self
  {
    Self(endpoint: try .taxonProfile(code: code, kind: kind, deriveIfBroken: deriveIfBroken))
  }
}

extension NPSTaxonomyRequest where Response == [NPSTaxonProfile] {
  /// Describes taxonProfilesResponse as one response, preserving provider order and identifiers.
  public static func taxonProfilesResponse(query: TaxonProfileQuery) -> Self {
    Self(endpoint: .taxonProfilesResponse(query: query), query: .profile(query))
  }
}

extension NPSTaxonomyRequest where Response == [NPSTaxonSummary] {
  /// Describes taxonSummariesResponse as one response, preserving provider order and identifiers.
  public static func taxonSummariesResponse(query: TaxonSummaryQuery) -> Self {
    Self(endpoint: .taxonSummariesResponse(query: query), query: .summary(query))
  }
}

extension NPSTaxonomyRequest where Response == NPSTaxonSummary {
  /// Describes taxonSummary as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input before I/O.
  public static func taxonSummary(code: String, kind: TaxonCodeKind) throws(TaxonomyValidationError)
    -> Self
  {
    Self(endpoint: try .taxonSummary(code: code, kind: kind))
  }
}
