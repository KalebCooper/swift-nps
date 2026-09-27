extension TaxonomyEndpoint where Response == [TaxonomicCategory] {
  /// Describes sourceCategories as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input before I/O.
  public static func sourceCategories(code: String) throws(TaxonomyValidationError) -> Self {
    return route(
      "/sources/" + (try TaxonomyEncoding.component(code)) + "/categories?format=json")
  }
}

extension TaxonomyEndpoint where Response == [TaxonomicRank] {
  /// Describes sourceRanks as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input before I/O.
  public static func sourceRanks(code: String) throws(TaxonomyValidationError) -> Self {
    return route("/sources/" + (try TaxonomyEncoding.component(code)) + "/ranks?format=json")
  }
}

extension TaxonomyEndpoint where Response == [TaxonomicCategory] {
  /// Describes taxonomicCategories as one response, preserving provider order and identifiers.
  public static func taxonomicCategories() -> Self {
    route("/categories?format=json")
  }
}

extension TaxonomyEndpoint where Response == TaxonomicCategoryProfile {
  /// Describes taxonomicCategory as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input before I/O.
  public static func taxonomicCategory(code: String) throws(TaxonomyValidationError) -> Self {
    return route("/categories/" + (try TaxonomyEncoding.component(code)) + "?format=json")
  }
}

extension TaxonomyEndpoint where Response == TaxonomicRank {
  /// Describes taxonomicRank as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input before I/O.
  public static func taxonomicRank(code: String) throws(TaxonomyValidationError) -> Self {
    return route("/ranks/" + (try TaxonomyEncoding.component(code)) + "?format=json")
  }
}

extension TaxonomyEndpoint where Response == [TaxonomicRank] {
  /// Describes taxonomicRanks as one response, preserving provider order and identifiers.
  public static func taxonomicRanks() -> Self {
    route("/ranks?format=json")
  }
}

extension TaxonomyEndpoint where Response == TaxonomicSourceProfile {
  /// Describes taxonomicSource as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input before I/O.
  public static func taxonomicSource(code: String) throws(TaxonomyValidationError) -> Self {
    return route("/sources/" + (try TaxonomyEncoding.component(code)) + "?format=json")
  }
}

extension TaxonomyEndpoint where Response == [TaxonomicSourceProfile] {
  /// Describes taxonomicSourceProfiles as one response, preserving provider order and identifiers.
  public static func taxonomicSourceProfiles() -> Self {
    route("/sources?detail=profile&format=json")
  }
}

extension TaxonomyEndpoint where Response == [TaxonomicSource] {
  /// Describes taxonomicSources as one response, preserving provider order and identifiers.
  public static func taxonomicSources() -> Self {
    route("/sources?detail=basic&format=json")
  }
}

extension TaxonomyEndpoint where Response == TaxonomicSourceTree {
  /// Describes taxonomicSourceTree as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input before I/O.
  public static func taxonomicSourceTree(code: String) throws(TaxonomyValidationError) -> Self {
    return route("/sources/tree/" + (try TaxonomyEncoding.component(code)) + "?format=json")
  }
}

extension TaxonomyEndpoint where Response == [TaxonomicSourceTree] {
  /// Describes taxonomicSourceTrees as one response, preserving provider order and identifiers.
  public static func taxonomicSourceTrees() -> Self {
    route("/sources/tree?format=json")
  }
}

extension TaxonomyEndpoint where Response == [TaxonomyOption] {
  /// Describes taxonomyOptions as one response, preserving provider order and identifiers.
  public static func taxonomyOptions(kind: TaxonomyOptionKind) -> Self {
    route("/urlOptions/" + kind.rawValue + "?format=json")
  }
}
