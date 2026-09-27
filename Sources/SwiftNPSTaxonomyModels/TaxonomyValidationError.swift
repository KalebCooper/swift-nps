/// Invalid inputs rejected before a taxonomy request is sent.
public enum TaxonomyValidationError: Error, Hashable, Sendable {
  /// A code is not positive ASCII decimal text within the provider's Int32 range.
  case invalidCode
  /// Page size must be positive and fit Int32.
  case invalidPageSize
  /// Text is empty, contains controls, or cannot safely form a path component.
  case invalidSearchText
  /// The starting index must be nonnegative and fit Int32.
  case invalidStartIndex
}
