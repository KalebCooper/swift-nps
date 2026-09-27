extension NPSSpeciesRequest where Response == [SpeciesItem] {
  /// Creates an inspectable species request.
  /// - Parameter query: Exact unit and optional categories.
  public static func species(query: SpeciesQuery) -> Self { Self(endpoint: .species(query: query)) }
}

extension NPSSpeciesRequest where Response == [SpeciesChecklistItem] {
  /// Creates an inspectable speciesChecklist request.
  /// - Parameter query: Exact unit and optional categories.
  public static func speciesChecklist(query: SpeciesQuery) -> Self {
    Self(endpoint: .speciesChecklist(query: query))
  }
}

extension NPSSpeciesRequest where Response == [SpeciesDetailItem] {
  /// Creates an inspectable speciesDetails request.
  /// - Parameter query: Exact unit and optional categories.
  public static func speciesDetails(query: SpeciesQuery) -> Self {
    Self(endpoint: .speciesDetails(query: query))
  }
}
