import SwiftNPSTaxonomyModels

extension NPSTaxonomyClient {
  /// Fetches sourceCategories as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input or original transport, HTTP, decoding and cancellation errors.
  public func sourceCategories(code: String) async throws(NPSTaxonomyError) -> [TaxonomicCategory] {
    let request: NPSTaxonomyRequest<[TaxonomicCategory]>
    do { request = try .sourceCategories(code: code) } catch { throw .invalidInput }
    return try await value(for: request)
  }
}

extension NPSTaxonomyClient {
  /// Fetches sourceRanks as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input or original transport, HTTP, decoding and cancellation errors.
  public func sourceRanks(code: String) async throws(NPSTaxonomyError) -> [TaxonomicRank] {
    let request: NPSTaxonomyRequest<[TaxonomicRank]>
    do { request = try .sourceRanks(code: code) } catch { throw .invalidInput }
    return try await value(for: request)
  }
}

extension NPSTaxonomyClient {
  /// Fetches taxonomicCategories as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input or original transport, HTTP, decoding and cancellation errors.
  public func taxonomicCategories() async throws(NPSTaxonomyError) -> [TaxonomicCategory] {
    try await value(for: .taxonomicCategories())
  }
}

extension NPSTaxonomyClient {
  /// Fetches taxonomicCategory as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input or original transport, HTTP, decoding and cancellation errors.
  public func taxonomicCategory(code: String) async throws(NPSTaxonomyError)
    -> TaxonomicCategoryProfile
  {
    let request: NPSTaxonomyRequest<TaxonomicCategoryProfile>
    do { request = try .taxonomicCategory(code: code) } catch { throw .invalidInput }
    return try await value(for: request)
  }
}

extension NPSTaxonomyClient {
  /// Fetches taxonomicRank as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input or original transport, HTTP, decoding and cancellation errors.
  public func taxonomicRank(code: String) async throws(NPSTaxonomyError) -> TaxonomicRank {
    let request: NPSTaxonomyRequest<TaxonomicRank>
    do { request = try .taxonomicRank(code: code) } catch { throw .invalidInput }
    return try await value(for: request)
  }
}

extension NPSTaxonomyClient {
  /// Fetches taxonomicRanks as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input or original transport, HTTP, decoding and cancellation errors.
  public func taxonomicRanks() async throws(NPSTaxonomyError) -> [TaxonomicRank] {
    try await value(for: .taxonomicRanks())
  }
}

extension NPSTaxonomyClient {
  /// Fetches taxonomicSource as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input or original transport, HTTP, decoding and cancellation errors.
  public func taxonomicSource(code: String) async throws(NPSTaxonomyError) -> TaxonomicSourceProfile
  {
    let request: NPSTaxonomyRequest<TaxonomicSourceProfile>
    do { request = try .taxonomicSource(code: code) } catch { throw .invalidInput }
    return try await value(for: request)
  }
}

extension NPSTaxonomyClient {
  /// Fetches taxonomicSourceProfiles as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input or original transport, HTTP, decoding and cancellation errors.
  public func taxonomicSourceProfiles() async throws(NPSTaxonomyError) -> [TaxonomicSourceProfile] {
    try await value(for: .taxonomicSourceProfiles())
  }
}

extension NPSTaxonomyClient {
  /// Fetches taxonomicSources as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input or original transport, HTTP, decoding and cancellation errors.
  public func taxonomicSources() async throws(NPSTaxonomyError) -> [TaxonomicSource] {
    try await value(for: .taxonomicSources())
  }
}

extension NPSTaxonomyClient {
  /// Fetches taxonomicSourceTree as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input or original transport, HTTP, decoding and cancellation errors.
  public func taxonomicSourceTree(code: String) async throws(NPSTaxonomyError)
    -> TaxonomicSourceTree
  {
    let request: NPSTaxonomyRequest<TaxonomicSourceTree>
    do { request = try .taxonomicSourceTree(code: code) } catch { throw .invalidInput }
    return try await value(for: request)
  }
}

extension NPSTaxonomyClient {
  /// Fetches taxonomicSourceTrees as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input or original transport, HTTP, decoding and cancellation errors.
  public func taxonomicSourceTrees() async throws(NPSTaxonomyError) -> [TaxonomicSourceTree] {
    try await value(for: .taxonomicSourceTrees())
  }
}

extension NPSTaxonomyClient {
  /// Fetches taxonomyOptions as one response, preserving provider order and identifiers.
  /// - Throws: Invalid input or original transport, HTTP, decoding and cancellation errors.
  public func taxonomyOptions(kind: TaxonomyOptionKind) async throws(NPSTaxonomyError)
    -> [TaxonomyOption]
  {
    try await value(for: .taxonomyOptions(kind: kind))
  }
}
