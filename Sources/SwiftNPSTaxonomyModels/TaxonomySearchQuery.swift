/// Inspectable search continuation retained by a request, without execution or erased closures.
public enum TaxonomySearchQuery: Hashable, Sendable {
  /// A profile search; its representation cannot change during continuation.
  case profile(TaxonProfileQuery)
  /// A basic search; its representation cannot change during continuation.
  case summary(TaxonSummaryQuery)
}
