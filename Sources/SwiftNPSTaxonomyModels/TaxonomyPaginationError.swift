/// A response cannot safely continue a taxonomy traversal.
public enum TaxonomyPaginationError: Error, Hashable, Sendable {
  /// Lazy traversal needs explicit page parameters; use a response method for all results.
  case allModeUnavailable
  /// Advancing by returned count exceeds the provider's Int32 index range.
  case indexOverflow
  /// The response contains more records than requested.
  case oversizedPage
}
