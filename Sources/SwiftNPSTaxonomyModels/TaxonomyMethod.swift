/// The HTTP method of a read-only taxonomy operation.
public enum TaxonomyMethod: String, Hashable, Sendable {
  /// Read through a URL query.
  case get = "GET"
  /// Read a batch using a JSON array body.
  case post = "POST"
}
