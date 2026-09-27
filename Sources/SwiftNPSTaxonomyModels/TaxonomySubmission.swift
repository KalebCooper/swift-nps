/// Explicit code-list submission; the library never switches methods based on length.
public enum TaxonomySubmission: Hashable, Sendable {
  /// Submit comma-separated code text in the URL query.
  case get
  /// Submit an original-order JSON array of strings.
  case post
}
