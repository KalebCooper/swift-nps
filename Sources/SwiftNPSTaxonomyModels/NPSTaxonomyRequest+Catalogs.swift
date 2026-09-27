extension NPSTaxonomyRequest where Response == [TaxonomicCategory] {
  /// Describes sourceCategories as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input before I/O.
  public static func sourceCategories(code: String) throws(TaxonomyValidationError) -> Self {
    Self(endpoint: try .sourceCategories(code: code))
  }
}

extension NPSTaxonomyRequest where Response == [TaxonomicRank] {
  /// Describes sourceRanks as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input before I/O.
  public static func sourceRanks(code: String) throws(TaxonomyValidationError) -> Self {
    Self(endpoint: try .sourceRanks(code: code))
  }
}

extension NPSTaxonomyRequest where Response == [TaxonomicCategory] {
  /// Describes taxonomicCategories as one response, preserving provider order and identifiers.
  public static func taxonomicCategories() -> Self {
    Self(endpoint: .taxonomicCategories())
  }
}

extension NPSTaxonomyRequest where Response == TaxonomicCategoryProfile {
  /// Describes taxonomicCategory as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input before I/O.
  public static func taxonomicCategory(code: String) throws(TaxonomyValidationError) -> Self {
    Self(endpoint: try .taxonomicCategory(code: code))
  }
}

extension NPSTaxonomyRequest where Response == TaxonomicRank {
  /// Describes taxonomicRank as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input before I/O.
  public static func taxonomicRank(code: String) throws(TaxonomyValidationError) -> Self {
    Self(endpoint: try .taxonomicRank(code: code))
  }
}

extension NPSTaxonomyRequest where Response == [TaxonomicRank] {
  /// Describes taxonomicRanks as one response, preserving provider order and identifiers.
  public static func taxonomicRanks() -> Self {
    Self(endpoint: .taxonomicRanks())
  }
}

extension NPSTaxonomyRequest where Response == TaxonomicSourceProfile {
  /// Describes taxonomicSource as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input before I/O.
  public static func taxonomicSource(code: String) throws(TaxonomyValidationError) -> Self {
    Self(endpoint: try .taxonomicSource(code: code))
  }
}

extension NPSTaxonomyRequest where Response == [TaxonomicSourceProfile] {
  /// Describes taxonomicSourceProfiles as one response, preserving provider order and identifiers.
  public static func taxonomicSourceProfiles() -> Self {
    Self(endpoint: .taxonomicSourceProfiles())
  }
}

extension NPSTaxonomyRequest where Response == [TaxonomicSource] {
  /// Describes taxonomicSources as one response, preserving provider order and identifiers.
  public static func taxonomicSources() -> Self {
    Self(endpoint: .taxonomicSources())
  }
}

extension NPSTaxonomyRequest where Response == TaxonomicSourceTree {
  /// Describes taxonomicSourceTree as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input before I/O.
  public static func taxonomicSourceTree(code: String) throws(TaxonomyValidationError) -> Self {
    Self(endpoint: try .taxonomicSourceTree(code: code))
  }
}

extension NPSTaxonomyRequest where Response == [TaxonomicSourceTree] {
  /// Describes taxonomicSourceTrees as one response, preserving provider order and identifiers.
  public static func taxonomicSourceTrees() -> Self {
    Self(endpoint: .taxonomicSourceTrees())
  }
}

extension NPSTaxonomyRequest where Response == [TaxonomyOption] {
  /// Describes taxonomyOptions as one response, preserving provider order and identifiers.
  public static func taxonomyOptions(kind: TaxonomyOptionKind) -> Self {
    Self(endpoint: .taxonomyOptions(kind: kind))
  }
}
